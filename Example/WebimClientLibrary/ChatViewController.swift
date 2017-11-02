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


import UIKit

import PopupDialog
import SlackTextViewController
import WebimClientLibrary


class ChatViewController: SLKTextViewController {
    
    // MARK: - Constants
    
    private enum SessionDefaults: String {
        case ACCOUNT_NAME = "demo"
        case LOCATION = "mobile"
        case PAGE_TITLE = "iOS demo app"
    }
    
    private enum VisitorField: String {
        case ID = "id"
        case NAME = "display_name"
        case CRC = "crc"
    }
    
    private enum VisitorFieldValue: String {
        // Hardcoded. See https://webim.ru/help/identification/
        case ID = "1234567890987654321"
        case NAME = "Никита"
        case CRC = "ffadeb6aa3c788200824e311b9aa44cb"
    }
    
    
    // MARK: - Properties
    let imagePicker = UIImagePickerController()
    let refreshControl = UIRefreshControl()
    private lazy var alreadyRated = [String : Bool]()
    private var lastOperatorID: String?
    private lazy var messages = [Message]()
    private var messageStream: MessageStream?
    private var messageTracker: MessageTracker?
    private var webimSession: WebimSession? = nil
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isInverted = false
        
        tableView?.estimatedRowHeight = 64.0
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorStyle = .none
        tableView?.register(MessageTableViewCell.self,
                            forCellReuseIdentifier: "MessageCell")
        
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                            target: self,
                                                            action: #selector(endChat))
        
        leftButton.setImage(#imageLiteral(resourceName: "ClipIcon"),
                            for: .normal)
        
        imagePicker.delegate = self
        
        // Setting an image to NavigationItem TitleView.
        let navigationItemImageView = UIImageView(image: #imageLiteral(resourceName: "LogoWebimNavigationBar"))
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
        
        // MARK: WEBIM: Hardcoded visitor fields.
        let visitorFieldsJSONString = "{\"\(VisitorField.ID.rawValue)\":\"\(VisitorFieldValue.ID.rawValue)\",\"\(VisitorField.NAME.rawValue)\":\"\(VisitorFieldValue.NAME.rawValue)\",\"\(VisitorField.CRC.rawValue)\":\"\(VisitorFieldValue.CRC.rawValue)\"}"
        
        let deviceToken: String? = UserDefaults.standard.object(forKey: AppDelegate.UserDefaultsKey.DEVICE_TOKEN.rawValue) as? String
        
        // MARK: WEBIM: Creating session.
        webimSession = try! Webim.newSessionBuilder()
            .set(accountName: SessionDefaults.ACCOUNT_NAME.rawValue)
            .set(location: SessionDefaults.LOCATION.rawValue)
            .set(pageTitle: SessionDefaults.PAGE_TITLE.rawValue)
            .set(visitorFieldsJSONString: visitorFieldsJSONString)
            .set(fatalErrorHandler: self)
            .set(remoteNotificationSystem: (deviceToken != nil) ? .APNS : .NONE)
            .set(deviceToken: deviceToken)
            .build()
        
        // MARK: WEBIM: Starting session.
        try! webimSession!.resume()
        
        // MARK: WEBIM: Receiving message stream.
        messageStream = webimSession!.getStream()
        
        // MARK: WEBIM: Creating message tracker.
        try! messageTracker = messageStream!.new(messageTracker: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        try! webimSession?.pause()
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        // MARK: WEBIM: Send visitor typing state.
        try! messageStream?.setVisitorTyping(draftMessage: textView.text)
    }
    
    // Send message button.
    override func didPressRightButton(_ sender: Any?) {
        textView.refreshFirstResponder()
        
        if let text = textView.text {
            if !text.isEmpty {
                // MARK: WEBIM: Send message.
                _ = try! messageStream?.send(message: text)
            }
            
            textView.text = ""
            
            // Delete visitor typing draft after message is sent.
            try! messageStream?.setVisitorTyping(draftMessage: nil)
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
                                                           action:  #selector (ChatViewController.rateOperator(_:)))
            cell.avatarImageView.addGestureRecognizer(gestureRecognizer)
        }
        
        return cell
    }
    
    
    // MARK: Private methods
    
    @objc private func requestMessages() {
        // MARK: WEBIM: Requesting messages for this chat.
        try! messageTracker!.getNextMessages(byLimit: 25) { messages in
            for message in messages {
                self.messages.append(message)
                self.messages = messages.sorted { $0.getID() > $1.getID() }
                
                DispatchQueue.main.async() {
                    self.tableView?.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }
    
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
    
    @objc private func endChat() {
        // WEBIM: Chat state.
        let chatState = messageStream?.getChatState()
        
        // WEBIM: Close chat.
        try! messageStream?.closeChat()
        
        if let operatorID = lastOperatorID {
            if alreadyRated[operatorID] != true {
                // Don't offer to rate an operator if a visitor already did it independently.
                if chatState == .QUEUE
                    || chatState == .CHATTING
                    || chatState == .CLOSED_BY_OPERATOR
                    || chatState == .INVITATION {
                    showRatingDialog(forOperator: operatorID)
                }
            }
        }
    }
    
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
    
    private func showRatingDialog(forOperator operatorID: String) {
        let ratingVC = RatingViewController(nibName: "RatingViewController",
                                            bundle: nil)
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                gestureDismissal: true)
        
        let cancelButton = CancelButton(title: "Cancel",
                                        height: 60,
                                        dismissOnTap: true,
                                        action: nil)
        let rateButton = DefaultButton(title: "Rate",
                                       height: 60,
                                       dismissOnTap: true) {
                                        self.alreadyRated[operatorID] = true
                                        
                                        // WEBIM: Rate operator.
                                        try! self.messageStream?.rateOperatorWith(id: operatorID,
                                                                                  byRating: Int(ratingVC.ratingView.rating))
        }
        popup.addButtons([cancelButton,
                          rateButton])
        
        present(popup, animated: true, completion: nil)
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
                    
                    // MARK: WEBIM: Send file.
                    let _ = try! messageStream?.send(file: imageData,
                                                     filename: imageName,
                                                     mimeType: mimeType.value,
                                                     completionHandler: nil)
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
        // Handle an error.
    }
    
}

// MARK: - WEBIM: MessageListener
extension ChatViewController: MessageListener {
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        if let previousMessage = previousMessage {
            for (index, message) in messages.enumerated() {
                if previousMessage.getID() == message.getID() {
                    messages.insert(newMessage,
                                    at: (index + 1))
                }
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
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == message.getID() {
                messages.remove(at: messageIndex)
                break
            }
        }
        
        DispatchQueue.main.async() {
            self.tableView?.reloadData()
            self.scrollToBottom()
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
        for (messageIndex, iteratedMessage) in messages.enumerated() {
            if iteratedMessage.getID() == oldVersion.getID() {
                messages[messageIndex] = newVersion
            }
        }
        
        DispatchQueue.main.async() {
            self.tableView?.reloadData()
            self.scrollToBottom()
        }
    }
    
}
