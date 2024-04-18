//
//  XcodeProjectParser.swift
//  
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

import Spinner
import PathKit

import XcodeProj

// Parses all Xcode projects contained in a Xcode workspace
class XcodeWorkspaceParser: XcodeProjectParser {
    override func parse() throws {
        print("---")

        let xcworkspace = try XCWorkspace(path: projectPath)

        try xcworkspace.data.children.filter {
            Path($0.location.path).extension == XCODE_PROJECT_PATH_EXTENSION
        }.forEach { element in
            print("\(CliSyntaxColor.WHITE_BOLD)\(element.location.path)\(CliSyntaxColor.END)")

            ConcurrentSpinnerStream.hideCursor()

            let projectPath = projectPath.parent() + Path(element.location.path)

            try parseProject(projectPath)
        }
    }
}

// Parses all targets' supported source files and frameworks.
class XcodeProjectParser: ProjectParser {
    var deepLibraryFrameworkCheck = false

    init(with path: Path,
         deepLibraryFrameworkCheck: Bool = false) {
        super.init(with: path)
        self.deepLibraryFrameworkCheck = deepLibraryFrameworkCheck
    }

    override func parse() throws {
        print("---")

        try parseProject(projectPath)
    }

    fileprivate func parseProject(_ path: Path) throws {
        let xcodeproj = try XcodeProj(path: path)

        // Gather all local and remote package dependencies from the root
        // project.
        var packageDepedencyNames: [String] = []
        do {
            try xcodeproj.pbxproj.rootProject()?.localPackages.compactMap {
                $0.name
            }.forEach {
                packageDepedencyNames.append($0)
            }
            try xcodeproj.pbxproj.rootProject()?.remotePackages.compactMap {
                $0.name
            }.forEach {
                packageDepedencyNames.append($0)
            }
        }
        catch {
            // Suppress any errors due to missing references.
        }

        packageDepedencyNames.forEach { packageDepedencyName in
            let spinner = concurrentStream.createSilentSpinner(with: "Looking up \(CliSyntaxColor.GREEN)\(packageDepedencyName)'s\(CliSyntaxColor.END) package dependency...")
            concurrentStream.start(spinner: spinner)
            queue.async(group: group,
                        execute: DispatchWorkItem(block: {
                SDKS_TO_CHECK.forEach { (key, value) in
                    let markedResults = Self.mark(searchString: key,
                                                  in: packageDepedencyName,
                                                  lineNumber: nil,
                                                  caseInsensitive: true,
                                                  requiredReasonKeys: [value])
                    guard let firstResult = markedResults.first?.1 else {
                        return
                    }
                    let highlightedCode = "\(Self.addBracketsToString(firstResult.line,around: firstResult.range))"
                    let foundInBuildPhase = "Found \(highlightedCode) in Package Dependencies."
                    self.updateRequiredAPIs(value,
                                            with: PresentedResult(filePath: foundInBuildPhase))
                }
                self.concurrentStream.success(spinner: spinner,
                                              "Parsed \(CliSyntaxColor.GREEN)\(packageDepedencyName)\(CliSyntaxColor.END) package dependency")
            }))
        }

        try xcodeproj.pbxproj.nativeTargets.forEach { target in
            guard let productType = target.productType else {
                return
            }

            // Skip UI / Unit tests
            if productType == .unitTestBundle || productType == .uiTestBundle {
                return
            }

            if productType == .staticLibrary
                || productType == .staticFramework
                || productType == .framework
                || productType == .xcFramework {
                let spinner = concurrentStream.createSilentSpinner(with: "Looking up \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) name...")
                concurrentStream.start(spinner: spinner)
                queue.async(group: group,
                            execute: DispatchWorkItem(block: {
                    SDKS_TO_CHECK.forEach { (key, value) in
                        let markedResults = Self.mark(searchString: key,
                                                      in: target.name,
                                                      lineNumber: nil,
                                                      caseInsensitive: true,
                                                      requiredReasonKeys: [value])
                        guard let firstResult = markedResults.first?.1 else {
                            return
                        }
                        let highlightedCode = "\(Self.addBracketsToString(firstResult.line,around: firstResult.range))"
                        let foundInBuildPhase = "Found \(highlightedCode)."
                        self.updateRequiredAPIs(value,
                                                with: PresentedResult(filePath: foundInBuildPhase))
                    }
                    self.concurrentStream.success(spinner: spinner,
                                                  "Looked up \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) name")
                }))
                // Do not proceed into looking at the build phase or the source
                // files of the project targets that are libraries or frameworks
                // if not instructed.
                if !deepLibraryFrameworkCheck {
                    return
                }
            }

            // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests
            target.buildPhases.forEach { phase in
                guard phase.buildPhase == .frameworks else {
                    return
                }
                guard let files = phase.files, files.count > 0 else {
                    return
                }
                let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase...")
                concurrentStream.start(spinner: spinner)
                queue.async(group: group,
                            execute: DispatchWorkItem(block: {
                    files.forEach({ file in
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
                            self.updateRequiredAPIs(value,
                                                    with: PresentedResult(filePath: foundInBuildPhase))
                        }
                    })
                    self.concurrentStream.success(spinner: spinner,
                                                  "Parsed \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase")
                }))
            }

            var sourceFiles: [PBXFileElement] = []
            do {
                sourceFiles = try target.sourceFiles()
            }
            catch is PBXObjectError {
                // Suppress PBXObjectError
            }

            let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...")
            concurrentStream.start(spinner: spinner)
            do {
                var filePathsForParsing: [Path] = []
                try sourceFiles.forEach { file in
                    guard let filePath = file.path,
                          let ext = Path(filePath).extension,
                          ALLOWED_EXTENSIONS.contains(ext)
                    else {
                        return
                    }
                    guard let fullPath = try file.fullPath(sourceRoot: path.parent()) else {
                        return
                    }
                    filePathsForParsing.append(fullPath)
                }
                try self.parseFiles(filePathsForParsing: filePathsForParsing,
                                    targetName: target.name,
                                    spinner: spinner)
                self.concurrentStream.success(spinner: spinner,
                                              "Parsed \(filePathsForParsing.count) \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files")
            }
            catch {
                self.concurrentStream.error(spinner: spinner,
                                            "Error parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files: \(CliSyntaxColor.RED)\(error)\(CliSyntaxColor.END)")
            }
        }

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.waitAndShowCursor()

        print("---")
    }
}
