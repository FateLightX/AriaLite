# AriaLite

<p align="center">
  <img src="docs/assets/AppIcon.png" alt="AriaLite app icon" width="96">
</p>

<p align="center">
  <img src="docs/assets/AriaLite.png" alt="AriaLite main window" width="600">
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
- 固定主窗口 600×400
- 无 Torrent 文件选择、无历史库、无 Peer Blocklist、无 Dock 进度

### 系统要求

- macOS 14 或更高版本；macOS 26 会启用 Liquid Glass 效果
- 源码构建需要 Xcode 26 或兼容的 Swift 6.2 工具链

### 下载与安装

从 [Releases](https://github.com/FateLightX/AriaLite/releases) 下载 `AriaLite-*.zip` 和对应 `.sha256`。当前构建为 ad-hoc 签名，未经过 Apple 公证。首次打开若被 Gatekeeper 拦截：在 Finder 中按住 Control 点击 `AriaLite.app` →「打开」。

```bash
shasum -a 256 -c AriaLite-0.1.0.zip.sha256
unzip AriaLite-0.1.0.zip
# 将 AriaLite.app 拖入「应用程序」
```

### 从源码构建

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift build --disable-sandbox
scripts/package_app.sh
open dist/AriaLite.app
```

完整门禁：

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/verify_release.sh
```

产物：`dist/AriaLite.app`、`dist/AriaLite-0.1.0.zip`、`.sha256`。

### 与 AriaFlow

| | AriaFlow | AriaLite |
|---|---|---|
| 协议 | HTTP/FTP/Magnet/ED2K/BT | HTTP/FTP/Magnet |
| 布局 | 侧边栏 | 顶部筛选栏 |
| 远程 RPC | 固定本机 | 可配置 `rpcHost` |
| 历史 / Blocklist / Dock | 有 | 无 |
| 主窗口 | 可缩放 | 固定 600×400 |

## English

AriaLite is a lightweight macOS download client derived from [AriaFlow](https://github.com/FateLightX/AriaFlow).

### Highlights

- Download queue: add, pause/resume, delete, Reveal in Finder, copy link
- Top filter bar, search, sort, menu bar speed
- Bundled Aria2 Next 2.5.1 (Apple Silicon + Intel)
- Configurable RPC host / port / secret (remote is connect-only)
- Fixed main window 600×400
- No torrent picker, history, peer blocklist, or Dock progress

### Requirements

- macOS 14+
- Xcode 26 / Swift 6.2 to build from source

### Install

Download from [Releases](https://github.com/FateLightX/AriaLite/releases). Builds are ad-hoc signed (not notarized); Gatekeeper may require Control-click → Open.

### Build and verify

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/verify_release.sh
```

## Docs

| Document | Contents |
| --- | --- |
| [Architecture](docs/ARCHITECTURE.md) | Modules, data flow, connection model |
| [Sidecar](docs/SIDECAR.md) | Bundled engine contract |
| [Release checklist](docs/RELEASE_CHECKLIST.md) | Ship gate |
| [Changelog](CHANGELOG.md) | Version history |
| [Agent context](AGENTS.md) | Contributor / AI recovery notes |
| [Third-party notices](THIRD_PARTY_NOTICES.md) | aria2-next GPL provenance |

## Licensing

AriaLite source is [MIT](LICENSE). Bundled `aria2-next` is GPL-2.0; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
