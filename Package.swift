// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MPGSDK",
    platforms: [
        .iOS(.v12)  // Minimum iOS version set to 12
    ],
    products: [
        .library(
            name: "MPGSDK",
            targets: ["MPGSDK"]
        ),
    ],
    dependencies: [
        // Add any dependencies if MPGSDK has any
    ],
    targets: [
        .target(
            name: "MPGSDK",
            dependencies: [],
            path: "Sources",
            exclude: [
                // List files or directories you want to exclude from the build process
                // For example: "SomeFile.swift"
            ]
        ),
        // Add any test targets or other targets related to MPGSDK
        // For example:
        // .testTarget(name: "MPGSDKTests", dependencies: ["MPGSDK"], path: "Tests/MPGSDKTests"),
    ],
    swiftLanguageVersions: [.v3, .v4, .v5]
)

