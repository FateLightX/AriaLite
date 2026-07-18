# AriaLite 设计文档

## 1. 项目概述

AriaLite 是 AriaFlow 的轻量版本，保留核心下载管理功能，裁剪掉高级特性（BT 种子管理、文件选择、Dock 进度、Smoke 测试等），专注于 **URL 下载 + aria2 RPC 连接 + 简洁 UI**。

### 1.1 与 AriaFlow 的关系

| 维度 | AriaFlow | AriaLite |
|------|----------|----------|
| 定位 | 全功能 aria2 GUI 客户端 | 精简版，快速上手 |
| 下载协议 | HTTP/HTTPS/FTP/Magnet/ED2K/BT | HTTP/HTTPS/FTP/Magnet |
| 种子文件 | 支持 .torrent 导入 + 文件选择 | 不支持 |
| 引擎管理 | 内嵌 + 外部 aria2 | 内嵌 + 外部 aria2（保留，裁剪 Blocklist） |
| Dock 进度 | 有 | 无 |
| 历史记录 | 有 | 无 |
| Peer Blocklist | 有 | 无 |
| Smoke 测试 | 有 | 无 |
| 菜单栏 | 有 | 有（精简） |
| 设置项 | 4 个 Tab（通用/下载/引擎/关于） | 4 个 Tab（通用/下载/引擎/关于），引擎 Tab 裁剪 Blocklist |

### 1.2 主页面设计参考

参照 `Design/主页面.png`：

```
┌─────────────────────────────────────────────────────────────────┐
│  AriaLite                              [+] [▶] [⏸] [🗑] [⚙]  │  ← 标题栏 + 工具栏
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ [全部 0] [下载中 0] [等待中 0] [已完成 0] [已失败 0]       │ │  ← 筛选栏（Tab 式）
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│                        （任务列表区域）                          │
│                                                                 │
│              无法连接 / 空状态 / 任务卡片列表                   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ ● 连接失败 │ ↓ 0 KB/s  ↑ 0 KB/s │ 0下载 0等待 0完成 0失败     │  ← 状态栏
└─────────────────────────────────────────────────────────────────┘
```

**与 AriaFlow 主页面的区别：**
- 移除侧边栏 `NavigationSplitView`，改为顶部 Tab 筛选栏（更轻量）
- 移除历史记录（Library 区域）
- 工具栏按钮保持一致：添加(+)、恢复(▶)、暂停(⏸)、删除(🗑)、设置(⚙)
- 状态栏保持一致

---

## 2. 技术架构

### 2.1 技术栈

- **语言**: Swift 6.2
- **UI**: SwiftUI（macOS 14+）
- **最低部署**: macOS 14 (Sonoma)
- **依赖**: 无第三方依赖
- **构建**: Swift Package Manager

### 2.2 项目结构

```
AriaLite/
├── Package.swift
├── Sources/
│   └── AriaLite/
│       ├── AriaLiteApp.swift      ← @main 入口，场景定义
│       ├── AppDelegate.swift      ← NSApplicationDelegate 生命周期
│       ├── AppPresentation.swift  ← 窗口/激活策略管理
│       ├── Aria2Client.swift      ← aria2 JSON-RPC 客户端（从 AriaFlow 裁剪）
│       ├── EngineManager.swift    ← aria2 进程发现/启动/停止（裁剪 Blocklist）
│       ├── Models.swift           ← AppStore + 数据模型（核心裁剪）
│       ├── Views.swift            ← 主窗口 UI
│       ├── MenuBarViews.swift     ← 菜单栏视图
│       ├── LoginItemService.swift ← 登录项管理
│       ├── NotificationService.swift ← 通知服务
│       └── Resources/            ← 内嵌 aria2-next 引擎 + 配置
├── Tests/
│   └── AriaLiteTests/
└── docs/
    └── AriaLite-Design.md
```

### 2.3 数据流

```
                            EngineManager (进程管理)
                                    ↕
Aria2Client (JSON-RPC)  ←→  AppStore (状态管理)  →  SwiftUI Views
                                    ↕
                            LocalAppFiles (持久化)
                            ~/Library/Application Support/AriaLite/
                              ├── settings.json
                              ├── rpc-secret.txt
                              ├── download.session
                              └── aria2-next.log
```

---

## 3. 模块设计

### 3.1 AriaLiteApp.swift — 入口与场景

