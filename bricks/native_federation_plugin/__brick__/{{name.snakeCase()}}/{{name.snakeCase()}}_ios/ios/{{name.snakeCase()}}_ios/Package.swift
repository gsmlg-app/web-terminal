// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "{{name.snakeCase()}}_ios",
    platforms: [.iOS("12.0")],
    products: [
        .library(name: "{{name.paramCase()}}-ios", targets: ["{{name.snakeCase()}}_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "{{name.snakeCase()}}_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
