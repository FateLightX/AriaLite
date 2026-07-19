# Optimization Execution Log

Date: 2026-07-20  
Scope: AriaLite 0.1.3 → **0.1.4**  
Source plan: dual-app review (reliability / security / engineering)

## Goals completed

| Item | Status | Notes |
| --- | --- | --- |
| Task list pagination | Done | Waiting/stopped pages of 100, max 20 (~2000) |
| Truncation UX | Done | Status bar “列表过长已截断” |
| Soft poll failures | Done | 3 consecutive failures before disconnect |
| Adaptive poll interval | Done | 2s active / 5s idle |
| Stable selection | Done | No auto-select first task after refresh |
| Quieter notifications | Done | Complete/fail only |
| Certificate verification default | Done | `check-certificate=true` |
| RPC origin tighten | Done | `rpc-allow-origin-all=false` |
| RPC secret off argv | Done | `engine-runtime.conf` mode `0600` |
| CI | Done | `.github/workflows/ci.yml` verify + tag release |
| Tests | Done | Protocol/status mapping cases |
| Execution document | Done | This file |

## Deferred

- Shared core with AriaFlow
- File-level split of Models/Views
- Notarization
- Remote-RPC health/latency panel (product enhancement)

## Key code touchpoints

- `Sources/AriaLite/Models.swift`
- `Sources/AriaLite/EngineManager.swift`
- `Sources/AriaLite/Resources/aria2.conf`
- `Sources/AriaLite/Views.swift`
- `scripts/package_app.sh`, `scripts/verify_release.sh`
- `.github/workflows/ci.yml`
- `Tests/AriaLiteTests/AriaLiteTests.swift`

## Verification

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/verify_release.sh
```

## Follow-ups

1. Align release notes template with AriaFlow when cutting GitHub releases.
2. Consider remote connection diagnostics UI for non-local `rpcHost`.
