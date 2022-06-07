//
//  WMFileQuoteTableViewCell.swift
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

class WMQuoteFileCell: FileMessage {
    @IBOutlet var messageTextView: UITextView!
    
    @IBOutlet var quoteAuthorName: UILabel!
    @IBOutlet var quoteMessageText: UILabel!
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        self.isForOperator = true
        var fileSize: Int64 = -1
        
        if let attachment = message.getQuote()?.getMessageAttachment(),
           let fileURL = attachment.getURL() {
            fileSize = attachment.getSize() ?? -1
            self.documentDownloadTask = WMDocumentDownloadTask.documentDownloadTaskFor(url: fileURL, fileSize: fileSize, delegate: self)
        }
        self.quoteAuthorName.text = message.getQuote()?.getSenderName()
        
        let checkLink = self.messageTextView.setTextWithReferences(message.getText(), alignment: .left)
        self.messageTextView.isUserInteractionEnabled = true
        for recognizer in messageTextView.gestureRecognizers ?? [] {
            if recognizer.isKind(of: UITapGestureRecognizer.self) && !checkLink {
                recognizer.delegate = self
            }
            if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                recognizer.isEnabled = false
            }
        }
        self.quoteMessageText.text = message.getData()?.getAttachment()?.getFileInfo().getFileName()
        self.fileDownloadIndicator?.isHidden = true
        self.downloadStatusLabel?.text = ""
    
        self.quoteMessageText?.text = FileMessage.byteCountFormatter.string(fromByteCount: fileSize)
        
        // case sent
        
        switch message.getSendStatus() {
        case .sent:
            resetFileStatus()
        case .sending:
            self.fileDescription?.text = "Sending".localized
            self.fileStatus.setBackgroundImage( UIImage(named: "FileDownloadButton")!, for: .normal )
            self.fileStatus.isUserInteractionEnabled = false
        }
    }
    
}
