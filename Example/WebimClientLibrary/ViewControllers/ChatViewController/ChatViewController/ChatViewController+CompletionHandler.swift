//
//  ChatViewController+Comple.swift
//  WebimClientLibrary_Example
//
//  Created by Anna Frolova on 21.01.2022.
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

import Foundation
import WebimClientLibrary

extension ChatViewController: SendFileCompletionHandler,
                              EditMessageCompletionHandler,
                              DeleteMessageCompletionHandler,
                              SendKeyboardRequestCompletionHandler,
                              ReactionCompletionHandler {
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        // Ignored.
        // Delete visitor typing draft after message is sent.
        WebimServiceController.currentSession.setVisitorTyping(draft: nil)
    }
    
    // SendFileCompletionHandler
    func onFailure(messageID: String, error: SendFileError) {
        DispatchQueue.main.async {
            var message = "Find sending unknown error".localized
            switch error {
            case .fileSizeExceeded:
                message = "File is too large.".localized
            case .fileTypeNotAllowed:
                message = "File type is not supported".localized
            case .unknown:
                message = "Find sending unknown error".localized
            case .uploadedFileNotFound:
                message = "Sending files in body is not supported".localized
            case .unauthorized:
                message = "Failed to upload file: visitor is not logged in".localized
            case .maxFilesCountPerChatExceeded:
                message = "MaxFilesCountExceeded".localized
            case .fileSizeTooSmall:
                message = "File is too small".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "File sending failed".localized
            )
        }
    }
    
    // EditMessageCompletionHandler
    func onFailure(messageID: String, error: EditMessageError) {
        DispatchQueue.main.async {
            var message = "Edit message unknown error".localized
            switch error {
            case .unknown:
                message = "Edit message unknown error".localized
            case .notAllowed:
                message = "Editing messages is turned off on the server".localized
            case .messageEmpty:
                message = "Editing message is empty".localized
            case .messageNotOwned:
                message = "Message not owned by visitor".localized
            case .maxLengthExceeded:
                message = "MaxMessageLengthExceeded".localized
            case .wrongMesageKind:
                message = "Wrong message kind (not text)".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "Message editing failed".localized
            )
        }
    }
    
    // DeleteMessageCompletionHandler
    func onFailure(messageID: String, error: DeleteMessageError) {
        DispatchQueue.main.async {
            var message = "Delete message unknown error".localized
            switch error {
            case .unknown:
                message = "Delete message unknown error".localized
            case .notAllowed:
                message = "Deleting messages is turned off on the server".localized
            case .messageNotOwned:
                message = "Message not owned by visitor".localized
            case .messageNotFound:
                message = "Message not found".localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: "Message deleting failed".localized
            )
        }
    }
    
    // ReacionCompletionHandler
    func onFailure(error: ReactionError) {
        DispatchQueue.main.async {
            var message = "Неизвестная ошибка"
            switch error {
            case .unknown:
                message = "Неизвестная ошибка"
            case .notAllowed:
                message = "Реакция на сообщения отключена на сервере"
            case .messageNotOwned:
                message = "Сообщение не принадлежит оператору"
            case .messageNotFound:
                message = "Сообщение не найдено"
            }
            self.alertOnFailure(
                with: message,
                id: "",
                title: "Ошибка"
            )
        }
    }
    
    // SendKeyboardRequestCompletionHandler
    func onFailure(messageID: String, error: KeyboardResponseError) {
        DispatchQueue.main.async {
            var message = "Send keyboard request unknown error".localized
            switch error {
            case .unknown:
                message = "Send keyboard request unknown error".localized
            case .noChat:
                message = "Chat does not exist".localized
            case .buttonIdNotSet:
                message = "Wrong button ID in request".localized
            case .requestMessageIdNotSet:
                message = "Wrong message ID in request".localized
            case .canNotCreateResponse:
                message = "Response cannot be created for this request".localized
            }
            
            let title = "Send keyboard request failed".localized
            
            self.alertDialogHandler.showSendFailureDialog(
                withMessage: message,
                title: title,
                action: { [weak self] in
                    guard self != nil else { return }
                
                // TODO: Make sure to delete message if needed
//                    for (index, message) in self.messages.enumerated() {
//                        if message.getID() == messageID {
//                            self.messages.remove(at: index)
//                            DispatchQueue.main.async {
//                                self.tableView?.reloadData()
//                            }
//
//                            return
//                        }
//                    }
                }
            )
        }
    }
    
    func alertOnFailure(with message: String, id messageID: String, title: String) {
        alertDialogHandler.showSendFailureDialog(
            withMessage: message,
            title: title,
            action: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    for (index, message) in self.chatMessages.enumerated() {
                        if message.getID() == messageID {
                            self.chatMessages.remove(at: index)
                            self.chatTableView?.reloadData()
                            return
                        }
                    }
                }
            }
        )
    }
}

extension ChatViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        let alertController = UIAlertController(
            title: "Session creation failed".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "Ok".localized,
            style: .cancel,
            handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true)
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            if let startViewController = navigationController.viewControllers.first as? WMStartViewController {
                navigationController.popViewController(animated: false)
                startViewController.startChatButton.isHidden = true
                startViewController.showErrorDialog(withMessage: message)
            }
        }
    }
    
}

extension ChatViewController: NotFatalErrorHandler {
    
    func on(error: WebimNotFatalError) {
    }
    
    func connectionStateChanged(connected: Bool) {
        self.setConnectionStatus(connected: connected)
    }
}
