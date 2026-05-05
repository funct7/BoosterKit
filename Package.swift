// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BoosterKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "BoosterKit",
            targets: ["BoosterKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", exact: "10.0.0"),
    ],
    targets: [
        .target(
            name: "BoosterKit",
            path: "BoosterKit",
            exclude: [
                ".DS_Store",
                "BoosterKit.h",
                "Info.plist",
            ]
        ),
        .testTarget(
            name: "BoosterKitTests",
            dependencies: [
                "BoosterKit",
                .product(name: "Nimble", package: "Nimble"),
            ],
            path: "BoosterKitTests",
            exclude: [
                "Info.plist",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
