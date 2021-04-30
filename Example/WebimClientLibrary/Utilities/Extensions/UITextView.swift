//
//  UITextView.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 24.02.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

extension UITextView {
    public func updateText(_ text: String) {
        self.text = text
        // Workaround to trigger textViewDidChange
        self.replace(
            self.textRange(
                from: self.beginningOfDocument,
                to: self.endOfDocument) ?? UITextRange(),
                withText: text
        )
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
}
