//
//  ChatViewController+UITableView.swift
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if !messages().isEmpty {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.emptyTableView(
                message: "Send first message to start chat.".localized
            )
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages().count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard indexPath.row < messages().count else { return UITableViewCell() }
        let message = messages()[indexPath.row]
        
        return updatedCellGeneration(message)
        
    }
    
    @available(iOS 11.0, *)
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let message = messages()[indexPath.row]
        
        if message.isSystemType() || message.isOperatorType() || !message.canBeReplied() {
            return nil
        }
        
        let replyAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { (_, _, completionHandler) in
                self.selectedMessage = message
                self.addQuoteReplyBar()
                completionHandler(true)
            }
        )
        
        // Workaround for iOS < 13
        if let cgImageReplyAction = trailingSwipeActionImage.cgImage {
            replyAction.image = CustomUIImage(
                cgImage: cgImageReplyAction,
                scale: UIScreen.main.nativeScale,
                orientation: .up
            )
        }
        replyAction.backgroundColor = tableView.backgroundColor
        
        return UISwipeActionsConfiguration(actions: [replyAction])
    }
    
    @available(iOS 11.0, *)
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let message = messages()[indexPath.row]
        
        if message.isSystemType() || message.isVisitorType() || !message.canBeReplied() {
            return nil
        }
        
        let replyAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { (_, _, completionHandler) in
                self.selectedMessage = message
                self.addQuoteReplyBar()
                completionHandler(true)
            }
        )
        
        // Workaround for iOS < 13
        if let cgImageReplyAction = leadingSwipeActionImage.cgImage {
            replyAction.image = CustomUIImage(
                cgImage: cgImageReplyAction,
                scale: UIScreen.main.nativeScale,
                orientation: .up
            )
        }
        replyAction.backgroundColor = tableView.backgroundColor
        
        return UISwipeActionsConfiguration(actions: [replyAction])
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle { .none }
    
    func messages() -> [Message] {
        return showSearchResult ? searchMessages : chatMessages
    }
    
    func showSearchResult(messages: [Message]?) {
        if let messages = messages {
            self.searchMessages = messages
            self.showSearchResult = true
        } else {
            self.searchMessages = []
            self.showSearchResult = false
        }
        
        self.reloadTableWithNewData()
    }
    
    func updatedCellGeneration(_ message: Message) -> UITableViewCell {
        
        var isImage = false
        var isFile = false
        
        var hasQuote = false
        var hasQuoteImage = false
        var hasQuoteFile = false
        
        if let quote = message.getQuote() {
            hasQuote = true
            if quote.getMessageAttachment() != nil {
                hasQuoteImage = MimeType.isImage(contentType: quote.getMessageAttachment()?.getContentType() ?? "")
                hasQuoteFile = !isImage
            }
        } else {
            if let attachment = message.getData()?.getAttachment() {
                isImage = MimeType.isImage(contentType: attachment.getFileInfo().getContentType() ?? "")
                isFile = !isImage
            }
        }
        if message.getType() == .info || message.getType() == .contactInformationRequest || message.getType() == .operatorBusy {
            return self.messageCellWithType(WMInfoCell.self, message: message)
        }
        if message.getType() == .keyboard {
            return self.messageCellWithType(WMBotButtonsTableViewCell.self, message: message)
        }
        if message.getType() == .keyboardResponse {
            return self.messageCellWithType(WMNilTableViewCell.self, message: message)
        }
        
        if message.isVisitorType() {
            if hasQuote {
                if hasQuoteImage {
                    return self.messageCellWithType(WMVisitorQuoteImageCell.self, message: message)
                }
                if hasQuoteFile {
                    return self.messageCellWithType(WMVisitorQuoteFileCell.self, message: message)
                }
                return self.messageCellWithType(WMVisitorQuoteMessageCell.self, message: message)
            } else {
                if isImage {
                    return self.messageCellWithType(WMVisitorImageCell.self, message: message)
                } else if isFile || message.getType() == .fileFromVisitor {
                    return self.messageCellWithType(WMVisitorFileCell.self, message: message)
                }
            }
            return self.messageCellWithType(WMVisitorMessageCell.self, message: message)
        }
        
        if message.isOperatorType() {
            if hasQuote {
                if hasQuoteImage {
                    return self.messageCellWithType(WMOperatorQuoteImageCell.self, message: message)
                }
                if hasQuoteFile {
                    return self.messageCellWithType(WMOperatorQuoteFileCell.self, message: message)
                }
                return self.messageCellWithType(WMOperatorQuoteMessageCell.self, message: message)
                
            } else {
                if isFile {
                    return self.messageCellWithType(WMOperatorFileCell.self, message: message)
                }
                if isImage {
                    return self.messageCellWithType(WMOperatorImageCell.self, message: message)
                }
                return self.messageCellWithType(WMOperatorMessageCell.self, message: message)
            }
        }
        
#if DEBUG
        fatalError("no correct cell type")
#else
        print("no correct cell type")
#endif
        return self.messageCellWithType(WMInfoCell.self, message: message)
    }
    
    func messageCellWithType<T: WMMessageTableCell>(_ type: T.Type, message: Message) -> T {
        let cell = self.chatTableView.dequeueReusableCellWithType(type)
        cell.delegate = self
        _ = cell.initialSetup()
        cell.setMessage(message: message, tableView: self.chatTableView)
        cell.delegate = self
        return cell
    }
}
