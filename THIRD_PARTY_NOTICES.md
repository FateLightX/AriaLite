# Third-Party Notices

## aria2-next 3.0.5

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.5><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.5.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.5-macos-arm64` | `076dbf6537d7936479666a3b9fe1ed6a097a21eeb1d952e480e78743b70a45b1` |
| Intel | `aria2-next-3.0.5-macos-x86_64` | `5588fd16337c5837c2b24e9da0978b0d16aa4a441cb61d2598113478d13b557e` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
