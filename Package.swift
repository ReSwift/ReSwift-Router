// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ReSwift-Router",
    products: [
      .executable(name: "ReSwift-Router", targets: ["ReSwiftRouter"]),
    ],
    dependencies: [
      .package(url: "https://github.com/ReSwift/ReSwift", .upToNextMajor(from: "4.0.1"))
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