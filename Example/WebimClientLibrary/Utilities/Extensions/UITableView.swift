//
//  UITableView.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 03.01.18.
//  Copyright © 2017 Webim. All rights reserved.
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

import UIKit

extension UITableView {
    
    // MARK: - Methods
    func emptyTableView(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        messageLabel.attributedText = NSAttributedString(string: message)
        messageLabel.textColor = textMainColour
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func scrollToRowSafe(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        if  indexPath.section >= 0 &&
            indexPath.row >= 0 &&
            self.numberOfSections > indexPath.section &&
            self.numberOfRows(inSection: indexPath.section) > indexPath.row {
            self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
}
