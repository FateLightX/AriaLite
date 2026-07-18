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

Publish:

```bash
gh release create v<version> \
  dist/AriaLite-<version>.zip \
  dist/AriaLite-<version>.zip.sha256 \
  --title "AriaLite <version>" \
  --notes-file -   # or --generate-notes
```

Update `CHANGELOG.md` and bump `APP_VERSION` / `BUILD_NUMBER` in `scripts/package_app.sh` (and Info.plist via the script) before tagging.

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
