//
//  WMQuoteView.swift
//  Webim.Ru
//
//  Created by Anna Frolova on 16.02.2022.
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

import UIKit
import Nuke
import WebimClientLibrary

enum WMQuoteViewMode {
    case quote
    case edit
}

protocol WMQuoteViewDelegate: AnyObject {
    func cleanTextView()
}

class WMQuoteView: UIView, URLSessionDelegate {
    @IBOutlet var quoteView: UIView!
    @IBOutlet var quoteMessageText: UILabel!
    @IBOutlet var quoteAuthorName: UILabel!
    @IBOutlet var quoteImageView: UIImageView!
    @IBOutlet var quoteLine: UIView!
    @IBOutlet var fileStatus: UIButton!
    @IBOutlet var fileDownloadIndicator: CircleProgressIndicator!
    @IBOutlet var downloadStatusLabel: UILabel!
    
    weak var delegate: WMDialogCellDelegate?
    var fileSize: Int64 = 0
    var fileURL: URL?
    
    private var mode = WMQuoteViewMode.quote
    
    func currentMessage() -> String {
        return quoteMessageText.text ?? ""
    }
    
    func currentMode() -> WMQuoteViewMode {
        return mode
    }
    
    func addQuoteEditBarForMessage(_ message: Message, delegate: WMDialogCellDelegate) {
        mode = WMQuoteViewMode.edit
        self.delegate = delegate
        self.setupTextQuoteMessage(quoteText: message.getText(), quoteAuthor: String.unwarpOrEmpty(message.getSenderName()), fromOperator: message.isOperatorType())
    }
    
    func addQuoteBarForMessage(_ message: Message, delegate: WMDialogCellDelegate) {
        self.delegate = delegate
        mode = WMQuoteViewMode.quote
        if message.isText() {
            self.setupTextQuoteMessage(quoteText: message.getText(), quoteAuthor: message.getSenderName(), fromOperator: message.isOperatorType())
        } else if message.isFile() {
            guard let fileInfo = message.getData()?.getAttachment()?.getFileInfo(), let url = fileInfo.getURL(), let quoteState = message.getData()?.getAttachment()?.getState() else {
                return
            }
            if fileInfo.getImageInfo() != nil {
                self.setupImageQuoteMessage(quoteText: fileInfo.getFileName(), quoteAuthor: message.getSenderName(), url: url, fileInfo: fileInfo, fromOperator: message.isOperatorType())
            } else {
                self.setupFileQuoteMessage(quoteText: fileInfo.getFileName(), quoteAuthor: message.getSenderName(), url: url, fileInfo: fileInfo, quoteState: quoteState, openFileDelegate: delegate, fromOperator: message.isOperatorType())
            }
        }
    }
    
    func setup(_ quoteText: String, _ quoteAuthor: String, _ fromOperator: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.quoteMessageText.text = quoteText
        self.quoteAuthorName.text = quoteAuthor
        if fromOperator {
            quoteView.backgroundColor = messageBackgroundViewColourSystem
        } else {
            quoteView.backgroundColor = quoteBackgroundColor
        }
        quoteView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            quoteView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func setupTextQuoteMessage(quoteText: String, quoteAuthor: String, fromOperator: Bool) {
        self.setup(quoteText, quoteAuthor, fromOperator)
        self.quoteMessageText.text = quoteText
        self.quoteAuthorName.text = quoteAuthor
        // self.quoteMessageText.textColor = .wmDarkGray
        self.quoteImageView.isHidden = true
        self.fileStatus.isHidden = true
        self.quoteMessageText.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 12.0).isActive = true
        self.quoteAuthorName.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 12.0).isActive = true
    }
    
    func setupImageQuoteMessage(quoteText: String, quoteAuthor: String, url: URL, fileInfo: FileInfo, fromOperator: Bool) {
        self.setup(quoteText, quoteAuthor, fromOperator)
        self.fileStatus.isHidden = true
        self.quoteImageView.isHidden = false
        self.quoteMessageText.textColor = quoteBodyLabelColourVisitor
        self.quoteMessageText.leftAnchor.constraint(equalTo: self.quoteImageView.rightAnchor, constant: 10.0).isActive = true
        self.quoteAuthorName.leftAnchor.constraint(equalTo: self.quoteImageView.rightAnchor, constant: 10.0).isActive = true
        self.quoteImageView.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 8.0).isActive = true
        self.quoteImageView.accessibilityIdentifier = url.absoluteString
        let request = ImageRequest(url: url)
        if let imageContainer = ImageCache.shared[request] {
            self.quoteImageView.image = imageContainer
        } else {
            self.quoteImageView.image = loadingPlaceholderImage
        }
    }
    
    func setupFileQuoteMessage(quoteText: String, quoteAuthor: String, url: URL, fileInfo: FileInfo, quoteState: AttachmentState, openFileDelegate: WMDialogCellDelegate, fromOperator: Bool) {
        self.setup(quoteText, quoteAuthor, fromOperator)
        self.quoteImageView.isHidden = true
        self.fileStatus.isHidden = false
        self.quoteMessageText.leftAnchor.constraint(equalTo: self.fileStatus.rightAnchor, constant: 10.0).isActive = true
        self.quoteAuthorName.leftAnchor.constraint(equalTo: self.fileStatus.rightAnchor, constant: 10.0).isActive = true
        self.fileStatus.leftAnchor.constraint(equalTo: self.quoteLine.rightAnchor, constant: 8.0).isActive = true
        self.fileStatus.heightAnchor.constraint(equalTo: self.fileStatus.widthAnchor).isActive = true
        // self.quoteMessageText.textColor = .wmGray
        self.fileURL = url
        self.fileSize = fileInfo.getSize() ?? 0
    }
    
    override func loadXibViewSetup() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
        // topBorder.backgroundColor = UIColor.wmGray.cgColor
        layer.addSublayer(topBorder)
    }
    
    @IBAction func removeQuoteEditBar() {
        if mode == .edit {
            self.delegate?.cleanTextView()
        }
        self.removeFromSuperview()
    }
}
