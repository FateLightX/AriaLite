# Third-Party Notices

## aria2-next 3.0.9

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.9><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.9.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.9-macos-arm64` | `be6e8ee76a8124fca03d20fa2a8446bac35ea0f24df7e159aa9206106bcfe47c` |
| Intel | `aria2-next-3.0.9-macos-x86_64` | `68b4c64c338b27b2bf929b9110393420908f79de4e33e6037973b38577b715a5` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
