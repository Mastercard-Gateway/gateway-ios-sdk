// swift-tools-version:5.0
import PackageDescription

import PackageDescription

let pkg = Package(name: "MPGSDK")
pkg.products = [
    .library(name: "MPGSDK", targets: ["MPGSDK"]),
]

let mpg: Target = .target(name: "MPGSDK")
mpg.path = "Sources"
mpg.exclude = [
    // List files or directories you want to exclude from the build process
    // For example: "SomeFile.swift"
]
pkg.swiftLanguageVersions = [3, 4, 5]  // Assuming MPGSDK uses Swift 5
pkg.targets = [
    mpg,
    // Add any test targets or other targets related to MPGSDK
    // For example:
    // .testTarget(name: "MPGSDKTests", dependencies: ["MPGSDK"], path: "Tests/MPGSDKTests"),
]

