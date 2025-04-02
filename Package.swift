// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.2"
let frameworks = ["DeviceKit": "e44709c0b521c1aa6922accdb11b004516334467098817082b121ae75b505c97", "KeymanEngine": "575b4ac47d5e0a763f3bebce9454a1a81e08222dae50fc5b6f997277c9ef55c4", "Reachability": "bba06c574e425e9d4030f2b4237b7ec2233602141b8ccf02434c4e95cf6a9a9f", "Sentry": "0c8ff80c86c62284b1f23268d738a422bd6c0471cdd407a452eac5f1e067581a", "SentrySwiftUI": "b1f8e39c64444cecf1f3122a4e7e978dad5b8e8409979bf80a74ff6b6b77aa3c", "ZIPFoundation": "a8369182121a358566e2727151baaef229c814bd5cd3ea0d97a05f08ff34f4ce"]

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
