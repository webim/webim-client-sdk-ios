// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    products: [
        .library(name: "WebimClientLibrary", targets: ["WebimClientLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.2")
    ],
    targets: [
        .target(
            name: "WebimClientLibrary",
            dependencies: ["SQLite"],
            path: "WebimClientLibrary"
        )
    ]
)
