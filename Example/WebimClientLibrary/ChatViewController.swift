//
//  ChatViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 02.10.17.
//  Copyright © 2017 Webim. All rights reserved.
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

import SlackTextViewController
import UIKit
import WebimClientLibrary

final class ChatViewController: SLKTextViewController {
    
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private let refreshControl = UIRefreshControl()
    private lazy var alreadyRated = [String: Bool]()
    private var lastOperatorID: String?
    private lazy var messages = [Message]()
    private var popupDialogHandler: PopupDialogHandler?
    private var scrollToBottomButton: UIButton?
    private var webimService: WebimService?
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webimService = WebimService(fatalErrorHandlerDelegate: self,
                                    departmentListHandlerDelegate: self)
        popupDialogHandler = PopupDialogHandler(delegate: self)
        
        imagePicker.delegate = self
        
        setupNavigationItem()
        setupRefreshControl()
        setupSlackTextViewController()
        setupWebimSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupTableView()
        
        scrollToBottomButton?.removeFromSuperview() // Need for redrawing after device is rotated.
        setupScrollToBottomButton()
    }
    
    // For testing purposes.
    func set(messages: [Message]) {
        self.messages = messages
    }
    
    // MARK: SlackTextViewController methods
    
    override func textViewDidChange(_ textView: UITextView) {
        webimService!.setVisitorTyping(draft: textView.text)
    }
    
    override func didPressRightButton(_ sender: Any?) { // Send message button
        textView.refreshFirstResponder()
        
        if let text = textView.text,
            !text.isEmpty {
            webimService!.send(message: text) { [weak self] in
                self?.textView.text = ""
                self?.webimService!.setVisitorTyping(draft: nil) // Delete visitor typing draft after message is sent.
            }
        }
    }
    
    override func didPressLeftButton(_ sender: Any?) { // Send file buton
        dismissKeyboard(true)
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker,
                animated: true,
                completion: nil)
    }
    
    // MARK: UICollectionViewDataSource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        if messages.count > 0 {
            tableView.backgroundView = nil
            
            return 1
        } else {
            tableView.emptyTableView(message: TableView.emptyTableViewText.rawValue.localized)
            
            return 0
        }
    }
    
    
    // MARK: UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell",
                                                       for: indexPath) as? MessageTableViewCell else {
                                                        fatalError("The dequeued cell is not an instance of MessageTableViewCell.")
        }
        
        let message = messages[indexPath.row]
        cell.setContent(withMessage: message)
        
        if let operatorID = message.getOperatorID() {
            lastOperatorID = operatorID // For using on chat closing.
            let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                           action:  #selector(ChatViewController.rateOperator(_:)))
            cell.avatarImageView.addGestureRecognizer(gestureRecognizer)
        }
        
        if (message.getType() == .fileFromOperator)
            || (message.getType() == .fileFromVisitor) {
            let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                           action: #selector(ChatViewController.showFile(_:)))
            cell.bodyLabel.addGestureRecognizer(gestureRecognizer)
        }
        
        return cell
    }
    
    // MARK: UIScrollViewDelegate protocol methods
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView!.contentOffset.y >= (tableView!.contentSize.height - tableView!.frame.size.height - ScrollToBottomButton.visibilityThreshold.rawValue) {
            UIView.animate(withDuration: ScrollToBottomButtonAnimation.duration.rawValue,
                           delay: 0.1,
                           options: [],
                           animations: { [weak self] in
                            self?.scrollToBottomButton?.alpha = 0.0
            }
                , completion: nil)
        } else {
            UIView.animate(withDuration: ScrollToBottomButtonAnimation.duration.rawValue,
                           delay: 0.1,
                           options: [],
                           animations: { [weak self] in
                            self?.scrollToBottomButton?.alpha = 1.0
            }
                , completion: nil)
        }
    }
    
    // MARK: Private methods
    
    private func setupTableView() {
        tableView?.backgroundColor = backgroundTableViewColor.color()
        
        tableView?.estimatedRowHeight = 64.0
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.separatorStyle = .none
        tableView?.register(MessageTableViewCell.self,
                            forCellReuseIdentifier: "MessageCell")
    }
    
    private func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = refreshControl
        } else {
            tableView?.addSubview(refreshControl)
        }
        refreshControl.addTarget(self,
                                 action: #selector(requestMessages),
                                 for: .valueChanged)
        refreshControl.tintColor = textMainColor.color()
        refreshControl.attributedTitle = NSAttributedString(string: TableView.refreshControlText.rawValue.localized,
                                                            attributes: [.foregroundColor : textMainColor.color()])
    }
    
    private func setupSlackTextViewController() {
        isInverted = false
        
        leftButton.setImage(#imageLiteral(resourceName: "Clip"),
                            for: .normal)
        leftButton.accessibilityLabel = LeftButton.accessibilityLabel.rawValue.localized
        leftButton.accessibilityHint = LeftButton.accessibilityHint.rawValue.localized
        
        rightButton.setImage(#imageLiteral(resourceName: "SendMessage"),
                             for: .normal)
        rightButton.setTitle(nil,
                             for: .normal)
        
        textInputbar.tintColor = textTintColor.color()
        textInputbar.backgroundColor = backgroundSecondaryColor.color()
        textInputbar.textView.textInputView.layer.backgroundColor = backgroundTextFieldColor.color().cgColor
        textInputbar.textView.textColor = textTextFieldColor.color()
        textInputbar.textView.tintColor = textTextFieldColor.color()
        textInputbar.textView.keyboardAppearance = ColorScheme.shared.keyboardAppearance()
        textInputbar.textView.layer.cornerRadius = 15.0
    }
    
    private func setupNavigationItem() {
        setupLeftBarButtonItem()
        setupRightBarButtonItem()
        setupTitleView()
    }
    
    private func setupLeftBarButtonItem() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(ColorScheme.shared.backButtonImage(),
                            for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = BackButton.accessibilityLabel.rawValue.localized
        backButton.accessibilityHint = BackButton.accessibilityHint.rawValue.localized
        backButton.addTarget(self,
                             action: #selector(onBackButtonClick(sender:)),
                             for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @objc
    private func onBackButtonClick(sender: UIButton) {
        webimService!.stopSession()
        
        navigationController?.popViewController(animated: true)
    }
    
    private func setupRightBarButtonItem() {
        let closeChatButton = UIButton(type: .custom)
        closeChatButton.setImage(ColorScheme.shared.closeChatButtonImage(),
                                 for: .normal)
        closeChatButton.imageView?.contentMode = .scaleAspectFit
        closeChatButton.accessibilityLabel = CloseChatButton.accessibilityLabel.rawValue.localized
        closeChatButton.accessibilityHint = CloseChatButton.accessibilityHint.rawValue.localized
        closeChatButton.addTarget(self,
                                  action: #selector(endChat),
                                  for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeChatButton)
    }
    
    @objc
    private func endChat() {
        webimService!.closeChat()
        
        if let operatorID = lastOperatorID {
            if alreadyRated[operatorID] != true { // Don't offer to rate an operator if a visitor already did it independently.
                if showRatingDialog(forOperator: operatorID) {
                    return
                }
            }
        }
        
        popupDialogHandler?.showChatClosedDialog()
    }
    
    private func setupTitleView() {
        let navigationItemImageView = UIImageView(image: ColorScheme.shared.navigationItemImage())
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
    }
    
    private func setupScrollToBottomButton() {
        let xPosition = view.frame.size.width - ScrollToBottomButton.size.rawValue - ScrollToBottomButton.margin.rawValue
        let yPosition = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.size.height + ScrollToBottomButton.margin.rawValue
        scrollToBottomButton = UIButton(frame: CGRect(x: xPosition,
                                                      y: yPosition,
                                                      width: ScrollToBottomButton.size.rawValue,
                                                      height: ScrollToBottomButton.size.rawValue))
        scrollToBottomButton!.setImage(ColorScheme.shared.scrollToBottomButtonImage(),
                                       for: .normal)
        scrollToBottomButton!.addTarget(self,
                                        action: #selector(scrollToBottom),
                                        for: .touchUpInside)
        scrollToBottomButton!.alpha = 0.0
        view.addSubview(scrollToBottomButton!)
    }
    
    private func setupWebimSession() {
        webimService!.createSession()
        webimService!.startSession()
        
        webimService!.setMessageStream()
        webimService!.setMessageTracker(withMessageListener: self)
        webimService!.setHelloMessageListener(with: self)
        webimService!.getLastMessages() { [weak self] messages in
            self?.messages.insert(contentsOf: messages,
                                  at: 0)
            DispatchQueue.main.async() {
                self?.tableView?.reloadData()
                self?.scrollToBottom()
                self?.webimService?.setChatRead()
            }
        }
    }
    
    @objc
    private func requestMessages() {
        webimService!.getNextMessages() { [weak self] messages in
            self?.messages.insert(contentsOf: messages,
                                  at: 0)
            DispatchQueue.main.async() {
                self?.tableView?.reloadData()
                self?.refreshControl.endRefreshing()
                self?.webimService?.setChatRead()
            }
        }
    }
    
    @objc
    private func rateOperator(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else {
            return
        }
        
        let tapLocation = recognizer.location(in: tableView)
        if let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) {
            let message = messages[tapIndexPath.row]
            if let operatorID = message.getOperatorID() {
                _ = showRatingDialog(forOperator: operatorID)
            }
        }
    }
    
    private func showRatingDialog(forOperator operatorID: String) -> Bool {
        guard webimService!.isChatExist() else {
            return false
        }
        
        popupDialogHandler?.showRatingDialog(forOperator: operatorID) { [weak self] rating in
            self?.alreadyRated[operatorID] = true
            
            self?.webimService!.rateOperator(withID: operatorID,
                                            byRating: rating,
                                            completionHandler: self)
        }
        
        return true
    }
    
    @objc
    private func showFile(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else {
            return
        }
        
        let tapLocation = recognizer.location(in: tableView)
        guard let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) else {
            return
        }
        
        let message = messages[tapIndexPath.row]
        guard let data = message.getData(),
            let fileData = data.getAttachment() else {
            return
        }
        let attachment = fileData.getFileInfo()
        
        guard let contentType = attachment.getContentType(),
        let attachmentURL = attachment.getURL() else {
            return
        }
        
        var popupMessage: String?
        var image: UIImage?
        
        if isImage(contentType: contentType) {
            let semaphore = DispatchSemaphore(value: 0)
            let request = URLRequest(url: attachmentURL)
            
            print("Requesting file: \(attachmentURL.absoluteString)")
            
            URLSession.shared.dataTask(with: request,
                                       completionHandler: { data, _, _ in
                                        if let data = data {
                                            if let downloadedImage = UIImage(data: data) {
                                                image = downloadedImage
                                            } else {
                                                popupMessage = ShowFileDialog.imageFormatInvalid.rawValue.localized
                                            }
                                        } else {
                                            popupMessage = ShowFileDialog.imageLinkInvalid.rawValue.localized
                                        }
                                        
                                        semaphore.signal()
            }).resume()
            
            _ = semaphore.wait(timeout: .distantFuture)
        } else {
            popupMessage = ShowFileDialog.notImage.rawValue
        }
        
        popupDialogHandler?.showFileDialog(withMessage: popupMessage,
                                           title: attachment.getFileName(),
                                           image: image)
    }
    
    @objc
    private func scrollToBottom() {
        if messages.isEmpty {
            return
        }
        
        let bottomMessageIndex = IndexPath(row: (tableView?.numberOfRows(inSection: 0))! - 1,
                                           section: 0)
        tableView?.scrollToRow(at: bottomMessageIndex,
                               at: .bottom,
                               animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate {
    
    // MARK: - Methods
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let imageData: Data
                let mimeType = MimeType(url: imageURL as URL)
                let imageName = imageURL.lastPathComponent
                let imageExtension = imageURL.pathExtension.lowercased()
                if imageExtension == "jpg" || imageExtension == "jpeg" {
                    imageData = image.jpegData(compressionQuality: 1.0)!
                } else {
                    imageData = image.pngData()!
                }

                webimService!.send(file: imageData,
                                   fileName: imageName,
                                   mimeType: mimeType.value,
                                   completionHandler: self)
            }
        }
        
        dismiss(animated: true,
                completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true,
                completion: nil)
    }
    
}

