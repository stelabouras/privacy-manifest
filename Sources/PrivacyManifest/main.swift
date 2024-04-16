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
An easy and fast way to parse your whole Xcode project, Xcode workspace or
Swift Package in order to find whether your codebase makes use of Apple's
required reason APIs
(https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api) or privacy collected data (https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests).

!!! Disclaimer: This tool must *not* be used as the only way to generate the privacy manifest. Do your own research !!!
""",
        version: "0.0.12",
        subcommands: [Analyze.self])
}

struct Analyze: ParsableCommand {
    private static let PRIVACYINFO_FILENAME = "PrivacyInfo.xcprivacy"

    // The data structure of the generated PrivacyInfo.xcprivacy file
    struct PrivacyManifestDataStructure: Encodable {
        struct PrivacyAccessedAPIType: Encodable {
            var nsPrivacyAccessedAPIType: String
            var nSPrivacyAccessedAPITypeReasons: [String]
        }
        var nsPrivacyTracking: Bool
        var nsPrivacyTrackingDomains: [String]
        var nsPrivacyCollectedDataTypes: [[String:String]]
        var nsPrivacyAccessedAPITypes: [PrivacyAccessedAPIType]
    }

    enum DetectedProjectType {
        case xcodeProject(Path)
        case xcodeWorkspace(Path)
        case swiftPackage(Path)
        case directory(Path)
    }

    public static let configuration = CommandConfiguration(
        commandName: "analyze",
        abstract: "Analyzes the project to detect privacy aware API usage",
        discussion: """
Supports Xcode projects (.xcodeproj), Xcode workspaces (.xcworkspace) and
Swift Packages (Package.swift).

!!! Disclaimer: This tool must *not* be used as the only way to generate the privacy manifest. Do your own research !!!
"""
    )
    
    @Option(name: .long, help: """
Either the (relative/absolute) path to the project's
.xcodeproj(e.g. path/to/MyProject.xcodeproj),
.xcworkspace (e.g. path/to/MyWorkspace.xcworkspace) or
Package.swift (e.g. path/to/Package.swift).
""")
    private var project : String

    @Flag(name: .long, help: "Reveals the API occurrences on each file.")
    var revealOccurrences: Bool = false

    @Option(name: .long, help: """
