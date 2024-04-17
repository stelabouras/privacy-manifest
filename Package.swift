// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrivacyManifest",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "privacy-manifest",
                    targets: ["PrivacyManifest"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser",
                 exact: "1.2.3"),
        .package(url: "https://github.com/apple/swift-package-manager",
                 branch: "release/5.10"),
        .package(url: "https://github.com/tuist/XcodeProj",
                 exact: "8.20.0"),
        .package(url: "https://github.com/dominicegginton/Spinner",
                 exact: "2.1.0")
    ],
    targets: [
        .executableTarget(
            name: "PrivacyManifest",
            dependencies: [
                "XcodeProj",
                "Spinner",
                .product(name: "ArgumentParser",
                         package: "swift-argument-parser"),
                .product(name: "SwiftPM-auto", 
                         package: "swift-package-manager"),
            ]
        )
    ]
)
