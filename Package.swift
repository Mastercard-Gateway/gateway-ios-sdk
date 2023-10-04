// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MPGSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "MPGSDK",
            targets: ["MPGSDK"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MPGSDK",
            dependencies: [],
            path: "MPGSDK"  // Replace with the actual path to your source files
        )
    ],
    swiftLanguageVersions: [.v3, .v4, .v5]
)

