//
//  ChatTableViewController+UITableView.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 11.05.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

// MARK: - WEBIM: SurveyListener
extension ChatTableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
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

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { messages().count }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard indexPath.row < messages().count else { return UITableViewCell() }
        let message = messages()[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FlexibleTableViewCell",
            for: indexPath
        ) as? FlexibleTableViewCell else {
            fatalError("The dequeued cell is not an instance of FlexibleTableViewCell.")
        }
        
        cell.configureTheCell(
            forMessage: message,
            showFullDate: shouldShowFullDate(forMessageNumber: indexPath.row),
            shouldShowOperatorInfo: shouldShowOperatorInfo(forMessageNumber: indexPath.row),
            isEdited: message.isEdited()
        )
        cell.delegate = self
        cell.selectionStyle = .none
        cell.backgroundColor = flexibleTableViewCellBackgroundColour
        
        if let data = message.getData(),
           let attachment = data.getAttachment(),
           let contentType = attachment.getFileInfo().getContentType() {
            
            if isImage(contentType: contentType) {
                let gestureRecognizer = UITapGestureRecognizer(
                    target: self,
                    action: #selector(showImage)
                )
                
                if cell.hasImageAsDocument {
                    cell.documentFileStatusButton.isUserInteractionEnabled = true
                    cell.documentFileStatusButton.addGestureRecognizer(gestureRecognizer)
                } else {
                    cell.imageImageView.isUserInteractionEnabled = true
                    cell.imageImageView.addGestureRecognizer(gestureRecognizer)
                }
            } else if isAcceptableFile(contentType: contentType) {
                cell.documentFileStatusButton.isUserInteractionEnabled = true
            } else {
                cell.documentFileStatusButton.isUserInteractionEnabled = false
            }
        }
        
        if cell.userAvatarImageView.image != nil {
            let rateOperatorTapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(rateOperatorByTappingAvatar)
            )
            cell.userAvatarImageView.isUserInteractionEnabled = true
            cell.userAvatarImageView.addGestureRecognizer(rateOperatorTapGesture)
        }
        
        let longPressPopupGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(showPopoverMenu)
        )
        longPressPopupGestureRecognizer.minimumPressDuration = 0.5
        longPressPopupGestureRecognizer.cancelsTouchesInView = false
        
        let doubleTapPopupGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(showPopoverMenu)
        )
        doubleTapPopupGestureRecognizer.numberOfTapsRequired = 2
        doubleTapPopupGestureRecognizer.cancelsTouchesInView = false
        
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(longPressPopupGestureRecognizer)
        cell.addGestureRecognizer(doubleTapPopupGestureRecognizer)
        
        if selectedCellRow != nil {
            cell.alpha = 0
        }
        
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(
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
                self.selectedCellRow = indexPath.row
                let actionsDictionary = ["Action": PopupAction.reply]
                NotificationCenter.default.postInMainThread(
                    name: .shouldShowQuoteEditBar,
                    object: nil,
                    userInfo: actionsDictionary
                )
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
    override func tableView(
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
                self.selectedCellRow = indexPath.row
                let actionsDictionary = ["Action": PopupAction.reply]
                NotificationCenter.default.postInMainThread(
                    name: .shouldShowQuoteEditBar,
                    object: nil,
                    userInfo: actionsDictionary
                )
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
    
    override func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle { .none }
    
    // Dynamic Cell Sizing
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat { cellHeights[indexPath] ?? 70.0 }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if tableView.numberOfSections <= 0 { return }
            
        let lastCellIndexPath = IndexPath(
            row: tableView.numberOfRows(inSection: 0) - 1,
            section: 0
        )
        
        if tableView.indexPathsForVisibleRows?.contains(lastCellIndexPath) == false {
            if scrollButtonIsHidden {
                scrollButtonIsHidden = false
                NotificationCenter.default.postInMainThread(
                    name: .shouldShowScrollButton,
                    object: nil
                )
            }
        } else {
            if !scrollButtonIsHidden {
                scrollButtonIsHidden = true
                NotificationCenter.default.postInMainThread(
                    name: .shouldHideScrollButton,
                    object: nil
                )
            }
        }
        
    }
    
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
        
        self.tableView.reloadData()
    }
}
