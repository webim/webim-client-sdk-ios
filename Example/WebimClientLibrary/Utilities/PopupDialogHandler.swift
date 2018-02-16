//
//  PopupDialogHandler.swift
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

import PopupDialog
import UIKit
import WebimClientLibrary

final class PopupDialogHandler {
    
    // MARK: - Constants
    static let BUTTON_HEIGHT = 60
    
    // MARK: - Properties
    let delegate: UIViewController
    
    // MARK - Initializer
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func showSettingsAlertDialog(withMessage message: String) {
        let popup = PopupDialog(title: SettingsErrorDialog.TITLE.rawValue.localized,
                                message: message)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SettingsErrorDialog.BUTTON_TITLE.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = SettingsErrorDialog.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(okButton)
        
        delegate.present(popup,
                         animated: true,
                         completion: nil)
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        let popup = PopupDialog(title: SessionCreationErrorDialog.TITLE.rawValue.localized,
                                message: message.localized)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SessionCreationErrorDialog.BUTTON_TITLE.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = SessionCreationErrorDialog.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(okButton)
        
        delegate.present(popup,
                         animated: true,
                         completion: nil)
    }
    
    func showDepartmentListDialog(withDepartmentList departmentList: [Department],
                                  action: @escaping (String) -> ()) {
        let popup = PopupDialog(title: DepartmentListDialog.TITLE.rawValue.localized,
                                message: nil,
                                image: nil,
                                buttonAlignment: .vertical,
                                transitionStyle: .bounceDown,
                                completion: nil)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        for department in departmentList {
            let button = DefaultButton(title: department.getName()) {
                action(department.getKey())
            }
            button.accessibilityHint = DepartmentListDialog.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
            button.titleColor = textMainColor.color()
            button.backgroundColor = backgroundSecondaryColor.color()
            popup.addButton(button)
        }
        
        let cancelButton = CancelButton(title: DepartmentListDialog.CANCEL_BUTTON_TITLE.rawValue.localized,
                                        height: PopupDialogHandler.BUTTON_HEIGHT,
                                        dismissOnTap: true,
                                        action: nil)
        cancelButton.accessibilityHint = DepartmentListDialog.CANCEL_BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        cancelButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(cancelButton)
        
        delegate.present(popup,
                         animated: true,
                         completion: nil)
    }
    
    func showFileSendFailureDialog(withMessage message: String,
                                   action: (() -> ())? = nil) {
        let popupDialog = PopupDialog(title: SendFileErrorMessage.TITLE.rawValue.localized,
                                      message: message)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SendFileErrorMessage.BUTTON_TITLE.rawValue.localized) {
            action?()
        }
        okButton.accessibilityHint = SendFileErrorMessage.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        okButton.backgroundColor = backgroundSecondaryColor.color()
        okButton.titleColor = textMainColor.color()
        popupDialog.addButton(okButton)
        
        delegate.present(popupDialog,
                         animated: true,
                         completion: nil)
    }
    
    func showFileDialog(withMessage message: String?,
                        title: String,
                        image: UIImage?) {
        let button = CancelButton(title: ShowFileDialog.BUTTON_TITLE.rawValue.localized,
                                  action: nil)
        button.accessibilityHint = ShowFileDialog.ACCESSIBILITY_HINT.rawValue.localized
        button.backgroundColor = backgroundSecondaryColor.color()
        button.titleColor = textMainColor.color()
        
        let popup = PopupDialog(title: title,
                                message: message,
                                image: image,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                gestureDismissal: true,
                                completion: nil)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        popup.addButton(button)
        
        delegate.present(popup,
                     animated: true,
                     completion: nil)
    }
    
    func showRatingDialog(forOperator operatorID: String,
                          action: @escaping (_ rating: Int) -> ()) {
        let ratingViewController = RatingViewController(nibName: "RatingViewController",
                                                        bundle: nil)
        let popup = PopupDialog(viewController: ratingViewController,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                gestureDismissal: true)
        
        let cancelButton = CancelButton(title: RatingDialog.CANCEL_BUTTON_TITLE.rawValue.localized,
                                        height: PopupDialogHandler.BUTTON_HEIGHT,
                                        dismissOnTap: true,
                                        action: nil)
        cancelButton.accessibilityHint = RatingDialog.CANCEL_BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        cancelButton.backgroundColor = backgroundSecondaryColor.color()
        
        let rateButton = DefaultButton(title: RatingDialog.ACTION_BUTTON_TITLE.rawValue.localized,
                                       height: PopupDialogHandler.BUTTON_HEIGHT,
                                       dismissOnTap: true) {
                                        action(Int(ratingViewController.ratingView.rating))
        }
        rateButton.accessibilityHint = RatingDialog.ACTION_BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        rateButton.backgroundColor = backgroundSecondaryColor.color()
        rateButton.titleColor = textMainColor.color()
        
        popup.addButtons([cancelButton,
                          rateButton])
        
        delegate.present(popup,
                         animated: true,
                         completion: nil)
    }
    
    func showRatingFailureDialog() {
        let popupDialog = PopupDialog(title: RateOperatorErrorMessage.TITLE.rawValue.localized,
                                      message: RateOperatorErrorMessage.MESSAGE.rawValue.localized)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: RateOperatorErrorMessage.BUTTON_TITLE.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = RateOperatorErrorMessage.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popupDialog.addButton(okButton)
        
        delegate.present(popupDialog,
                         animated: true,
                         completion: nil)
    }
    
    func showChatClosedDialog() {
        let popupDialog = PopupDialog(title: nil,
                                      message: ChatClosedDialog.MESSAGE.rawValue.localized)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).messageColor = textMainColor.color()
        
        let okButton = CancelButton(title: ChatClosedDialog.BUTTON_TITLE.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = ChatClosedDialog.BUTTON_ACCESSIBILITY_HINT.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popupDialog.addButton(okButton)
        
        delegate.present(popupDialog,
                         animated: true,
                         completion: nil)
    }
    
}
