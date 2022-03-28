// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodableWrapper",
    products: [
        .library(
            name: "CodableWrapper",
            targets: ["CodableWrapper"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CodableWrapper",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CodableWrapperTests",
            dependencies: ["CodableWrapper"],
            path: "Tests/CodableWrapperTests")
    ]
)
