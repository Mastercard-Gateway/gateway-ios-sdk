// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MPGSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MPGSDK",
            targets: ["MPGSDK"]
        )
    ],
    targets: [
        .target(
            name: "MPGSDK",
            path: "Sources/MPGSDK"
        ),
        .testTarget(
            name: "MPGSDKTests",
            dependencies: ["MPGSDK"],
            path: "Tests/MGPSDKTests"
        )
    ]
)
