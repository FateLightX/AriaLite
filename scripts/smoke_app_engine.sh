#!/usr/bin/env bash
# Launch packaged AriaLite.app with an isolated Application Support dir,
# wait for its managed aria2 RPC, complete one HTTP download, then quit.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${APP_DIR:-$ROOT_DIR/dist/AriaLite.app}"
APP_EXECUTABLE="$APP_DIR/Contents/MacOS/AriaLite"
PYTHON_BIN="${PYTHON_BIN:-python3}"

if [[ ! -x "$APP_EXECUTABLE" ]]; then
    echo "missing executable app: $APP_EXECUTABLE" >&2
    exit 1
fi

command -v "$PYTHON_BIN" >/dev/null 2>&1 || {
    echo "python3 is required for the app engine smoke test" >&2
    exit 1
}

TMP_DIR="$(mktemp -d)"
SERVER_DIR="$TMP_DIR/server"
DOWNLOAD_DIR="$TMP_DIR/downloads"
APP_SUPPORT_DIR="$TMP_DIR/app-support"
BASE_PORT=$(( ( $$ % 1000 ) * 10 + 23000 ))
HTTP_PORT="${HTTP_PORT:-$BASE_PORT}"
RPC_PORT="${RPC_PORT:-$((BASE_PORT + 1))}"
SECRET="arialite-app-smoke"
APP_PID=""

mkdir -p "$SERVER_DIR" "$DOWNLOAD_DIR" "$APP_SUPPORT_DIR"

cleanup() {
    if [[ -n "$APP_PID" ]]; then
        kill "$APP_PID" >/dev/null 2>&1 || true
        wait "$APP_PID" >/dev/null 2>&1 || true
    fi
    # Managed engine may outlive a hard kill of the GUI briefly.
    pkill -f "rpc-listen-port=$RPC_PORT" >/dev/null 2>&1 || true
    [[ -n "${HTTP_PID:-}" ]] && kill "$HTTP_PID" >/dev/null 2>&1 || true
    [[ -n "${HTTP_PID:-}" ]] && wait "$HTTP_PID" >/dev/null 2>&1 || true
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

printf "AriaLite app engine smoke\n" > "$SERVER_DIR/payload.txt"
URL="http://127.0.0.1:$HTTP_PORT/payload.txt"

"$PYTHON_BIN" -m http.server "$HTTP_PORT" --bind 127.0.0.1 --directory "$SERVER_DIR" >/dev/null 2>&1 &
HTTP_PID=$!
for _ in {1..40}; do
    if curl -fsS --max-time 1 "$URL" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done
if ! curl -fsS --max-time 1 "$URL" >/dev/null; then
    echo "failed to start local HTTP server on 127.0.0.1:$HTTP_PORT" >&2
    echo "this environment may block local TCP listeners" >&2
    exit 1
fi

"$PYTHON_BIN" - <<PY
import json
from pathlib import Path

support = Path("$APP_SUPPORT_DIR")
support.mkdir(parents=True, exist_ok=True)
settings = {
    "autoConnectEngine": True,
    "downloadDirectory": "$DOWNLOAD_DIR",
    "maxConcurrentDownloads": 5,
    "splitCount": 16,
    "maxConnectionsPerServer": 16,
    "downloadSpeedLimit": 0,
    "uploadSpeedLimit": 0,
    "showSpeedInMenuBar": True,
    "showMainWindowOnLaunch": False,
    "keepRunningAfterMainWindowClose": True,
    "hideDockIconInMenuBarMode": True,
    "rpcHost": "127.0.0.1",
    "rpcPort": $RPC_PORT,
}
(support / "settings.json").write_text(json.dumps(settings, indent=2), encoding="utf-8")
(support / "rpc-secret.txt").write_text("$SECRET", encoding="utf-8")
PY

ARIALITE_APP_SUPPORT_DIR="$APP_SUPPORT_DIR" \
    "$APP_EXECUTABLE" >/tmp/arialite-app-engine-smoke.log 2>&1 &
APP_PID=$!

rpc() {
    local method="$1"
    local extra_params="${2:-}"
    local params="\"token:$SECRET\""
    if [[ -n "$extra_params" ]]; then
        params="$params,$extra_params"
    fi
    curl -sS \
        -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"id\":\"smoke\",\"method\":\"$method\",\"params\":[$params]}" \
        "http://127.0.0.1:$RPC_PORT/jsonrpc"
}

for _ in {1..60}; do
    if rpc "aria2.getVersion" >/dev/null 2>&1; then
        break
    fi
    sleep 0.25
done

VERSION_RESPONSE="$(rpc "aria2.getVersion" || true)"
if ! printf "%s" "$VERSION_RESPONSE" | "$PYTHON_BIN" -c '
import json, sys
data = json.load(sys.stdin)
assert data["result"]["version"] == "2.5.1", data
' 2>/dev/null; then
    echo "app-managed aria2 RPC did not become ready on 127.0.0.1:$RPC_PORT" >&2
    echo "--- app log ---" >&2
    tail -40 /tmp/arialite-app-engine-smoke.log 2>/dev/null || true
    echo "--- engine log ---" >&2
    tail -40 "$APP_SUPPORT_DIR/aria2-next.log" 2>/dev/null || true
    exit 1
fi

ADD_RESPONSE="$(rpc "aria2.addUri" "[\"$URL\"],{\"dir\":\"$DOWNLOAD_DIR\"}")"
GID="$(printf "%s" "$ADD_RESPONSE" | "$PYTHON_BIN" -c 'import json,sys; print(json.load(sys.stdin)["result"])')"

for _ in {1..80}; do
    STATUS_RESPONSE="$(rpc "aria2.tellStatus" "\"$GID\"")"
    STATUS="$(printf "%s" "$STATUS_RESPONSE" | "$PYTHON_BIN" -c 'import json,sys; print(json.load(sys.stdin)["result"]["status"])')"
    if [[ "$STATUS" == "complete" ]]; then
        cmp "$SERVER_DIR/payload.txt" "$DOWNLOAD_DIR/payload.txt"
        echo "app engine smoke test passed (RPC $RPC_PORT)"
        exit 0
    fi
    if [[ "$STATUS" == "error" || "$STATUS" == "removed" ]]; then
        echo "$STATUS_RESPONSE" >&2
        exit 1
    fi
    sleep 0.25
done

echo "timed out waiting for app-managed download" >&2
exit 1
