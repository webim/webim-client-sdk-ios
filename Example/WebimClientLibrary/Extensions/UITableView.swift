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
    
    /**
     Sets text message to table view background view to show if table view is empty.
     Code example inside `numberOfSections(in tableView:)`:
     ```
     if rows.count > 0 {
        return 1
     } else {
        tableView.emptyTableView(message: "Table is empty.")
     
        return 0
     }
     ```
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func emptyTableView(message: NSAttributedString) {
        let messageLabel = UILabel(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        messageLabel.attributedText = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
}
