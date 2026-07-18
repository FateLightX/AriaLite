# AriaLite Agent Context

## Start Here

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build --disable-sandbox
swift test
```

Read `docs/AriaLite-Design.md` for scope vs AriaFlow.

## Facts

- SwiftPM macOS app, SwiftUI, macOS 14+, Simplified Chinese UI.
- No third-party Swift dependencies.
- Bundled aria2-next 2.5.1 engines under `Sources/AriaLite/Resources/`.
- `AppSettings.rpcHost` allows remote RPC; local hosts still launch the bundled engine.
- No torrent import UI, history library, peer blocklist, or Dock progress.

## Ownership

- `AriaLiteApp.swift`, `AppDelegate.swift`, `AppPresentation.swift`: scenes / lifecycle.
- `Views.swift`, `MenuBarViews.swift`: UI only.
- `Models.swift`: `AppStore`, persistence, orchestration.
- `Aria2Client.swift`: JSON-RPC.
- `EngineManager.swift`: process discovery / launch / stop.
- `scripts/package_app.sh`: `.app` packaging.

## Verification

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/package_app.sh
scripts/smoke_sidecar_download.sh
scripts/smoke_app_engine.sh
# or the full gate:
scripts/verify_release.sh
```

Do not commit `dist/`, `.build/`, local app data, or RPC secrets.
