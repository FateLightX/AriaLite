# Third-Party Notices

## aria2-next 3.1.0

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.1.0><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.1.0.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.1.0-macos-arm64` | `328964a77fbf6ef958d5f828a9c20eb6c8cab01ae0a1864128c6af42bf144078` |
| Intel | `aria2-next-3.1.0-macos-x86_64` | `d918ae011599cd3ebe967e721961a52c185306c965ea025357f9dca11613b989` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
