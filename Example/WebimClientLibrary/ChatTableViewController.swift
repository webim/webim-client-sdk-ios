//
//  ChatTableViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 19/09/2019.
//  Copyright © 2019 Webim. All rights reserved.
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

import AVFoundation
import UIKit
import WebimClientLibrary
import SnapKit
import Nuke

class ChatTableViewController: UITableViewController {

    // MARK: - Properties
    var selectedCellRow: Int?
    var scrollButtonIsHidden = true
    
    // MARK: - Private properties
    private let newRefreshControl = UIRefreshControl()
    
    private var alreadyRatedOperators = [String: Bool]()
    private var cellHeights = [IndexPath: CGFloat]()
    private var overlayWindow: UIWindow?
    private var visibleRows = [IndexPath]()
    private var keyboardWindow: UIWindow? {
        // The window containing the keyboard always seems to be the last one
        return UIApplication.shared.windows.last
    }
    
    private weak var containerNewChatViewController: ChatViewController?
    
    private lazy var messages = [Message]()
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var webimService = WebimService(
        fatalErrorHandlerDelegate: self,
        departmentListHandlerDelegate: self
    )

    // MARK: - View Life Cycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? ChatViewController {
            containerNewChatViewController = vc
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addRatedOperator),
            name: .shouldRateOperator,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showRatingDialog(_:)),
            name: .shouldShowRatingDialog,
            object: nil
        )
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showFile),
            name: .shouldShowFile,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setVisitorTypingDraft),
            name: .shouldSetVisitorTypingDraft,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideOverlayWindow),
            name: .shouldHideOverlayWindow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendKeyboardRequest),
            
            name: .shouldSendKeyboardRequest,
            object: nil
        )
        
        setupWebimSession()
        
        registerCells()
        
        setupRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCurrentOperatorInfo(to: webimService.getCurrentOperator())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if containerNewChatViewController == nil {
            stopWebimSession()
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldRateOperator,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldShowFile,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldShowRatingDialog,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldSetVisitorTypingDraft,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldHideOverlayWindow,
                object: nil
            )
            
            NotificationCenter.default.removeObserver(
                self,
                name: .shouldSendKeyboardRequest,
                object: nil
            )
        }
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Will not trigger method hidePopupActionsViewController()
        // if PopupActionsTableView is not presented
        NotificationCenter.default.post(
            name: .shouldHidePopupActionsViewController,
            object: nil
        )
        
        // Will not trigger method hideRatingDialogViewController()
        // if RatingDialogViewController is not presented
        NotificationCenter.default.post(
            name: .shouldHideRatingDialogViewController,
            object: nil
        )
        
        
        coordinator.animate(
            alongsideTransition: { context in
                // Save visible rows position
                if let visibleRows = self.tableView.indexPathsForVisibleRows {
                    self.visibleRows = visibleRows
                }
                context.viewController(forKey: .from)
            },
            completion: { _ in
                // Scroll to the saved position prior to screen rotate
                if let lastVisibleRow = self.visibleRows.last {
                    self.tableView.scrollToRow(
                        at: lastVisibleRow,
                        at: .bottom,
                        animated: true
                    )
                }
            }
        )
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if messages.count > 0 {
            tableView.backgroundView = nil
            return 1
        } else {
            tableView.emptyTableView(
                message: TableView.emptyTableViewText.rawValue.localized
            )
            return 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { messages.count }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard indexPath.row < messages.count else { return UITableViewCell() }
        let message = messages[indexPath.row]
        
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
        
        cell.messageBackgroundView.isUserInteractionEnabled = true
        cell.messageBackgroundView.addGestureRecognizer(longPressPopupGestureRecognizer)
        cell.messageBackgroundView.addGestureRecognizer(doubleTapPopupGestureRecognizer)
        
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
        
        let message = messages[indexPath.row]
        
        if message.isSystemType() || message.isOperatorType() || !message.canBeReplied() {
            return nil
        }

        let replyAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { (context, view, completionHandler) in
                self.selectedCellRow = indexPath.row
                let actionsDictionary = ["Action": PopupAction.reply]
                NotificationCenter.default.post(
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

        let message = messages[indexPath.row]

        if message.isSystemType() || message.isVisitorType() || !message.canBeReplied() {
            return nil
        }

        let replyAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { (context, view, completionHandler)  in
                self.selectedCellRow = indexPath.row
                let actionsDictionary = ["Action": PopupAction.reply]
                NotificationCenter.default.post(
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

        let lastCellIndexPath = IndexPath(
            row: tableView.numberOfRows(inSection: 0) - 1,
            section: 0
        )
        
        if tableView.indexPathsForVisibleRows?.contains(lastCellIndexPath) == false {
            if scrollButtonIsHidden {
                scrollButtonIsHidden = false
                NotificationCenter.default.post(
                    name: .shouldShowScrollButton,
                    object: nil
                )
            }
        } else {
            if !scrollButtonIsHidden {
                scrollButtonIsHidden = true
                NotificationCenter.default.post(
                    name: .shouldHideScrollButton,
                    object: nil
                )
            }
        }
        
    }

    // MARK: - Methods
    /// Preparation for the future
    internal func set(messages: [Message]) {
        self.messages = messages
    }
    
    @objc
    private func sendKeyboardRequest(_ notification: Notification) {
        guard let buttonInfoDictionary = notification.userInfo as? [String: String],
            let messageID = buttonInfoDictionary["Message"],
            let buttonID = buttonInfoDictionary["ButtonID"],
            buttonInfoDictionary["ButtonTitle"] != nil
            else { return }
        
        if let message = findMessage(withID: messageID),
            let button = findButton(inMessage: message, buttonID: buttonID) {
            // TODO: Send request
            print("Sending keyboard request...")
            
            webimService.sendKeyboardRequest(
                button: button,
                message: message,
                completionHandler: self
            )
        } else {
            print("HALT! There isn't such message or button in #function")
        }
    }
    
    private func findMessage(withID id: String) -> Message? {
        for message in messages {
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
    ///
    
    func sendMessage(_ message: String) {
        webimService.send(message: message) { [weak self] in
            // Delete visitor typing draft after message is sent.
            self?.webimService.setVisitorTyping(draft: nil)
        }
    }
    
    func sendImage(image: UIImage, imageURL: URL?) {
        containerNewChatViewController?.dismissKeyboardNow()
        
        var imageData = Data()
        var imageName = String()
        var mimeType = MimeType()
        
        if let imageURL = imageURL {
            mimeType = MimeType(url: imageURL as URL)
            imageName = imageURL.lastPathComponent
            
            let imageExtension = imageURL.pathExtension.lowercased()
            
            switch imageExtension {
            case "jpg", "jpeg":
                guard let unwrappedData = image.jpegData(compressionQuality: 1.0)
                    else { return }
                imageData = unwrappedData
                
            case "heic", "heif":
                guard let unwrappedData = image.jpegData(compressionQuality: 0.5)
                    else { return }
                imageData = unwrappedData
            
                var components = imageName.components(separatedBy: ".")
                if components.count > 1 {
                    components.removeLast()
                    imageName = components.joined(separator: ".")
                }
                imageName += ".jpeg"
                
            default:
                guard let unwrappedData = image.pngData()
                    else { return }
                imageData = unwrappedData
            }
        } else {
            guard let unwrappedData = image.jpegData(compressionQuality: 1.0)
                else { return }
            imageData = unwrappedData
            imageName = "photo.jpeg"
        }
        
        webimService.send(
            file: imageData,
            fileName: imageName,
            mimeType: mimeType.value,
            completionHandler: self
        )
    }
    
    func sendFile(file: Data, fileURL: URL?) {
        if let fileURL = fileURL {
            webimService.send(
                file: file,
                fileName: fileURL.lastPathComponent,
                mimeType: MimeType(url: fileURL as URL).value,
                completionHandler: self
            )
        } else {
            let url = URL(fileURLWithPath: "document.pdf")
            webimService.send(
                file: file,
                fileName: url.lastPathComponent,
                mimeType: MimeType(url: url).value,
                completionHandler: self
            )
        }
    }
    
    func getSelectedMessage() -> Message? {
        guard let selectedCellRow = selectedCellRow,
            selectedCellRow >= 0,
            selectedCellRow < messages.count else { return nil }
        return messages[selectedCellRow]
    }
    
    func replyToMessage(_ message: String) {
        guard let messageToReply = getSelectedMessage() else { return }
        webimService.reply(
            message: message,
            repliedMessage: messageToReply,
            completion: { [weak self] in
                // Delete visitor typing draft after message is sent.
                self?.webimService.setVisitorTyping(draft: nil)
            }
        )
    }
    
    func copyMessage() {
        guard let messageToCopy = getSelectedMessage() else { return }
        UIPasteboard.general.string = messageToCopy.getText()
    }
    
    func editMessage(_ message: String) {
        guard let messageToEdit = getSelectedMessage() else { return }
        webimService.edit(
            message: messageToEdit,
            text: message,
            completionHandler: self
        )
    }
    
    func deleteMessage() {
        guard let messageToDelete = getSelectedMessage() else { return }
        webimService.delete(
            message: messageToDelete,
            completionHandler: self
        )
    }
    
    @objc
    func scrollToBottom(animated: Bool) {
        if messages.isEmpty {
            return
        }
        
        let row = (tableView.numberOfRows(inSection: 0)) - 1
        let bottomMessageIndex = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: animated)
    }
    
    @objc
    func scrollToTop(animated: Bool) {
        if messages.isEmpty {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    // MARK - Private methods
    private func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = newRefreshControl
        } else {
            tableView?.addSubview(newRefreshControl)
        }
        newRefreshControl.layer.zPosition -= 1
        newRefreshControl.addTarget(
            self,
            action: #selector(requestMessages),
            for: .valueChanged
        )
        newRefreshControl.tintColor = refreshControlTintColour
        let attributes = [NSAttributedString.Key.foregroundColor: refreshControlTextColour]
        newRefreshControl.attributedTitle = NSAttributedString(
            string: ChatTableView.refreshControlText.rawValue.localized,
            attributes: attributes
        )
    }
    
    @objc
    private func requestMessages() {
        webimService.getNextMessages() { [weak self] messages in
            self?.messages.insert(contentsOf: messages, at: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.tableView?.reloadData()
                self?.newRefreshControl.endRefreshing()
                self?.webimService.setChatRead()
            }
        }
    }
    
    private func shouldShowFullDate(forMessageNumber index: Int) -> Bool {
        guard index - 1 >= 0 else { return true }
        let currentMessageTime = messages[index].getTime()
        let previousMessageTime = messages[index - 1].getTime()
        let differenceBetweenDates = Calendar.current.dateComponents(
            [.day],
            from: previousMessageTime,
            to: currentMessageTime
        )
        return differenceBetweenDates.day != 0
    }
    
    private func shouldShowOperatorInfo(forMessageNumber index: Int) -> Bool {
        guard messages[index].isOperatorType() else { return false }
        guard index + 1 < messages.count else { return true }
        
        let nextMessage = messages[index + 1]
        if nextMessage.isOperatorType() {
            return false
        } else {
            return true
        }
    }
    
    @objc
    private func showPopoverMenu(_ gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
        var stateToCheck = UIGestureRecognizer.State.ended
        
        if gestureRecognizer is UILongPressGestureRecognizer {
            stateToCheck = UIGestureRecognizer.State.began
        }
        
        if gestureRecognizer.state == stateToCheck {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                
                guard let selectedCell = self.tableView.cellForRow(at: indexPath)
                    as? FlexibleTableViewCell
                    else { return }
                let selectedCellRow = indexPath.row
                self.selectedCellRow = selectedCellRow
                
                let viewController = PopupActionsViewController()
                viewController.modalPresentationStyle = .overFullScreen
                viewController.cellImageViewImage = selectedCell.takeScreenshot()
                
                guard let globalYPosition = selectedCell.superview?
                    .convert(selectedCell.center, to: nil)
                    else { return }
                viewController.cellImageViewCenterYPosition = globalYPosition.y
                
                guard let cellHeight = cellHeights[indexPath] else { return }
                viewController.cellImageViewHeight = cellHeight
                
                let message = messages[selectedCellRow]
                
                if message.isOperatorType() {
                    viewController.originalCellAlignment = .leading
                } else if message.isVisitorType() {
                    viewController.originalCellAlignment = .trailing
                }
                
                if message.canBeReplied() {
                    viewController.actions.append(.reply)
                }
                
                if message.canBeCopied() {
                    viewController.actions.append(.copy)
                }
                
                if message.canBeEdited() {
                    viewController.actions.append(.edit)

                    // If image hide show edit action
                    if let contentType = message.getData()?.getAttachment()?.getFileInfo().getContentType() {
                        if isImage(contentType: contentType) {
                            viewController.actions.removeLast()
                        }
                    }
                    viewController.actions.append(.delete)
                }
                
                if viewController.actions.count != 0 {
                    // Workaround to keep keyboard shown.
                    /// TODO: Probably there is a better solution to check if the keyboard is shown.
                    /// Now it is NOT accurate, since this check could fail if something goes wrong (i.e. some windows haven't been hidden)
                    if UIApplication.shared.windows.count > 2 {
                        /// More details at: https://github.com/robbajorek/ModalOverlayIOS
                        guard let overlayFrame = view?.window?.frame else { return }
                        overlayWindow = UIWindow(frame: overlayFrame)
                        overlayWindow?.windowLevel = .alert
                        overlayWindow?.rootViewController = viewController
                        
                        showOverlayWindow()
                    } else {
                        self.present(viewController, animated: false)
                    }
                }
            }
        }
    }
    
    @objc
    private func hideOverlayWindow(notification: Notification) {
        // TODO: Same as the above one. Potentially could fail.
        if UIApplication.shared.windows.count > 2 {
            keyboardWindow?.isHidden = false
            overlayWindow = nil
        }
    }

    private func showOverlayWindow() {
        overlayWindow?.isHidden = false
        keyboardWindow?.isHidden = true
    }
    
    @objc
    private func showImage(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let tapLocation = recognizer.location(in: tableView)
        
        guard let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) else { return }
        let message = messages[tapIndexPath.row]
        guard let url = message.getData()?.getAttachment()?.getFileInfo().getURL(),
            let vc = storyboard?.instantiateViewController(withIdentifier: "ImageView")
                as? ImageViewController
            else { return }

        let request = ImageRequest(url: url)
        vc.selectedImageURL = url
        vc.selectedImage = ImageCache.shared[request]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func showFile(sender: Notification) {
        guard let files = sender.userInfo as? [String: String],
            let fileName = files["FullName"]
            else { return }
        
        let documentsPath = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask)[0]
        
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: destinationURL.path),
            let vc = storyboard?.instantiateViewController(withIdentifier: "FileView")
                as? FileViewController
            else { return }
        
        vc.fileDestinationURL = destinationURL
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func showRatingDialog(_ notification: Notification) {
        guard let currentOperator = webimService.getCurrentOperator() else {
            alertDialogHandler.showNoCurrentOperatorDialog()
            return
        }
        
        let operatorInfo = [
            "Name": currentOperator.getName(),
            "ID": currentOperator.getID(),
            "AvatarURL": currentOperator.getAvatarURL()?.absoluteString
        ]
        
        showRatingDialog(forOperatorInfo: operatorInfo)
    }
    
    private func showRatingDialog(forOperatorInfo info: [String: String?]) {
        guard let optionalOperatorName = info["Name"],
            let optionalOperatorID = info["ID"],
            let operatorName = optionalOperatorName,
            let operatorID = optionalOperatorID
            else { return }
        
        let operatorRating = 0
        var operatorAvatarImage = UIImage()
        var operatorAvatarImageURL = String()
        
        if let optionalAvatarURLString = info["AvatarURL"],
            let avatarURLString = optionalAvatarURLString,
            let avatarURL = URL(string: avatarURLString) {
            let request = ImageRequest(url: avatarURL)
            
            operatorAvatarImageURL = avatarURLString
            operatorAvatarImage = ImageCache.shared[request] ?? UIImage()
        } else {
            operatorAvatarImage = userAvatarImagePlaceholder
        }
        
        let centerOfTheScreen = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2
        )
        
        let vc = RatingDialogViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.operatorID = operatorID
        vc.viewCenterYPosition = centerOfTheScreen.y
        vc.operatorName = operatorName
        vc.operatorAvatarImage = operatorAvatarImage
        vc.operatorAvatarImageURL = operatorAvatarImageURL
        vc.operatorRating = Double(operatorRating)

        // Workaround to keep keyboard shown.
        /// TODO: Probably there is a better solution to check if the keyboard is shown.
        /// Now it is NOT accurate, since this check could fail if something goes wrong (i.e. some windows haven't been hidden)
        if UIApplication.shared.windows.count > 2 {
            /// More details at: https://github.com/robbajorek/ModalOverlayIOS
            guard let overlayFrame = view?.window?.frame else { return }
            overlayWindow = UIWindow(frame: overlayFrame)
            overlayWindow?.windowLevel = .alert
            overlayWindow?.rootViewController = vc
            
            showOverlayWindow()
        } else {
            self.present(vc, animated: false)
        }
    }
    
    @objc
    func rateOperatorByTappingAvatar(recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let tapLocation = recognizer.location(in: tableView)
        
        guard let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) else { return }
        let message = messages[tapIndexPath.row]
        
        let operatorInfo = [
            "Name": message.getSenderName(),
            "ID": message.getOperatorID(),
            "AvatarURL": message.getSenderAvatarFullURL()?.absoluteString
        ]
        
        showRatingDialog(forOperatorInfo: operatorInfo)
    }

    
    @objc
    private func addRatedOperator(_ notification: Notification) {
        guard let ratingInfoDictionary = notification.userInfo
        as? [String: Int]
        else { return }
        
        for (id, rating) in ratingInfoDictionary {
            rateOperator(
                operatorID: id,
                rating: rating
            )
        }
    }
    
    private func rateOperator(operatorID: String, rating: Int) {
        webimService.rateOperator(
            withID: operatorID,
            byRating: rating,
            completionHandler: self
        )
    }
    
    // Webim methods
    private func setupWebimSession() {
        webimService.createSession()
        webimService.startSession()
        webimService.setMessageStream()
        webimService.setMessageTracker(withMessageListener: self)
        webimService.set(operatorTypingListener: self)
        webimService.set(currentOperatorChangeListener: self)
        webimService.set(chatStateListener: self)
        webimService.getLastMessages() { [weak self] messages in
            self?.messages.insert(contentsOf: messages, at: 0)
            DispatchQueue.main.async() {
                self?.tableView?.reloadData()
                self?.scrollToBottom(animated: false)
                self?.webimService.setChatRead()
            }
        }
    }
    
    private func stopWebimSession() {
        webimService.stopSession()
    }
    
    private func updateCurrentOperatorInfo(to newOperator: Operator?) {
        let operatorInfoDictionary: [String: String]
        if let currentOperator = newOperator {
            let operatorURLString: String
            if let avatarURLString = currentOperator.getAvatarURL()?.absoluteString {
                operatorURLString = avatarURLString
            } else {
                operatorURLString = OperatorAvatar.placeholder.rawValue
            }
        
            operatorInfoDictionary = [
                "OperatorName": currentOperator.getName(),
                "OperatorAvatarURL": operatorURLString
            ]
        } else {
            operatorInfoDictionary = [
                "OperatorName": OperatorStatus.noOperator.rawValue.localized,
                "OperatorAvatarURL": OperatorAvatar.empty.rawValue
            ]
        }
        
        NotificationCenter.default.post(
            name: .shouldUpdateOperatorInfo,
            object: nil,
            userInfo: operatorInfoDictionary
        )
    }
    
    @objc
    private func setVisitorTypingDraft(_ notification: Notification) {
        guard let typingDraftDictionary = notification.userInfo as? [String: String] else { // Not string passed (nil) set draft to nil
            webimService.setVisitorTyping(draft: nil)
            return
        }
        guard let draftText = typingDraftDictionary["DraftText"] else { return }
        webimService.setVisitorTyping(draft: draftText)
    }
    
    private func registerCells() {
        tableView?.register(
            FlexibleTableViewCell.self,
            forCellReuseIdentifier: "FlexibleTableViewCell"
        )
    }
}

