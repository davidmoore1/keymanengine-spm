// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.1"
let frameworks = ["DeviceKit": "9c656fe2257b8dd1be2e857ea698fedc39f283f5662127f76f84c6dc21dcbbe3", "KeymanEngine": "66e707faaaa790e952928ec2daa2cb8a44688f6736b9dbde00544e12ca462f31", "Reachability": "fe4c8521179afc8345bca10ed44072d2d422d137071b7d731664a5682de851b8", "Sentry": "7dcd0b9cbc22402a8b61c5ad6b69a76a2f4193ec4ef41a9433c18ef05a0e0733", "SentrySwiftUI": "14f70a4ed89a0c85a69d90d731aa5db6ddc889c5b6d2d47e5514103965201fa9", "ZIPFoundation": "6c004abf028c07778d56c4a94d7ef2d6c309bd17cb5a5ba5775b84d76fbc8ddf"]

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
