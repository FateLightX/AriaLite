#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="${APP_VERSION:-0.2.16}"
APP_DIR="$ROOT_DIR/dist/AriaLite.app"
ZIP_PATH="$ROOT_DIR/dist/AriaLite-$APP_VERSION.zip"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

cd "$ROOT_DIR"

scripts/verify_localizations.py

echo "== unit tests =="
swift test --disable-sandbox

echo "== package =="
scripts/package_app.sh

echo "== binary layout =="
lipo -info "$APP_DIR/Contents/MacOS/AriaLite"
file \
    "$APP_DIR/Contents/Resources/motrix-next-engine-aarch64-apple-darwin" \
    "$APP_DIR/Contents/Resources/motrix-next-engine-x86_64-apple-darwin"
printf '21c327c64549dc15ca1ab70165c56b4aaab4b45724de7d45e3c1b7d541328537  %s\n' "$APP_DIR/Contents/Resources/motrix-next-engine-aarch64-apple-darwin" | shasum -a 256 -c -
printf 'b5a185a8f7057d10c868fafa6adfde8e619aeee2d7e82964eadf3fb0b9484a22  %s\n' "$APP_DIR/Contents/Resources/motrix-next-engine-x86_64-apple-darwin" | shasum -a 256 -c -
test -x "$APP_DIR/Contents/Resources/motrix-next-engine-aarch64-apple-darwin"
test -x "$APP_DIR/Contents/Resources/motrix-next-engine-x86_64-apple-darwin"
test -f "$APP_DIR/Contents/Resources/AppIcon.icns"
test -f "$APP_DIR/Contents/Resources/aria2.conf"
test -f "$APP_DIR/Contents/Resources/THIRD_PARTY_NOTICES.md"
test -f "$APP_DIR/Contents/Resources/ThirdParty/aria2-next/COPYING"
test -f "$APP_DIR/Contents/Resources/en.lproj/Localizable.strings"
test -f "$APP_DIR/Contents/Resources/zh-Hans.lproj/Localizable.strings"
test -f "$APP_DIR/Contents/Resources/zh-Hant.lproj/Localizable.strings"

echo "== Info.plist =="
plutil -lint "$APP_DIR/Contents/Info.plist"
[[ "$(plutil -extract CFBundleIdentifier raw "$APP_DIR/Contents/Info.plist")" == "com.arialite.desktop" ]]
[[ "$(plutil -extract CFBundleShortVersionString raw "$APP_DIR/Contents/Info.plist")" == "$APP_VERSION" ]]
[[ "$(plutil -extract LSMinimumSystemVersion raw "$APP_DIR/Contents/Info.plist")" == "14.0" ]]
[[ "$(plutil -extract CFBundleDevelopmentRegion raw "$APP_DIR/Contents/Info.plist")" == "en" ]]

echo "== codesign =="
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

echo "== zip checksum =="
(
    cd "$(dirname "$ZIP_PATH")"
    shasum -a 256 -c "$(basename "$ZIP_PATH").sha256"
)

echo "== smoke: sidecar =="
scripts/smoke_sidecar_download.sh

echo "== smoke: app-managed engine =="
scripts/smoke_app_engine.sh

echo "release verification passed: $APP_DIR"
echo "$ZIP_PATH"
