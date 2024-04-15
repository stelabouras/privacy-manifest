//
//  SwiftPackageProjectParser.swift
//  
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

import Spinner
import PathKit

import PackageModel
import PackageLoading
import PackageGraph
import Workspace
import Basics
import class TSCBasic.Process
import func TSCBasic.tsc_await

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

// Parses all the Swift Package's supported source files and dependencies.
class SwiftPackageProjectParser : ProjectParser {
    override func parse() throws {
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
        spinner.success("Resolved graph")

        graph.requiredDependencies.forEach { dependency in
            guard !dependency.kind.isRoot else {
                return
            }

            let dependencyString = dependency.canonicalLocation.description
            let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(dependencyString) dependency...")
            concurrentStream.start(spinner: spinner)
            queue.async(group: group,
                        execute: DispatchWorkItem(block: {
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
                    self.updateRequiredAPIs(value,
                                            with: PresentedResult(filePath: foundInBuildPhase))
                }
                self.concurrentStream.success(spinner: spinner,
                                              "Parsed \(dependencyString) dependency")
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

                let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...")
                concurrentStream.start(spinner: spinner)
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
                    do {
                        try self.parseFiles(filePathsForParsing: filePathsForParsing,
                                            targetName: target.name,
                                            spinner: spinner)
                        self.concurrentStream.success(spinner: spinner,
                                                      "Parsed \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files")
                    }
                    catch {
                        self.concurrentStream.error(spinner: spinner,
                                                    "Error parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files: \(CliSyntaxColor.RED)\(error)\(CliSyntaxColor.END)")
                    }
                }))
            }
        }

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.waitAndShowCursor()
    }
}
