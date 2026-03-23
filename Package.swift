// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.6"
let frameworks = ["DeviceKit": "5b8298dd52f7c153879a5cd1cbcf4a8b052bb66b46e54747a3cfc5a51573cd3e", "KeymanEngine": "57038b3422337b0af58861e4b5483f1c25473ce118d8dbbb75ee9aa975333d4a", "ReachabilitySIL": "b72ac2a4027f6f6632c77a9046b5fb4390a6bf48ed57caafdf294ce6555ae53d", "Sentry": "6ea79ff1277e26d05d30b1edddb1fa41e0305c80eb267e84c0f0f2d79b2fe072", "SentrySwiftUI": "3aabf2f5e626b8fe3f0119056317c2c3a09bfbb3540f3f94e67a5b23f97d5921", "ZIPFoundation": "e4c37fbf8e6e23c029c31e8f121500ea8d7d8eee2f035af5755bf1bb8c0a482e"]

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
