// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.1"
let frameworks = ["DeviceKit": "20db57af9549d9878fc2ebc5a608910864f66706377d1898c85d1fe0c0d4fd1b", "KeymanEngine": "b152ae8d20d8d28b8ef95af15828e1e3609583a91856522ad3ec56f17863d976", "ReachabilitySIL": "d4ae14de744f80c47e0bff6a092374a721d4a2e56eb776a1497bba5cd7ee1d1c", "Sentry": "72b735748cde04adebdfb3fc7b12dcfcf7a3f5d1d2c6e3d3750115f837c8b9dc", "SentrySwiftUI": "853a15adf96ca643d26d0b056d326bc65091d3533cf29202aaea859f46cc149e", "ZIPFoundation": "a0c775db5a85f2e052d20133ec948852025ddc61f34586f2c1143ce64d4d38fd"]

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
    ] + frameworks.map { framework in
        .library(name: framework.key, targets: [framework.key])
    },
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
