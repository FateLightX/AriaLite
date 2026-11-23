# Third-Party Notices

## aria2-next 3.1.2

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v3.1.2><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v3.1.2.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-3.1.2-macos-arm64` | `d85ce293bdfeb85b070aed88bd8fb391fd0fc11cd3d574af2788d4b52b2ca38c` |
| Intel | `aria2-next-3.1.2-macos-x86_64` | `c7303ab80b286819f335cac09fa961eabc0bd47c8d8a0e6d9cbebe84510b4585` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
