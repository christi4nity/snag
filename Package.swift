// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Snag",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Snag",
            path: "Sources/Snag",
            exclude: ["Info.plist"]
        )
    ]
)
