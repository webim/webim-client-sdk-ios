// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    products: [
        .library(name: "WebimClientLibrary", targets: ["WebimClientLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0")
    ],
    targets: [
        .target(
            name: "WebimClientLibrary",
            dependencies: ["SQLite"],
            path: "WebimClientLibrary",
            resoursec: [.copy("WebimClientLibrary/PrivacyInfo.xcprivacy")]
        )
    ]
)