**从 AriaFlow 移植并裁剪：**
- 保留：`Window` 主窗口场景、`MenuBarExtra` 菜单栏场景、`Settings` 设置窗口场景
- 保留：自定义菜单（新建任务、刷新、暂停/恢复等）
- 移除：`chooseTorrentFile()` 和 Open Torrent 菜单项
- 移除：`SmokeDownloadRunner.runIfRequested()`
- 窗口尺寸：最小 640×380（比 AriaFlow 的 720×420 略小）

### 3.2 AppDelegate.swift — 生命周期

**从 AriaFlow 移植并裁剪：**
- 保留：`applicationWillFinishLaunching` → `.accessory` 策略
- 保留：`applicationDidFinishLaunching` → 菜单栏点击监听
- 保留：`applicationShouldTerminate` → 停止引擎进程
- 保留：`applicationShouldHandleReopen` → 重新显示窗口
- 保留：`application(_:open:)` 中的 `magnet:` URL scheme 处理
- 保留：`ensureConnected` 自动连接/启动引擎
- 移除：`application(_:open:)` 中的 `.torrent` 文件处理

### 3.3 AppPresentation.swift — 窗口管理

**从 AriaFlow 完整移植，无裁剪：**
- `showMainWindow(using:)`
- `showSettings(using:)`
- `mainWindowDidAppear/Disappear`
- `updateActivationPolicy(store:)`
- `settingsDidAppear/Disappear`

### 3.4 Aria2Client.swift — RPC 客户端

**从 AriaFlow 移植并裁剪：**

保留的 RPC 方法：
```swift
// 连接检测
func getVersion() async throws -> Aria2Version
func isReachable() async -> Bool

// 全局状态
func getGlobalStat() async throws -> Aria2GlobalStat

// 任务查询
func tellActive() async throws -> [Aria2Task]
func tellWaiting(offset:count:) async throws -> [Aria2Task]
func tellStopped(offset:count:) async throws -> [Aria2Task]
func tellStatus(gid:) async throws -> Aria2Task

// 任务操作
func addUri(_:options:) async throws -> String
func pause(gid:) async throws -> String
func forcePause(gid:) async throws -> String
func pauseAll() async throws
func unpause(gid:) async throws -> String
func unpauseAll() async throws
func remove(gid:) async throws -> String
func forceRemove(gid:) async throws -> String
func removeDownloadResult(gid:) async throws

// 全局操作
func changeGlobalOption(_:) async throws
func saveSession() async throws
func forceShutdown() async throws
```

移除的 RPC 方法：
- `addTorrent(_:options:)` — 不支持种子
- `getFiles(gid:)` — 不需要文件选择
- `changeOption(gid:options:)` — 不需要单任务选项修改
- 所有 `Sync` 变体 — 不需要 Smoke 测试

移除的模型：
- `Aria2File`, `Aria2URI` — 文件选择相关
- `SyncRPCResultBox` — 同步调用相关

### 3.5 EngineManager.swift — 引擎进程管理

**从 AriaFlow 移植，裁剪 Peer Blocklist：**

保留：
- `findExecutable()` — 引擎发现逻辑（Bundle 内嵌 → 系统路径）
- `startIfNeeded(settings:rpcSecret:)` — 启动 aria2 进程，参数包括 RPC 端口/密钥、下载目录、并发数、分片数等
- `stop()` — 停止进程
- Application Support 目录创建、session 文件管理

移除：
- `PeerBlocklistFile` 枚举及验证逻辑
- `PeerBlocklistFileError` 错误类型
- `--bt-peer-blocklist` 启动参数

### 3.6 Models.swift — 核心数据与状态

#### 3.6.1 持久化

```swift
enum LocalAppFiles {
    static let settingsURL: URL    // ~/Library/Application Support/AriaLite/settings.json
    static let rpcSecretURL: URL   // ~/Library/Application Support/AriaLite/rpc-secret.txt
    static let logURL: URL         // ~/Library/Application Support/AriaLite/aria2-next.log
    static let sessionURL: URL    // ~/Library/Application Support/AriaLite/download.session
}
```

移除：`history.json`（不支持历史记录）

#### 3.6.2 枚举

保留并简化：
```swift
enum ConnectionState { case starting, connected, failed, stopped }  // 保留 .starting（引擎启动中）
enum TaskFilter { case all, active, waiting, complete, failed }  // 移除 .history
enum TaskStatus { case active, waiting, paused, complete, failed }
enum TaskSort { case status, name, progress }
```

#### 3.6.3 DownloadTask 模型

