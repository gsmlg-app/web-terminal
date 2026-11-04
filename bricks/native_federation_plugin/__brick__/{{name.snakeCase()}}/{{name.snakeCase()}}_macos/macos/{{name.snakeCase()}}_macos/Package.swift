// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "{{name.snakeCase()}}_macos",
    platforms: [.macOS("10.14")],
    products: [
        .library(name: "{{name.paramCase()}}-macos", targets: ["{{name.snakeCase()}}_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "{{name.snakeCase()}}_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
