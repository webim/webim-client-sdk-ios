//
//  ChatTableViewController+WMDialogCellDelegate.swift
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
import Nuke

extension ChatViewController: WMDialogCellDelegate {
    
    func longPressAction(cell: UITableViewCell, message: Message) {
        selectedMessage = message
        shoowPopover(cell: cell, message: message, cellHeight: cell.frame.height)
    }
    func imageViewTapped(message: Message, image: UIImage?, url: URL?) {
        
        guard let url = url
        else { return }
        
        let vc = WMImageViewController.loadViewControllerFromXib()
        vc.selectedImageURL = url
        vc.selectedImage = image
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func quoteMessageTapped(message: Message?) {
        if let messageId = message?.getQuote()?.getMessageID() {
            guard let row = chatMessages.firstIndex(where: { (message) in
                message.getServerSideID() == messageId
            }) else { return }
            let indexPath = IndexPath(row: row, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    public func openFile(message: Message?, url: URL?) {
        let vc = WMFileViewController.loadViewControllerFromXib()
        vc.fileDestinationURL = url
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func cleanTextView() {
        self.toolbarView.messageView.setMessageText("")
    }
    
    func sendKeyboardRequest(buttonInfoDictionary: [String: String]) {
        guard let messageID = buttonInfoDictionary["Message"],
            let buttonID = buttonInfoDictionary["ButtonID"],
            buttonInfoDictionary["ButtonTitle"] != nil
        else { return }
        if let message = findMessage(withID: messageID),
        let button = findButton(inMessage: message, buttonID: buttonID) {
        // TODO: Send request
        print("Sending keyboard request...")
                    
        WebimServiceController.currentSession.sendKeyboardRequest(
            button: button,
            message: message,
            completionHandler: self
        )
        
        } else {
            print("HALT! There isn't such message or button in #function")
        }
    }
    
    private func findMessage(withID id: String) -> Message? {
        for message in chatMessages {
            if message.getID() == id {
                return message
            }
        }
        return nil
    }
    
    private func findButton(
        inMessage message: Message,
        buttonID: String
    ) -> KeyboardButton? {
        guard let buttonsArrays = message.getKeyboard()?.getButtons() else { return nil }
        let buttons = buttonsArrays.flatMap { $0 }
        
        for button in buttons {
            if button.getID() == buttonID {
                return button
            }
        }
        return nil
    }
}
