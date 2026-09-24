# Third-Party Notices

## aria2-next 2.8.2

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.8.2><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.8.2.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.8.2-macos-arm64` | `32abfca1ebeeff020aa47c30e3680c86162ab49703dc4924a0510557b830a69f` |
| Intel | `aria2-next-2.8.2-macos-x86_64` | `4362e5f2b6fd725f21a03c96b7cd0adbec59744c75d9564f386297b99add6435` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
