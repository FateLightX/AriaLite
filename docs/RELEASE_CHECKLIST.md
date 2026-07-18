# Release Checklist

## Automated

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/verify_release.sh
```

Required results:

- Universal `x86_64 arm64` app
- Executable arm64 and x86_64 sidecars
- Valid `Info.plist` and code signature
- Valid ZIP SHA-256
- Bundled third-party notices and GPL text
- Passing unit tests, sidecar download smoke, and app-managed engine smoke

Artifacts:

```text
dist/AriaLite.app
dist/AriaLite-<version>.zip
dist/AriaLite-<version>.zip.sha256
```

## Manual

- Launch `dist/AriaLite.app` on macOS 14+.
- Confirm menu-bar icon and main window (FilterTabBar layout).
- Add, pause, resume, and delete an HTTP task from the UI.
- Open Settings → 引擎, change RPC 端口, confirm reconnect.
- Set RPC 地址 to a remote host and confirm connect-only (no local engine start).
- Confirm magnet URL handling from the system (if registered).

## Distribution

- Upload the ZIP and matching checksum together.
- Preserve `THIRD_PARTY_NOTICES.md` and `third_party/aria2-next/COPYING`.
- State whether the build is ad-hoc signed or notarized.
- For notarization, set `SIGN_IDENTITY` and `NOTARY_PROFILE` when running `scripts/package_app.sh`.
