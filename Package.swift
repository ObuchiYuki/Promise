// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Promise",
    products: [
        .library(name: "Promise", targets: ["Promise"]),
    ],
    targets: [
        .target(name: "Promise", dependencies: []),
        .testTarget(name: "PromiseTests", dependencies: ["Promise"]),
    ]
)
