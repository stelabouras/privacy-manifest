//
//  main.swift
//  PrivacyManifest
//
//  Created by Stelios Petrakis on 9/4/24.
//  Copyright © 2024 Stelios Petrakis. All rights reserved.
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
        version: "0.0.6",
        subcommands: [Analyze.self])
}

struct Analyze: ParsableCommand {

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
        if projectPath.url.lastPathComponent == "Package.swift" {
            print("Swift Package detected.")
            try measure {
                let swiftPackage = SwiftPackageProjectParser(with: projectPath)
                try swiftPackage.parse()
                swiftPackage.process(revealOccurrences: revealOccurrences)
            }
        }
        else if projectPath.extension == "xcodeproj" {
            print("Xcode project detected.")
            try measure {
                let xcodeProject = XcodeProjectParser(with: projectPath)
                try xcodeProject.parse()
                xcodeProject.process(revealOccurrences: revealOccurrences)
            }
        }
        else if let ext = projectPath.extension {
            print("Project extension not supported: \(ext)")
        }
        else {
            print("Path is a directory: \(projectPath.lastComponent)")
        }
    }

    func measure(function: () throws -> Void) throws {
        let clock = ContinuousClock()
        let result = try clock.measure(function)
        print("Execution took \(result)")
    }
}

PrivacyManifest.main()
