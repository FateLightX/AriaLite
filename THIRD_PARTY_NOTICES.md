# Third-Party Notices

## aria2-next 2.5.1

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.5.1><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.5.1.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.5.1-macos-arm64` | `c99cdc4a19655f4b72ed91c2a55a34ee9ca6aab63ef38a468dff4ff6a0590910` |
| Intel | `aria2-next-2.5.1-macos-x86_64` | `c1a45b7e38b91eec7759411ae6b8dd37abd1af24e9ae12cbfd6e26541ba316da` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
