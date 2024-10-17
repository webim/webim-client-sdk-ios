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
import WebimMobileSDK

class WMSettingsViewController: UIViewController {
    
    // Text fields
    @IBOutlet var accountNameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    
    // Text fields error hints
    @IBOutlet var accountNameHintLabel: UILabel!
    @IBOutlet var locationHintLabel: UILabel!
    
    // Editing/error views
    @IBOutlet var accountNameView: UIView!
    @IBOutlet var locationView: UIView!
    @IBOutlet var accountNameInfoButton: UIButton!
    @IBOutlet var accountNameTitleLabel: UILabel!
    @IBOutlet var locationTitleLabel: UILabel!
    
    // Select User cell
    lazy var selectVisitorCell = SelectVisitorTableViewCell.loadXibView()
    
    // tableView
    var dataSource: [Section: [UITableViewCell]] = [:]
    @IBOutlet var tableView: UITableView!
    @IBOutlet var accountNameCell: UITableViewCell!
    @IBOutlet var locationCell: UITableViewCell!
    @IBOutlet var accountHeaderView: UIView!
    @IBOutlet var userHeaderView: UIView!

    //constraints
    @IBOutlet var accountNameViewHeightContsraint: NSLayoutConstraint!
    @IBOutlet var locationViewHeightContsraint: NSLayoutConstraint!
    
    // VisitorFields
    lazy var visitorFieldsManager = WMVisitorFieldsManager()
    
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
        selectVisitorCell.delegate = self
        dataSource[.account] = [accountNameCell, locationCell]
        dataSource[.user] = [selectVisitorCell]
        
        WebimServiceController.shared.stopSession()
        accountNameTextField.text = Settings.shared.accountName
        locationTextField.text = Settings.shared.location
        
        setupLabels()
        setupTextFieldsDelegate()
        
        setupNavigationItem()
        setupSaveButton()
        setupSelectVisitorCell()
        
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
                startViewController.unreadMessageCounterView.isHidden = false
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
    
    @objc
    func toogleTestMode() {
        let message = WMTestManager.toogleTestMode() ? "Test mode enabled" : "Test mode disabled"
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func onSaveButtonClick(sender: UIButton) {
        let isAccountNameValid = validateTextField(accountNameTextField)
        let islocationValid = validateTextField(locationTextField)
        let isVisitorValid = visitorFieldsManager.isSelectedVisitorValid

        if isAccountNameValid && islocationValid && isVisitorValid {
            if Settings.shared.accountName != accountNameTextField.text {
                visitorFieldsManager.updateVisitorsData()
            }
            saveSettings(
                accountName: accountNameTextField.text ?? "",
                location: locationTextField.text ?? ""
            )
            visitorFieldsManager.updateCurrentVisitor()
            navigationController?.popViewController(animated: true)
        }
        
        if !isVisitorValid {
            showDemoVisitorAlert()
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
        
        guard let currentText = textField.text, !currentText.isEmpty else {
            updateHint(
                for: textField,
                hintLabelTextType: .empty,
                hintState: .error)
            return false
        }
        
        switch textField {
        case accountNameTextField:
            if !isAccountNameValid(with: currentText) {
                updateHint(for: textField, hintLabelTextType: .error, hintState: .error)
                return false
            } else if isTextContainsInvalidChar(currentText) {
                updateHint(for: textField, hintLabelTextType: .invalidChar, hintState: .error)
                return false
            } else {
                updateHint(for: textField, hintState: .common)
                return true
            }
        case locationTextField:
            if isTextContainsInvalidChar(currentText) {
                updateHint(for: textField, hintLabelTextType: .invalidChar, hintState: .error)
                return false
            } else {
                updateHint(for: textField, hintState: .common)
                return true
            }
        default:
            return false
        }
    }
    
    private func isAccountNameValid(with text: String) -> Bool {
        let isValidURL = URLComponents(string: text).map { components in
            let isURLType = components.scheme != nil && components.host != nil
            
            if isURLType {
                let regexPattern = #"^(https?://)?([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})(:[0-9]+)?(/.*)?$"#
                let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
                let range = NSRange(location: 0, length: text.utf16.count)
                let matches = regex.matches(in: text, options: [], range: range)
                return !matches.isEmpty
            }
            
            return components.path
                .components(separatedBy: ".")
                .filter { !$0.contains("www") }
                .count <= 1
        }
        return isValidURL == true
    }

    private func isTextContainsInvalidChar(_ currentText: String) -> Bool {
        for currentChar in currentText {
            if !validCharactersForTextfields.contains(currentChar) {
                return true
            }
        }
        return false
    }
    
    private func showDemoVisitorAlert() {
        let alert = UIAlertController(
            title: "Error".localized,
            message: "Parse demo visitor error.".localized,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ok".localized, style: .default) { [weak self] _ in
            self?.didSelect(visitor: .unauthorized)
        }
        
        alert.addAction(action)
        present(alert, animated: true)
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
            case .error:
                accountNameHintLabel.text = "Error".localized
            }
        } else if textField == locationTextField {
            switch type {
            case .empty:
                locationHintLabel.text = "* Location can't be empty.".localized
            case .invalidChar:
                locationHintLabel.text = "Location has invalid characters".localized
            case .error:
                locationHintLabel.text = "Error".localized
            }
        }
    }
    
    private func saveSettings(
        accountName: String,
        location: String
    ) {
        Settings.shared.accountName = accountName
        Settings.shared.location = location
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
            action: #selector(onSaveButtonClick)
        )
        saveButton.addGestureRecognizer(tapGesture)
    }
    
    enum Section: Int {
        case account
        case user
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
        var currentTitleLabel: UILabel?
        if textField == accountNameTextField {
            currentView = accountNameView
            currentHintLabel = accountNameHintLabel
            currentHeightConstraint = accountNameViewHeightContsraint
            currentTitleLabel = accountNameTitleLabel
        } else if textField == locationTextField {
            currentView = locationView
            currentHintLabel = locationHintLabel
            currentHeightConstraint = locationViewHeightContsraint
            currentTitleLabel = locationTitleLabel
        }
        switch type {
        case .common:
            currentView?.backgroundColor = editViewBackgroundColourDefault
            currentHintLabel?.isHidden = true
            currentTitleLabel?.isHidden = false
            currentHintLabel?.alpha = 0.0
            currentHeightConstraint?.constant = 1
        case .editing:
            currentView?.backgroundColor = editViewBackgroundColourEditing
            currentHintLabel?.isHidden = true
            currentTitleLabel?.isHidden = false
            currentHintLabel?.alpha = 0.0
            currentHeightConstraint?.constant = 2
        case .error:
            currentView?.backgroundColor = editViewBackgroundColourError
            currentHintLabel?.isHidden = false
            currentTitleLabel?.isHidden = true
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
    case error
}

enum TextFieldHintState {
    case common
    case editing
    case error
}
