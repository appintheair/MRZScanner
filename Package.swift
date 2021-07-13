// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentScanner",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "DocumentScanner",
            targets: ["DocumentScanner"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/appintheair/MRZParser.git", .branch("develop"))
    ],
    targets: [
        .target(
            name: "DocumentScanner",
            dependencies: ["MRZParser"]
        ),
        .testTarget(
            name: "DocumentScannerTests",
            dependencies: ["DocumentScanner"]),
    ]
)
