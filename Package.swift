// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.7"
let frameworks = ["DeviceKit": "97bae425eb8e3c12afef2ee86e05560eac8c251bd983f28a744f7162e53c7fa8", "KeymanEngine": "baa352c0a612400c800676552b60cd787a5ec25ad8d626bd421741e16150a7d4", "ReachabilitySIL": "02b0b8bfbf0590fb7d0cb920fa20ec25741bea24f37ad58b11a6343c9678472c", "Sentry": "dfaadabc19acf9a2edca4be4008240e0c27e3b99f84024e6ab481a5d4c591e93", "SentrySwiftUI": "69e9259546fa22f12e856bb1652c96dc38f61f70c673e86cf6fad1c6779bccd8", "ZIPFoundation": "a95e09a556b4aad5694c00d3078235a5ed09a1477d692eea013edd4eca6fb261"]

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
