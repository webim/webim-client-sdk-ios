//
//  SettingsTableViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 07.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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

final class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var delegate: SettingsViewController?
    
    // MARK: Outlets
    
    // Text fields
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UITextField!
    
    // Text fields error hints
    @IBOutlet weak var accountNameHintLabel: UILabel!
    @IBOutlet weak var locationHintLabel: UILabel!
    
    // Text
    @IBOutlet var textFieldLabels: [UILabel]!
    
    // Color scheme
    @IBOutlet weak var classicCheckboxImageView: UIImageView! // Row 0
    @IBOutlet weak var darkCheckboxImageView: UIImageView! // Row 2
    @IBOutlet var colorSchemeNames: [UILabel]!
    
    // Table cells
    @IBOutlet weak var accountSettingsCell: UITableViewCell!
    @IBOutlet var colorThemeCells: [UITableViewCell]!
    @IBOutlet weak var delimiter: UIView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountNameTextField.text = Settings.shared.accountName
        locationTextField.text = Settings.shared.location
        pageTitleTextField.text = Settings.shared.pageTitle
        
        setupColorSchemeCheckboxes()
        setupColorScheme()
        
        for hintLabel in [accountNameHintLabel, locationHintLabel] {
            hintLabel!.alpha = 0.0
            hintLabel!.textColor =  textTextFieldErrorColor.color()
        }
        for textField in [accountNameTextField,
                          locationTextField] {
            textField!.addTarget(self,
                                 action: #selector(textDidChange),
                                 for: .editingChanged)
            textField!.layer.cornerRadius = 5.0
            textField!.layer.borderColor = textTextFieldErrorColor.color().cgColor
            textField!.delegate = self
        }
        pageTitleTextField.delegate = self
    }
    
    // MARK: UITableViewDelegate protocol methods
    
    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        view.tintColor = backgroundMainColor.color()
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { // Color theme section
            return
        }
        
        var selectedColorScheme: ColorScheme.SchemeType?
        switch indexPath.row {
        case 0:
            selectedColorScheme = .light
            
            break
        case 2:
            selectedColorScheme = .dark
            
            break
        default:
            return
        }
        
        if ColorScheme.shared.schemeType != selectedColorScheme {
            ColorScheme.shared.schemeType = selectedColorScheme!
            UIView.animate(withDuration: 0.2) {
                self.setupColorSchemeCheckboxes()
                self.setupColorScheme()
            }
        }
    }
    
    // MARK: Private mwethods
    
    private func setupColorSchemeCheckboxes() {
        switch ColorScheme.shared.schemeType {
        case .light:
            classicCheckboxImageView.alpha = 1.0
            darkCheckboxImageView.alpha = 0.0
        case .dark:
            classicCheckboxImageView.alpha = 0.0
            darkCheckboxImageView.alpha = 1.0
        }
    }
    
    private func setupColorScheme() {
        delegate?.setupColorScheme()
        
        tableView.backgroundColor = backgroundMainColor.color()
        accountSettingsCell.backgroundColor = backgroundMainColor.color()
        for cell in colorThemeCells {
            cell.backgroundColor = backgroundCellLightColor.color()
        }
        
        for label in textFieldLabels {
            label.textColor = textMainColor.color()
        }
        for label in colorSchemeNames {
            label.textColor = textCellLightColor.color()
        }
        
        for textField in [accountNameTextField,
                          locationTextField,
                          pageTitleTextField] {
            textField!.backgroundColor = backgroundTextFieldColor.color()
            textField!.textColor = textTextFieldColor.color()
            textField!.tintColor = textTextFieldColor.color()
            textField!.keyboardAppearance = ColorScheme.shared.keyboardAppearance()
        }
        
        delimiter.backgroundColor = delimiterColor.color()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusBarColor()
    }
    
    @objc
    private func textDidChange(textField: UITextField) {
        var hintLabel: UILabel?
        if textField == accountNameTextField {
            hintLabel = accountNameHintLabel
        } else {
            hintLabel = locationHintLabel
        }
        
        UIView.animate(withDuration: 0.2) {
            if (textField.text == nil)
                || textField.text!.isEmpty {
                textField.layer.borderWidth = 1.0
                hintLabel!.alpha = 1.0
            } else {
                textField.layer.borderWidth = 0.0
                hintLabel!.alpha = 0.0
            }
        }
    }
    
}

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
