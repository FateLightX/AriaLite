# Third-Party Notices

## aria2-next 2.8.0

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.8.0><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.8.0.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.8.0-macos-arm64` | `218902d199159f161ef77e6e912999df15dab6215877bf60f05adc41141aea4c` |
| Intel | `aria2-next-2.8.0-macos-x86_64` | `968b0b3e300f3afcddbd0db57e5c062447aaee2b3ca2b4ab9db2c6c0f2b7ff1f` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
