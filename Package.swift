// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.4"
let frameworks = ["DeviceKit": "26f3ae3edc573c9c93ef63afb7d7a7888f8e4238f69351839e5b38bdd8ed6391", "KeymanEngine": "b2827d6f691931cbfc80c88f24cbad48d9ebe0d00a5332c46f9bdfb2a4fef396", "Reachability": "bd51dde150ad6ba2862718424a523d97b1de0968e6a81533f9a4d6f117f75326", "Sentry": "5624bfb9bdfe4358984216aeceac7de67d43c6ce04dab3f7399cb9ec30b71e04", "SentrySwiftUI": "cfc036138431fabeec9627afbf218d396cd63e6ef0eb28583019962b740ae6f0", "ZIPFoundation": "fbcceb0fde3e047f642568e262df2b797ba96b83feeb2d7aeade3bb95fe6ba25"]

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
