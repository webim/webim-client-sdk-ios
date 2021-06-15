//
//  SettingsTableView.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 16/09/2019.
//  Copyright © 2019 Webim. All rights reserved.
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

class SettingsTableViewController: UITableViewController {

    // MARK: - Properties
    weak var delegate: SettingsViewController?
    
    // MARK: - Outlets
    // Text fields
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UITextField!
    
    // Text fields error hints
    @IBOutlet weak var accountNameHintLabel: UILabel!
    @IBOutlet weak var locationHintLabel: UILabel!
    
    // Editing/error views
    @IBOutlet weak var accountNameView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var pageTitleView: UIView!
  
    // Labels
    @IBOutlet weak var accountTitlelabel: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebimServiceController.shared.stopSession()
        accountNameTextField.text = Settings.shared.accountName
        locationTextField.text = Settings.shared.location
        pageTitleTextField.text = Settings.shared.pageTitle
        
        accountNameTextField.placeholder = Settings.shared.accountName
        locationTextField.placeholder = Settings.shared.location
        
        for hintLabel in [
            accountNameHintLabel,
            locationHintLabel
        ] {
            guard let hintLabel = hintLabel else { continue }
            hintLabel.alpha = 0.0
        }
        
        for textField in [
            accountNameTextField,
            locationTextField,
            pageTitleTextField
        ] {
            guard let textField = textField else { continue }
            
            textField.addTarget(
                self,
                action: #selector(startedTyping),
                for: .editingDidBegin
            )
            textField.addTarget(
                self,
                action: #selector(stoppedTyping),
                for: .editingDidEnd
            )
            textField.delegate = self
        }
    }
    
    // MARK: - Methods
    @objc
    func scrollToBottom(animated: Bool) {
        let row = (tableView.numberOfRows(inSection: 0)) - 1
        let bottomMessageIndex = IndexPath(row: row, section: 0)
        tableView.scrollToRowSafe(at: bottomMessageIndex, at: .bottom, animated: animated)
    }
    
    @objc
    func scrollToTop(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRowSafe(at: indexPath, at: .top, animated: animated)
    }
    
    // MARK: - Private Methods
    @objc
    private func startedTyping(textField: UITextField) {
        var hintLabel: UILabel?
        var editView: UIView?
        
        if textField == accountNameTextField {
            editView = accountNameView
            hintLabel = accountNameHintLabel
        } else if textField == locationTextField {
            editView = locationView
            hintLabel = locationHintLabel
        } else {
            editView = pageTitleView
        }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                hintLabel?.alpha = 0.0
                editView?.backgroundColor = editViewBackgroundColourEditing
            }
        )
    }

    @objc
    private func stoppedTyping(textField: UITextField) {
        var hintLabel: UILabel?
        var editView: UIView?
        
        if textField == accountNameTextField {
            editView = accountNameView
            hintLabel = accountNameHintLabel
        } else if textField == locationTextField {
            editView = locationView
            hintLabel = locationHintLabel
        } else {
            editView = pageTitleView
            if let text = textField.text?.trimWhitespacesIn(), text.isEmpty {
                textField.text = "iOS demo app"
            }
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

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
