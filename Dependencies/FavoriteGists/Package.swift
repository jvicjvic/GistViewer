// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FavoriteGists",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FavoriteGists",
            targets: ["FavoriteGists"]
        )
    ],
    dependencies: [
        .package(path: "../CoreNetwork"),
        .package(path: "../CoreCommons"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FavoriteGists",
            dependencies: ["CoreNetwork", "SnapKit", "CoreCommons"]
        ),
        .testTarget(
            name: "FavoriteGistsTests",
            dependencies: ["CoreNetwork", "SnapKit", "CoreCommons"]
        )
    ]
)
