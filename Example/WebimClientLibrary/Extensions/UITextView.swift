//
//  UITextView.swift
//  Webim.Ru
//
//  Created by EVGENII Loshchenko on 01.03.2021.
//  Copyright © 2021 _webim_. All rights reserved.
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
import UIKit

class SearchLinkData {
    var fullLinkString: String?
    var linkDescription: String?
    var link: URL?
    var range: NSRange?
    var changedText: String?
    func setFullLinkString(fullLinkString: String?) {
        if let fullLinkString = fullLinkString {
            if let (linkDescription, link) = fullLinkString.splitOnceBySeparator("](") {
                if !fullLinkString.contains("\n") {
                    self.fullLinkString = fullLinkString
                    self.linkDescription = String(linkDescription.dropFirst(1))
                    self.link = String.openableUrlFromLink(String(link.dropLast(1)))
                }
            }
        }
    }
}

extension String {
    
    func splitOnceBySeparator(_ separator: String) -> (String, String)? {

        let elements = self.components(separatedBy: separator)
        if elements.count > 1 {
            let a = elements[0]
            let b = String(self.dropFirst(a.count + separator.count))
            return (a, b)
        }
        return nil
    }
    
    static func openableUrlFromLink(_ link: String) -> URL? {
        if link.contains(":") {
            if let url = URL(string: link) {
                if UIApplication.shared.canOpenURL(url) {
                    return url
                }
            }
        } else {
            if let url = URL(string: "https://\(link)") {
                if UIApplication.shared.canOpenURL(url) {
                    return url
                }
            }
        }
        return nil
    }
    
    static func matchesHyperLink(text: String, startingIndex: Int) -> SearchLinkData? {
        let regex = "\\[.*?\\]\\(.*?\\)"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results: [NSTextCheckingResult] = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            if let textCheckingResult = results.first(where: { $0.range.upperBound >= startingIndex }) {
                
                guard let firstRange = results.first?.range else {
                    return nil
                }
                guard let fullLinkRange = Range(textCheckingResult.range, in: text) else {
                    return nil
                }
                // swiftlint:disable all
                let range = NSMakeRange(firstRange.location, firstRange.length)
                // swiftlint:enable all
                guard let replaceTextRange = Range(range, in: text) else {
                    return nil
                }
                
                let searchData = SearchLinkData()
                searchData.range = firstRange
                searchData.setFullLinkString(fullLinkString: String(text[fullLinkRange]))
                searchData.changedText = text.replacingCharacters(in: replaceTextRange, with: searchData.linkDescription ?? "")
                searchData.range?.length = (searchData.linkDescription ?? "").count
                return searchData
            }
            return nil
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension UITextView {
    
    func updateText(_ text: String) {
        self.text = text
        // Workaround to trigger textViewDidChange
        self.replace(
            self.textRange(
                from: self.beginningOfDocument,
                to: self.endOfDocument) ?? UITextRange(),
            withText: text
        )
    }
    
    func notNilFont() -> UIFont {
        var font = UIFont()
        if let tempFont = self.font {
            font = tempFont
        }
        return font
    }
    
    func setTextWithReferences(_ originalText: String, textColor: UIColor? = nil, alignment: NSTextAlignment) -> Bool {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        
        var text = originalText
        var hyperLinkArray = [SearchLinkData]()
        
        var link = String.matchesHyperLink(text: text, startingIndex: 0)
        var linkCounter = 0
        while link != nil && linkCounter < 100 {
            linkCounter += 1
            if let nextLink = link {
                text = nextLink.changedText ?? ""
                hyperLinkArray.append(nextLink)
                link = String.matchesHyperLink(text: text, startingIndex: 0)
            }
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches: [NSTextCheckingResult] = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        var stringAttributes: [NSAttributedString.Key: AnyObject] = [ NSAttributedString.Key.font: self.notNilFont() ]
        if let textColor = textColor {
            stringAttributes[NSAttributedString.Key.foregroundColor] = textColor
            
        }
        stringAttributes[.paragraphStyle] = paragraph
        let attributedOriginalText = NSMutableAttributedString(string: text, attributes: stringAttributes)
        
        // add average links like "google.com"
        for linkRange in matches {
            guard let range = Range(linkRange.range, in: text) else { continue }
            let link = text[range]
            
            if let url = String.openableUrlFromLink("\(link)") {
                let linkRange = text.nsRange(from: range)
                attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: url, range: linkRange)
            }
        }
        
        // add hyperLinks like "[google](google.com)"
        for hyperLink in hyperLinkArray {
            
            guard let range = Range(hyperLink.range!, in: text) else { continue }
            
            if let url = hyperLink.link {
                let linkRange = text.nsRange(from: range)
                attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: url, range: linkRange)
            }
        }
        linkTextAttributes = [.foregroundColor: linkColor]
        self.attributedText = attributedOriginalText
        return !matches.isEmpty || !hyperLinkArray.isEmpty
    }
    
    func setTextWithHyperLinks(_ originalText: String) {
        
        var font = UIFont()
        if let tempFont = self.font {
            font = tempFont
        }
        let attributedOriginalText = NSMutableAttributedString(string: originalText, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: self.textColor ?? UIColor.black ])
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: originalText, options: [], range: NSRange(location: 0, length: originalText.utf16.count))
            
            for textCheckingResult in matches {
                let linkRange = textCheckingResult.range
                guard let substring = originalText.substring(linkRange) else { continue }
                let link: String = String(substring).addHttpsPrefix()
                if link.contains("@") { // skip mail
                    continue
                }
                
                attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: link, range: linkRange)
            }
        } catch {
            print("NSDataDetector error")
        }
        self.attributedText = attributedOriginalText
    }

    func removeInsets() {
        textContainer.lineFragmentPadding = 0
        contentInset = .zero
        textContainerInset = .zero
    }
    
}
