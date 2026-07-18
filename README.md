# AriaLite

<p align="center">
  <img src="docs/assets/AppIcon.png" alt="AriaLite app icon" width="96">
</p>

<p align="center">
  <img src="docs/assets/AriaLite.png" alt="AriaLite main window" width="720">
</p>

[中文](#中文) | [English](#english)

## 中文

AriaLite 是 [AriaFlow](https://github.com/FateLightX/AriaFlow) 的轻量 macOS 下载客户端：URL / magnet 下载、内嵌 aria2-next、菜单栏速度、可配置远程 RPC。

### 功能

- 下载队列：添加、暂停/继续、删除、在 Finder 中显示、复制链接
- 顶部筛选栏（全部 / 下载中 / 等待中 / 已完成 / 已失败）、搜索、排序
- 菜单栏速度显示
- 内嵌 Aria2 Next 2.5.1（Apple Silicon + Intel）
- 可配置 RPC 地址 / 端口 / Secret（本机自动启动引擎，远程只连接 RPC）
- 无 Torrent 文件选择、无历史库、无 Peer Blocklist、无 Dock 进度

### 系统要求

- macOS 14 或更高版本；macOS 26 会启用 Liquid Glass 效果
- 源码构建需要 Xcode 26 或兼容的 Swift 6.2 工具链

### 下载与安装

从 [Releases](https://github.com/FateLightX/AriaLite/releases) 下载 ZIP 和对应 `.sha256` 校验文件（发布后可用）。当前开发版本使用 ad-hoc 签名，未经过 Apple 公证。首次打开时，Gatekeeper 可能拦截：在 Finder 中按住 Control 点击 `AriaLite.app`，选择“打开”，然后再次确认。

本地构建：

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build --disable-sandbox
scripts/package_app.sh
open dist/AriaLite.app
```

### 构建与验证

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/verify_release.sh
```

产物：

```text
dist/AriaLite.app
dist/AriaLite-0.1.0.zip
dist/AriaLite-0.1.0.zip.sha256
```

### 与 AriaFlow 的区别

| | AriaFlow | AriaLite |
|---|---|---|
| 协议 | HTTP/FTP/Magnet/ED2K/BT | HTTP/FTP/Magnet |
| 布局 | 侧边栏 | 顶部筛选栏 |
| 远程 RPC | 固定本机 | 可配置 `rpcHost` |
| 历史 / Blocklist / Dock | 有 | 无 |

更多设计说明见 [docs/AriaLite-Design.md](docs/AriaLite-Design.md)。

## English

AriaLite is a lightweight macOS download client derived from [AriaFlow](https://github.com/FateLightX/AriaFlow): URL/magnet downloads, bundled aria2-next, menu bar speed, and configurable remote RPC.

### Highlights

- Download queue with add, pause/resume, delete, Reveal in Finder, and copy-link
- Top filter bar, search, sort, menu bar speed
- Bundled Aria2 Next 2.5.1 for Apple Silicon and Intel
- Configurable RPC host/port/secret (local engine auto-start; remote is connect-only)
- No torrent file picker, history library, peer blocklist, or Dock progress

### Requirements

- macOS 14 or later; Liquid Glass styling is enabled on macOS 26
- Xcode 26 or a compatible Swift 6.2 toolchain to build from source

### Build and verify

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift test --disable-sandbox
scripts/verify_release.sh
```

Artifacts are written to `dist/AriaLite.app`, `dist/AriaLite-<version>.zip`, and its checksum.

## Development Docs

- [AI / agent context](AGENTS.md)
- [Design](docs/AriaLite-Design.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)

## Licensing

AriaLite source code is available under the [MIT License](LICENSE). Bundled `aria2-next` engines are separate GPL-2.0 components; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
