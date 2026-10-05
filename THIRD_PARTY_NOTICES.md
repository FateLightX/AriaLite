# Third-Party Notices

## aria2-next 2.8.6

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.8.6><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.8.6.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.8.6-macos-arm64` | `6767bc6e79e22dbc491fe7bbcd36daca9dc0fb3b28abca7b9a9cfb8e6e67ece5` |
| Intel | `aria2-next-2.8.6-macos-x86_64` | `933fb85f42adb6acd56e0e728b5d561908669dcdcb5e13459ec5c0195a960e95` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