// MARK: - WEBIM: MessageListener
extension ChatTableViewController: MessageListener {
    
    // MARK: - Methods
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        var inserted = false
        
        if let previousMessage = previousMessage {
            for (index, message) in messages.enumerated() {
                if previousMessage.isEqual(to: message) {
                    messages.insert(newMessage, at: index)
                    inserted = true
                    break
                }
            }
        }
        
        if !inserted {
            messages.append(newMessage)
        }
        
        DispatchQueue.main.async() {
            self.tableView?.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    func removed(message: Message) {
        var toUpdate = false
        if message.getCurrentChatID() == getSelectedMessage()?.getCurrentChatID() {
            NotificationCenter.default.post(
                name: .shouldHideQuoteEditBar,
                object: nil,
                userInfo: nil
            )
        }
        
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == message.getID() {
                messages.remove(at: messageIndex)
                let indexPath = IndexPath(row: messageIndex, section: 0)
                cellHeights.removeValue(forKey: indexPath)
                toUpdate = true
                
                break
            }
        }
        
        if toUpdate {
            DispatchQueue.main.async() {
                self.tableView?.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func removedAllMessages() {
        messages.removeAll()
        cellHeights.removeAll()
        
        DispatchQueue.main.async() {
            self.tableView?.reloadData()
        }
    }
    
    func changed(message oldVersion: Message,
                 to newVersion: Message) {
        let messagesCountBefore = messages.count
        var toUpdate = false
        var cellIndexToUpdate = 0
        
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == oldVersion.getID() {
                messages[messageIndex] = newVersion
                toUpdate = true
                cellIndexToUpdate = messageIndex
                
                break
            }
        }
        
        if toUpdate {
            DispatchQueue.main.async() {
                let indexPath = IndexPath(row: cellIndexToUpdate, section: 0)
                if self.messages.count != messagesCountBefore ||
                    self.messages.count != self.tableView.numberOfRows(inSection: 0) {
                        self.tableView.reloadData()
                } else {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        DispatchQueue.main.async() {
            self.scrollToBottom(animated: false)
        }
    }
}

// MARK: - WEBIM: HelloMessageListener
extension ChatViewController: HelloMessageListener {
    func helloMessage(message: String) {
        print("Received Hello message: \"\(message)\"")
    }
}

// MARK: - WEBIM: FatalErrorHandler
extension ChatTableViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        alertDialogHandler.showCreatingSessionFailureDialog(withMessage: message)
    }
    
}

// MARK: - WEBIM: DepartmentListHandlerDelegate
extension ChatTableViewController: DepartmentListHandlerDelegate {
    
    // MARK: - Methods
    func show(departmentList: [Department], action: @escaping (String) -> ()) {
        alertDialogHandler.showDepartmentListDialog(
            withDepartmentList: departmentList,
            action: action
        )
    }
    
}

// MARK: - WEBIM: CompletionHandlers
extension ChatTableViewController: SendFileCompletionHandler,
                                   EditMessageCompletionHandler,
                                   DeleteMessageCompletionHandler,
                                   RateOperatorCompletionHandler,
                                   SendKeyboardRequestCompletionHandler {
    // MARK: - Methods
    
    func onSuccess() {
        // Workaround needed since operator dialog dismissed after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) {
            let title = AlertDialog.rateSuccessTitle.rawValue.localized
            let message = AlertDialog.rateSuccessMessage.rawValue.localized
            self.alertDialogHandler.showDialog(withMessage: message, title: title)
        }
    }
    
    func onSuccess(messageID: String) {
        // Ignored.
        // Delete visitor typing draft after message is sent.
        self.webimService.setVisitorTyping(draft: nil)
    }
    
    // SendFileCompletionHandler
    func onFailure(messageID: String, error: SendFileError) {
        DispatchQueue.main.async {
            var message = SendFileErrorMessage.unknownError.rawValue.localized
            switch error {
            case .fileSizeExceeded:
                message = SendFileErrorMessage.fileSizeExceeded.rawValue.localized
                break
            case .fileTypeNotAllowed:
                message = SendFileErrorMessage.fileTypeNotAllowed.rawValue.localized
                break
            case .unknown:
                message = SendFileErrorMessage.unknownError.rawValue.localized
                break
            case .uploadedFileNotFound:
                message = SendFileErrorMessage.fileNotFound.rawValue.localized
                break
            case .unauthorized:
                message = SendFileErrorMessage.unauthorized.rawValue.localized
                break
            case .maxFilesCountPerChatExceeded:
                message = SendFileErrorMessage.maxFilesCountPerChatExceeded.rawValue.localized
                break
            case .fileSizeTooSmall:
                message = SendFileErrorMessage.fileSizeTooSmall.rawValue.localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: SendFileErrorMessage.title.rawValue.localized
            )
        }
    }
    
    // EditMessageCompletionHandler
    func onFailure(messageID: String, error: EditMessageError) {
        DispatchQueue.main.async {
            var message = EditMessageErrorMessage.unknownError.rawValue.localized
            switch error {
            case .unknown:
                message = EditMessageErrorMessage.unknownError.rawValue.localized
            case .notAllowed:
                message = EditMessageErrorMessage.notAllowed.rawValue.localized
            case .messageEmpty:
                message = EditMessageErrorMessage.messageEmpty.rawValue.localized
            case .messageNotOwned:
                message = EditMessageErrorMessage.messageNotOwned.rawValue.localized
            case .maxLengthExceeded:
                message = EditMessageErrorMessage.maxMessageLengthExceede.rawValue.localized
            case .wrongMesageKind:
                message = EditMessageErrorMessage.wrongMessageKind.rawValue.localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: EditMessageErrorMessage.title.rawValue.localized
            )
        }
    }
    
    // DeleteMessageCompletionHandler
    func onFailure(messageID: String, error: DeleteMessageError) {
        DispatchQueue.main.async {
            var message = DeleteMessageErrorMessage.unknownError.rawValue.localized
            switch error {
            case .unknown:
                message = DeleteMessageErrorMessage.unknownError.rawValue.localized
            case .notAllowed:
                message = DeleteMessageErrorMessage.notAllowed.rawValue.localized
            case .messageNotOwned:
                message = DeleteMessageErrorMessage.messageNotOwned.rawValue.localized
            case .messageNotFound:
                message = DeleteMessageErrorMessage.messageNotFound.rawValue.localized
            }
            
            self.alertOnFailure(
                with: message,
                id: messageID,
                title: DeleteMessageErrorMessage.title.rawValue.localized
            )
        }
    }
    
    // RateOperatorCompletionHandler
    func onFailure(error: RateOperatorError) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) {
            var message = String()
            switch error {
            case .noChat:
                message = RateOperatorErrorMessage.rateOperatorNoChat.rawValue.localized
            case .wrongOperatorId:
                message = RateOperatorErrorMessage.rateOperatorWrongID.rawValue.localized
            case .noteIsTooLong:
                message = RateOperatorErrorMessage.rateOperatorLongNote.rawValue.localized
            }
            
            self.alertDialogHandler.showDialog(
                withMessage: message,
                title: RateOperatorErrorMessage.title.rawValue.localized
            )
        }
    }
    
