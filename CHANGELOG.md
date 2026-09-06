# Changelog

## 0.2.10 - 2026-09-06

- Updated bundled `aria2-next` sidecars to 2.7.0 (arm64 and x86_64).

## 0.2.9 - 2026-08-30

- Updated bundled `aria2-next` sidecars to 2.6.8 (arm64 and x86_64).

## 0.2.8 - 2026-08-28

- Updated bundled `aria2-next` sidecars to 2.6.7 (arm64 and x86_64).

## 0.2.7 - 2026-08-27

- Updated bundled `aria2-next` sidecars to 2.6.5 (arm64 and x86_64).

## 0.2.6 - 2026-08-26

- Updated bundled `aria2-next` sidecars to 2.6.2 (arm64 and x86_64).

## 0.2.5 - 2026-08-25

- Updated bundled `aria2-next` sidecars to 2.6.0 (arm64 and x86_64).

## 0.2.4 - 2026-08-24

- 修复 aria2-next 引擎写入用户主目录 `~/.aria2-next` 的问题，DHT/状态数据迁移到 App Support 下。

## 0.2.3 - 2026-08-24

- Updated bundled `aria2-next` sidecars to 2.5.7 (arm64 and x86_64).

## 0.2.2 - 2026-08-22

- Updated bundled `aria2-next` sidecars to 2.5.6 (arm64 and x86_64).

## 0.2.1 - 2026-08-12

- 修复 RPC 地址构造、连接恢复与设置重置生命周期问题。
- 收紧 RPC Secret 文件权限，并避免无精确文件列表时删除下载目录。
- 修正公证 stapled ticket 流程与发布门禁校验。

All notable changes to AriaLite are documented in this file.

## 0.2.0 - 2026-08-11

### Changed

- Updated bundled `aria2-next` sidecars from 2.5.2 to 2.5.5.
- Automatic engine recovery now restarts the local managed engine when RPC is
  unresponsive, so downloads resume without a manual restart.
- Added AI continuation guidance in `docs/AI_DEVELOPMENT.md`.

### Added

- Added automatic Simplified Chinese and English UI localization. Chinese
  system languages use Chinese; all other languages fall back to English.

## 0.1.7 - 2026-07-30

### Changed

- Replaced manual login-item setup with an in-app toggle backed by the macOS
  Service Management API, with a System Settings link when approval is needed.
- Architecture-specific ZIPs now extract to `AriaLite.app` instead of adding the
  CPU architecture to the app bundle name.

### Fixed

- Fixed a launch crash in packaged builds when the managed local engine tried to
  resolve flattened SwiftPM resources through a missing module bundle.

## 0.1.6 - 2026-07-29

### Added

- Added automatic software updates when network access becomes available, with
  SHA256, code-signature, bundle-ID, version, and CPU-architecture validation.
- Added updater status and a manual check action to the About page.
- Added a fastly.jsdelivr.net update-manifest fallback when the official GitHub
  Releases API cannot be reached.

### Changed

- Updated bundled `aria2-next` sidecars from 2.5.1 to 2.5.2.
- Added separate Apple Silicon and Intel release packages while preserving the
  Universal package for compatibility.

## 0.1.5 - 2026-07-20

### Fixed

- HTTPS downloads failed with “unable to get local issuer certificate” after enabling TLS verification. The managed engine now loads the macOS CA bundle (`/etc/ssl/cert.pem`) via `ca-certificate`.

## 0.1.4 - 2026-07-20

### Changed

- Debounce settings disk writes (400ms) and flush on app termination.
- Compress README assets (`AppIcon.png` 1024→256, screenshot palette/optimized PNG).
- Split oversized `Models.swift` / `Views.swift` into focused source files (persistence, task models, settings, store, window/list/sheets/settings views).
- Poll slower when idle; tolerate brief RPC failures before disconnecting.
- Paginate waiting/stopped task lists (up to 2000) and show a status-bar truncation hint.
- Keep selection stable when a task disappears instead of jumping to the first row.
- Notify only on complete/fail (no “任务开始” spam).
- Default TLS certificate verification on; tighten RPC origin; keep RPC secret in a 0600 runtime conf (not process argv).
- Add GitHub Actions verify/release workflow.

## 0.1.3 - 2026-07-19

### Changed

- When “隐藏 Dock 图标” is on, the Dock stays hidden even while main/settings windows are open.
- Settings toggle label simplified to “隐藏 Dock 图标”.

## 0.1.2 - 2026-07-19

### Changed

- Filter tabs use colorful semantic icons (全部 / 下载中 / 等待中 / 已完成 / 已失败).
- About page GitHub link points to FateLightX/AriaLite.
- Updated main-window README screenshot.

## 0.1.1 - 2026-07-19

### Changed

- Settings window height now fits each tab's content (no scrollbar / fixed 360 height).

## 0.1.0 - 2026-07-19

### Added

- Initial public release of AriaLite, a lightweight AriaFlow-derived macOS download client.
- Top filter bar (全部 / 下载中 / 等待中 / 已完成 / 已失败), task list, add/delete sheets, and settings.
- Bundled aria2-next 2.5.1 for Apple Silicon and Intel.
- Configurable RPC host, port, and secret (remote hosts are connect-only).
- Menu bar speed display and magnet URL handling.
- Packaging scripts, unit tests, sidecar and app-engine smoke tests, and `verify_release.sh`.

### Notes

- Main window is fixed at 600×400 (not resizable).
- No torrent file import, history library, peer blocklist, or Dock progress.
- Archives use ad-hoc signing and are not notarized; Gatekeeper may require explicit confirmation.
