//
//  StartViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 01.00.2017.
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
import WebimClientLibrary

final class StartViewController: UIViewController, DepartmentListHandlerDelegate {
    
    // MARK: - Private Properties
    private var unreadMessageCounter: Int = 0
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    // MARK: - Outlets
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var welcomeTextView: UITextView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var unreadMessageCounterView: UIView!
    @IBOutlet weak var unreadMessageCounterLabel: UILabel!
    @IBOutlet weak var unreadMessageCounterActivity: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        // Workaround for displaying correctly the position of the text inside weclomeTextView
        DispatchQueue.main.async {
            self.welcomeTextView.setTextWithHyperLinks(self.welcomeTextView.text.localized)
            self.welcomeTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
        
        setupColorScheme()
        
        startWebimSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStartChatButton()
        setupSettingsButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func unwindFromSettings(_: UIStoryboardSegue) {
        // No need to do anything.
    }
    
    // MARK: - Private methods
    private func setupStartChatButton() {
        startChatButton.layer.cornerRadius = 8.0
        startChatButton.layer.borderWidth = 1.0
        startChatButton.layer.borderColor = startChatButtonBorderColour
    }
    
    private func setupSettingsButton() {
        settingsButton.layer.cornerRadius = 8.0
        settingsButton.layer.borderWidth = 1.0
    }
    
    private func setupColorScheme() {
        view.backgroundColor = startViewBackgroundColour

        // Fixing 'shadow' on top of the main colour
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = navigationBarBarTintColour
        
        navigationController?.navigationBar.tintColor = navigationBarTintColour
        welcomeLabel.textColor = welcomeLabelTextColour

        welcomeTextView.textColor = welcomeTextViewTextColour
        welcomeTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: welcomeTextViewForegroundColour
        ]

        startChatButton.backgroundColor = startChatButtonBackgroundColour
        startChatButton.setTitleColor(startChatTitleColour, for: .normal)
        
        settingsButton.setTitleColor(settingsButtonTitleColour, for: .normal)
        
        settingsButton.layer.borderColor = settingButtonBorderColour
    }
    
    private func updateMessageCounter() {
        DispatchQueue.main.async {
            if self.unreadMessageCounter > 0 {
                self.unreadMessageCounterView.alpha = 1
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
                self.unreadMessageCounterActivity.stopAnimating()
                self.unreadMessageCounterLabel.fadeTransition(0.2)
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
            } else {
                self.unreadMessageCounterView.alpha = 0
            }
            
        }
    }
    
    private func startWebimSession() {
        WebimServiceController.currentSession.set(unreadByVisitorMessageCountChangeListener: self)
        WebimServiceController.shared.fatalErrorHandlerDelegate = self
        unreadMessageCounter = WebimServiceController.currentSession.getUnreadMessagesByVisitor()
        updateMessageCounter()
    }
}

// MARK: - WEBIM: MessageListener
extension StartViewController: UnreadByVisitorMessageCountChangeListener {
    
    // MARK: - Methods
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        if unreadMessageCounter == 0 {
            DispatchQueue.main.async {
                self.unreadMessageCounterActivity.stopAnimating()
            }
        }
        unreadMessageCounter = newValue
        updateMessageCounter()
    }
    
}

// MARK: - FatalErrorHandler
extension StartViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        alertDialogHandler.showCreatingSessionFailureDialog(withMessage: message)
    }
    
}
