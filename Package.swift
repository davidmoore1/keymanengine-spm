// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.3"
let frameworks = ["DeviceKit": "70a39d6acb7490109bd46d5dc31281c93ca98c710a42dddeb12df9eabc2d2a4c", "KeymanEngine": "454b90b761e772d743991d52a920fdc38dc9f8743db4cc8e90276a19dcda3dfe", "Reachability": "28d5c194b086b2f88692f005255067d5c50a70148655d8603f2a4af7046486b7", "Sentry": "7e4f1060d29a397271f28f34210705421d9e0e56705e8bd2c314e696fc5f20d6", "SentrySwiftUI": "f23b9bd19cd768312aac37a202b84da7f56349345a1c9aeed1f55aa81d0947e2", "ZIPFoundation": "ca0423a249948b44064ecfeb5d81bf820ce958e5890ce0d291ad236698d390a4"]

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
