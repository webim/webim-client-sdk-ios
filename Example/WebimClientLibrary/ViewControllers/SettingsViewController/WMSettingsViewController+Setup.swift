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
        let titleView = getTitleView()
        self.navigationItem.titleView = titleView
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
        pageTitleTextField.delegate = self
        accountNameTextField.delegate = self
        locationTextField.delegate = self
        pageTitleTextField.delegate = self
    }
    
    private func getTitleView() -> UIView {
        let label = UILabel()
        let imageView = UIImageView()
        let titleView = UIView()

        titleView.addSubview(imageView)

        setupTitleImageView(imageView)

        setupTitleViewConstraints(imageView: imageView)
        return titleView
    }


    private func setupTitleImageView(_ imageView: UIImageView) {
        let toogleTestModeGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(toogleTestMode)
        )
        imageView.image = navigationBarTitleImageViewImage
        imageView.contentMode = .scaleAspectFill
    }


    private func setupTitleViewConstraints(
        imageView: UIView
    ) {
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(1.5)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
