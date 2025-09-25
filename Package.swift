// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.3"
let frameworks = ["DeviceKit": "46822d4d77c6d7d21c03c4b3f791d1205006fb7b4c77716b596d43b2ebd98946", "KeymanEngine": "09c79cbc959f9893b09856d799cf2306eb29e8a8ec902277ce49db227b4fa053", "ReachabilitySIL": "f68b4c0747b97b8e881a89987779fc8a2989207419b893ca04c3fb2e3bb65445", "Sentry": "3a8da97d2d8433d9a395faf09911d535f8391a3ff4b59d855169af9a511b41ec", "SentrySwiftUI": "819749fa62c0dbd4e0dfaf2e9269a16da32c0734cdb6832d87157a2ca008b14e", "ZIPFoundation": "85bc45172b68187338b6d5549a8ca4b0673381e7ccc0640a5167c20ff888f68a"]

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
