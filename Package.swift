// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.7"
let frameworks = ["DeviceKit": "d0341057f9d270c61740bf7fa355cbf2c5462eeb1be97e5b5a278d660efd5c8a", "KeymanEngine": "ea006301416e14fd6bf802473408442601090727b6b81786d6d2372b9e3cd152", "Reachability": "fea4330003033d3513b11b7bd7fc8f451ca216f293a7e4e1bddfcb441bef8c9c", "Sentry": "58dde1ad2ce6b315c6a0710a5965b8cc713dd1ef17e51a031e35025eec9dd225", "SentrySwiftUI": "f0b6ba693d7ebd63da366be51b7f0c7bf09a96ffc0872f25d57d38ac0740096b", "ZIPFoundation": "01de85a5e3e32a75e76e90a06c7e263d4478ea7890e884a2c5af62a8e9a142cd"]

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