    // SendKeyboardRequestCompletionHandler
    func onFailure(messageID: String, error: KeyboardResponseError) {
        DispatchQueue.main.async {
            var message = SendKeyboardRequestErrorMessage.unknownError.rawValue.localized
            switch error {
            case .unknown:
                message = SendKeyboardRequestErrorMessage.unknownError.rawValue.localized
            case .noChat:
                message = SendKeyboardRequestErrorMessage.noChat.rawValue.localized
            case .buttonIdNotSet:
                message = SendKeyboardRequestErrorMessage.buttonIDNotSet.rawValue.localized
            case .requestMessageIdNotSet:
                message = SendKeyboardRequestErrorMessage.requestMessageIDNotSet.rawValue.localized
            case .canNotCreateResponse:
                message = SendKeyboardRequestErrorMessage.cannotCreateResponse.rawValue.localized
            }
            
            let title = SendKeyboardRequestErrorMessage.title.rawValue.localized
            
            self.alertDialogHandler.showSendFailureDialog(
                withMessage: message,
                title: title,
                action: { [weak self] in
                    guard self != nil else { return }
                
                // TODO: Make sure to delete message if needed
//                    for (index, message) in self.messages.enumerated() {
//                        if message.getID() == messageID {
//                            self.messages.remove(at: index)
//                            DispatchQueue.main.async() {
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
    
    private func alertOnFailure(with message: String, id messageID: String, title: String) {
        alertDialogHandler.showSendFailureDialog(
            withMessage: message,
            title:title,
            action: { [weak self] in
                guard let self = self else { return }
                
                for (index, message) in self.messages.enumerated() {
                    if message.getID() == messageID {
                        self.messages.remove(at: index)
                        DispatchQueue.main.async() {
                            self.tableView?.reloadData()
                        }
                        return
                    }
                }
            }
        )
    }
}

// MARK: - WEBIM: OperatorTypingListener
extension ChatTableViewController: OperatorTypingListener {
    func onOperatorTypingStateChanged(isTyping: Bool) {
        guard webimService.getCurrentOperator() != nil else { return }
        
        if isTyping {
            let statusTyping = OperatorStatus.isTyping.rawValue.localized
            let operatorStatus = ["Status": statusTyping]
            NotificationCenter.default.post(
                name: .shouldChangeOperatorStatus,
                object: nil,
                userInfo: operatorStatus
            )
        } else {
            let operatorStatus = ["Status": OperatorStatus.online.rawValue.localized]
            NotificationCenter.default.post(
                name: .shouldChangeOperatorStatus,
                object: nil,
                userInfo: operatorStatus
            )
        }
    }
}

// MARK: - WEBIM: CurrentOperatorChangeListener
extension ChatTableViewController: CurrentOperatorChangeListener {
    func changed(operator previousOperator: Operator?, to newOperator: Operator?) {
        updateCurrentOperatorInfo(to: newOperator)
    }
}

// MARK: - WEBIM: ChatStateLisneter
extension ChatTableViewController: ChatStateListener {
    func changed(state previousState: ChatState, to newState: ChatState) {
        if newState == .closedByVisitor || newState == .closed || newState == .closedByOperator {
            // TODO: rating operator
        }
    }
}
