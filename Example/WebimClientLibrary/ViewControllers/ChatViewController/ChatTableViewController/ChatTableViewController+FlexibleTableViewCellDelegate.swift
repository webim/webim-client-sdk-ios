//
//  ChatTableViewController+FlexibleTableViewCellDelegate.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 30.04.2021.
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

import UIKit
import WebimClientLibrary

extension ChatTableViewController: WMDownloadFileManagerDelegate {
    func updateImageDownloadProgress(url: URL, progress: Float, image: UIImage? ) {
        for cell in self.tableView.visibleCells {
            if let cell = cell as? FlexibleTableViewCell {
                cell.updateImageDownloadProgress(url: url, progress: progress, image: image)
            }
        }
    }
}

extension ChatTableViewController: FlexibleTableViewCellDelegate {
    
    func imageForUrl(_ url: URL) -> UIImage? {
        WMDownloadFileManager.shared.addDelegate(delegate: self)
        return WMDownloadFileManager.shared.imageForUrl(url)
    }
    
    func progressForUrl(_ url: URL) -> Float {
        return WMDownloadFileManager.shared.progressForURL(url)
    }
}
