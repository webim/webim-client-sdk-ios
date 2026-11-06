// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "webim-client-sdk-ios",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WebimMobileSDK", targets: ["WebimMobileSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", exact: "0.17.0")
    ],
    targets: [
        .target(
            name: "WebimMobileSDK",
            dependencies:  [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "WebimMobileSDK",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
