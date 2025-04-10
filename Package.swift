// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.5"
let frameworks = ["DeviceKit": "a9d83a429d3b508d03cb066e45b40820b8dee607b87ef2613c66ce90faff4bd0", "KeymanEngine": "d99f0e8b077d6591bcbd5dfd05b510e535ba366d0266e2cb40c34e4137c45de4", "Reachability": "695a9f6e775830ed984487a7f871ea425f063dc2df2a9afce43d27fd548d34bb", "Sentry": "316f0aceee7cc0d7018dd7baa27887714d38480d30290331a1eb8be59d4b1db8", "SentrySwiftUI": "53e2ffbc2d8acad3c93dac392cea664306432f0eac0b30100c6b65d2df42fb83", "ZIPFoundation": "e735439a74abc97427265a2efa37cb85e83479844a899c0b4ddd3e3a72b5db3a"]

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
