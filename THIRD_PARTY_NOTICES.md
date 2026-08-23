# Third-Party Notices

## aria2-next 2.5.7

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.5.7><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.5.7.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.5.7-macos-arm64` | `2d4d314f9affff4725bf15d884038e5628206e3d3d26b8cdc603bb869115e1ac` |
| Intel | `aria2-next-2.5.7-macos-x86_64` | `d828ca4b00e86e27ac058291bde2a75925f33e96d9f1fd9b778cfeba0d86f9e3` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
