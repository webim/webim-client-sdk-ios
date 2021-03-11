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
import WebimClientLibrary

final class UIAlertHandler {
    
    // MARK: - Properties
    private weak var delegate: UIViewController?
    
    // MARK: - Initializer
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    func showDialog(
        withMessage message: String,
        title: String?,
        buttonTitle: String = AlertDialog.buttonTitle.rawValue.localized,
        buttonStyle: UIAlertAction.Style = .cancel,
        action: (() -> ())? = nil
    ) {
        let alertController = UIAlertController(
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
                title: CancelButton.cancel.rawValue.localized,
                style: .cancel)
            alertController.addAction(alertActionOther)
        }
        
        delegate?.present(alertController, animated: true)
    }
    
    func showDepartmentListDialog(
        withDepartmentList departmentList: [Department],
        action: @escaping (String) -> ()
    ) {
        let alertController = UIAlertController(
            title: DepartmentListDialog.title.rawValue.localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for department in departmentList {
            let departmentAction = UIAlertAction(
                title: department.getName(),
                style: .default,
                handler: { _ in
                    action(department.getKey())
                }
            )
            
            alertController.addAction(departmentAction)
        }
        
        let alertAction = UIAlertAction(
            title: DepartmentListDialog.cancelButtonTitle.rawValue.localized,
            style: .cancel)
        
        alertController.addAction(alertAction)
        
        delegate?.present(alertController, animated: true)
    }
    
    func showSendFailureDialog(
        withMessage message: String,
        title: String,
        action: (() -> ())? = nil
    ) {
        showDialog(
            withMessage: message,
            title: title,
            buttonTitle: SendErrorMessage.buttonTitle.rawValue.localized,
            action: action
        )
    }
    
    func showChatClosedDialog() {
        showDialog(
            withMessage: ChatClosedDialog.message.rawValue.localized,
            title: nil,
            buttonTitle: ChatClosedDialog.buttonTitle.rawValue.localized
        )
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: SessionCreationErrorDialog.title.rawValue.localized,
            buttonTitle: SessionCreationErrorDialog.buttonTitle.rawValue.localized
        )
    }
    
    func showFileLoadingFailureDialog(withError error: Error) {
        showDialog(
            withMessage: error.localizedDescription,
            title: LoadingFileDialog.loadErrorTitle.rawValue.localized,
            buttonTitle: LoadingFileDialog.buttonTitle.rawValue.localized
        )
    }
    
    func showFileSavingFailureDialog(withError error: Error) {
        let action = getGoToSettingsAction()
        showDialog(
            withMessage: SavingFileDialog.saveErrorMessage.rawValue.localized,
            title: SavingFileDialog.saveErrorTitle.rawValue.localized,
            buttonTitle: SavingFileDialog.errorButtonTitle.rawValue.localized,
            buttonStyle: .default,
            action: action
        )
    }
    
    func showFileSavingSuccessDialog() {
        showDialog(
            withMessage: SavingFileDialog.saveSuccessMessage.rawValue.localized,
            title: SavingFileDialog.saveSuccessTitle.rawValue.localized,
            buttonTitle: SavingFileDialog.buttonTitle.rawValue.localized
        )
    }
    
    func showImageSavingFailureDialog(withError error: NSError) {
        let action = getGoToSettingsAction()

        showDialog(
            withMessage: SavingImageDialog.saveErrorMessage.rawValue.localized,
            title: SavingImageDialog.saveErrorTitle.rawValue.localized,
            buttonTitle: SavingImageDialog.errorButtonTitle.rawValue.localized,
            buttonStyle: .default,
            action: action
        )
    }
    
    func showImageSavingSuccessDialog() {
        showDialog(
            withMessage: SavingImageDialog.saveSuccessMessage.rawValue.localized,
            title: SavingImageDialog.saveSuccessTitle.rawValue.localized,
            buttonTitle: SavingImageDialog.buttonTitle.rawValue.localized
        )
    }
    
    func showNoCurrentOperatorDialog() {
        showDialog(
            withMessage: NoCurrentOperatorErrorMessage.message.rawValue.localized,
            title: NoCurrentOperatorErrorMessage.title.rawValue.localized,
            buttonTitle: NoCurrentOperatorErrorMessage.buttonTitle.rawValue.localized
        )
    }
    
    func showSettingsAlertDialog(withMessage message: String) {
        showDialog(
            withMessage: message,
            title: SettingsErrorDialog.title.rawValue.localized,
            buttonTitle: SettingsErrorDialog.buttonTitle.rawValue.localized
        )
    }
    
    // MARK: - Private methods
    private func getGoToSettingsAction() -> (() ->()) {
        return {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }
    }
}
