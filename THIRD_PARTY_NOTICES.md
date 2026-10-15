# Third-Party Notices

## aria2-next 3.0.4

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.0.4><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.0.4.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.0.4-macos-arm64` | `b3421c474bcffd79ce4d6c3c20d0779c74b655e699bcb200663766effa015a46` |
| Intel | `aria2-next-3.0.4-macos-x86_64` | `f1c7b9e4527884c9640f2b8fafe0665fc29aad940a14b8a04fb2ff0174aad897` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