```swift
struct DownloadTask: Identifiable {
    let gid: String
    var name: String
    var status: TaskStatus
    var progress: Double          // 0.0 ~ 1.0
    var completedSize: String     // 格式化后的大小
    var totalSize: String
    var downloadSpeed: String
    var uploadSpeed: String
    var remainingTime: String
    var savePath: String
    var errorMessage: String?
    var sourceLink: String?       // 原始 URL 或 magnet 链接
}
```

移除：`protocolLabel`、`fileNames`、`localFilePaths`、`sourceURLs`、`infoHash`、`ed2kHash`

#### 3.6.4 AppSettings

```swift
struct AppSettings: Codable {
    // 通用
    var showSpeedInMenuBar: Bool = true
    var showMainWindowOnLaunch: Bool = true
    var keepRunningAfterMainWindowClose: Bool = true
    var hideDockIconInMenuBarMode: Bool = false

    // 下载
    var downloadDirectory: String = "~/Downloads"
    var maxConcurrentDownloads: Int = 5
    var defaultSplitCount: Int = 16
    var maxConnectionPerServer: Int = 16
    var maxOverallDownloadLimit: Int = 0   // Mb/s, 0 = 无限制
    var maxOverallUploadLimit: Int = 0

    // 连接
    var rpcHost: String = "127.0.0.1"      // AriaFlow 写死为 127.0.0.1，AriaLite 允许配置
    var rpcPort: Int = 6800
    var autoConnectEngine: Bool = true
}
```

**与 AriaFlow 的区别：**
- 新增 `rpcHost`：允许连接远程 aria2（AriaFlow 固定 localhost）
- 移除 `peerBlocklistPath`：不支持 Blocklist

#### 3.6.5 AppStore

```swift
@MainActor final class AppStore: ObservableObject {
    // 连接状态
    @Published var connectionState: ConnectionState = .stopped
    @Published var engineMessage: String = ""

    // 速度显示
    @Published var downloadSpeedText: String = "0 KB/s"
    @Published var uploadSpeedText: String = "0 KB/s"

    // 任务筛选与排序
    @Published var selectedFilter: TaskFilter = .all
    @Published var taskSearchText: String = ""
    @Published var taskSort: TaskSort = .status
    @Published var selectedTaskID: String?

    // UI 状态
    @Published var showAddTask: Bool = false
    @Published var showDeleteConfirmation: Bool = false

    // 设置
    @Published var rpcSecret: String = ""
    @Published var rpcPortNeedsRestart: Bool = false
    @Published var settings: AppSettings

    // 任务列表
    @Published var tasks: [DownloadTask] = []

    // 服务
    private let engineManager = EngineManager()
    private let notificationService = NotificationService()
}
```

**移除的 Published 属性：**
- `showFileSelection`, `pendingFileSelectionGID`, `fileCandidates` — BT 文件选择
- `peerBlocklistMessage` — 不支持 Blocklist
- `history`, `historySearchText` — 不支持历史

**移除的方法：**
- `addTorrentTask()` — 不支持种子
- `prepareFileSelection()`, `startSelectedFilesDownload()`, `cancelFileSelection()` — BT 文件选择
- `setPeerBlocklist()`, `reloadPeerBlocklist()`, `clearPeerBlocklist()` — Blocklist
- 历史记录相关方法

**保留的核心方法：**
```swift
// 引擎 + 连接管理
func startAutomaticConnectionIfNeeded()   // 启动时自动连接
func retryEngineConnection()              // 重试连接（含启动引擎）
func connectOrStartEngine()               // 连接或启动 aria2 进程
func stopEngine()                         // 停止引擎
func stopEngineForAppTermination()        // 退出时停止
func restartEngineSavingSession()         // 保存会话后重启
func setRPCPort(_:)                       // 修改端口（触发重启）
func setRPCSecret(_:)                     // 修改密钥（触发重启）

// 任务管理
func addURLTask(urlText:fileName:splitCount:downloadDirectory:)
func deleteSelected(deleteFiles:)
func pauseSelected()
func resumeSelected()
func pauseAll()
func resumeAll()
func clearStoppedResults()
func saveSession()

// 轮询
func startPolling()               // 每 2 秒刷新
func refreshTasks()               // 查询 aria2 获取最新任务列表

// 设置
func applyRuntimeDownloadSettings()
func resetSettings()
```

### 3.7 Views.swift — 主界面

#### 3.7.1 视图层级

