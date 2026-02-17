// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v0.18.4"
let frameworks = ["DeviceKit": "96656cee6881de4af0fb2f16d4f1866c79ba373a3eaa3aa4ecc09fa733e1df52", "KeymanEngine": "e4b427d2beb5140b618af1795663f94cb4dcdd75e3254afca3a66fdba5c9153b", "ReachabilitySIL": "bd23c393118725a1ea1d0dd66a08086b0b6c4cd387395ecf68619bac465e517e", "Sentry": "1697e1ac1079f693d991124f79d5177122b95c4a209574decf6d49c3b6058760", "SentrySwiftUI": "f053e4d1f2cb629feaba6abbf260e525f69bd687b39ba6f368c97ea6aee5321c", "ZIPFoundation": "38e55a049a8fa90e9ea75268f8fdf9b28bd02cb233667b045797f1542c6ef5b0"]

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
