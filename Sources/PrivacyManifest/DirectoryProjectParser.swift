//
//  DirectoryProjectParser.swift
//  
//
//  Created by Stelios Petrakis on 15/4/24.
//

import Foundation

import PathKit

// Recursively rarses all the children files of the provided path, detects the
// supported files and parses them.
class DirectoryProjectParser: ProjectParser {
    override func parse() throws {
        print("---")

        let targetName = projectPath.lastComponent
        let spinner = concurrentStream.createSilentSpinner(with: "Parsing \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files...")
        concurrentStream.start(spinner: spinner)
        do {
            var filePathsForParsing: [Path] = []
            try self.projectPath.recursiveChildren().forEach { path in
                guard let ext = path.extension,
                      ALLOWED_EXTENSIONS.contains(ext) else {
                    return
                }
                filePathsForParsing.append(path)
            }
            try self.parseFiles(filePathsForParsing: filePathsForParsing,
                                targetName: targetName,
                                spinner: spinner)
            self.concurrentStream.success(spinner: spinner,
                                          "Parsed \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files")
        }
        catch {
            self.concurrentStream.error(spinner: spinner,
                                        "Error parsing \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files: \(CliSyntaxColor.RED)\(error)\(CliSyntaxColor.END)")
        }

        _ = group.wait(timeout: .distantFuture)
        concurrentStream.waitAndShowCursor()
    }
}
