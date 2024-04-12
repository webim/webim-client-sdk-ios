// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    products: [
        .library(name: "WebimMobileSDK", targets: ["WebimMobileSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0")
    ],
    targets: [
        .target(
            name: "WebimMobileSDK",
            dependencies: ["SQLite"],
            path: "WebimMobileSDK",
            resources: [.copy("WebimMobileSDK/PrivacyInfo.xcprivacy")]
        )
    ]
)
