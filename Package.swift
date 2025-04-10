// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.6"
let frameworks = ["DeviceKit": "3b1fdeac155c1b2cd16fb811388c17ae4641629a8b7e92a5a7062467c36a9104", "KeymanEngine": "9637428b5a69b00c65ad865925bd10be5b79ae2d8b787943c81a9bc0f33d56d7", "Reachability": "0dfbd0ece84c8504a07a73449e59ee9ee0dd32a00fea0ccb36e1d330ce45dd7f", "Sentry": "98b0d481cf6dcbd73fcb8bbd5d60e5cb66903382f0d1b65f3a1a18df6a8d5b64", "SentrySwiftUI": "85a0d42855d1d9f96bf4641af49be68df88c86365833541b3ea074b9c5c8604d", "ZIPFoundation": "d2c29c479b79440e55d3cddc3efe9941a71fa7f7784b0f5190a9a4720035382a"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/davidmoore1/keymanengine-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let libOtherFrameworks = frameworks.filter({ $0.key != "KeymanEngine" })

let package = Package(
    name: "keymanengine-spm",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "keymanengine-spm",
            type: .dynamic,
            targets: ["keymanengine-spm", "KeymanEngine"] + libOtherFrameworks.map { $0.key }),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "keymanengine-spm",
            dependencies: frameworks.map { .byName(name: $0.key) }),
        .testTarget(
            name: "keymanengine-spmTests",
            dependencies: ["keymanengine-spm"]
        ),
    ] + frameworks.map { xcframework($0) }
)