```
MainWindowView
├── Toolbar (+ ▶ ⏸ 🗑 ⚙)
├── VStack
│   ├── FilterTabBar            ← 替代 AriaFlow 的侧边栏
│   │   ├── FilterTab("全部", count, .all)
│   │   ├── FilterTab("下载中", count, .active)
│   │   ├── FilterTab("等待中", count, .waiting)
│   │   ├── FilterTab("已完成", count, .complete)
│   │   └── FilterTab("已失败", count, .failed)
│   ├── ContentArea
│   │   ├── ConnectionStateView   (未连接时)
│   │   ├── EmptyTaskView         (已连接但无任务)
│   │   └── TaskListView          (有任务时)
│   │       └── TaskRowView × N
│   └── StatusBarView
├── .sheet: AddTaskSheet
└── .sheet: DeleteConfirmationSheet
```

#### 3.7.2 FilterTabBar（新设计）

AriaFlow 使用侧边栏 `NavigationSplitView`，AriaLite 改为水平 Tab 栏：

```swift
struct FilterTabBar: View {
    @EnvironmentObject var store: AppStore
    // 水平排列的筛选按钮，选中项高亮
    // 每个按钮显示：图标 + 标签 + 数量 badge
    // 样式参照 Design/主页面.png 中的顶部栏
}
```

设计参照 `主页面.png`：
- 选中的 Tab 为蓝色填充胶囊，白色文字
- 未选中的 Tab 为灰色文字
- 每个 Tab 右侧有灰色数字 badge

#### 3.7.3 TaskRowView

从 AriaFlow 移植，简化：
- 保留：状态点、名称、进度条、速度、剩余时间、大小
- 保留：右键菜单（恢复/暂停/打开文件夹/复制链接/删除）
- 保留：行内操作按钮（暂停/恢复、打开文件夹、复制链接、删除）
- 移除：`protocolLabel` 标签

#### 3.7.4 AddTaskSheet（简化）

- 仅保留 URL 输入（移除 Torrent Tab）
- 多行 URL 编辑器 + 粘贴按钮
- URL 协议验证：http/https/ftp/magnet
- 下载目录选择
- 文件名字段（可选）
- 分片数量
- macOS 26+ Liquid Glass 支持

#### 3.7.5 DeleteConfirmationSheet

从 AriaFlow 完整移植。

#### 3.7.6 StatusBarView

从 AriaFlow 完整移植。

#### 3.7.7 SettingsWindowView

四个 Tab（与 AriaFlow 一致，裁剪部分条目）：

**通用 Tab：**
- 菜单栏显示速度（开关）
- 开机启动（打开系统设置按钮）
- 启动到菜单栏（开关）
- 关闭主窗口后保持运行（开关）
- 菜单栏模式下隐藏 Dock 图标（开关）
- 恢复默认设置（按钮）

**下载 Tab：**
- 默认保存位置（路径 + 选择器）
- 最大并发下载数（1-10）
- 默认分片数（1-64）
- 每服务器最大连接数（1-64）
- 下载速度限制（Mb/s，0 = 无限制）
- 上传速度限制（Mb/s，0 = 无限制）

**引擎 Tab：**
- RPC 地址（文本框，默认 127.0.0.1，AriaLite 新增支持远程）
- RPC 端口（文本框，默认 6800，修改后触发引擎重启）
- RPC 密钥（文本框，修改后触发引擎重启）
- 引擎状态指示 + 重启引擎按钮
- 引擎操作：重试连接、停止引擎、保存会话、打开日志、打开数据目录
- （Blocklist 相关移除）

**关于 Tab：**
- App 版本
- Aria2 Next 版本
- GitHub 链接

**移除（相比 AriaFlow）：**
- BT Peer Blocklist（引擎 Tab 内）

### 3.8 MenuBarViews.swift

**从 AriaFlow 移植并裁剪：**

菜单项：
- 显示 AriaLite
- 新建任务
- 设置
- ---
- 全部恢复 / 全部暂停
- 保存会话
- 清除结果
- ---
- ↓ 速度 / ↑ 速度
- ---
- 退出

保留菜单栏 Label 的速度显示功能。

### 3.9 LoginItemService.swift

**从 AriaFlow 完整移植：**
- `openSystemSettings()` — 打开系统登录项设置
- `removeLegacyLaunchAgent()` — 清理旧版 LaunchAgent

### 3.10 NotificationService.swift

从 AriaFlow 完整移植，无修改。

---

## 4. 移除的模块

