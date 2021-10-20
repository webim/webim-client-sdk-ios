//
//  SurveyViewController.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 20.04.2021.
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

protocol WMSurveyViewControllerDelegate: AnyObject {
    func sendSurveyAnswer(_ surveyAnswer: String)
    func surveyViewControllerClosed()
}

class WMSurveyViewController: UIViewController {

    weak var delegate: WMSurveyViewControllerDelegate?
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var transparentBackgroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        sendButton.layer.cornerRadius = 8
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(closeViewController))
        
        self.transparentBackgroundView?.addGestureRecognizer(touch)
    }
    
    @objc
    func closeViewController() {
        self.transparentBackgroundView?.alpha = 0
        dismiss(animated: true, completion: nil)
        self.delegate?.surveyViewControllerClosed()
    }
    
    @IBAction func close(_ sender: Any?) {
        self.closeViewController()
    }
    
    func disableSendButton() {
        self.sendButton.alpha = 0.5
        self.sendButton.isEnabled = false
    }
    
    func enableSendButton() {
        self.sendButton.alpha = 1
        self.sendButton.isEnabled = true
    }
}
