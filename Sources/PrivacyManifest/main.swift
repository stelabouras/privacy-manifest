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

// Used for parsing Swift Packages
import PackageModel
import PackageLoading
import PackageGraph
import Workspace
import Basics
import class TSCBasic.Process
import func TSCBasic.tsc_await

// Used for parsing Xcode projects
import PathKit
import XcodeProj

let ALLOWED_EXTENSIONS = [
    "m",    // Objective-C
    "mm",   // Objective-C++
    "c",    // C
    "cpp",  // C++
    "swift" // Swift
]

let FILE_TIMESTAMP_APIS_KEY = "File Timestamp APIs"
let SYSTEM_BOOT_APIS_KEY = "System boot time APIs"
let DISK_SPACE_APIS_KEY = "Disk space APIs"
let ACTIVE_KEYBOARD_APIS_KEY = "Active keyboard APIs"
let USER_DEFAULTS_APIS_KEY = "User defaults APIs"
let CORELOCATION_FRAMEWORK_KEY = "Core Location"
let HEALTHKIT_FRAMEWORK_KEY = "HealthKit"
let CRASH_FRAMEWORK_KEY = "Crash data"
let CONTACTS_FRAMEWORK_KEY = "Contacts"

let LINKS_TO_APIS = [
    FILE_TIMESTAMP_APIS_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393",
    SYSTEM_BOOT_APIS_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278394",
    DISK_SPACE_APIS_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397",
    ACTIVE_KEYBOARD_APIS_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278400",
    USER_DEFAULTS_APIS_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401",
    CORELOCATION_FRAMEWORK_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263133",
    HEALTHKIT_FRAMEWORK_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263132",
    CRASH_FRAMEWORK_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263159",
    CONTACTS_FRAMEWORK_KEY: "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263130",
]

let APIS_TO_CHECK = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
    FILE_TIMESTAMP_APIS_KEY: [
        "creationDate",
        "modificationDate",
        "fileModificationDate",
        "contentModificationDateKey",
        "creationDateKey",
        "getattrlist(",
        "getattrlistbulk(",
        "fgetattrlist(",
        "fstat(",
        "fstatat(",
        "lstat(",
        "getattrlistat("
    ],
    SYSTEM_BOOT_APIS_KEY: [
        "systemUptime",
        "mach_absolute_time("
    ],
    DISK_SPACE_APIS_KEY: [
        "volumeAvailableCapacityKey",
        "volumeAvailableCapacityForImportantUsageKey",
        "volumeAvailableCapacityForOpportunisticUsageKey",
        "volumeTotalCapacityKey",
        "systemFreeSize",
        "systemSize",
        "statfs(",
        "statvfs(",
        "fstatfs(",
        "fstatvfs(",
        "getattrlist(",
        "fgetattrlist(",
        "getattrlistat("
    ],
    ACTIVE_KEYBOARD_APIS_KEY: [
        "activeInputModes"
    ],
    USER_DEFAULTS_APIS_KEY: [
        "UserDefaults"
    ],

    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests
    CORELOCATION_FRAMEWORK_KEY: [
        "import CoreLocation",
        "#import <CoreLocation/CoreLocation.h>"
    ],
    HEALTHKIT_FRAMEWORK_KEY: [
        "import HealthKit",
        "#import <HealthKit/HealthKit.h>",
        "#import <HealthKitUI/HealthKitUI.h>"
    ],
    CRASH_FRAMEWORK_KEY: [
        "import Sentry",
        "#import <Sentry/Sentry.h>"
        // TODO: Add more third-party crash frameworks here
    ],
    CONTACTS_FRAMEWORK_KEY: [
        "import Contacts",
        "#import <ContactsUI/ContactsUI.h>",
        "#import <Contacts/Contacts.h>"
    ]
]

