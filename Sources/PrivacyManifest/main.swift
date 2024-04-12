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

// Display several different spinner outputs concurrently
class ConcurrentSpinnerStream {
    // The array of concurrent silent spinner streams to manage
    var silentSpinners: [SilentSpinnerStream] = []

    private let printLock = NSLock()
    private var previousRows = 0

    // Renders the added silent spinner streams
    func render() {
        printLock.lock()
        defer { printLock.unlock() }
        guard silentSpinners.count > 0 else {
            return
        }
        // Move cursor at the beginning of the previously rendered string
        if previousRows > 0 {
            print("\u{001B}[\(previousRows)F", terminator: "")
        }
        // Clear from cursor to end of screen
        print("\u{001B}[0J", terminator: "")
        // Generate the buffer
        var buffer = ""
        silentSpinners.forEach { silentSpinner in
            buffer.append(silentSpinner.buffer + "\n")
        }
        print("\(buffer)", terminator: "")
        fflush(stdout)
        previousRows = silentSpinners.count
    }

    // Hides the cursor from console
    func hideCursor() {
        previousRows = 0
        print("\u{001B}[?25l", terminator: "")
        fflush(stdout)
    }

    /// Shows the cursor to console
    func showCursor() {
        print("\u{001B}[?25h", terminator: "")
        fflush(stdout)
    }

    // Adds a silent spinner stream
    func add(stream: SilentSpinnerStream) {
        printLock.lock()
        silentSpinners.append(stream)
        printLock.unlock()
    }
}

// Writes the spinner stream to a buffer, instead of the stdout
class SilentSpinnerStream: SpinnerStream {
    var buffer = ""
    var concurrentStream: ConcurrentSpinnerStream

    init(concurrentStream: ConcurrentSpinnerStream) {
        self.concurrentStream = concurrentStream
        concurrentStream.add(stream: self)
    }

    func write(string: String, terminator: String) {
        if string.count == 0 {
            return
        }
        buffer = string
        concurrentStream.render()
    }

    func hideCursor() { }

    func showCursor() { }
}

enum RequiredReasonKey: CaseIterable {
    case FILE_TIMESTAMP_APIS_KEY
    case SYSTEM_BOOT_APIS_KEY
    case DISK_SPACE_APIS_KEY
    case ACTIVE_KEYBOARD_APIS_KEY
    case USER_DEFAULTS_APIS_KEY
    case CORELOCATION_FRAMEWORK_KEY
    case HEALTHKIT_FRAMEWORK_KEY
    case CRASH_FRAMEWORK_KEY
    case CONTACTS_FRAMEWORK_KEY
    
    var description: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "File Timestamp APIs"
        case .SYSTEM_BOOT_APIS_KEY:
            return "System boot time APIs"
        case .DISK_SPACE_APIS_KEY:
            return "Disk space APIs"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "Active keyboard APIs"
        case .USER_DEFAULTS_APIS_KEY:
            return "User defaults APIs"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "Core Location"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "HealthKit"
        case .CRASH_FRAMEWORK_KEY:
            return "Crash data"
        case .CONTACTS_FRAMEWORK_KEY:
            return "Contacts"
        }
    }

    var link: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393"
        case .SYSTEM_BOOT_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278394"
        case .DISK_SPACE_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278400"
        case .USER_DEFAULTS_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263133"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263132"
        case .CRASH_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263159"
        case .CONTACTS_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263130"
        }
    }
}

let ALLOWED_EXTENSIONS = [
    "m",    // Objective-C
    "mm",   // Objective-C++
    "c",    // C
    "cpp",  // C++
    "swift" // Swift
]

// Look through the code for the listed strings (Case Sensitive)
let APIS_TO_CHECK: [String: [RequiredReasonKey]] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api

    "creationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "modificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "fileModificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "contentModificationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "creationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlist(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY], // also covers: fgetattrlist(
    "getattrlistbulk(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstatat(": [.FILE_TIMESTAMP_APIS_KEY],
    "lstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlistat(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY],
    "systemUptime": [.SYSTEM_BOOT_APIS_KEY],
    "mach_absolute_time(": [.SYSTEM_BOOT_APIS_KEY],

    "volumeAvailableCapacityKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForImportantUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForOpportunisticUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeTotalCapacityKey": [.DISK_SPACE_APIS_KEY],
    "systemFreeSize": [.DISK_SPACE_APIS_KEY],
    "systemSize": [.DISK_SPACE_APIS_KEY],
    "statfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatfs(
    "statvfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatvfs(

    "activeInputModes": [.ACTIVE_KEYBOARD_APIS_KEY],

    "UserDefaults": [.USER_DEFAULTS_APIS_KEY],

    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests

    "import CoreLocation": [.CORELOCATION_FRAMEWORK_KEY],
    "#import <CoreLocation/CoreLocation.h>": [.CORELOCATION_FRAMEWORK_KEY],

    "import HealthKit": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKit/HealthKit.h>": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKitUI/HealthKitUI.h>": [.HEALTHKIT_FRAMEWORK_KEY],

    "import Sentry": [.CRASH_FRAMEWORK_KEY],
    "#import <Sentry/Sentry.h>": [.CRASH_FRAMEWORK_KEY],
    // TODO: Add more third-party crash frameworks here

    "import Contacts": [.CONTACTS_FRAMEWORK_KEY],
    "#import <ContactsUI/ContactsUI.h>": [.CONTACTS_FRAMEWORK_KEY],
    "#import <Contacts/Contacts.h>": [.CONTACTS_FRAMEWORK_KEY]
]

