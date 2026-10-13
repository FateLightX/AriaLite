# Third-Party Notices

## aria2-next 3.0.1

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.1><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.1.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.1-macos-arm64` | `eeb8a0513655b8c9b4efdee5a9f3550bd05b5deffb56c623ef2bd9ff3651c678` |
| Intel | `aria2-next-3.0.1-macos-x86_64` | `613d4afda9ad960163617a032c57f197a0e443bfcc614c9e388ebdd42223686d` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
