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

extension WMSettingsViewController {
    // MARK: - Methods
    func setupColorScheme() {
        view.backgroundColor = backgroundViewColour
        
        saveButton.backgroundColor = saveButtonBackgroundColour
        saveButton.setTitleColor(saveButtonTitleColour, for: .normal)
    }
    
    // MARK: - Private methods
    func setupNavigationItem() {
        
        let imageView = UIImageView(image: navigationBarTitleImageViewImage)
        imageView.contentMode = .scaleAspectFit
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 40))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        let toogleTestModeGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toogleTestMode)
        )
        toogleTestModeGestureRecognizer.numberOfTapsRequired = 5
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(toogleTestModeGestureRecognizer)
        self.navigationItem.titleView = titleView
    }
    
    func setupTextFields() {
        
        pageTitleTextField.addTarget(
            self,
            action: #selector(stoppedTyping),
            for: .editingDidEnd
        )
        pageTitleTextField.delegate = self
        
        accountNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        locationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
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
}