| 模块 | 原因 |
|------|------|
| `DockService.swift` | 移除 Dock 进度条 |
| `SmokeDownloadRunner.swift` | 不需要 CLI 测试 |

---

## 5. 裁剪清单

### 5.1 从 Aria2Client.swift 裁剪

```diff
- func addTorrent(_:options:) async throws -> String
- func getFiles(gid:) async throws -> [Aria2File]
- func changeOption(gid:options:) async throws
- func getVersionSync() -> Aria2Version
- func getGlobalOptionSync() -> [String:String]
- func addUriSync(_:options:) -> String
- func tellStatusSync(gid:) -> Aria2Task
- struct Aria2File
- struct Aria2URI
- class SyncRPCResultBox
```

### 5.2 从 EngineManager.swift 裁剪

```diff
- enum PeerBlocklistFile（整个枚举）
- enum PeerBlocklistFileError（整个枚举）
- startIfNeeded() 中的 --bt-peer-blocklist 参数
```

### 5.3 从 Models.swift 裁剪

```diff
- enum TaskFilter.history
- struct HistoryItem
- struct FileCandidate
- LocalAppFiles.historyURL
- AppStore: dockService
- AppStore: showFileSelection, pendingFileSelectionGID, fileCandidates
- AppStore: history, historySearchText, peerBlocklistMessage
- AppStore.addTorrentTask()
- AppStore.prepareFileSelection() / startSelectedFilesDownload() / cancelFileSelection()
- AppStore.setPeerBlocklist() / reloadPeerBlocklist() / clearPeerBlocklist()
- 历史记录相关全部方法
- Dock badge 更新逻辑
```

### 5.4 从 Views.swift 裁剪

```diff
- NavigationSplitView → VStack + FilterTabBar
- SidebarView / SidebarFilterRow → FilterTabBar / FilterTab
- HistoryListView → 移除
- FileSelectionSheet → 移除
- AddTaskSheet 中的 Torrent Tab → 移除
- SettingsWindowView 引擎 Tab 中的 BT Peer Blocklist → 移除
- protocolLabel 相关 UI → 移除
```

---

## 6. 新增功能

### 6.1 远程 RPC 连接

AriaFlow 固定连接 `127.0.0.1`，AriaLite 新增 `rpcHost` 配置项，允许连接远程 aria2 实例。

```swift
// Aria2Client 初始化
Aria2Client(host: settings.rpcHost, port: settings.rpcPort, token: rpcSecret)
```

### 6.2 保留引擎管理

与 AriaFlow 一致，AriaLite 保留完整的引擎发现/启动/停止逻辑，`ConnectionState` 保持 `.starting`（引擎启动中）。仅移除 Peer Blocklist 相关参数。

---

## 7. 文件 LOC 预估

| 文件 | AriaFlow LOC | AriaLite 预估 |
|------|-------------|---------------|
| AriaLiteApp.swift | 147 → | ~100 |
| AppDelegate.swift | 116 → | ~100 |
| AppPresentation.swift | 93 → | ~90 |
| Aria2Client.swift | 317 → | ~220 |
| EngineManager.swift | 237 → | ~180 |
| Models.swift | 1363 → | ~900 |
| Views.swift | 1760 → | ~1200 |
| MenuBarViews.swift | 105 → | ~90 |
| LoginItemService.swift | 32 → | ~32 |
| NotificationService.swift | 57 → | ~57 |
| **总计** | **~4227** | **~2970** |

预计代码量减少约 **30%**。

---

## 8. 实施步骤

1. **创建项目骨架**: Package.swift + 目录结构 + Resources（内嵌 aria2-next）
2. **移植 Aria2Client**: 裁剪种子/文件/同步方法
3. **移植 EngineManager**: 裁剪 Peer Blocklist 验证
4. **移植 Models**: 裁剪 AppStore，移除历史、Dock 服务、BT 文件选择、Blocklist
5. **移植 NotificationService**: 原样复制
6. **移植 LoginItemService**: 原样复制
7. **移植 AppPresentation**: 原样复制
8. **构建 Views**: 重构为 FilterTabBar 布局，移植 TaskRowView/AddTaskSheet/StatusBarView/Settings
9. **移植 MenuBarViews**: 裁剪菜单项
10. **移植 AppDelegate**: 移除 .torrent 处理
11. **构建 AriaLiteApp**: 场景定义 + 菜单
12. **测试与调试**: 启动内嵌引擎 + 连接验证全流程
