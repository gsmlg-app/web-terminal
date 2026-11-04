// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ios_shell",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "ios-shell", targets: ["ios_shell"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ios_shell",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "IosShellNative",
                "ios_system",
                "shell",
                "files",
                "text",
                "tar",
                "awk",
                "openssl",
                "libssh2",
                "curl_ios",
                "network_ios",
                "lua_ios",
                "lg2",
                "Python"
            ],
            path: "Swift"
        ),
        .target(
            name: "IosShellNative",
            dependencies: ["ios_system", "Python"],
            path: "Native",
            publicHeadersPath: "include"
        ),
        .binaryTarget(name: "ios_system", path: "Frameworks/ios_system.xcframework"),
        .binaryTarget(name: "shell", path: "Frameworks/shell.xcframework"),
        .binaryTarget(name: "files", path: "Frameworks/files.xcframework"),
        .binaryTarget(name: "text", path: "Frameworks/text.xcframework"),
        .binaryTarget(name: "tar", path: "Frameworks/tar.xcframework"),
        .binaryTarget(name: "awk", path: "Frameworks/awk.xcframework"),
        .binaryTarget(name: "openssl", path: "Frameworks/openssl.xcframework"),
        .binaryTarget(name: "libssh2", path: "Frameworks/libssh2.xcframework"),
        .binaryTarget(name: "curl_ios", path: "Frameworks/curl_ios.xcframework"),
        .binaryTarget(name: "network_ios", path: "Frameworks/network_ios.xcframework"),
        .binaryTarget(name: "lua_ios", path: "Frameworks/lua_ios.xcframework"),
        .binaryTarget(name: "lg2", path: "Frameworks/lg2.xcframework"),
        .binaryTarget(name: "Python", path: "Frameworks/Python.xcframework")
    ]
)
