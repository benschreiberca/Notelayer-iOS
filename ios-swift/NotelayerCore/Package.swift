// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotelayerCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "NotelayerCore", targets: ["NotelayerCore"])
    ],
    targets: [
        .target(
            name: "NotelayerCore",
            path: "Sources/NotelayerCore"
        )
    ]
)
