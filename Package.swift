// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Carboclip",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Carboclip",
            targets: ["Carboclip"]
        )
    ],
    dependencies: [
        // Dependencies will be added as needed
        // MASShortcut for global hotkeys (will be added later)
    ],
    targets: [
        // Main application target
        .executableTarget(
            name: "Carboclip",
            dependencies: [
                "ClipboardCore",
                "CarbonSwiftUI"
            ],
            path: "Sources/Carboclip"
        ),

        // Core clipboard functionality
        .target(
            name: "ClipboardCore",
            dependencies: [],
            path: "Sources/ClipboardCore"
        ),

        // Carbon Design System SwiftUI components
        .target(
            name: "CarbonSwiftUI",
            dependencies: [],
            path: "Sources/CarbonSwiftUI",
            resources: [
                .process("Resources")
            ]
        ),

        // Test targets
        .testTarget(
            name: "ClipboardCoreTests",
            dependencies: ["ClipboardCore"],
            path: "Tests/ClipboardCoreTests"
        ),

        .testTarget(
            name: "CarbonSwiftUITests",
            dependencies: ["CarbonSwiftUI"],
            path: "Tests/CarbonSwiftUITests"
        ),

        .testTarget(
            name: "CarboclipTests",
            dependencies: ["Carboclip"],
            path: "Tests/CarboclipTests"
        )
    ]
)
