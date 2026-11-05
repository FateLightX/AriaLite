# Third-Party Notices

## aria2-next 3.0.10

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.10><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.10.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.10-macos-arm64` | `ba93b34c2ba831ecf9236684b9627a56d4b02a99377fa49d965548fdca549563` |
| Intel | `aria2-next-3.0.10-macos-x86_64` | `4fe1624cb36c4d985ea17bc5895bfa458b8861ec943fd1bccd511f05bb2b2b7f` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
