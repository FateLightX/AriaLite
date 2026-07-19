# Optimization Notes (0.1.4)

Status: **complete** for the 0.1.3 → 0.1.4 reliability/security track.  
Date: 2026-07-20

## Delivered

### Reliability
- Paginate waiting/stopped task lists (100/page, max 20 pages); status bar truncation hint
- Adaptive polling: 2s while active, 5s when idle
- Soft-fail poll errors (3 consecutive failures before disconnect)
- Stable selection: missing task clears selection instead of jumping to first row

### Product polish
- Notifications only on complete/fail
- Dock hide setting works with open windows; caption in Settings

### Security
- Default `check-certificate=true`
- `rpc-allow-origin-all=false`
- RPC secret written to `engine-runtime.conf` (mode `0600`), not process argv

### Engineering
- Split models: `Persistence`, `TaskModels`, `AppSettings`, `AppStore`
- Split views: `MainWindowViews`, `TaskListViews`, sheets, `SettingsViews`
- Settings JSON saves debounced 400ms; flush on app termination
- GitHub Actions verify/release workflow
- Protocol/status mapping unit tests
- README assets compressed (`AppIcon` 1024→256; screenshot optimized)

## Parked (explicitly out of scope for now)

- Shared Core / monorepo dual-target with AriaFlow
- Product features (remote RPC diagnostics panel, etc.)
- Developer ID notarization

## Layout after split

| Area | Files |
| --- | --- |
| Persistence | `Persistence.swift` |
| Models | `TaskModels.swift`, `AppSettings.swift` |
| Store | `AppStore.swift` |
| UI | `MainWindowViews.swift`, `TaskListViews.swift`, `*Sheet.swift`, `SettingsViews.swift` |
| Engine | `EngineManager.swift`, `Resources/aria2.conf` |

`AppStore` stays one file because Swift `private` is file-scoped.

## Verify

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/package_app.sh
# full gate:
scripts/verify_release.sh
```

Artifacts: `dist/AriaLite.app`, `dist/AriaLite-0.1.4.zip`, checksum.
