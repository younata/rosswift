// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonTestDependencies: [Target.Dependency] = ["Quick", "Nimble"]

let package = Package(
    name: "rosswift",
    products: [
        .library(
            name: "Ros",
            targets: ["Ros"]
        ),
        .library(
            name: "MessageGeneratorKit",
            targets: ["MessageGeneratorKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/quick/quick.git", from: "1.3.3"),
        .package(url: "https://github.com/quick/nimble.git", from: "7.3.3"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Ros",
            dependencies: []
        ),
        .testTarget(
            name: "RosTests",
            dependencies: ["Ros"] + commonTestDependencies
        ),
        .target(
            name: "MessageGeneratorKit",
            dependencies: []
        ),
        .target(
            name: "MessageGenerator",
            dependencies: ["MessageGeneratorKit", "Utility"]
        ),
        .testTarget(
            name: "MessageGeneratorKitTests",
            dependencies: ["MessageGeneratorKit"] + commonTestDependencies
        ),
    ]
)