extension SwiftSDK {
    package static var `default`: Self {
        get throws {
            // ref: https://github.com/compnerd/swift-package-manager/blob/master/Examples/package-info/Sources/package-info/main.swift#L10
            let swiftCompiler: AbsolutePath? = {
                let string: String
                #if os(macOS)
                string = try! Process.checkNonZeroExit(args: "xcrun", "--sdk", "macosx", "-f", "swiftc").spm_chomp()
                #else
                string = try! Process.checkNonZeroExit(args: "which", "swiftc").spm_chomp()
                #endif
                return try! AbsolutePath(validating: string)
            }()
            return try! SwiftSDK.hostSwiftSDK(swiftCompiler)
        }
    }
}

extension UserToolchain {
    package static var `default`: Self {
        get throws {
            return try .init(swiftSDK: SwiftSDK.default)
        }
    }
}

struct CliSyntaxColor {
    static let WHITE_BOLD = "\u{001B}[0;1m"
    static let RED = "\u{001B}[0;0;31m"
    static let GREEN = "\u{001B}[0;32m"
    static let YELLOW = "\u{001B}[0;33m"
    static let BLUE = "\u{001B}[0;34m"
    static let MAGENTA = "\u{001B}[0;35m"
    static let CYAN = "\u{001B}[0;36m"
    static let PINK = "\u{001B}[0;91m"
    static let GREEN_BRIGHT = "\u{001B}[0;92m"
    static let YELLOW_BRIGHT = "\u{001B}[0;93m"
    static let BLUE_BRIGHT = "\u{001B}[0;94m"
    static let MAGENTA_BRIGHT = "\u{001B}[0;95m"
    static let CYAN_BRIGHT = "\u{001B}[0;96m"
    static let END = "\u{001B}[0;0m"
}

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
        version: "0.0.1",
        subcommands: [Analyze.self])
}

struct ParsedResult: Hashable {
    var line: String
    var lineNumber: Int
    var range: Range<String.Index>
    var api: String
}

