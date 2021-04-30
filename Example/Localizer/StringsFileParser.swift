//
//  StringsFileParser.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Cocoa

// swiftlint:disable force_unwrapping
class StringsFileParser: NSObject {
    
    static func getKeysFromStringsFile(text: String) -> [String: String] {
        
        let lines = text.split(whereSeparator: \.isNewline)
        
        var dict = [String: String]()
        for line in lines {
            if line.starts(with: "\"") {
                var quotesIndexes = String(line).indicesOf(string: "\"")
                let escapedQuotesIndexes = String(line).indicesOf(string: "\\\"")
                
                quotesIndexes = quotesIndexes.filter { !escapedQuotesIndexes.contains($0 - 1) }
                if quotesIndexes.count >= 4 {
                    let key = String(line).substring(quotesIndexes[0] + 1, to: quotesIndexes[1])
                    let value = String(line).substring(quotesIndexes[2] + 1, to: quotesIndexes[3])
                    dict[key] = value
                }
            }
        }
        return dict
    }
    
    static func getXibKeysFromFile(filePath: String) -> [String: String] {
        let text = ShellWrapper.generateStringsFileForXib(filePath)
        return getKeysFromStringsFile(text: text)
    }
    
    static func getCodeKeysFromFile(filePath: String) -> [String] {
        var keys = [String]()
        let fileText = ShellWrapper.readUTF8File(filePath)
        let lines = fileText.split(whereSeparator: \.isNewline)
        for line in lines.reversed() { // only single line values
            if line.contains(".localized") {
                
                let localizedIndexes = String(line).indicesOf(string: "\".localized")
                var quotesIndexes = String(line).indicesOf(string: "\"")
                let escapedQuotesIndexes = String(line).indicesOf(string: "\\\"")
                
                quotesIndexes = quotesIndexes.filter { !escapedQuotesIndexes.contains($0 - 1) }

                for localizedIndex in localizedIndexes {
                    if quotesIndexes.contains(localizedIndex) {
                        let arrayIndex = quotesIndexes.firstIndex(of: localizedIndex)
                        if let arrayIndex = arrayIndex {
                            if arrayIndex > 0 {
                                let startIndex = quotesIndexes[arrayIndex - 1]
                                let localizedValue = String(line).substring(startIndex + 1, to: localizedIndex)
                                if !localizedValue.isEmpty {
                                    keys.append(localizedValue)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
        return keys
    }
    
    static func filesList(inFolder folder: String, withSuffix suffix: String) -> [String] {
        
        let folderUrl = URL(fileURLWithPath: folder)
        var files = [String]()
        if let enumerator = FileManager.default.enumerator(at: folderUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        if fileURL.absoluteString.hasSuffix(suffix) {
                            files.append(fileURL.path)
                        }
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
        
    }
}
// swiftlint:enable force_unwrapping
