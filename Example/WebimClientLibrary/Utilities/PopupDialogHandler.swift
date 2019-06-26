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
    private weak var delegate: UIViewController?
    
    // MARK - Initializer
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func showSettingsAlertDialog(withMessage message: String) {
        let popup = PopupDialog(title: SettingsErrorDialog.title.rawValue.localized,
                                message: message)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SettingsErrorDialog.buttonTitle.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = SettingsErrorDialog.buttonAccessibilityHint.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(okButton)
        
        delegate?.present(popup,
                          animated: true,
                          completion: nil)
    }
    
    func showCreatingSessionFailureDialog(withMessage message: String) {
        let popup = PopupDialog(title: SessionCreationErrorDialog.title.rawValue.localized,
                                message: message.localized)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SessionCreationErrorDialog.buttonTitle.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = SessionCreationErrorDialog.buttonAccessibilityHint.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(okButton)
        
        delegate?.present(popup,
                          animated: true,
                          completion: nil)
    }
    
    func showDepartmentListDialog(withDepartmentList departmentList: [Department],
                                  action: @escaping (String) -> ()) {
        let popup = PopupDialog(title: DepartmentListDialog.title.rawValue.localized,
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
            button.accessibilityHint = DepartmentListDialog.buttonAccessibilityHint.rawValue.localized
            button.titleColor = textMainColor.color()
            button.backgroundColor = backgroundSecondaryColor.color()
            popup.addButton(button)
        }
        
        let cancelButton = CancelButton(title: DepartmentListDialog.cancelButtonTitle.rawValue.localized,
                                        height: PopupDialogHandler.BUTTON_HEIGHT,
                                        dismissOnTap: true,
                                        action: nil)
        cancelButton.accessibilityHint = DepartmentListDialog.cancelButtonAccessibilityHint.rawValue.localized
        cancelButton.backgroundColor = backgroundSecondaryColor.color()
        popup.addButton(cancelButton)
        
        delegate?.present(popup,
                          animated: true,
                          completion: nil)
    }
    
    func showFileSendFailureDialog(withMessage message: String,
                                   action: (() -> ())? = nil) {
        let popupDialog = PopupDialog(title: SendFileErrorMessage.title.rawValue.localized,
                                      message: message)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: SendFileErrorMessage.buttonTitle.rawValue.localized) {
            action?()
        }
        okButton.accessibilityHint = SendFileErrorMessage.buttonAccessibilityHint.rawValue.localized
        okButton.backgroundColor = backgroundSecondaryColor.color()
        okButton.titleColor = textMainColor.color()
        popupDialog.addButton(okButton)
        
        delegate?.present(popupDialog,
                          animated: true,
                          completion: nil)
    }
    
    func showFileDialog(withMessage message: String?,
                        title: String,
                        image: UIImage?) {
        let button = CancelButton(title: ShowFileDialog.buttonTitle.rawValue.localized,
                                  action: nil)
        button.accessibilityHint = ShowFileDialog.accessibilityHint.rawValue.localized
        button.backgroundColor = backgroundSecondaryColor.color()
        button.titleColor = textMainColor.color()
        
        let popup = PopupDialog(title: title,
                                message: message,
                                image: image,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                completion: nil)
        popup.view.backgroundColor = backgroundSecondaryColor.color()
        (popup.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        popup.addButton(button)
        
        delegate?.present(popup,
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
                                tapGestureDismissal: true)
        
        let cancelButton = CancelButton(title: RatingDialog.cancelButtonTitle.rawValue.localized,
                                        height: PopupDialogHandler.BUTTON_HEIGHT,
                                        dismissOnTap: true,
                                        action: nil)
        cancelButton.accessibilityHint = RatingDialog.cancelButtonAccessibilityHint.rawValue.localized
        cancelButton.backgroundColor = backgroundSecondaryColor.color()
        
        let rateButton = DefaultButton(title: RatingDialog.actionButtonTitle.rawValue.localized,
                                       height: PopupDialogHandler.BUTTON_HEIGHT,
                                       dismissOnTap: true) {
                                        action(Int(ratingViewController.ratingView.rating))
        }
        rateButton.accessibilityHint = RatingDialog.actionButtonAccessibilityHint.rawValue.localized
        rateButton.backgroundColor = backgroundSecondaryColor.color()
        rateButton.titleColor = textMainColor.color()
        
        popup.addButtons([cancelButton,
                          rateButton])
        
        delegate?.present(popup,
                          animated: true,
                          completion: nil)
    }
    
    func showRatingFailureDialog() {
        let popupDialog = PopupDialog(title: RateOperatorErrorMessage.title.rawValue.localized,
                                      message: RateOperatorErrorMessage.message.rawValue.localized)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).titleColor = textMainColor.color()
        
        let okButton = CancelButton(title: RateOperatorErrorMessage.buttonTitle.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = RateOperatorErrorMessage.buttonAccessibilityHint.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popupDialog.addButton(okButton)
        
        delegate?.present(popupDialog,
                          animated: true,
                          completion: nil)
    }
    
    func showChatClosedDialog() {
        let popupDialog = PopupDialog(title: nil,
                                      message: ChatClosedDialog.message.rawValue.localized)
        popupDialog.view.backgroundColor = backgroundSecondaryColor.color()
        (popupDialog.viewController as! PopupDialogDefaultViewController).messageColor = textMainColor.color()
        
        let okButton = CancelButton(title: ChatClosedDialog.buttonTitle.rawValue.localized,
                                    action: nil)
        okButton.accessibilityHint = ChatClosedDialog.buttonAccessibilityHint.rawValue.localized
        okButton.titleColor = textMainColor.color()
        okButton.backgroundColor = backgroundSecondaryColor.color()
        popupDialog.addButton(okButton)
        
        delegate?.present(popupDialog,
                          animated: true,
                          completion: nil)
    }
    
}
