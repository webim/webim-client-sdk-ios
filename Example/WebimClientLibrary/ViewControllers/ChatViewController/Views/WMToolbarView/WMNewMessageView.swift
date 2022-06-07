//
//  WMNewMessageView.swift
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

import Foundation
import UIKit
import WebimClientLibrary

protocol WMNewMessageViewDelegate: AnyObject {
    func inputTextChanged()
    func sendMessage()
    func showSendFileMenu(_ sender: UIButton)
}

class WMNewMessageView: UIView {
    
    static let maxInputTextViewHeight: CGFloat = 90
    static let minInputTextViewHeight: CGFloat = 344
    
    weak var delegate: WMNewMessageViewDelegate?
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet private var fileButton: UIButton!
    @IBOutlet private var messagePlaceholder: UILabel!
    @IBOutlet var messageText: UITextView!
    
    @IBOutlet private var inputTextFieldConstraint: NSLayoutConstraint!
    
    func resignMessageViewFirstResponder() {
        self.messageText.resignFirstResponder()
    }
    
    func getMessage() -> String {
        return self.messageText.text
    }
    
    func setMessageText(_ message: String) {
        self.messageText.text = message
        // Workaround to trigger textViewDidChange
        self.messageText.replace(
            self.messageText.textRange(
                from: self.messageText.beginningOfDocument,
                to: self.messageText.endOfDocument) ?? UITextRange(),
            withText: message
        )
        recountViewHeight()
    }
    
    func recountViewHeight() {
        let size = messageText.sizeThatFits(CGSize(width: messageText.frame.width, height: CGFloat(MAXFLOAT)))
        inputTextFieldConstraint.constant = min(size.height, WMNewMessageView.maxInputTextViewHeight)
    }
    
    override func loadXibViewSetup() {
        messageText.layer.cornerRadius = 17
        messageText.layer.borderWidth = 1
        messageText.layer.borderColor = wmGreyMessage
        messageText.isScrollEnabled = true
        messageText.textColor = .black
        messageText.contentInset.left = 10
        messageText.textContainerInset.right = 40
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: 1)
        topBorder.backgroundColor = wmGreyMessage
        layer.addSublayer(topBorder)
        messageText.delegate = self

        translatesAutoresizingMaskIntoConstraints = false
        recountViewHeight()
    }
    
    var textInputTextViewBufferString: String?
    var alreadyPutTextFromBufferString = false
    
    @IBAction func sendMessage() {
        self.delegate?.sendMessage()
    }
    
    @IBAction func sendFile(_ sender: UIButton) {
        self.delegate?.showSendFileMenu(sender)
    }
    
    func insertText(_ text: String) {
        self.messageText.replace(self.messageText.selectedRange.toTextRange(textInput: self.messageText)!, withText: text)
    }
}

extension WMNewMessageView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        showHidePlaceholder(in: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        recountViewHeight()
        showHidePlaceholder(in: textView)
        self.delegate?.inputTextChanged()
    }
    
    func showHidePlaceholder(in textView: UITextView) {
        let check = textView.hasText && !textView.text.isEmpty
        messageText.layer.borderColor = check ? wmLayerColor : wmGreyMessage
        messagePlaceholder.isHidden = check
        sendButton.isEnabled = check
    }
}
