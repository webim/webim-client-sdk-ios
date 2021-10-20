//
//  SurveyCommentViewCointroller.swift
//  WebimClientLibrary_Example
//
//  Created by Возлеев Юрий on 11.03.2021.
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

import AVFoundation
import UIKit

class SurveyCommentViewController: WMSurveyViewController {
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var commentTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var commentTextView: TextViewWithPlaceholder!
    
    var descriptionText: String?
    var commentMessage: String?

    @IBOutlet var contentViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTextView.setPlaceholder("Enter your comment".localized, placeholderColor: WMSurveyCommentPlaceholderColor)
        self.setupSubviews()
        self.hideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.textViewDidChange(self.commentTextView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        self.textViewDidChange(self.commentTextView)
    }

    func fixContentViewWidth() {
        self.contentViewWidthConstraint?.constant = WMInterfaceData.shared.screenWidth()
    }
    
    func checkHeightConstraints() {
        fixContentViewWidth()
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            
            let contentHeight = self.recountContentViewHeight()
            var greyViewHeight = max(WMInterfaceData.shared.screenHeight() - contentHeight, 0)
            if greyViewHeight < 100 {
                if WMInterfaceData.shared.screenHeight() < 450 {
                    greyViewHeight = 0
                } else {
                    greyViewHeight = 100
                }
            }
            var frame = self.scrollView.frame
            frame.origin.x = 0
            frame.origin.y = greyViewHeight
            frame.size.height = WMInterfaceData.shared.screenHeight() - greyViewHeight
            frame.size.width = WMInterfaceData.shared.screenWidth()
            self.scrollView.frame = frame
        }
        
    }
    
    @objc
    func rotated() {
        textViewDidChange(self.commentTextView)
        
        var testRect = self.commentLabel.frame
        testRect.origin.y -= 5
        testRect.size.height = self.view.frame.height
        scrollView?.scrollRectToVisible(testRect, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commentTextView.becomeFirstResponder()
    }
    
    @IBAction private func send(_ sender: Any) {
        
        self.delegate?.sendSurveyAnswer(commentTextView.text ?? "")
        self.closeViewController()
    }
    
    private func setupSubviews() {
        descriptionLabel.text = descriptionText
    }
    func recountContentViewHeight() -> CGFloat {
        
        var contentViewHeight = self.contentView.frame.height - self.commentTextView.frame.height + WMInterfaceData.shared.keyboardHeight()
        let textViewHeight = commentTextView.sizeThatFits(CGSize(width: commentTextView.frame.width, height: CGFloat(MAXFLOAT))).height
        commentTextViewHeightConstraint.constant = textViewHeight
        contentViewHeight += textViewHeight
        scrollView.contentSize = CGSize(width: 320, height: contentViewHeight)
        return contentViewHeight
    }
}

extension SurveyCommentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.commentTextView.textViewDidChange()
        checkHeightConstraints()
    }
    
}
