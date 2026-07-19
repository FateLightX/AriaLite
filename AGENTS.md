# AriaLite Agent Context

## Start Here

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
git status -sb
swift build --disable-sandbox
swift test --disable-sandbox
```

Then read:

1. `docs/ARCHITECTURE.md` — modules, data flow, connection model
2. `CHANGELOG.md` — user-visible behavior
3. The source file you are about to change

Code and tests are authoritative.

## Project Facts

- SwiftPM macOS app, SwiftUI + AppKit, macOS 14+, Simplified Chinese UI
- No third-party Swift dependencies
- Bundle ID `com.arialite.desktop`, app version `0.1.2`
- Main window fixed `600×400` (`.windowResizability(.contentSize)`)
- Bundled aria2-next 2.5.1 under `Sources/AriaLite/Resources/`
- `AppSettings.rpcHost` allows remote RPC; only local hosts start the managed engine
- No torrent UI, history, peer blocklist, or Dock progress

## Ownership

| Area | Files |
| --- | --- |
| Scenes / lifecycle | `AriaLiteApp.swift`, `AppDelegate.swift`, `AppPresentation.swift` |
| UI only | `Views.swift`, `MenuBarViews.swift` |
| State / orchestration | `Models.swift` |
| RPC | `Aria2Client.swift` |
| Process | `EngineManager.swift` |
| Packaging | `scripts/` |

## Invariants

- Keep `AppStore` on `@MainActor`; keep JSON-RPC details out of views
- New `AppSettings` fields must use `decodeIfPresent` defaults
- Never force-shutdown a remote RPC host
- Do not commit `dist/`, `.build/`, local app data, or RPC secrets
- Sidecar replacement requires checksums + `THIRD_PARTY_NOTICES.md` update

## Verification

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/verify_release.sh
```

Expected artifacts:

```text
dist/AriaLite.app
dist/AriaLite-0.1.2.zip
dist/AriaLite-0.1.2.zip.sha256
```

## Documentation Map

| Doc | Purpose |
| --- | --- |
| `README.md` | Users: install, build, feature summary |
| `docs/ARCHITECTURE.md` | Modules and runtime design |
| `docs/SIDECAR.md` | Engine binaries and launch contract |
| `docs/RELEASE_CHECKLIST.md` | Release gate |
| `CHANGELOG.md` | Version history |
| `THIRD_PARTY_NOTICES.md` | GPL sidecar provenance |
| `AGENTS.md` | This file |
