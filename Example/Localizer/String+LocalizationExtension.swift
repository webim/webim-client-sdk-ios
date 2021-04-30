//
//  String+Extension.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Cocoa

extension String {
    
    // MARK: - Properties
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    var pathExtension: String {
        return fileURL.pathExtension
    }
    
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
    
    func nameWithoutExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
    
    func getLocale() -> String {
        
        let pathElements = self.split(separator: "/")
        return String(pathElements[pathElements.count - 2])
    }
    
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
              !range.isEmpty {
            
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    
    func substring(_ from: Int, to: Int) -> String {
        let start = self.index(startIndex, offsetBy: from)
        let end = self.index(startIndex, offsetBy: to)
        return String(self[start..<end])
    }
    
    func padRight(length: Int) -> String {
        if self.count >= length {
            return self
        }
        return self.padding(toLength: length, withPad: " ", startingAt: 0)
    }
    
    func writeToFile(_ filePath: String) {
        
        let fileUrl = URL(fileURLWithPath: filePath)
        do {
            try self.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
            print("Failed writing to URL: \(fileUrl), Error: " + error.localizedDescription)
        }
    }
}
