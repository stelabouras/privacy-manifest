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

class XcodeProjectParser: ProjectParser {
    override func parse() throws {
        let xcodeproj = try XcodeProj(path: projectPath)

        print("---")

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
                let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase...")
                concurrentStream.start(spinner: spinner)
                queue.async(group: group,
                            execute: DispatchWorkItem(block: {
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
                            self.updateRequiredAPIs(value,
                                                    with: PresentedResult(filePath: foundInBuildPhase))
                        }
                    })
                    self.concurrentStream.success(spinner: spinner,
                                                  "Parsed \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) Frameworks Build Phase")
                }))
            }

            let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(target.name)'s\(CliSyntaxColor.END) source files...")
            concurrentStream.start(spinner: spinner)
            queue.async(group: group,
                        execute: DispatchWorkItem(block: {
                do {
                    var filePathsForParsing: [Path] = []
                    try target.sourceFiles().forEach { file in
                        guard let path = file.path,
                              let ext = Path(path).extension,
                              ALLOWED_EXTENSIONS.contains(ext)
                        else {
                            return
                        }
                        guard let fullPath = try file.fullPath(sourceRoot: self.projectPath.parent()) else {
                            return
                        }
                        filePathsForParsing.append(fullPath)
                    }
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

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.waitAndShowCursor()
    }
}
