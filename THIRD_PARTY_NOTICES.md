# Third-Party Notices

## aria2-next 3.0.3

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.3><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.3.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.3-macos-arm64` | `d7d25612bc1d81a2e6222a1aab6940cc40312f6049225edd43b3f9d7a93edec2` |
| Intel | `aria2-next-3.0.3-macos-x86_64` | `3b6e88bf5f802c91e9c02470c695765eea979201cafb35a0e14233de0f8ba981` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
