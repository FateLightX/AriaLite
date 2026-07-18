// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AriaLite",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "AriaLite", targets: ["AriaLite"])
    ],
    targets: [
        .executableTarget(
            name: "AriaLite",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "AriaLiteTests",
            dependencies: ["AriaLite"]
        )
    ]
)
