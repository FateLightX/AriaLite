# Third-Party Notices

## aria2-next 2.6.2

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.6.2><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.6.2.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.6.2-macos-arm64` | `9b4af6486ba4d589b84472e7730960b0fe9a2558f504146a85aee40c11c62d38` |
| Intel | `aria2-next-2.6.2-macos-x86_64` | `ab22f017d744ba2d325996ff5db75077197aeab326bee9bd76fcea97327428b2` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
