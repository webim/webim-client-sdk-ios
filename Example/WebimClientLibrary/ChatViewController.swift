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

import PopupDialog
import SlackTextViewController
import UIKit
import WebimClientLibrary

/**
 View controller that visualize chat.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class ChatViewController: SLKTextViewController {
    
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private let refreshControl = UIRefreshControl()
    private lazy var alreadyRated = [String : Bool]()
    private var lastOperatorID: String?
    private lazy var messages = [Message]()
    private lazy var webimService = WebimService()
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        setupTableView()
        setupNavigationItem()
        setupSlackTextViewController()
        setupWebimSession()
    }
    
    // MARK: SlackTextViewController methods
    
    override func textViewDidChange(_ textView: UITextView) {
        webimService.setVisitorTyping(draft: textView.text)
    }
    
    // Send message button.
    override func didPressRightButton(_ sender: Any?) {
        textView.refreshFirstResponder()
        
        if let text = textView.text {
            if !text.isEmpty {
                webimService.send(message: text)
            }
            
            textView.text = ""
            
            // Delete visitor typing draft after message is sent.
            webimService.setVisitorTyping(draft: nil)
        }
    }
    
    // Send file buton.
    override func didPressLeftButton(_ sender: Any?) {
        dismissKeyboard(true)
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker,
                animated: true,
                completion: nil)
    }
    
    // MARK: UICollectionViewDataSource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        
        if (message.getType() == .FILE_FROM_OPERATOR)
            || (message.getType() == .FILE_FROM_VISITOR) {
            let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                           action: #selector(ChatViewController.showFile(_:)))
            cell.bodyLabel.addGestureRecognizer(gestureRecognizer)
        }
        
        return cell
    }
    
    
    // MARK: Private methods
    
    /**
     Sets up table view.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupTableView() {
        tableView?.estimatedRowHeight = 64.0
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorStyle = .none
        tableView?.register(MessageTableViewCell.self,
                            forCellReuseIdentifier: "MessageCell")
        
        // Setup refresh control.
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = refreshControl
        } else {
            tableView?.addSubview(refreshControl)
        }
        refreshControl.addTarget(self,
                                 action: #selector(requestMessages),
                                 for: .valueChanged)
        refreshControl.tintColor = MAIN_BACKGROUND_COLOR
        refreshControl.attributedTitle = REFRESH_CONTROL_TEXT
    }
    
    /**
     Sets up SlackTextViewController view.
     - SeeAlso:
     `SLKTextViewController` protocol.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupSlackTextViewController() {
        isInverted = false
        leftButton.setImage(#imageLiteral(resourceName: "ClipIcon"),
                            for: .normal)
    }
    
    /**
     Sets up navigation item.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                            target: self,
                                                            action: #selector(endChat))
        
        // Setting an image to NavigationItem TitleView.
        let navigationItemImageView = UIImageView(image: #imageLiteral(resourceName: "LogoWebimNavigationBar"))
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
    }
    
    /**
     Sets up `WebimService` class.
     - SeeAlso:
     `WebimService` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupWebimSession() {
        webimService.createSession()
        webimService.startSession()
        
        webimService.setMessageStream()
        
        webimService.setMessageTracker(withMessageListener: self)
        webimService.getLastMessages() { messages in
            self.messages.insert(contentsOf: messages,
                                 at: 0)
            
            DispatchQueue.main.async() {
                self.tableView?.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    /**
     Requests messages from above of the message history.
     - SeeAlso:
     `WebimService` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    @objc private func requestMessages() {
        webimService.getNextMessages() { messages in
            self.messages.insert(contentsOf: messages,
                                 at: 0)
            
            DispatchQueue.main.async() {
                self.tableView?.reloadData()
                
                self.refreshControl.endRefreshing()
                
                self.scrollToBottom()
            }
        }
    }
    
    /**
     Closes chat in virtual context.
     - SeeAlso:
     `WebimService` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    @objc private func endChat() {
        webimService.closeChat()
        
        if let operatorID = lastOperatorID {
            if alreadyRated[operatorID] != true { // Don't offer to rate an operator if a visitor already did it independently.
                showRatingDialog(forOperator: operatorID)
            }
        }
    }
    
    /**
     Rates current operator.
     - SeeAlso:
     `WebimService` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    @objc private func rateOperator(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let tapLocation = recognizer.location(in: tableView)
            if let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) {
                let message = messages[tapIndexPath.row]
                if let operatorID = message.getOperatorID() {
                    showRatingDialog(forOperator: operatorID)
                }
            }
        }
    }
    
    /**
     Show preview of file inside a chat message.
     - SeeAlso:
     `WebimService` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    @objc private func showFile(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let tapLocation = recognizer.location(in: tableView)
            if let tapIndexPath = tableView?.indexPathForRow(at: tapLocation) {
                let message = messages[tapIndexPath.row]
                
                if let attachment = message.getAttachment() {
                    if let fileName = attachment.getFileName() {
                        if let attachmentURLString = attachment.getURLString() {
                            var popupMessage: String?
                            var image: UIImage?
                            
                            let attachmentContentType = attachment.getContentType()
                            if (attachmentContentType == "image/gif")
                                || (attachmentContentType == "image/jpeg")
                                || (attachmentContentType == "image/png")
                                || (attachmentContentType == "image/tiff") {
                                let attachmentURL = URL(string: attachmentURLString)!
                                let semaphore = DispatchSemaphore(value: 0)
                                let request = URLRequest(url: attachmentURL)
                                URLSession.shared.dataTask(with: request,
                                                           completionHandler: { data, _, _ in
                                                            if let data = data {
                                                                if let downloadedImage = UIImage(data: data) {
                                                                    image = downloadedImage
                                                                } else {
                                                                    popupMessage = ShowFileDialog.INVALID_IMAGE_FORMAT.rawValue
                                                                }
                                                            } else {
                                                                popupMessage = ShowFileDialog.INVALID_IMAGE_LINK.rawValue
                                                            }
                                                            
                                                            semaphore.signal()
                                }).resume()
                                
                                _ = semaphore.wait(timeout: .distantFuture)
                            } else {
                                popupMessage = ShowFileDialog.NOT_IMAGE.rawValue
                            }
                            
                            let button = CancelButton(title: ShowFileDialog.BUTTON_TITLE.rawValue,
                                                      action: nil)
                            let popup = PopupDialog(title: fileName,
                                                    message: popupMessage,
                                                    image: image,
                                                    buttonAlignment: .horizontal,
                                                    transitionStyle: .bounceUp,
                                                    gestureDismissal: true,
                                                    completion: nil)
                            popup.addButton(button)
                            
                            self.present(popup,
                                         animated: true,
                                         completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Shows RatingViewController.
     - SeeAlso:
     `RatingViewController` class.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func showRatingDialog(forOperator operatorID: String) {
        let ratingVC = RatingViewController(nibName: "RatingViewController",
                                            bundle: nil)
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                gestureDismissal: true)
        
        let cancelButton = CancelButton(title: RatingDialog.CANCEL_BUTTON_TITLE.rawValue,
                                        height: 60,
                                        dismissOnTap: true,
                                        action: nil)
        let rateButton = DefaultButton(title: RatingDialog.ACTION_BUTTON_TITLE.rawValue,
                                       height: 60,
                                       dismissOnTap: true) {
                                        self.alreadyRated[operatorID] = true
                                        
                                        self.webimService.rateOperator(withID: operatorID,
                                                                       byRating: Int(ratingVC.ratingView.rating))
        }
        popup.addButtons([cancelButton,
                          rateButton])
        
        present(popup,
                animated: true,
                completion: nil)
    }
    
    /**
     Scroll table view to the bottom.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageData = UIImagePNGRepresentation(image)!
            
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
                if let imageName = imageURL.lastPathComponent {
                    let mimeType = MimeType(url: imageURL as URL)
                    
                    webimService.send(file: imageData,
                                      fileName: imageName,
                                      mimeType: mimeType.value,
                                      completionHandler: self)
                }
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

// MARK: - WEBIM: FatalErrorHandler
extension ChatViewController: FatalErrorHandler {
    
    func on(error: WebimError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .ACCOUNT_BLOCKED:
            print("Account with used account name is blocked by Webim service.")
            // Assuming to contact with Webim support.
        case .PROVIDED_VISITOR_EXPIRED:
            print("Provided visitor fields expired.")
            // Assuming to re-authorize it and re-create session object.
        case .UNKNOWN:
            print("An unknown error occured.")
        case .VISITOR_BANNED:
            print("Visitor with provided visitor fields is banned by an operator.")
        case .WRONG_PROVIDED_VISITOR_HASH:
            print("Provided visitor fields are wrong.")
            // Assuming to check visitor field generating.
        }
    }
    
}

// MARK: - WEBIM: MessageListener
extension ChatViewController: MessageListener {
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        if let previousMessage = previousMessage {
            var added = false
            
            for (index, message) in messages.enumerated() {
                if previousMessage.isEqual(to: message) {
                    messages.insert(newMessage,
                                    at: index + 1)
                    
                    added = true
                    
                    break
                }
            }
            
            if !added {
                messages.append(newMessage)
            }
        } else {
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
    
    func onSuccess(messageID: String) {
        // Ignored.
    }
    
    func onFailure(messageID: String,
                   error: SendFileError) {
        var message: String?
        switch error {
        case .FILE_SIZE_EXCEEDED:
            message = SendFileErrorMessage.FILE_SIZE_EXCEEDED.rawValue
        case .FILE_TYPE_NOT_ALLOWED:
            message = SendFileErrorMessage.FILE_TYPE_NOT_ALLOWED.rawValue
        }
        
        let popupDialog = PopupDialog(title: SendFileErrorMessage.TITLE.rawValue,
                                      message: message)
        let okButton = CancelButton(title: SendFileErrorMessage.BUTTON_TITLE.rawValue) {
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
        popupDialog.addButton(okButton)
        self.present(popupDialog,
                     animated: true,
                     completion: nil)
        
    }

}
