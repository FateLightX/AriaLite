# Third-Party Notices

## aria2-next 2.5.6

AriaLite bundles prebuilt `aria2-next` executables as separate local download-engine components:

- `Sources/AriaLite/Resources/motrix-next-engine-aarch64-apple-darwin`
- `Sources/AriaLite/Resources/motrix-next-engine-x86_64-apple-darwin`

Upstream project: <https://github.com/AnInsomniacy/aria2-next><br>
Upstream release: <https://github.com/AnInsomniacy/aria2-next/releases/tag/v2.5.6><br>
Corresponding source: <https://github.com/AnInsomniacy/aria2-next/archive/refs/tags/v2.5.6.tar.gz>

The sidecars are licensed under GNU General Public License version 2. The complete GPL-2.0 text is included at [third_party/aria2-next/COPYING](third_party/aria2-next/COPYING). AriaLite's Swift source is independently licensed under the MIT License; it communicates with the engine over JSON-RPC and does not link against the engine.

### Bundled Asset Record

| Architecture | Upstream release asset | SHA-256 |
| --- | --- | --- |
| Apple Silicon | `aria2-next-2.5.6-macos-arm64` | `f9d13d6847cd58fc06b136294862eeb6d6dd77356b7050549b8b565e524d8437` |
| Intel | `aria2-next-2.5.6-macos-x86_64` | `0945604133b41aeee16bd1ebad3242cad3770a2c6f0201984a4a489b49e3f39d` |

Distributors must preserve the GPL notice and make the corresponding upstream source available with the sidecar distribution.
