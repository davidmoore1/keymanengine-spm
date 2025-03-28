// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "minv0.1.1"
let frameworks = ["DeviceKit": "3ed853d184fa1549e4bea846398ad14f8059ca61cdbbc551383307b4d7880e66", "KeymanEngine": "f977e1730c2ef3f5b07606cd41a6baaad643fa7e8790945ce74969749b4a7244", "Reachability": "ef37d90cc4a45bf046dcf8958abc6efd0eda70864486ae7416f25384364abd4c", "Sentry": "37a86a9f49ccce96d4fb805324fd5acbbe1c299f66cb07cd00940265cd61430f", "SentrySwiftUI": "aeb42b0fff1ec61bdd74bdc9796636c977c0106b984fa1c1ff7fe335f370cbf8", "ZIPFoundation": "2536f35ede6c9d06a72780d3198eb7d33266caaaa2dd0ae6c813029b5e99f2af"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/davidmoore1/keymanengine-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    print("Downloading from URL: \(url)") // Debugging line
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
