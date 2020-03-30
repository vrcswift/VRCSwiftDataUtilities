// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "VRCSwiftDataUtilities",
    products: [
        .library(
            name: "VRCSwiftDataUtilities",
            targets: ["VRCSwiftDataUtilities"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VRCSwiftDataUtilities",
            dependencies: []),
        .testTarget(
            name: "VRCSwiftDataUtilitiesTests",
            dependencies: ["VRCSwiftDataUtilities"]),
    ]
)
