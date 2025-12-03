// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ClipboardApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClipboardApp", targets: ["ClipboardApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClipboardApp",
            dependencies: [],
            path: "ClipboardApp"
        ),
        .testTarget(
            name: "ClipboardAppTests",
            dependencies: ["ClipboardApp"],
            path: "ClipboardAppTests"
        )
    ]
)
