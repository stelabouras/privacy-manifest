//
//  main.swift
//
//
//  Created by Stelios Petrakis on 9/4/24.
//

import Foundation

import ArgumentParser
import Spinner
import PathKit

struct PrivacyManifest: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "privacy-manifest",
        abstract: "Privacy Manifest tool",
        discussion: """
An easy and fast way to parse your whole Xcode project or Swift Package in
order to find whether your codebase makes use of Apple's required reason APIs
(https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api) or privacy collected data (https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests).

!!! Disclaimer: This tool must *not* be used as the only way to generate the privacy manifest. Do your own research !!!
""",
        version: "0.0.10",
        subcommands: [Analyze.self])
}

struct Analyze: ParsableCommand {
    enum DetectedProjectType {
        case xcodeProject(Path)
        case swiftPackage(Path)
        case directory(Path)
    }

    public static let configuration = CommandConfiguration(
        commandName: "analyze",
        abstract: "Analyzes the project to detect privacy aware API usage",
        discussion: """
Supports Xcode projects (.xcodeproj) and Swift Packages (Package.swift).

On the Xcode projects, the tool also parses the Framework's Build Phase of each
target to detect the Libraries used.

!!! Disclaimer: This tool must *not* be used as the only way to generate the privacy manifest. Do your own research !!!
"""
    )
    
    @Option(name: .long, help: """
Either the (relative/absolute) path to the project's .xcodeproj (e.g. path/to/MyProject.xcodeproj) or to the Package.swift (e.g. path/to/Package.swift).
""")
    private var project : String

    @Flag(name: .long, help: "Reveals the API occurrences on each file.")
    var revealOccurrences: Bool = false

    func run() throws {
        let projectPath = Path(project).absolute()
        var detectedProjectType: DetectedProjectType?

        if projectPath.lastComponent == PACKAGE_SWIFT_FILENAME {
            detectedProjectType = .swiftPackage(projectPath)
        }
        else if projectPath.extension == XCODE_PROJECT_PATH_EXTENSION {
            detectedProjectType = .xcodeProject(projectPath)
        }
        else if projectPath.isDirectory {
            let children = try projectPath.children()
            guard children.count > 0 else {
                print("\(CliSyntaxColor.RED)Empty directory: \(projectPath)\(CliSyntaxColor.END)")
                return
            }
            children.forEach { childPath in
                if detectedProjectType != nil {
                    return
                }
                if childPath.extension == XCODE_PROJECT_PATH_EXTENSION {
                    detectedProjectType = .xcodeProject(childPath)
                }
                else if childPath.lastComponent == PACKAGE_SWIFT_FILENAME {
                    detectedProjectType = .swiftPackage(childPath)
                }
            }
            if detectedProjectType == nil {
                detectedProjectType = .directory(projectPath)
            }
        }

        guard let detectedProjectType = detectedProjectType else {
            print("\(CliSyntaxColor.RED)File type not supported: \(projectPath)\(CliSyntaxColor.END)")
            return
        }

        switch detectedProjectType {
            case .swiftPackage(let path):
                print("Swift Package detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
                try measure {
                    let swiftPackage = SwiftPackageProjectParser(with: path)
                    try swiftPackage.parse()
                    swiftPackage.process(revealOccurrences: revealOccurrences)
                }
                break
            case .xcodeProject(let path):
                print("Xcode project detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
                try measure {
                    let xcodeProject = XcodeProjectParser(with: path)
                    try xcodeProject.parse()
                    xcodeProject.process(revealOccurrences: revealOccurrences)
                }
                break
            case .directory(let path):
                print("Directory detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
                try measure {
                    let xcodeProject = DirectoryProjectParser(with: path)
                    try xcodeProject.parse()
                    xcodeProject.process(revealOccurrences: revealOccurrences)
                }
            break
        }
    }

    func measure(function: () throws -> Void) throws {
        let clock = ContinuousClock()
        let result = try clock.measure(function)
        print("Execution took \(result)")
    }
}

PrivacyManifest.main()
