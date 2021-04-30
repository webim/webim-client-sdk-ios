//
//  String.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 24.01.18.
//  Copyright © 2018 Webim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

extension String {
    
    // MARK: - Properties
    var localized: String {
        return NSLocalizedString(self,
                                 comment: "")
    }

    func substring(_ nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    func addHttpsPrefix() -> String {
        if self.lowercased().hasPrefix("https://") || self.lowercased().hasPrefix("http://") {
            return self
        }
        return "https://" + self
    }
}

// MARK: -
extension String {
    
    // MARK: - Methods
    public func decodePercentEscapedLinksIfPresent() -> String {
        var convertedString = String()
        
        let checkingTypes: NSTextCheckingResult.CheckingType = [.link]
        if let linksDetector = try? NSDataDetector(types: checkingTypes.rawValue) {
            
            // swiftlint:disable legacy_constructor
            let linkMatches = linksDetector.matches(in: self,
                                                    range: NSMakeRange(0,
                                                                       self.count))
            // swiftlint:enable legacy_constructor
            if !linkMatches.isEmpty {
                var position = 0
                
                for linkMatch in linkMatches {
                    let linkMatchRange = linkMatch.range
                    if let url = linkMatch.url {
                        let beforeLinkStringSliceRangeStart = self.index(self.startIndex,
                                                                         offsetBy: position)
                        let beforeLinkStringSliceRangeEnd = self.index(self.startIndex,
                                                                       offsetBy: linkMatchRange.location)
                        let beforeLinkStringSlice = String(self[beforeLinkStringSliceRangeStart ..< beforeLinkStringSliceRangeEnd])
                        convertedString += beforeLinkStringSlice
                        
                        position = linkMatchRange.location + linkMatchRange.length
                        
                        let urlString = url.absoluteString.removingPercentEncoding
                        if let urlString = urlString {
                            convertedString += urlString
                        } else {
                            let linkStringSliceRangeStart = self.index(self.startIndex,
                                                                       offsetBy: linkMatchRange.location)
                            let linkStringSliceRangeEnd = self.index(self.startIndex,
                                                                     offsetBy: linkMatchRange.length)
                            convertedString += String(self[linkStringSliceRangeStart ..< linkStringSliceRangeEnd])
                        }
                    }
                }
                
                let closingStringSliceRangeStart = self.index(self.startIndex,
                                                              offsetBy: position)
                let closingStringSliceRangeEnd = self.index(self.startIndex,
                                                            offsetBy: self.count)
                let closingStringSlice = String(self[closingStringSliceRangeStart ..< closingStringSliceRangeEnd])
                convertedString += closingStringSlice
            } else {
                return self
            }
        }
        
        return convertedString
    }
    
    public func trimWhitespacesIn() -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
}
