// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v0.0.3"
let frameworks = ["KeymanEngine": "df97f9ad47b51602fdc0c3822a6c6423003740c234ca31763c0475ec7b762eac"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/davidmoore1/keyengine-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let package = Package(
    name: "keymanengine-spm",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "keymanengine-spm",
            type: .dynamic,
            targets: ["keymanengine-spm", "KeymanEngine"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "keymanengine-spm"),
        .testTarget(
            name: "keymanengine-spmTests",
            dependencies: ["keymanengine-spm"]
        ),
    ]
)
