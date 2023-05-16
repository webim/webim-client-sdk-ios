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

    //constraints
    @IBOutlet var accountNameViewHeightContsraint: NSLayoutConstraint!
    @IBOutlet var locationViewHeightContsraint: NSLayoutConstraint!
    @IBOutlet var pageTitleViewHeightContsraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    var rotationDuration: TimeInterval = 0.0
    
    lazy var alertDialogHandler = UIAlertHandler(delegate: self)

    fileprivate lazy var validCharactersForTextfields: Set<Character> = [
        "A", "a", "B", "b", "C", "c", "D", "d",
        "E", "e", "F", "f", "G", "g", "H", "h",
        "I", "i", "J", "j", "K", "k", "L", "l",
        "M", "m", "N", "n", "O", "o", "P", "p",
        "Q", "q", "R", "r", "S", "s", "T", "t",
        "U", "u", "V", "v", "W", "w", "X", "x",
        "Y", "y", "Z", "z",
        "1", "2", "3", "4", "5", "6", "7", "8",
        "9", "0",
        ":", "/", ".", "-", "_"
    ]
    
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
        
        setupLabels()
        setupTextFieldsDelegate()
        
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
        updateNavigationBar()
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
                textField.text = "iOS app"
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
    
    @objc
    private func onBackButtonClick(sender: UIButton) {
        let isAccountNameValid = validateTextField(accountNameTextField)
        let islocationValid = validateTextField(locationTextField)

        if isAccountNameValid &&
            islocationValid {
            saveSettings(accountName: accountNameTextField.text ?? "",
                         location: locationTextField.text ?? "",
                         pageTitle: pageTitleTextField.text,
                         userDataJson: userDataJsonTextView.text)
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

        let animationDuration: TimeInterval = keyboardDurationEmergenceAnimation
        let keyboardHeight: CGFloat = view.frame.maxY - keyboardFrame.cgRectValue.minY

        keyboardWillStartAnimate(animationDuration: animationDuration, keyboardHeight: keyboardHeight)
    }
    
    private func validateTextField(_ textField: UITextField) -> Bool {
        if let currentText = textField.text, !currentText.isEmpty {
            if !isTextContainsInvalidChar(currentText) {
                updateHint(
                    for: textField,
                    hintState: .common)
                return true
            } else {
                updateHint(
                    for: textField,
                    hintLabelTextType: .invalidChar,
                    hintState: .error)
                return false
            }
        } else {
            updateHint(
                for: textField,
                hintLabelTextType: .empty,
                hintState: .error)
            return false
        }
    }

    private func isTextContainsInvalidChar(_ currentText: String) -> Bool {
        for currentChar in currentText {
            if !validCharactersForTextfields.contains(currentChar) {
                return true
            }
        }
        return false
    }

    private func updateHint(
        for textField: UITextField,
        hintLabelTextType type: HintLabelTextType? = nil,
        hintState: TextFieldHintState
    ) {
        updateHintText(type: type, for: textField)

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.changeHintState(textField: textField, to: hintState)
            }
        )
    }

    private func updateHintText(type: HintLabelTextType?, for textField: UITextField) {
        guard let type = type else {
            return
        }
        if textField == accountNameTextField {
            switch type {
            case .empty:
                accountNameHintLabel.text = "* Account name can't be empty.".localized
            case .invalidChar:
                accountNameHintLabel.text = "Account name has invalid characters".localized
            }
        } else if textField == locationTextField {
            switch type {
            case .empty:
                locationHintLabel.text = "* Location can't be empty.".localized
            case .invalidChar:
                locationHintLabel.text = "Location has invalid characters".localized
            }
        }
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
        if let pageTitle = pageTitle {
            Settings.shared.pageTitle = pageTitle
        }
        Settings.shared.save()
    }
    
    func setupSaveButton() {
        saveButton.layer.borderWidth = 0
        saveButton.layer.borderColor = saveButtonBorderColour
        saveButton.layer.cornerRadius = 8.0
        setupSaveButtonGesture()
    }

    private func setupSaveButtonGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onBackButtonClick)
        )
        saveButton.addGestureRecognizer(tapGesture)
    }
}

extension WMSettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeHintState(textField: textField, to: .editing)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        changeHintState(textField: textField, to: .common)
    }

    private func changeHintState(textField: UITextField, to type: TextFieldHintState) {
        var currentView: UIView?
        var currentHintLabel: UILabel?
        var currentHeightConstraint: NSLayoutConstraint?
        if textField == accountNameTextField {
            currentView = accountNameView
            currentHintLabel = accountNameHintLabel
            currentHeightConstraint = accountNameViewHeightContsraint
        } else if textField == locationTextField {
            currentView = locationView
            currentHintLabel = locationHintLabel
            currentHeightConstraint = locationViewHeightContsraint
        } else if textField == pageTitleTextField {
            currentView = pageTitleView
            currentHeightConstraint = pageTitleViewHeightContsraint
        }
        switch type {
        case .common:
            currentView?.backgroundColor = editViewBackgroundColourDefault
            currentHintLabel?.alpha = 0.0
            currentHeightConstraint?.constant = 1
        case .editing:
            currentView?.backgroundColor = editViewBackgroundColourEditing
            currentHintLabel?.alpha = 0.0
            currentHeightConstraint?.constant = 2
        case .error:
            currentView?.backgroundColor = editViewBackgroundColourError
            currentHintLabel?.alpha = 1.0
            currentHeightConstraint?.constant = 2
        }
    }

    private func keyboardWillStartAnimate(animationDuration: TimeInterval, keyboardHeight: CGFloat) {
        UIView.animate(
            withDuration: animationDuration,
            animations: { [weak self] in
                guard let self = self else { return }
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

    private func updateNavigationBar() {
        NavigationBarUpdater.shared.update(with: .defaultStyle)
        NavigationBarUpdater.shared.set(isNavigationBarVisible: true)
    }
}

enum HintLabelTextType {
    case empty
    case invalidChar
}

enum TextFieldHintState {
    case common
    case editing
    case error
}
