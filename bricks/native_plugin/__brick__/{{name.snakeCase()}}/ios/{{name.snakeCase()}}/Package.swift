// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "{{name.snakeCase()}}",
    platforms: [.iOS("12.0")],
    products: [
        .library(name: "{{name.paramCase()}}", targets: ["{{name.snakeCase()}}"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "{{name.snakeCase()}}",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
