// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.2"
let frameworks = ["DeviceKit": "9ab6fefbc8b43757f5498874eec2bb4ea582618750e61d851137c03e619c6b76", "KeymanEngine": "3dce6a7bfb6127c599766c03aa7094e5c939d3a1d80024c52d0b3490a00d5be6", "ReachabilitySIL": "a11904c79014b288e7327214e8e2c73264ef41d2d086e7aca3838c2aa271a27d", "Sentry": "2a02f543b7d45086d610a9dcb40b20534656f3f11b4cb74dbee2ea94ca84dfde", "SentrySwiftUI": "10cd20ef305d1b4251534e4ec45e36906d811130202851dad0bbdaee5e6820c7", "ZIPFoundation": "e124ab217d79a4f334ab9f0265b34c63f5a19e90100729a5edf1bfc23ce0724c"]

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
