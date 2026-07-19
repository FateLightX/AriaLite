# Sidecar

AriaLite ships `aria2-next 2.5.1` for arm64 and x86_64. Source URLs, licenses, and SHA-256 values are in [`THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md).

## Resource Names

| Architecture | Resource |
| --- | --- |
| arm64 | `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin` |
| x86_64 | `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin` |

`EngineManager` selects the current architecture’s bundled binary, then falls back to system `aria2c` / `aria2-next` paths. For `swift run`, resources also resolve through `Bundle.module`.

## Launch Contract

Runtime arguments are assembled in `EngineManager.startIfNeeded()`:

- RPC listen port (local only: `--rpc-listen-all=false`)
- download directory and concurrency / split / per-server limits
- session input and save paths
- log path at `info` level
- bundled `aria2.conf` when present
- optional overall download / upload limits
- `--conf-path` pointing at Application Support `engine-runtime.conf` (mode `0600`), which holds `rpc-secret` and related overrides

Do not put the RPC secret on process argv. AriaLite does **not** pass `--bt-peer-blocklist` (no peer blocklist feature).

## Replace Binaries

1. Download both macOS assets and the upstream checksum file from the same [aria2-next release](https://github.com/AnInsomniacy/aria2-next/releases).
2. Verify SHA-256 against the published checksums.
3. Replace the two files under `Sources/AriaLite/Resources/`.
4. Update About-window version text if shown, `THIRD_PARTY_NOTICES.md`, and `CHANGELOG.md`.
5. Run `scripts/verify_release.sh`.

Do not replace binaries without the upstream checksum and GPL source record.

## Verification

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/smoke_sidecar_download.sh
scripts/smoke_app_engine.sh
```
