# AriaLite Agent Context

## Start Here

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
git status -sb
git diff --stat
```

Read in order:

1. This file (ownership + invariants)
2. `docs/ARCHITECTURE.md` for modules, connection model, UI
3. `docs/SIDECAR.md` only when changing the engine binary or launch args
4. `CHANGELOG.md` for recent user-visible behavior
5. The source file and every caller of the symbol being changed

Code and tests are authoritative. Do not recreate removed progress or optimization narrative documents.

## Project Facts

- SwiftPM macOS app: SwiftUI + AppKit; no third-party Swift packages
- Deployment: macOS 14+; Liquid Glass on macOS 26
- Toolchain: Xcode 26 / Swift 6.2
- UI language: Simplified Chinese
- Bundle ID `com.arialite.desktop`
- Main window fixed `600×400` (`.windowResizability(.contentSize)`)
- Bundled aria2-next 2.5.1 under `Sources/AriaLite/Resources/`
- `AppSettings.rpcHost` allows remote RPC; only local hosts start the managed engine
- No torrent UI, history library, peer blocklist, or Dock progress

## Ownership

| Area | Files |
| --- | --- |
| Scenes / lifecycle | `AriaLiteApp.swift`, `AppDelegate.swift`, `AppPresentation.swift` |
| UI only | `MainWindowViews.swift`, `TaskListViews.swift`, sheets, `SettingsViews.swift`, `MenuBarViews.swift` |
| Persistence / models | `Persistence.swift`, `TaskModels.swift`, `AppSettings.swift` |
| Orchestration | `AppStore.swift` |
| RPC | `Aria2Client.swift` |
| Engine process | `EngineManager.swift` |
| Packaging / smoke | `scripts/` |
| Tests | `Tests/` |

## Invariants

- `AppStore` is `@MainActor`; keep JSON-RPC details out of views
- New `AppSettings` fields must use `decodeIfPresent` defaults
- Settings disk writes are debounced (400ms) and must flush on app termination
- Never force-shutdown a remote RPC host
- Managed local engine writes `rpc-secret` into `engine-runtime.conf` mode `0600` via `--conf-path`; do not put secrets on process argv
- Default TLS verification on with system CA bundle (`ca-certificate`, usually `/etc/ssl/cert.pem`); `rpc-allow-origin-all=false`
- Window activation and Dock policy live only in `AppPresentation`
- Sidecar replacement needs checksums + `THIRD_PARTY_NOTICES.md` update
- Do not commit `dist/`, `.build/`, local app data, or RPC secrets

## Out of scope (unless explicitly requested)

- Shared Core / monorepo with AriaFlow
- Product expansions (torrent UI, history, blocklist, Dock progress, remote diagnostics)
- Developer ID notarization

## Verification

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/verify_release.sh
```

Expected artifacts:

```text
dist/AriaLite.app
dist/AriaLite-<version>.zip
dist/AriaLite-<version>.zip.sha256
```

## Documentation Map

| Doc | Purpose |
| --- | --- |
| `README.md` | End-user install and feature summary |
| `docs/ARCHITECTURE.md` | Modules, connection model, UI, packaging |
| `docs/SIDECAR.md` | Engine binaries and launch contract |
| `docs/RELEASE_CHECKLIST.md` | Release gate |
| `CHANGELOG.md` | Version history |
| `THIRD_PARTY_NOTICES.md` | GPL sidecar provenance |
| `AGENTS.md` | This file |

Update only the smallest relevant document. Prefer code + tests over long narrative docs.