// Look through the Frameworks Build Phase or Package Dependencies for the
// listed strings (Case Insensitive)
let SDKS_TO_CHECK: [String: RequiredReasonKey] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests

    "sentry-cocoa": .CRASH_FRAMEWORK_KEY,
    "Sentry": .CRASH_FRAMEWORK_KEY,
    "CoreLocation": .CORELOCATION_FRAMEWORK_KEY,
    "HealthKit": .HEALTHKIT_FRAMEWORK_KEY,
    "Contacts": .CONTACTS_FRAMEWORK_KEY, // also covers ContactsUI
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

struct ParsedResult: Hashable {
    var line: String
    var lineNumber: Int?
    var range: Range<String.Index>
}

struct PresentedResult: Hashable {
    var filePath: String
    var formattedLine: String?
    var parsedResult: ParsedResult?
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
        version: "0.0.2",
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
        var requiredAPIs: [RequiredReasonKey: Set<PresentedResult>] = [:]
        RequiredReasonKey.allCases.forEach { key in
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

        let concurrentStream = ConcurrentSpinnerStream()
        concurrentStream.hideCursor()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "parser",
                                  attributes: .concurrent)

        graph.requiredDependencies.forEach { dependency in
            guard !dependency.kind.isRoot else {
                return
            }

            queue.async(group: group,
                        execute: DispatchWorkItem(block: {
                let dependencyString = dependency.canonicalLocation.description
                let silentStream = SilentSpinnerStream(concurrentStream: concurrentStream)
                let spinner = Spinner(.dots8Bit,
                                      "Parsing package dependencies...",
                                      stream: silentStream)
                spinner.start()
                SDKS_TO_CHECK.forEach { (key, value) in
                    let markedResults = Self.mark(searchString: key,
                                                  in: dependencyString,
                                                  lineNumber: nil,
                                                  caseInsensitive: true,
                                                  requiredReasonKeys: [value])
                    guard let firstResult = markedResults.first?.1 else {
                        return
                    }
                    let highlightedCode = "\(Self.addBracketsToString(firstResult.line,around: firstResult.range))"
                    let foundInBuildPhase = "Found \(highlightedCode) in dependencies."
                    requiredAPIs[value]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                }
                spinner.success()
            }))
        }

        // We only care about the targets of the root packages, not the
        // dependencies
        graph.rootPackages.forEach { package in
            package.targets.forEach { target in
                // Exclude test targets
                guard target.type != .test else {
                    return
                }

                queue.async(group: group,
                            execute: DispatchWorkItem(block: {
                    var filePathsForParsing: [Path] = []
                    let rootDirectory = target.sources.root
                    target.sources.relativePaths.forEach { relativePath in
                        guard let ext = relativePath.extension,
                              ALLOWED_EXTENSIONS.contains(ext) else {
                            return
                        }
                        filePathsForParsing.append(Path(rootDirectory.pathString) + relativePath.pathString)
                    }
                    let silentStream = SilentSpinnerStream(concurrentStream: concurrentStream)
                    let spinner = Spinner(.dots8Bit,
                                          "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...",
                                          stream: silentStream)
                    spinner.start()
                    do {
                        try parseFiles(filePathsForParsing: filePathsForParsing,
                                       requiredAPIs: &requiredAPIs,
                                       targetName: target.name,
                                       spinner: spinner)
                        spinner.success()
                    }
                    catch {
                        spinner.error()
                    }
                }))
            }
        }

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.showCursor()

