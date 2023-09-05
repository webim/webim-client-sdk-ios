// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    products: [
        .library(name: "WebimMobileSDK", targets: ["WebimMobileSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3")
    ],
    targets: [
        .target(
            name: "WebimMobileSDK",
            dependencies: ["SQLite"],
            path: "WebimMobileSDK"
        )
    ]
)
