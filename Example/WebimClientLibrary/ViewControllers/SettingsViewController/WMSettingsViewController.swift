//
//  WMSettingsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 31.12.2021.
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

class WMSettingsViewController: UIViewController {
    
    // Text fields
    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var pageTitleTextField: UITextField!
    @IBOutlet var userDataJsonTextView: UITextView!
    
    // Text fields error hints
    @IBOutlet var accountNameHintLabel: UILabel!
    @IBOutlet var locationHintLabel: UILabel!
    
    // Editing/error views
    @IBOutlet var accountNameView: UIView!
    @IBOutlet var locationView: UIView!
    @IBOutlet var pageTitleView: UIView!
    @IBOutlet var accountNameInfoButton: UIButton!
    // tableView
    var cells = [UITableViewCell]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var accountNameCell: UITableViewCell!
    @IBOutlet var locationCell: UITableViewCell!
    @IBOutlet var pageTitleCell: UITableViewCell!
    @IBOutlet var accountFooterCell: UITableViewCell!
    @IBOutlet var userDataJsonCell: UITableViewCell!
    
    // MARK: - Private Properties
    var rotationDuration: TimeInterval = 0.0
    
    lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    // MARK: - Outlets
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = [accountNameCell, locationCell, pageTitleCell, accountFooterCell, userDataJsonCell]
        WebimServiceController.shared.stopSession()
        accountNameTextField.text = Settings.shared.accountName
        locationTextField.text = Settings.shared.location
        pageTitleTextField.text = Settings.shared.pageTitle
        userDataJsonTextView.text = Settings.shared.userDataJson
        accountNameTextField.placeholder = Settings.shared.accountName
        locationTextField.placeholder = Settings.shared.location
        
        setupLabels()
        setupTextFields()
        
        setupNavigationItem()
        setupSaveButton()
        
        hideKeyboardOnTap()
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
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            if let startViewController = navigationController.viewControllers.first as? WMStartViewController {
                startViewController.startChatButton.isHidden = false
            }
        }
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
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupColorScheme()
    }
    
    @IBAction func showAlertForAccountName(_ sender: Any) {
        alertDialogHandler.showAlertForAccountName()
    }
    // MARK: - Methods
    @objc
    func scrollToBottom(animated: Bool) {
        let row = (tableView.numberOfRows(inSection: 0)) - 1
        let bottomMessageIndex = IndexPath(row: row, section: 0)
        tableView.scrollToRowSafe(at: bottomMessageIndex, at: .bottom, animated: animated)
    }
    
//    @objc
//    func scrollToTop(animated: Bool) {
//        let indexPath = IndexPath(row: 0, section: 0)
//        self.tableView.scrollToRowSafe(at: indexPath, at: .top, animated: animated)
//    }
    
    @objc func stoppedTyping(textField: UITextField) {
        
        if textField == pageTitleTextField {
            if let text = textField.text?.trimWhitespacesIn(), text.isEmpty {
                textField.text = "iOS demo app"
            }
        }
    }
    
    @objc
    func toogleTestMode() {
        let message = WMTestManager.toogleTestMode() ? "Test mode enabled" : "Test mode disabled"
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction @objc
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
                if keyboardHeight > 0 && self.userDataJsonTextView.isFirstResponder {
                    self.scrollToBottom(animated: false)
                }
            }
        )
    }
    
    private func settingsValidated() -> Bool {
        guard let accountName = accountNameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !accountName.isEmpty else {
                alertDialogHandler.showSettingsAlertDialog(
                    withMessage: "Account name can't be empty".localized
                )
                return false
        }
        guard let location = locationTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !location.isEmpty else {
                alertDialogHandler.showSettingsAlertDialog(
                    withMessage: "Location can't be empty".localized
                )
                return false
        }
        if !accountName.validateURLString() {
            alertDialogHandler.showSettingsAlertDialog(
                withMessage: "Account name has invalid characters".localized
            )
            return false
        }
        saveSettings(accountName: accountName,
                     location: location,
                     pageTitle: pageTitleTextField.text,
                     userDataJson: userDataJsonTextView.text)
        
        return true
    }
    
    private func saveSettings(
        accountName: String,
        location: String,
        pageTitle: String?,
        userDataJson: String?
    ) {
        Settings.shared.accountName = accountName
        Settings.shared.location = location
        Settings.shared.userDataJson = userDataJson ?? ""
        if let pageTitle = pageTitle,
            !pageTitle.isEmpty {
            Settings.shared.pageTitle = pageTitle
        }
        Settings.shared.save()
    }
    
    func setupSaveButton() {
        saveButton.layer.borderWidth = 0
        saveButton.layer.borderColor = saveButtonBorderColour
        saveButton.layer.cornerRadius = 8.0
    }
    
}

extension WMSettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let newText = self.accountNameTextField.text ?? ""
        let filtred = newText.filter { !"|{}%^\\<>&?*".contains($0) }
        if newText != filtred {
            self.accountNameTextField.text = filtred
        }
        showHint(textField)
    }
    
    func showHint(_ textField: UITextField) {
        var hintLabel: UILabel?
        var editView: UIView?
        
        if textField == accountNameTextField {
            editView = accountNameView
            hintLabel = accountNameHintLabel
        } else if textField == locationTextField {
            editView = locationView
            hintLabel = locationHintLabel
        } else {
            return
        }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                    text.isEmpty {
                    hintLabel?.alpha = 1.0
                    editView?.backgroundColor = editViewBackgroundColourError
                } else {
                    hintLabel?.alpha = 0.0
                    editView?.backgroundColor = editViewBackgroundColourDefault
                }
            }
        )
    }
    
}
