//
//  SettingsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 28.11.17.
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
import Firebase

final class SettingsViewController: UIViewController {
    
    // MARK: - Private Properties
    private var settingsTableViewController: SettingsTableViewController?
    private var rotationDuration: TimeInterval = 0.0
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    // MARK: - Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if let viewController = segue.destination as? SettingsTableViewController,
            segue.identifier == "EmbedSettingsTable" {
            settingsTableViewController = viewController
            
            viewController.delegate = self
        }
    }
    
    override func shouldPerformSegue(
        withIdentifier identifier: String,
        sender: Any?
    ) -> Bool { identifier == "EmbedSettingsTable" || settingsValidated() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupSaveButton()
        
        hideKeyboardOnTap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupColorScheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
           NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        view.endEditing(true)
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
            alongsideTransition: { context in
                self.rotationDuration = context.transitionDuration
            }
        )
    }
    
    // MARK: - Methods
    func setupColorScheme() {
        view.backgroundColor = backgroundViewColour
        
        saveButton.backgroundColor = saveButtonBackgroundColour
        saveButton.setTitleColor(saveButtonTitleColour, for: .normal)
    }
    
    // MARK: - Private methods
    private func setupNavigationItem() {
        navigationItem.setHidesBackButton(true, animated: false)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = navigationBarTitleImageViewImage
        imageView.accessibilityLabel = "Webim logo".localized
        imageView.accessibilityTraits = .header
        
        navigationItem.titleView = imageView
    }

    @objc
    private func onBackButtonClick(sender: UIButton) {
        if settingsValidated() {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func keyboardWillChange(_ notification: Notification) {
        guard let keyboardDurationEmergenceAnimation = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
                as? TimeInterval,
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    as? NSValue
            else { return }

        var animationDuration: TimeInterval = keyboardDurationEmergenceAnimation
        var keyboardHeight: CGFloat = view.frame.maxY - keyboardFrame.cgRectValue.minY
        
        if animationDuration == 0 {
            if keyboardHeight == 0 {
                return
            }
            keyboardHeight = 0
            animationDuration = rotationDuration
        }
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                if keyboardHeight > 0 {
                    // Keyboard is visible
                    self.bottomConstraint.constant = 8.0 + keyboardHeight
                } else {
                    // Keyboard is hidden
                    self.bottomConstraint.constant = 8.0
                }
                
                self.view.layoutIfNeeded()
                if keyboardHeight > 0 {
                    self.settingsTableViewController?.scrollToBottom(animated: false)
                }
            }
        )
    }
    
    private func settingsValidated() -> Bool {
        guard let accountName = settingsTableViewController?.accountNameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !accountName.isEmpty else {
                alertDialogHandler.showSettingsAlertDialog(
                    withMessage: "Account name can't be empty".localized
                )
                return false
        }
        guard let location = settingsTableViewController?.locationTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !location.isEmpty else {
                alertDialogHandler.showSettingsAlertDialog(
                    withMessage: "Location can't be empty".localized
                )
                return false
        }
        
        set(accountName: accountName,
            location: location,
            pageTitle: settingsTableViewController?.pageTitleTextField.text)
        
        return true
    }
    
    private func set(
        accountName: String,
        location: String,
        pageTitle: String?
    ) {
        Settings.shared.accountName = accountName
        Crashlytics.crashlytics().setCustomValue(accountName, forKey: "AccountName")
        Settings.shared.location = location
        if let pageTitle = pageTitle,
            !pageTitle.isEmpty {
            Settings.shared.pageTitle = pageTitle
        }
        Settings.shared.save()
    }
    
    private func setupSaveButton() {
        saveButton.layer.borderWidth = 0
        saveButton.layer.borderColor = saveButtonBorderColour
        saveButton.layer.cornerRadius = 8.0
    }
}
