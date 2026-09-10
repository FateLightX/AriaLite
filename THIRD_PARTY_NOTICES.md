# Third-Party Notices

## aria2-next 2.7.5

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.7.5><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.7.5.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.7.5-macos-arm64` | `c36268f2ab67614ad8737586adab7fc1e1df85e0aef55421bd45f778f0868343` |
| Intel | `aria2-next-2.7.5-macos-x86_64` | `c94d4bed9f1d8270320e17d3af1fa72d5fd4040efd5ee8a87c6d75d47aa6c5b4` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