        process(requiredAPIs: requiredAPIs)
    }

    func parseXcodeProject(projectPath: Path) throws {
        var requiredAPIs: [RequiredReasonKey: Set<PresentedResult>] = [:]
        RequiredReasonKey.allCases.forEach { key in
            requiredAPIs[key] = Set()
        }

        let xcodeproj = try XcodeProj(path: projectPath)

        print("---")

        let concurrentStream = ConcurrentSpinnerStream()
        concurrentStream.hideCursor()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "parser",
                                  attributes: .concurrent)

        xcodeproj.pbxproj.nativeTargets.forEach { target in
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
                queue.async(group: group,
                            execute: DispatchWorkItem(block: {
                    let silentStream = SilentSpinnerStream(concurrentStream: concurrentStream)
                    let spinner = Spinner(.dots8Bit,
                                          "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase...",
                                          stream: silentStream)
                    spinner.start()
                    phase.files?.forEach({ file in
                        guard let fullFileName = file.file?.name else {
                            return
                        }
                        SDKS_TO_CHECK.forEach { (key, value) in
                            let markedResults = Self.mark(searchString: key,
                                                          in: fullFileName,
                                                          lineNumber: nil,
                                                          caseInsensitive: true,
                                                          requiredReasonKeys: [value])
                            guard let firstResult = markedResults.first?.1 else {
                                return
                            }
                            let highlightedCode = "\(Self.addBracketsToString(firstResult.line,around: firstResult.range))"
                            let foundInBuildPhase = "Found \(highlightedCode) in \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase."
                            requiredAPIs[value]?.update(with: PresentedResult(filePath: foundInBuildPhase))
                        }
                    })
                    spinner.success()
                }))
            }

            queue.async(group: group,
                        execute: DispatchWorkItem(block: {
                let silentStream = SilentSpinnerStream(concurrentStream: concurrentStream)
                let spinner = Spinner(.dots8Bit,
                                      "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...",
                                      stream: silentStream)
                spinner.start()
                do {
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
                    try parseFiles(filePathsForParsing: filePathsForParsing,
                                   requiredAPIs: &requiredAPIs,
                                   targetName: target.name,
                                   spinner: spinner)
                    spinner.success()
                }
                catch {
                    spinner.error()
                }
            }))
        }

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.showCursor()

        process(requiredAPIs: requiredAPIs)
    }

    func parseFiles(filePathsForParsing: [Path],
                    requiredAPIs: inout [RequiredReasonKey: Set<PresentedResult>],
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

            Self.lookForAPI(contents: contents).forEach { (key, parsedResult) in
                let highlightedCode = "\(Self.addBracketsToString(parsedResult.line,around: parsedResult.range))"
                var formattedLine = ""
                if let lineNumber = parsedResult.lineNumber {
                    formattedLine = "\(CliSyntaxColor.GREEN)\(lineNumber):\(CliSyntaxColor.END)\t\(highlightedCode)"
                }
                else {
                    formattedLine = "\(highlightedCode)"
                }
                requiredAPIs[key]?.update(with: PresentedResult(filePath: filePath.string,
                                                                formattedLine: formattedLine,
                                                                parsedResult: parsedResult))
            }

            spinner.message("Parsing \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files (\(fileCount)/\(filePathsForParsing.count))...")
            fileCount += 1
        }
    }

    func process(requiredAPIs: [RequiredReasonKey: Set<PresentedResult>]) {
        print("---")
        requiredAPIs.sorted(by: {
            if $0.value.count == $1.value.count {
                $0.key.hashValue < $1.key.hashValue
            }
            else {
                $0.value.count < $1.value.count
            }
        }).forEach { (key, list) in
            print("\(CliSyntaxColor.WHITE_BOLD)\(key.description) (\(list.count) \(list.count == 1 ? "occurrence" : "occurrences")\(CliSyntaxColor.END))")
            if list.count > 0 {
                print("\(CliSyntaxColor.CYAN)⚓︎ \(key.link)\(CliSyntaxColor.END)")
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
                        return firstParsedResult.lineNumber ?? -1 < secondParentResult.lineNumber ?? -1
                    }
                    else {
                        return $0.filePath < $1.filePath
                    }
                }
                return $0.filePath < $1.filePath
            }).forEach { presentedResult in
                if presentedResult.filePath != currentPath {
                    print("\n\t\(presentedResult.formattedLine != nil ? "✎" : "⛺︎") \(presentedResult.filePath)\(presentedResult.formattedLine != nil ? ":" : "")")
                }

                if let formattedLine = presentedResult.formattedLine {
                    print("\t\t\(formattedLine)")
                }

                currentPath = presentedResult.filePath
            }

            print("\n")
        }
    }

    static func lookForAPI(contents: String) -> [(RequiredReasonKey, ParsedResult)] {
        var foundAPIs: [(RequiredReasonKey, ParsedResult)] = []
        var lineNumber = 1
        contents.components(separatedBy: .newlines).forEach { line in
            APIS_TO_CHECK.forEach { (api, requiredReasonKeys) in
                let results = mark(searchString: api,
                                   in: line,
                                   lineNumber: lineNumber,
                                   requiredReasonKeys: requiredReasonKeys)
                foundAPIs.append(contentsOf: results)
            }
            lineNumber += 1
        }
        return foundAPIs
    }

    static func mark(searchString: String, 
                     in line: String,
                     lineNumber: Int?,
                     caseInsensitive: Bool = false,
                     requiredReasonKeys: [RequiredReasonKey]) -> [(RequiredReasonKey, ParsedResult)] {
        var parsedResults: [(RequiredReasonKey, ParsedResult)] = []
        var searchRange = line.startIndex..<line.endIndex
        while let range = line.range(of: searchString,
                                     options: caseInsensitive ? .caseInsensitive : [],
                                     range: searchRange) {
            requiredReasonKeys.forEach { requiredReasonKey in
                parsedResults.append((requiredReasonKey, ParsedResult(line: line,
                                                                      lineNumber: lineNumber,
                                                                      range: range)))
            }
            searchRange = range.upperBound..<line.endIndex
        }
        return parsedResults
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
