# Third-Party Notices

## aria2-next 3.1.1

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.1.1><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.1.1.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.1.1-macos-arm64` | `53f2430ae11af60864694c4edb9ec6e8dd1125c54c216671ed395cd28d5464c1` |
| Intel | `aria2-next-3.1.1-macos-x86_64` | `08097252ea5101dd3b8f74e3b50e530f16c8848abd079688945c7907e976a16a` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
