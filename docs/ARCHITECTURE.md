# Architecture

## Runtime

AriaLite is a SwiftPM macOS 14+ executable using SwiftUI and AppKit. There are no third-party Swift packages.

```text
SwiftUI views / menu bar
        │
        ▼
     AppStore ──────► notifications / local persistence
        │
        ▼
   Aria2Client ───► JSON-RPC (local or remote)
        │
        ▼
 EngineManager ─► bundled aria2-next (local hosts only)
```

`AppStore` is `@MainActor` and owns application state. Views bind to published properties and start short `Task` blocks for RPC work.

## Source Modules

| Module | Responsibility |
| --- | --- |
| `AriaLiteApp.swift` | Scenes, commands, fixed main-window size `600×400` |
| `AppDelegate.swift` | Lifecycle, magnet URL open, status-item click → main window |
| `AppPresentation.swift` | Activation policy; main / settings window visibility |
| `Views.swift` | Main window, filter tabs, task list, sheets, settings |
| `MenuBarViews.swift` | Menu bar label, menu actions, startup bootstrap |
| `Models.swift` | `AppStore`, `AppSettings`, tasks, orchestration |
| `Aria2Client.swift` | Typed JSON-RPC transport |
| `EngineManager.swift` | Engine discovery, launch, stop, log tail |
| `NotificationService.swift` | Download complete / fail / start notifications |
| `LoginItemService.swift` | System Settings login-item navigation |

Not present (vs AriaFlow): torrent import UI, file selection, history library, peer blocklist, Dock progress, smoke CLI runner.

## Persistence

Data lives under `~/Library/Application Support/AriaLite` unless `ARIALITE_APP_SUPPORT_DIR` overrides it.

| File | Contents |
| --- | --- |
| `settings.json` | `AppSettings` (includes `rpcHost` / `rpcPort`; excludes secret) |
| `rpc-secret.txt` | RPC secret |
| `download.session` | aria2 session |
| `aria2-next.log` | Engine log |

`AppSettings` uses `decodeIfPresent` defaults. New persisted fields must do the same.

## Connection Model

| Host | Behavior |
| --- | --- |
| `127.0.0.1` / `localhost` / `::1` | Start or reuse managed local engine |
| Any other host | Connect-only; never `forceShutdown` remote |

`Aria2Client` endpoint: `http://{rpcHost}:{rpcPort}/jsonrpc`.

## Engine Lifecycle (local)

1. Menu bar label configures `AppDelegate` and calls `startAutomaticConnectionIfNeeded()`.
2. `retryEngineConnection()` builds a client and runs `connectOrStartEngine()`.
3. `EngineManager` prefers bundled sidecars, then system `aria2c` / `aria2-next`.
4. While connected, poll global stats and task lists every 2 seconds.
5. App termination stops the managed process; remote engines are left alone.

Bundled resource names:

- `motrix-next-engine-aarch64-apple-darwin`
- `motrix-next-engine-x86_64-apple-darwin`
- `aria2.conf`

## UI Layout

```text
┌──────────────── AriaLite 600×400 (fixed) ────────────────┐
│  [+] [▶] [⏸] [🗑]                              [⚙]      │
├──────────────────────────────────────────────────────────┤
│     全部  下载中  等待中  已完成  已失败   (centered)   │
├──────────────────────────────────────────────────────────┤
│  empty state  /  connection state  /  task cards         │
├──────────────────────────────────────────────────────────┤
│ ● 已连接 │ ↓ …  ↑ … │ n 下载中 …                         │
└──────────────────────────────────────────────────────────┘
```

Settings: four tabs — 通用 / 下载 / 引擎 / 关于. Engine tab includes RPC host, port, secret.

## Data Flows

**Add URL**  
`AddTaskSheet` → `AppStore.addURLTask()` → `aria2.addUri` → refresh.

**Pause / resume / delete**  
Toolbar or row actions → corresponding `AppStore` methods → RPC → refresh.

**Remote host change**  
Settings draft → `setRPCHost` on commit → reconnect (no local engine for non-local hosts).

## Packaging

| Script | Role |
| --- | --- |
| `scripts/package_app.sh` | Universal (or native) `.app`, zip, sha256 |
| `scripts/smoke_sidecar_download.sh` | Sidecar HTTP download via RPC |
| `scripts/smoke_app_engine.sh` | Packaged app launches managed engine + download |
| `scripts/verify_release.sh` | Tests → package → layout/sign/checksum → smokes |

Bundle ID: `com.arialite.desktop`. Version: `0.1.2`.
