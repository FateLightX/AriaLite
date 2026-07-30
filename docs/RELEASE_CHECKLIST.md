# Release Checklist

## Automated

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/verify_release.sh
```

Required results:

- Universal `x86_64` + `arm64` app
- Executable arm64 and x86_64 sidecars
- Valid `Info.plist` (`com.arialite.desktop`, min macOS 14) and code signature
- Valid ZIP SHA-256
- Bundled `THIRD_PARTY_NOTICES.md` and GPL `COPYING`
- Unit tests + sidecar smoke + app-managed engine smoke

Artifacts:

```text
dist/AriaLite.app
dist/AriaLite-<version>.zip
dist/AriaLite-<version>.zip.sha256
```

Architecture-specific builds:

```bash
ARCH=arm64 scripts/package_app.sh
ARCH=x86_64 scripts/package_app.sh
```

These produce `AriaLite-<version>-arm64.zip` and
`AriaLite-<version>-x86_64.zip` with only the matching sidecar. Both archives
extract to `AriaLite.app`; the architecture suffix belongs only to the ZIP name.

## Version and Publish

Before tagging, keep the release version aligned in:

- `CHANGELOG.md` and `update.json`
- `APP_VERSION` / `BUILD_NUMBER` in `scripts/package_app.sh`
- `APP_VERSION` in `scripts/verify_release.sh`
- updater and About fallbacks in `SoftwareUpdater.swift` / `SettingsViews.swift`
- the branch-build fallback in `.github/workflows/ci.yml`

Push `main`, then push `v<version>`. The tag workflow validates `update.json`,
runs the release gate, builds Universal / arm64 / x86_64 ZIPs, and creates or
updates the GitHub Release with checksums and notices. Use `gh run watch` and
verify the published asset list before announcing the release.

## Manual

- Launch `dist/AriaLite.app` on macOS 14+
- Confirm fixed 600×400 main window and centered filter tabs
- Add, pause, resume, and delete an HTTP task
- Settings → 引擎: change port, confirm reconnect
- Set a remote RPC host and confirm connect-only (no local engine)
- Magnet open (if scheme is registered)

## Distribution

- Upload ZIP and matching `.sha256` together
- Preserve `THIRD_PARTY_NOTICES.md` and `third_party/aria2-next/COPYING`
- State ad-hoc vs notarized signing
- For notarization: `SIGN_IDENTITY=… NOTARY_PROFILE=… scripts/package_app.sh`
