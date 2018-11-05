// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "forthmack",
    dependencies: [
      .package(url: "https://github.com/andybest/linenoise-swift", from: "0.0.3")
    ],
    targets: [
        .target(
            name: "forthmack",
            dependencies: ["LineNoise"]),
        .testTarget(
            name: "forthmackTests",
            dependencies: ["forthmack"]),
    ]
)
