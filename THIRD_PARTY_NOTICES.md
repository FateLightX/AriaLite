# Third-Party Notices

## aria2-next 2.6.7

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.6.7><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.6.7.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.6.7-macos-arm64` | `1f5ef0f8067f166f2c4dd2711b95f833f3244f5b7fc8998c7b011c23ddfef20c` |
| Intel | `aria2-next-2.6.7-macos-x86_64` | `6166d6dfd3b5609e6f390043d7a203e7048d6bc78c975bb65c69c7c93b0e4868` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
