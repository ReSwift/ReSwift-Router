// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ReSwift-Router",
    products: [
      .library(name: "ReSwift-Router", targets: ["ReSwiftRouter"]),
    ],
    dependencies: [
      .package(url: "https://github.com/ReSwift/ReSwift.git", .upToNextMajor(from: "4.1.1"))
    ],
    targets: [
      .target(
        name: "ReSwiftRouter",
        dependencies: [
          "ReSwift"
        ], 
        path: "ReSwiftRouter"
      )
    ]
)