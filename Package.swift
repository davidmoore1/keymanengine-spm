// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.1.8"
let frameworks = ["DeviceKit": "3563c60149fc228436cc903f5e5dabbe83f05fd563e8e383a2150ef1fcb669e3", "KeymanEngine": "d1740bb54d2c57e3943e99165e98802098721f2fb35f84676d70dd0711887277", "ReachabilitySIL": "54f86e89f43f73afb40304dbc282ae3e4bc2bbccfc28b9b1b9a8509cd4efcd5a", "Sentry": "fc55d94c85dd0e81fb9216b4aced72396f046750790163c7c72eadb837126e09", "SentrySwiftUI": "6d73dd5d84bbf2a38a9dbd1c2519ab1a8bf1b8c62640373bc3a7df8ba95bad9f", "ZIPFoundation": "ab0d2527cc35a96a337851e82769537f8cb6546cccdf0489b6ebfeef87b564e9"]

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