// MARK: - UINavigationControllerDelegate
extension ChatViewController: UINavigationControllerDelegate {
    // For image picker.
}

// MARK: - WEBIM: HelloMessageListener
extension ChatViewController: HelloMessageListener {
    func helloMessage(message: String) {
        print("Received Hello message: \"\(message)\"")
    }
}

// MARK: - WEBIM: MessageListener
extension ChatViewController: MessageListener {
    
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
            self.scrollToBottom()
        }
    }
    
    func removed(message: Message) {
        var toUpdate = false
        
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == message.getID() {
                messages.remove(at: messageIndex)
                toUpdate = true
                
                break
            }
        }
        
        if toUpdate {
            DispatchQueue.main.async() {
                self.tableView?.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func removedAllMessages() {
        messages.removeAll()
        
        DispatchQueue.main.async() {
            self.tableView?.reloadData()
        }
    }
    
    func changed(message oldVersion: Message,
                 to newVersion: Message) {
        var toUpdate = false
        
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == oldVersion.getID() {
                messages[messageIndex] = newVersion
                toUpdate = true
                
                break
            }
        }
        
        if toUpdate {
            DispatchQueue.main.async() {
                self.tableView?.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
}

// MARK: - SendFileCompletionHandler
extension ChatViewController: SendFileCompletionHandler {
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        // Ignored.
    }
    
    func onFailure(messageID: String,
                   error: SendFileError) {
        DispatchQueue.main.sync {
            var message: String?
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
            }
            
            popupDialogHandler?.showFileSendFailureDialog(withMessage: message!) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
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
        }
    }
    
}

// MARK: - RateOperatorCompletionHandler
extension ChatViewController: RateOperatorCompletionHandler {
    
    // MARK: - Methods
    
    func onSuccess() {
        // Ignored.
    }
    
    func onFailure(error: RateOperatorError) {
        popupDialogHandler?.showRatingFailureDialog()
    }
    
}

// MARK: - FatalErrorHandler
extension ChatViewController: FatalErrorHandlerDelegate {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        popupDialogHandler?.showCreatingSessionFailureDialog(withMessage: message)
    }
    
}

// MARK: - DepartmentListHandlerDelegate
extension ChatViewController: DepartmentListHandlerDelegate {
    
    // MARK: - Methods
    func show(departmentList: [Department],
              action: @escaping (String) -> ()) {
        popupDialogHandler?.showDepartmentListDialog(withDepartmentList: departmentList,
                                                     action: action)
    }
    
}
