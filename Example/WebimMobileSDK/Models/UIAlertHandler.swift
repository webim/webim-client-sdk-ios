//
//  UIAlertHandler.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 13.02.18.
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
import WebimMobileSDK

final class UIAlertHandler {
    
    // MARK: - Properties
    private weak var delegate: UIViewController?
    private var alertController: UIAlertController!
    
    // MARK: - Initializer
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    func showDialog(
        withMessage message: String,
        title: String?,
        buttonTitle: String = "OK".localized,
        buttonStyle: UIAlertAction.Style = .cancel,
        action: (() -> Void)? = nil
    ) {
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: buttonTitle,
            style: buttonStyle,
            handler: { _ in
                action?()
            })
        
        alertController.addAction(alertAction)
        
        if buttonStyle != .cancel {
            let alertActionOther = UIAlertAction(
                title: "Cancel".localized,
                style: .cancel)
            alertController.addAction(alertActionOther)
        }
        
        delegate?.present(alertController, animated: true)
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "Session creation failed".localized,
            buttonTitle: "OK".localized
        )
    }
    
    func showSettingsAlertDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: "InvalidSettings".localized,
            buttonTitle: "OK".localized
        )
    }

    func showAlertForAccountName() {
        showDialog(
            withMessage: "Alert account name".localized,
            title: "Account".localized,
            buttonTitle: "OK".localized
        )
    }
    
    // MARK: - Private methods
    private func getGoToSettingsAction() -> (() -> Void) {
        return {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (_) in
                })
            }
        }
    }
    
    private func dismiss() {
        let time = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.alertController.dismiss(animated: true, completion: nil)
        }
    }
}
