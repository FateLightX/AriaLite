# Changelog

All notable changes to AriaLite are documented in this file.

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
