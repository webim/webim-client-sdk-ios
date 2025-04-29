//
//  WMSettingsViewController_Setup.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 10.01.2022.
//  Copyright © 2022 Webim. All rights reserved.
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

extension WMSettingsViewController {
    
    // MARK: - Methods
    
    func setupColorScheme() {
        view.backgroundColor = backgroundViewColour
        
        saveButton.backgroundColor = saveButtonBackgroundColour
        saveButton.setTitleColor(saveButtonTitleColour, for: .normal)
    }
    
    // MARK: - Private methods
    
    func setupNavigationItem() {
        let titleLabel = UILabel()
        let toogleTestModeGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toogleTestMode)
        )
        toogleTestModeGestureRecognizer.numberOfTapsRequired = 5
        titleLabel.text = "Settings".localized
        titleLabel.textColor = .white
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(toogleTestModeGestureRecognizer)
        self.navigationItem.titleView = titleLabel
    }
    
    func setupLabels() {
        for hintLabel in [
            accountNameHintLabel,
            locationHintLabel
        ] {
            guard let hintLabel = hintLabel else { continue }
            hintLabel.alpha = 0.0
        }
    }

    func setupTextFieldsDelegate() {
        accountNameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    func setupSelectVisitorCell() {
        let visitorRow: SelectVisitorViewController.VisitorRows
        switch DemoVisitor.currentVisitor {
        case .fedor:
            visitorRow = .fedor
        case .semion:
            visitorRow = .semion
        default:
            visitorRow = .unauthorized
        }
        selectVisitorCell.usernameLabel.text = visitorRow.rawValue.localized
    }

}
