//
//  WMImageQuoteTableViewCell.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 23.12.2021.
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

class WMQuoteImageCell: WMMessageTableCell, WMFileDownloadProgressListener {
    
    @IBOutlet var messageTextView: UITextView!
    
    @IBOutlet var quoteMessageText: UILabel!
    @IBOutlet var quoteAuthorName: UILabel!
    
    @IBOutlet var quoteImage: UIImageView!
    var url: URL?

    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        self.quoteImage.image = UIImage(named: "placeholder")
        self.quoteMessageText.text = message.getQuote()?.getMessageText()
        self.quoteAuthorName.text = message.getQuote()?.getSenderName()
        
        if let imageURL = message.getQuote()?.getMessageAttachment()?.getImageInfo()?.getThumbURL() {
            self.url = imageURL
            WMFileDownloadManager.shared.subscribeForImage(url: imageURL, progressListener: self)
        }
        
        let checkLink = self.messageTextView.setTextWithReferences(message.getText(), alignment: .right)
        for recognizer in messageTextView.gestureRecognizers ?? [] {
            if recognizer.isKind(of: UITapGestureRecognizer.self) && !checkLink {
                recognizer.delegate = self
            }
            if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                recognizer.isEnabled = false
            }
        }
    }
    
    func progressChanged(url: URL, progress: Float, image: UIImage?) {
        if url != self.url {
            return
        }
        if let image = image {
            self.quoteImage.image = image
        } else {
            self.quoteImage.image = UIImage(named: "placeholder")
        }
    }
    
    @objc func imageViewTapped() {
        self.delegate?.imageViewTapped(message: self.message, image: self.quoteImage.image, url: self.url)
    }

    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            let imageTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(imageViewTapped)
            )

            self.sharpCorner(view: messageView, visitor: true)
            self.quoteImage.gestureRecognizers = nil
            self.quoteImage.addGestureRecognizer(imageTapGestureRecognizer)
        }
        return setup
    }
}

class TextMessage: WMMessageTableCell {
    @IBOutlet var messageLabel: UILabel!
}
