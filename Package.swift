// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.5"
let frameworks = ["DeviceKit": "e47df050855829a64a965d1f113f46bfc5876761e862aefa47e42d94d4ddfb0d", "KeymanEngine": "6ad7bad1aadf171a850da5e587b4eaf1ff37eafbba285ad1fbe87e83174771e6", "ReachabilitySIL": "6adefc6c41d362714794fdac8f4fe735a2d0b2e5b7e79e4864208299951e3fdb", "Sentry": "982fa0f30baf58158016cd776cff90b11a2c448a238b3eca32ee1aa716253b9c", "SentrySwiftUI": "d817f5643b39a1e85530e2d0b99e0a4d580316c876ffe80cb46b04dda34528bf", "ZIPFoundation": "ba0b2b1a5b869252c7a5c1a7f1f9ac41d6b87e1d9c9e5862bcf0ae94b5f85fa0"]

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
