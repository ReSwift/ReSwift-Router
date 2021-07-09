// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ReSwiftRouter",
    products: [
        .library(name: "ReSwiftRouter", targets: ["ReSwiftRouter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReSwift/ReSwift.git", .upToNextMajor(from: "6.1.0")),
    ],
    targets: [
        .target(
            name: "ReSwiftRouter",
            dependencies: [
                "ReSwift"
            ],
            path: "ReSwiftRouter"
        ),
    ]
)
