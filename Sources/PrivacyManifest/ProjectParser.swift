//
//  ProjectParser.swift
//
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

import Spinner
import PathKit

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

class ProjectParser {
    var requiredAPIs: [RequiredReasonKey: Set<PresentedResult>] = [:]
    var requiredAPIsLock = NSLock()
    
    let concurrentStream = ConcurrentSpinnerStream()
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "parser",
                              attributes: .concurrent)
    
    var projectPath: Path
    
    init(with projectPath: Path) {
        self.projectPath = projectPath
        RequiredReasonKey.allCases.forEach { key in
            requiredAPIs[key] = Set()
        }
    }
    
    func parse() throws { }

    final func parseFiles(filePathsForParsing: [Path],
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
                requiredAPIsLock.lock()
                requiredAPIs[key]?.update(with: PresentedResult(filePath: filePath.string,
                                                                formattedLine: formattedLine,
                                                                parsedResult: parsedResult))
                requiredAPIsLock.unlock()
            }

            concurrentStream.message(spinner: spinner,
                                     "Parsing \(CliSyntaxColor.GREEN)\(targetName)'s\(CliSyntaxColor.END) source files (\(fileCount)/\(filePathsForParsing.count))...")
            fileCount += 1
        }
    }

    final func process(revealOccurrences: Bool) {
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
}

// Helper methods
extension ProjectParser {
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