The path to the directory where the privacy manifest file will be generated (Optional).
""")
    var output: String?

    func run() throws {
        let projectPath = Path(project).absolute()
        var detectedProjectType: DetectedProjectType?

        if projectPath.lastComponent == PACKAGE_SWIFT_FILENAME {
            detectedProjectType = .swiftPackage(projectPath)
        }
        else if projectPath.extension == XCODE_PROJECT_PATH_EXTENSION {
            detectedProjectType = .xcodeProject(projectPath)
        }
        else if projectPath.extension == XCODE_WORKSPACE_PATH_EXTENSION {
            detectedProjectType = .xcodeWorkspace(projectPath)
        }
        else if projectPath.isDirectory {
            // Reverse sort the children paths so that xcworkspace is parsed
            // first if both .xcodeproj and .xcworkspace are found in the same
            // path.
            let children = try projectPath.children().sorted().reversed()
            guard children.count > 0 else {
                print("\(CliSyntaxColor.RED)Empty directory: \(projectPath)\(CliSyntaxColor.END)")
                return
            }
            children.forEach { childPath in
                if detectedProjectType != nil {
                    return
                }
                else if childPath.extension == XCODE_WORKSPACE_PATH_EXTENSION {
                    detectedProjectType = .xcodeWorkspace(childPath)
                }
                else if childPath.extension == XCODE_PROJECT_PATH_EXTENSION {
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

        var requiredAPIs: [RequiredReasonKey: Set<PresentedResult>]?

        switch detectedProjectType {
        case .swiftPackage(let path):
            print("Swift Package detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
            let swiftPackage = SwiftPackageProjectParser(with: path)
            try measure {
                do {
                    try swiftPackage.parse()
                }
                catch {
                    print("\(CliSyntaxColor.RED)Swift Package Parser Error: \(error)\(CliSyntaxColor.END)")
                }
            }
            requiredAPIs = swiftPackage.process(revealOccurrences: revealOccurrences)
        case .xcodeProject(let path):
            print("Xcode project detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
            let xcodeProject = XcodeProjectParser(with: path)
            try measure {
                do {
                    try xcodeProject.parse()
                }
                catch {
                    print("\(CliSyntaxColor.RED)Xcode Project Parser Error: \(error)\(CliSyntaxColor.END)")
                }
            }
            requiredAPIs = xcodeProject.process(revealOccurrences: revealOccurrences)
        case .xcodeWorkspace(let path):
            print("Xcode workspace detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
            let xcodeWorkspace = XcodeWorkspaceParser(with: path)
            try measure {
                do {
                    try xcodeWorkspace.parse()
                }
                catch {
                    print("\(CliSyntaxColor.RED)Xcode Workspace Parser Error: \(error)\(CliSyntaxColor.END)")
                }
            }
            requiredAPIs = xcodeWorkspace.process(revealOccurrences: revealOccurrences)
        case .directory(let path):
            print("Directory detected: \(CliSyntaxColor.WHITE_BOLD)\(path)\(CliSyntaxColor.END)")
            let xcodeProject = DirectoryProjectParser(with: path)
            try measure {
                do {
                    try xcodeProject.parse()
                }
                catch {
                    print("\(CliSyntaxColor.RED)Directory Parser Error: \(error)\(CliSyntaxColor.END)")
                }
            }
            requiredAPIs = xcodeProject.process(revealOccurrences: revealOccurrences)
        }
        
        if let output = output,
           let requiredAPIs = requiredAPIs {
            print("---")

            let outputPath = Path(output)

            guard outputPath.isDirectory else {
                print("\(CliSyntaxColor.RED)Error: Output path not a directory\(CliSyntaxColor.END)")
                return
            }
            generateManifest(requiredAPIs,
                             outputPath: Path(output) + Self.PRIVACYINFO_FILENAME)
        }
    }

    func measure(function: () throws -> Void) throws {
        let clock = ContinuousClock()
        let result = try clock.measure(function)
        print("Execution took \(result)")
    }

    func generateManifest(_ requiredAPIs: [RequiredReasonKey: Set<PresentedResult>],
                          outputPath: Path) {
        var manifestReasons: [PrivacyManifestDataStructure.PrivacyAccessedAPIType] = []

        requiredAPIs.forEach { (key, value) in
            guard value.count > 0, key.reasons.count > 0 else {
                return
            }

            if key == .THIRD_PARTY_SDK_KEY, let reason = key.reasons.first {
                var results: Set<String> = Set()
                value.forEach { result in
                    results.update(with: result.filePath)
                }
                print("\n\(CliSyntaxColor.WHITE_BOLD)WARNING:\(CliSyntaxColor.END) The following third-party SDKs were detected:\n")
                print("* \(results.joined(separator: "\n* "))")
                print("\(CliSyntaxColor.WHITE_BOLD)\(reason.value)\(CliSyntaxColor.END)")
                print("\(CliSyntaxColor.CYAN)⚓︎ \(key.link)\(CliSyntaxColor.END)\n")
                print("Hit ENTER to continue: ", terminator: "")
                _ = readLine()
                return
            }

            guard let privacyManifestKey = key.privacyManifestKey else {
                return
            }

            print("\n\(CliSyntaxColor.WHITE_BOLD)\(value.count) \(value.count == 1 ? "occurrence" : "occurrences") for \(key.description)\(CliSyntaxColor.END). Available reasons:\n")

            var index = 0
            let reasonKeys = [String](key.reasons.keys)
            reasonKeys.forEach { reasonKey in
                guard let value = key.reasons[reasonKey] else {
                    return
                }
                print("""
\(CliSyntaxColor.WHITE_BOLD)\(index+1).\(CliSyntaxColor.END) \(value)\n
""")
                index += 1
            }

            print("\(CliSyntaxColor.CYAN)⚓︎ \(key.link)\(CliSyntaxColor.END)\n")

            print("Enter the values that match your case (comma separated, enter for none): ",
                  terminator: "")

            var manifestReasonKeys: [String] = []

            if let input = readLine() {
                let values = input.components(separatedBy: ",")
                values.forEach { value in
                    guard let index = Int(value.trimmingCharacters(in: .whitespaces)),
                        index - 1 >= 0 && index - 1 < reasonKeys.count else {
                        return
                    }
                    let reasonKey = reasonKeys[index - 1]
                    manifestReasonKeys.append(reasonKey)
                }
            }

            if manifestReasonKeys.count > 0 {
                manifestReasons.append(PrivacyManifestDataStructure.PrivacyAccessedAPIType(
                    nsPrivacyAccessedAPIType: privacyManifestKey,
                    nSPrivacyAccessedAPITypeReasons: manifestReasonKeys))
            }
        }

        print("\n")

        guard manifestReasons.count > 0 else {
            print("\(CliSyntaxColor.YELLOW)No reasons were provided, Privacy Manifest file generation was skipped.\(CliSyntaxColor.END)")
            return
        }

        let privacyManifestDataStructure = PrivacyManifestDataStructure(
            nsPrivacyTracking: false,
            nsPrivacyTrackingDomains: [],
            nsPrivacyCollectedDataTypes: [],
            nsPrivacyAccessedAPITypes: manifestReasons)

        do {
            try PropertyListEncoder().encode(privacyManifestDataStructure).write(to: outputPath.url)
            print("\(CliSyntaxColor.GREEN)✔\(CliSyntaxColor.END) Privacy Manifest file was generated successfully at \(CliSyntaxColor.WHITE_BOLD)\(outputPath.absolute())\(CliSyntaxColor.END)")
        } catch {
            print("\(CliSyntaxColor.RED)✖ Error generating Privacy Manifest file: \(error)\(CliSyntaxColor.END)")
        }
    }
}

PrivacyManifest.main()
