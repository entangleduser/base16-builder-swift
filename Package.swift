// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "base16-builder-swift",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/JohnSundell/Files.git", .upToNextMinor(from: "4.1.1")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMinor(from: "4.0.0")),
        .package(url: "https://github.com/groue/GRMustache.swift.git", .upToNextMinor(from: "4.0.0"))
    ],
    targets: [
        .target(name: "builder", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Files",
            "Yams",
            "Mustache"
        ], path: "Sources/base16-builder-swift"),
        .testTarget(
            name: "base16-builder-swiftTests",
            dependencies: ["builder"])
    ]
)
