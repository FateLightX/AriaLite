# Third-Party Notices

## aria2-next 2.7.2

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.7.2><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.7.2.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.7.2-macos-arm64` | `761ae6d8b984af1787999a03fdefe01fa4fcaf023a733ca21ce74387166b4920` |
| Intel | `aria2-next-2.7.2-macos-x86_64` | `4f5141f9adc01b47adae0abbf6f10130367332916e7c478a139240564bca236c` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