struct PresentedResult: Hashable {
    var filePath: String
    var formattedLine: String?
    var parsedResult: ParsedResult?
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
                try parseSwiftPackage(projectPath: projectPath)
            }
        }
        else if projectPath.extension == "xcodeproj" {
            print("Xcode project detected.")
            try measure {
                try parseXcodeProject(projectPath: projectPath)
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

    func parseSwiftPackage(projectPath: Path) throws {
        var requiredAPIs : [String: Set<PresentedResult>] = [:]
        APIS_TO_CHECK.forEach { (key, value) in
            requiredAPIs[key] = Set()
        }
        print("---")
        let spinner = Spinner(.dots8Bit,
                              "Resolving graph...")
        spinner.start()
        let manifestLoader = try ManifestLoader(toolchain: UserToolchain.default)
        let packageAbsolutePath = try AbsolutePath(validating: projectPath.string)
        let root = packageAbsolutePath.parentDirectory
        // ref: https://github.com/unsignedapps/swift-create-xcframework/blob/0be3a68c84987493a7d7298027274a0862bc5ccd/Sources/CreateXCFramework/PackageInfo.swift#L93
        let workspace = try Workspace(
            forRootPackage: root,
            customManifestLoader: manifestLoader
        )
        // Only print warning and error messages
        let observability = Basics.ObservabilitySystem { _, diagnostics in
            guard diagnostics.severity != .debug && diagnostics.severity != .info else {
                return
            }
            print("\(diagnostics.severity): \(diagnostics.message)")
        }
        let scope = observability.topScope
        let graph = try workspace.loadPackageGraph(
            rootPath: root,
            observabilityScope: scope
        )
        spinner.success()
        // We only care about the targets of the root packages, not the
        // dependencies
        try graph.rootPackages.forEach { package in
            try package.targets.forEach { target in
                // Exclude test targets
                guard target.type != .test else {
                    return
                }
                var filePathsForParsing: [Path] = []
                let rootDirectory = target.sources.root
                target.sources.relativePaths.forEach { relativePath in
                    guard let ext = relativePath.extension,
                          ALLOWED_EXTENSIONS.contains(ext) else {
                        return
                    }
                    filePathsForParsing.append(Path(rootDirectory.pathString) + relativePath.pathString)
                }
                let spinner = Spinner(.dots8Bit,
                                      "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...")
                spinner.start()
                try parseFiles(filePathsForParsing: filePathsForParsing,
                               requiredAPIs: &requiredAPIs,
                               targetName: target.name,
                               spinner: spinner)
                spinner.success()
            }
        }

        process(requiredAPIs: requiredAPIs)
    }

    func parseXcodeProject(projectPath: Path) throws {
        var requiredAPIs : [String: Set<PresentedResult>] = [:]
        APIS_TO_CHECK.forEach { (key, value) in
            requiredAPIs[key] = Set()
        }

        let xcodeproj = try XcodeProj(path: projectPath)

        print("---")

        try xcodeproj.pbxproj.nativeTargets.forEach { target in
            guard let productType = target.productType else {
                return
            }

            // Skip UI / Unit tests
            if productType == .unitTestBundle || productType == .uiTestBundle {
                return
            }

            // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests
            target.buildPhases.forEach { phase in
                guard phase.buildPhase == .frameworks else {
                    return
                }
                let spinner = Spinner(.dots8Bit,
                                      "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase...")
                spinner.start()
                phase.files?.forEach({ file in
                    guard let fullFileName = file.file?.name,
                          let fileName = fullFileName.split(separator: ".").first else {
                        return
                    }

                    let foundInBuildPhase = "Found \(CliSyntaxColor.YELLOW)\(fullFileName)\(CliSyntaxColor.END) in \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase."

                    if fileName == "CoreLocation" {
                        requiredAPIs[CORELOCATION_FRAMEWORK_KEY]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                    }
                    else if fileName == "HealthKit" {
                        requiredAPIs[HEALTHKIT_FRAMEWORK_KEY]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                    }
                    else if fileName == "Sentry" {
                        requiredAPIs[CRASH_FRAMEWORK_KEY]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                    }
                    else if fileName == "Contacts" || fileName == "ContactsUI" {
                        requiredAPIs[CONTACTS_FRAMEWORK_KEY]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                    }
                })
                spinner.success()
            }

            var filePathsForParsing: [Path] = []
            try target.sourceFiles().forEach { file in
                guard let path = file.path,
                      let ext = Path(path).extension,
                      ALLOWED_EXTENSIONS.contains(ext)
                else {
                    return
                }

                guard let fullPath = try file.fullPath(sourceRoot: projectPath.parent()) else {
                    return
                }

                filePathsForParsing.append(fullPath)
            }

            let spinner = Spinner(.dots8Bit,
                                  "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...")
            spinner.start()
            try parseFiles(filePathsForParsing: filePathsForParsing,
                           requiredAPIs: &requiredAPIs,
                           targetName: target.name,
                           spinner: spinner)
            spinner.success()
        }

        process(requiredAPIs: requiredAPIs)
    }

    func parseFiles(filePathsForParsing: [Path],
                    requiredAPIs: inout [String: Set<PresentedResult>],
                    targetName: String,
                    spinner: Spinner) throws {
        var fileCount = 1
        for filePath in filePathsForParsing {
            guard let fileHandle = FileHandle(forReadingAtPath: filePath.string) else {
                continue
            }
            guard let data = try fileHandle.readToEnd(),
                  let contents = String(data: data, encoding: .utf8) else {
                continue
            }

            APIS_TO_CHECK.forEach { (key, value) in
                Self.lookForAPI(listOfAPIs: value,
                                contents: contents).forEach { parsedResult in
                    let highlightedCode = "\(Self.addBracketsToString(parsedResult.line,around: parsedResult.range))"
                    let formattedLine = "\(CliSyntaxColor.GREEN)\(parsedResult.lineNumber):\(CliSyntaxColor.END)\t\(highlightedCode)"
                    requiredAPIs[key]?.update(with: PresentedResult(filePath: filePath.string,
                                                                    formattedLine: formattedLine,
                                                                    parsedResult: parsedResult))
                }
            }
            spinner.message("Parsing \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files (\(fileCount)/\(filePathsForParsing.count))...")
            fileCount += 1
        }
    }

    func process(requiredAPIs: [String: Set<PresentedResult>]) {
        print("---")
        requiredAPIs.sorted(by: {
            if $0.value.count == $1.value.count {
                $0.key < $1.key
            }
            else {
                $0.value.count < $1.value.count
            }
        }).forEach { (key, list) in
            print("\(CliSyntaxColor.WHITE_BOLD)\(key) (\(list.count) \(list.count == 1 ? "occurrence" : "occurrences")\(CliSyntaxColor.END))")
            if list.count > 0,
               let link = LINKS_TO_APIS[key] {
                print("\(CliSyntaxColor.CYAN)⚓︎ \(link)\(CliSyntaxColor.END)")
            }

            if !revealOccurrences {
                return
            }
            var currentPath = ""
            list.sorted(by: {
                if $0.parsedResult == nil && $1.parsedResult != nil {
                    return true
                } else if $0.parsedResult != nil && $1.parsedResult == nil {
                    return false
                }
                else if let firstParsedResult = $0.parsedResult,
                         let secondParentResult = $1.parsedResult {
                    if $0.filePath == $1.filePath {
                        return firstParsedResult.lineNumber < secondParentResult.lineNumber
                    }
                    else {
                        return $0.filePath < $1.filePath
                    }
                }
                return $0.filePath < $1.filePath
            }).forEach { presentedResult in
                if presentedResult.filePath != currentPath {
                    print("\n\t\(presentedResult.formattedLine != nil ? "✎ " : "⛺︎")\(presentedResult.filePath)\(presentedResult.formattedLine != nil ? ":" : "")")
                }

                if let formattedLine = presentedResult.formattedLine {
                    print("\t\t\(formattedLine)")
                }

                currentPath = presentedResult.filePath
            }

            print("\n")
        }
    }

    static func lookForAPI(listOfAPIs: [String],
                           contents: String) -> [ParsedResult] {
        var foundAPIs: [ParsedResult] = []
        listOfAPIs.forEach { api in
            var lineNumber = 1
            contents.components(separatedBy: .newlines).forEach { line in
                var searchRange = line.startIndex..<line.endIndex
                while let range = line.range(of: api,
                                             options: [],
                                             range: searchRange) {
                    foundAPIs.append(ParsedResult(line: line,
                                                  lineNumber: lineNumber,
                                                  range: range,
                                                  api: api))
                    searchRange = range.upperBound..<line.endIndex
                }
                lineNumber += 1
            }
        }
        return foundAPIs
    }

    static func addTagsToString(_ string: String,
                                around range: Range<String.Index>,
                                openingTag: String,
                                closingTag: String) -> String {
        let lowerBoundIndex = range.lowerBound
        let upperBoundIndex = range.upperBound
        var modifiedString = string
        modifiedString.replaceSubrange(lowerBoundIndex..<lowerBoundIndex,
                                       with: openingTag)
        let adjustedUpperBoundIndex = modifiedString.index(upperBoundIndex,
                                                           offsetBy: openingTag.count)
        modifiedString.replaceSubrange(adjustedUpperBoundIndex..<adjustedUpperBoundIndex,
                                       with: closingTag)
        return modifiedString
    }

    static func addBracketsToString(_ string: String,
                                    around range: Range<String.Index>) -> String {
        return addTagsToString(string, around: range,
                               openingTag: CliSyntaxColor.YELLOW,
                               closingTag: CliSyntaxColor.END)
    }

}

PrivacyManifest.main()
