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
                 from: "1.2.2"),
        .package(url: "https://github.com/apple/swift-package-manager",
                 branch: "main"),
        .package(url: "https://github.com/tuist/XcodeProj",
                 .upToNextMajor(from: "8.20.0")),
        .package(url: "https://github.com/dominicegginton/Spinner",
                 from: "2.1.0")
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
