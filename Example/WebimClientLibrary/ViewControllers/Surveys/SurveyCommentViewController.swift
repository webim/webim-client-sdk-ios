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
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    var descriptionText: String?
    var commentMessage: String?

    @IBOutlet var transparentViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 400)

        self.setupSubviews()
        self.hideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.checkHeightConstraints()
        }
    }
    
    func checkHeightConstraints() {
        self.transparentViewHeightConstraint?.constant = self.view.frame.height > 700 ? 200 : 0
    }
    
    @objc
    func rotated() {
        var testRect = self.commentLabel.frame
        testRect.origin.y -= 5
        testRect.size.height = self.view.frame.height
        scrollView?.scrollRectToVisible(testRect, animated: true)
        checkHeightConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commentTextField.becomeFirstResponder()
    }
    
    @IBAction private func send(_ sender: Any) {
        
        self.delegate?.sendSurveyAnswer(commentTextField.text ?? "")
        self.closeViewController()
    }
    
    private func setupSubviews() {
        descriptionLabel.text = descriptionText
    }
    
}
