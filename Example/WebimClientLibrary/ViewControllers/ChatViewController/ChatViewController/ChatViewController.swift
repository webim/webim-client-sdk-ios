//
//  ChatViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 01/10/2019.
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

import MobileCoreServices
import UIKit
import Nuke
import WebimClientLibrary

class ChatViewController: UIViewController, WMToolbarBackgroundViewDelegate, DepartmentListHandlerDelegate {
    
    var popupActionsViewController: PopupActionsViewController?
    
    private var alreadyPutTextFromBufferString = false
    private var textInputTextViewBufferString: String?
    private var rateOperatorID: String?
    let newRefreshControl = UIRefreshControl()
    
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    var selectedMessage: Message?
    var scrollButtonIsHidden = true
    var surveyCounter = -1
    // MARK: - Private properties
    
    private var alreadyRatedOperators = [String: Bool]()
    var cellHeights = [IndexPath: CGFloat]()
    private var overlayWindow: UIWindow?
    private var visibleRows = [IndexPath]()
    private var scrollToBottom = false
    
    var rateStarsViewController: RateStarsViewController?
    var surveyCommentViewController: SurveyCommentViewController?
    var surveyRadioButtonViewController: SurveyRadioButtonViewController?
    
    var chatMessages = [Message]()
    var searchMessages = [Message]()
    var showSearchResult = false
    
    var hideKeyboardOnScrollEnabled = false
    lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    var delayedSurvayQuestion: SurveyQuestion?
    
    private lazy var filePicker = FilePicker(presentationController: self, delegate: self)
    
    // MARK: - Constraints
    let buttonWidthHeight: CGFloat = 20
    let fileButtonLeadingSpacing: CGFloat = 20
    let fileButtonTrailingSpacing: CGFloat = 10
    let textInputBackgroundViewTopBottomSpacing: CGFloat = 8
    
    // MARK: - Outletls
    @IBOutlet var toolbarBackgroundView: WMToolbarBackgroundView!
    @IBOutlet var toolbarView: WMToolbarView!
    @IBOutlet var messagesTableViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Subviews
    // Scroll button
    lazy var scrollButton: UIButton = createUIButton(type: .system)
    
    // Top bar (top navigation bar)
    lazy var titleViewOperatorAvatarImageView: UIImageView = createUIImageView(contentMode: .scaleAspectFit)
    lazy var titleViewOperatorNameLabel: UILabel = UILabel.createUILabel(systemFontSize: 15)
    lazy var titleViewOperatorStatusLabel: UILabel = UILabel.createUILabel(systemFontSize: 13, systemFontWeight: .light)
    var titleViewOperatorInfo: String?
    var titleViewOperatorTitle: String?
    
    lazy var titleViewTypingIndicator: TypingIndicator = createTypingIndicator()
    
    var connectionErrorView: UIView!
    var thanksView: WMThanksAlertView!
    var chatTestView = ChatTestView.loadXibView()
    
    var didLoad = false
    // Bottom bar
    lazy var fileButton: UIButton = createCustomUIButton(type: .system)
    
    override var inputAccessoryView: UIView? {
        return toolbarBackgroundView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    func showToolbarWithHeight(_ height: CGFloat) {}
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WebimServiceController.shared.notFatalErrorHandler = self
        WebimServiceController.shared.departmentListHandlerDelegate = self
        WebimServiceController.shared.fatalErrorHandlerDelegate = self
        updateCurrentOperatorInfo(to: WebimServiceController.currentSession.getCurrentOperator())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureThanksView()
        configureToolbarView()
        setupScrollButton()
        setupWebimSession()
        self.addDismissKeyboardGesture()
        
        setupRefreshControl()
        
        if true {
            setupTestView()
        }
        configureNotifications()
    }
    override func viewDidLayoutSubviews() {
        if !didLoad {
            recountTableSize()
        }
        didLoad = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WMTestManager.testDialogModeEnabled = false
        updateTestModeState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Will not trigger method hidePopupActionsViewController()
        // if PopupActionsTableView is not presented
        self.popupActionsViewController?.hidePopupActionsViewController()
        
        coordinator.animate(
            alongsideTransition: { context in
                // Save visible rows position
                if let visibleRows = self.chatTableView?.indexPathsForVisibleRows {
                    self.visibleRows = visibleRows
                }
                context.viewController(forKey: .from)
            },
            completion: { _ in
                // Scroll to the saved position prior to screen rotate
                if let lastVisibleRow = self.visibleRows.last {
                    self.chatTableView?.scrollToRowSafe(
                        at: lastVisibleRow,
                        at: .bottom,
                        animated: true
                    )
                }
            }
        )
    }
    
    // MARK: - Methods
    @objc func dismissViewKeyboard() {
        self.toolbarView.messageView.resignMessageViewFirstResponder()
    }
    
    // MARK: - Private methods
    
    func configureToolbarView() {
        self.toolbarBackgroundView.delegate = self
        self.toolbarBackgroundView.addSubview(toolbarView)
        self.toolbarView.messageView.delegate = self
        toolbarView.setup()
    }
    
    @objc
    func titleViewTapAction(_ sender: UITapGestureRecognizer) {
        self.showRateOperatorDialog()
    }
    
    @objc
    func updateOperatorStatus(typing: Bool, operatorStatus: String) {
        DispatchQueue.main.async {
            if typing {
                let offsetX = self.titleViewTypingIndicator.frame.width / 2
                self.titleViewTypingIndicator.addAllAnimations()
                self.titleViewOperatorStatusLabel.snp.remakeConstraints { (make) -> Void in
                    make.bottom.equalToSuperview()
                    make.centerX.equalToSuperview()
                        .inset(offsetX)
                    make.top.equalTo(self.titleViewOperatorNameLabel.snp.bottom)
                        .offset(2)
                }
            } else {
                self.titleViewTypingIndicator.removeAllAnimations()
                self.titleViewOperatorStatusLabel.snp.remakeConstraints { (make) -> Void in
                    make.bottom.equalToSuperview()
                    make.centerX.equalToSuperview()
                    make.top.equalTo(self.titleViewOperatorNameLabel.snp.bottom)
                        .offset(2)
                }
            }
            self.titleViewOperatorStatusLabel.text = operatorStatus
        }
    }
    
    @objc
    func updateOperatorInfo(operatorName: String, operatorAvatarURL: String, titleViewOperatorInfo: String, titleViewOperatorTitle: String ) {
        chatTestView.setupOperatorInfo(titleViewOperatorTitle: titleViewOperatorTitle, titleViewOperatorInfo: titleViewOperatorInfo)
        DispatchQueue.main.async {
            self.titleViewOperatorNameLabel.text = operatorName
            
            if operatorName == "Webim demo-chat".localized {
                self.titleViewOperatorStatusLabel.text = "No agent".localized
            } else {
                self.titleViewOperatorStatusLabel.text = "Online".localized
            }
            
            if operatorAvatarURL == OperatorAvatar.empty.rawValue {
                self.titleViewOperatorAvatarImageView.image = UIImage()
            } else if operatorAvatarURL == OperatorAvatar.placeholder.rawValue {
                self.titleViewOperatorAvatarImageView.image = userAvatarImagePlaceholder
                self.titleViewOperatorAvatarImageView.layer.cornerRadius = self.titleViewOperatorAvatarImageView.bounds.height / 2
            } else {
                guard let url = URL(string: operatorAvatarURL) else { return }
                
                let imageDownloadIndicator = CircleProgressIndicator()
                imageDownloadIndicator.lineWidth = 1
                imageDownloadIndicator.strokeColor = documentFileStatusPercentageIndicatorColour
                imageDownloadIndicator.isUserInteractionEnabled = false
                imageDownloadIndicator.isHidden = true
                imageDownloadIndicator.translatesAutoresizingMaskIntoConstraints = false
                
//                self.bottomBarQuoteAttachmentImageView.addSubview(imageDownloadIndicator)
//                imageDownloadIndicator.snp.remakeConstraints { (make) -> Void in
//                    make.edges.equalToSuperview()
//                        .inset(5)
//                }
                
                let loadingOptions = ImageLoadingOptions(
                    placeholder: UIImage(),
                    transition: .fadeIn(duration: 0.5)
                )
                let defaultRequestOptions = ImageRequestOptions()
                let imageRequest = ImageRequest(
                    url: url,
                    processors: [ImageProcessor.Circle()],
                    priority: .normal,
                    options: defaultRequestOptions
                )
                
                Nuke.loadImage(
                    with: imageRequest,
                    options: loadingOptions,
                    into: self.titleViewOperatorAvatarImageView,
                    progress: { _, completed, total in
                        DispatchQueue.global(qos: .userInteractive).async {
                            let progress = Float(completed) / Float(total)
                            DispatchQueue.main.async {
                                if imageDownloadIndicator.isHidden {
                                    imageDownloadIndicator.isHidden = false
                                    imageDownloadIndicator.enableRotationAnimation()
                                }
                                imageDownloadIndicator.setProgressWithAnimation(
                                    duration: 0.1,
                                    value: progress
                                )
                            }
                        }
                    },
                    completion: { _ in
                        DispatchQueue.main.async {
                            // self.bottomBarQuoteAttachmentImageView.image = ImageCache.shared[imageRequest]
                            imageDownloadIndicator.isHidden = true
                        }
                    }
                )
            }
        }
    }
    
    @objc
    func scrollTableView(_ sender: UIButton) {
        self.scrollToBottom(animated: true)
    }
    
    private func hidePlaceholderIfVisible() {
//        if !(self.textInputTextViewPlaceholderLabel.alpha == 0.0) {
//            UIView.animate(withDuration: 0.1) {
//                self.textInputTextViewPlaceholderLabel.alpha = 0.0
//            }
//        }
    }
    
    public func setConnectionStatus(connected: Bool) {
        DispatchQueue.main.async {
            if connected {
                self.navigationController?.setTopBar(isEnabled: false, isTranslucent: false, barTintColor: navigationBarTintColour, backgroundColor: navigationBarBarTintColour)
            } else {
                self.navigationController?.setTopBar(isEnabled: false, isTranslucent: false, barTintColor: navigationBarNoConnectionColour, backgroundColor: navigationBarNoConnectionColour)
            }
            self.connectionErrorView?.alpha = connected ? 0 : 1
        }
    }
    
    func sendMessage(_ message: String) {
        WebimServiceController.currentSession.send(message: message) {
            self.toolbarView.messageView.setMessageText("")
            // Delete visitor typing draft after message is sent.
            WebimServiceController.currentSession.setVisitorTyping(draft: nil)
        }
    }
    
    func sendImage(image: UIImage, imageURL: URL?) {
        dismissViewKeyboard()
        
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
        
        WebimServiceController.currentSession.send(
            file: imageData,
            fileName: imageName,
            mimeType: mimeType.value,
            completionHandler: self
        )
    }
    
    func sendFile(file: Data, fileURL: URL?) {
        if let fileURL = fileURL {
            WebimServiceController.currentSession.send(
                file: file,
                fileName: fileURL.lastPathComponent,
                mimeType: MimeType(url: fileURL as URL).value,
                completionHandler: self
            )
        } else {
            let url = URL(fileURLWithPath: "document.pdf")
            WebimServiceController.currentSession.send(
                file: file,
                fileName: url.lastPathComponent,
                mimeType: MimeType(url: url).value,
                completionHandler: self
            )
        }
    }
    
    func replyToMessage(_ message: String) {
        guard let messageToReply = selectedMessage else { return }
        WebimServiceController.currentSession.reply(
            message: message,
            repliedMessage: messageToReply,
            completion: {
                // Delete visitor typing draft after message is sent.
                WebimServiceController.currentSession.setVisitorTyping(draft: nil)
            }
        )
    }
    
    @objc
    func copyMessage() {
        guard let messageToCopy = selectedMessage else { return }
        UIPasteboard.general.string = messageToCopy.getText()
    }
    
    func editMessage(_ message: String) {
        guard let messageToEdit = selectedMessage else { return }
        WebimServiceController.currentSession.edit(
            message: messageToEdit,
            text: message,
            completionHandler: self
        )
    }
    
    func reactMessage(reaction: ReactionString) {
        guard let messageToReact = selectedMessage else { return }
        WebimServiceController.currentSession.react(
            reaction: reaction,
            message: messageToReact,
            completionHandler: self
        )
    }
    
    @objc
    func deleteMessage() {
        guard let messageToDelete = selectedMessage else { return }
        WebimServiceController.currentSession.delete(
            message: messageToDelete,
            completionHandler: self
        )
    }
    
    @objc
    func scrollToBottom(animated: Bool) {
        if messages().isEmpty {
            return
        }
        
        let row = (chatTableView.numberOfRows(inSection: 0)) - 1
        let bottomMessageIndex = IndexPath(row: row, section: 0)
        chatTableView?.scrollToRowSafe(at: bottomMessageIndex, at: .bottom, animated: animated)
    }
    
    @objc
    func scrollToTop(animated: Bool) {
        if messages().isEmpty {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.chatTableView?.scrollToRowSafe(at: indexPath, at: .top, animated: animated)
    }
    
    // MARK: - Private methods
    
    private func reloadTableWithNewData() {
        self.chatTableView?.reloadData()
        WebimServiceController.currentSession.setChatRead()
    }
    
    @objc
    func requestMessages() {
        WebimServiceController.currentSession.getNextMessages { [weak self] messages in
            DispatchQueue.main.async {
                self?.chatMessages.insert(contentsOf: messages, at: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.reloadTableWithNewData()
                if self?.scrollToBottom == true {
                    self?.scrollToBottom(animated: false)
                    self?.scrollToBottom = false
                } else {
                    //self?.chatTableView?.scrollToRowSafe(at: IndexPath(row: messages.count, section: 0), at: .middle, animated: false)
                }
                
                self?.newRefreshControl.endRefreshing()
            }
        }
    }
    
    func shouldShowFullDate(forMessageNumber index: Int) -> Bool {
        guard index - 1 >= 0 else { return true }
        let currentMessageTime = chatMessages[index].getTime()
        let previousMessageTime = chatMessages[index - 1].getTime()
        let differenceBetweenDates = Calendar.current.dateComponents(
            [.day],
            from: previousMessageTime,
            to: currentMessageTime
        )
        return differenceBetweenDates.day != 0
    }
    
    func shouldShowOperatorInfo(forMessageNumber index: Int) -> Bool {
        guard chatMessages[index].isOperatorType() else { return false }
        guard index + 1 < chatMessages.count else { return true }
        
        let nextMessage = chatMessages[index + 1]
        let progress = nextMessage.getData()?.getAttachment()?.getDownloadProgress() ?? 100
        if nextMessage.isOperatorType() {
            return progress != 100
        } else {
            return true
        }
    }
    
    func shoowPopover(cell: UITableViewCell, message: Message, cellHeight: CGFloat) {
        
        let viewController = PopupActionsViewController()
        self.popupActionsViewController = viewController
        viewController.modalPresentationStyle = .overFullScreen
        viewController.cellImageViewImage = cell.contentView.takeScreenshot()
        viewController.delegate = self
        UIImageView.animate(withDuration: 0.2, animations: {() -> Void in
            viewController.cellImageView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        })
        guard let globalYPosition = cell.superview?
                .convert(cell.center, to: nil)
        else { return }
        viewController.cellImageViewCenterYPosition = globalYPosition.y
        viewController.cellImageViewHeight = cellHeight
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
        
        if message.canBeEdited() && message.getData()?.getAttachment() == nil {
            viewController.actions.append(.edit)
            
            // If image hide show edit action
            if let contentType = message.getData()?.getAttachment()?.getFileInfo().getContentType() {
                if MimeType.isImage(contentType: contentType) {
                    viewController.actions.removeLast()
                }
            }
            viewController.actions.append(.delete)
        }
        
        if message.canVisitorReact() {
            if message.getVisitorReaction() == nil || message.canVisitorChangeReaction() {
                viewController.actions.append(.like)
                viewController.actions.append(.dislike)
            }
        }
        
        if !viewController.actions.isEmpty {
            AppDelegate.keyboardHidden(true)
            let scale = (self.view.frame.width + 19) / self.view.frame.width
            self.present(viewController, animated: false) {
                UIImageView.animate(withDuration: 0.2, animations: {() -> Void in
                    viewController.cellImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
            }
        }
    }
    
    func showOverlayWindow() {
        
        if AppDelegate.keyboardWindow != nil {
            overlayWindow?.isHidden = false
        }
        AppDelegate.keyboardHidden(true)
    }
    
    @objc
    func rateOperatorByTappingAvatar(recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let tapLocation = recognizer.location(in: chatTableView)
        
        guard let tapIndexPath = chatTableView?.indexPathForRow(at: tapLocation) else { return }
        let message = messages()[tapIndexPath.row]
        
        self.showRateOperatorDialog(operatorId: message.getOperatorID())
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
    
    // Webim methods
    private func setupWebimSession() {
        
        WebimServiceController.currentSession.setMessageTracker(withMessageListener: self)
        WebimServiceController.currentSession.set(operatorTypingListener: self)
        WebimServiceController.currentSession.set(currentOperatorChangeListener: self)
        WebimServiceController.currentSession.set(chatStateListener: self)
        WebimServiceController.currentSession.set(surveyListener: self)
        WebimServiceController.currentSession.getLastMessages { [weak self] messages in
            
            DispatchQueue.main.async {
                self?.chatMessages.insert(contentsOf: messages, at: 0)
                self?.reloadTableWithNewData()
                self?.scrollToBottom(animated: false)
                if messages.count < WebimService.ChatSettings.messagesPerRequest.rawValue {
                    self?.scrollToBottom = true
                    self?.requestMessages()
                }
            }
        }
    }
    
    func updateCurrentOperatorInfo(to newOperator: Operator?) {
        if let currentOperator = newOperator {
            let operatorURLString = currentOperator.getAvatarURL()?.absoluteString ?? OperatorAvatar.placeholder.rawValue
            updateOperatorInfo(operatorName: currentOperator.getName(),
                               operatorAvatarURL: operatorURLString,
                               titleViewOperatorInfo: currentOperator.getInfo() ?? "",
                               titleViewOperatorTitle: currentOperator.getTitle() ?? "")
            
        } else {
            updateOperatorInfo(operatorName: "Webim demo-chat".localized,
                               operatorAvatarURL: OperatorAvatar.empty.rawValue,
                               titleViewOperatorInfo: "",
                               titleViewOperatorTitle: "")
        }
    }
    
    // MARK: - WEBIM: DepartmentListHandlerDelegate
    func showDepartmentsList(_ departaments: [Department], action: @escaping (String) -> Void) {
        alertDialogHandler.showDepartmentListDialog(
            withDepartmentList: departaments,
            action: action,
            senderButton: self.toolbarView.messageView.sendButton,
            cancelAction: { }
        )
    }
}

// MARK: - FilePickerDelegate methods
extension ChatViewController: FilePickerDelegate {
    
    func didSelect(image: UIImage?, imageURL: URL?) {
        print("didSelect(image: \(String(describing: imageURL?.lastPathComponent)), imageURL: \(String(describing: imageURL)))")
        
        guard let imageToSend = image else { return }
        
        self.sendImage(
            image: imageToSend,
            imageURL: imageURL
        )
    }
    
    func didSelect(file: Data?, fileURL: URL?) {
        print("didSelect(file: \(fileURL?.lastPathComponent ?? "nil")), fileURL: \(fileURL?.path ?? "nil"))")
        
        guard let fileToSend = file else { return }
        
        self.sendFile(
            file: fileToSend,
            fileURL: fileURL
        )
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if toolbarView.messageView.messageText.isFirstResponder && hideKeyboardOnScrollEnabled {
//            self.toolbarView.messageView.messageText.resignFirstResponder()
//        }
//        if chatTableView.numberOfSections <= 0 { return }
//
//        let lastCellIndexPath = IndexPath(
//            row: chatTableView.numberOfRows(inSection: 0) - 1,
//            section: 0
//        )
//
//        if chatTableView.indexPathsForVisibleRows?.contains(lastCellIndexPath) == false {
//            if scrollButtonIsHidden {
//                scrollButtonIsHidden = false
//                scrollButton.fadeIn()
//            }
//        } else {
//            if !scrollButtonIsHidden {
//                scrollButtonIsHidden = true
//                scrollButton.fadeOut()
//            }
//        }
//    }
    
    func recountChatTableFrame(keyboardHeight: CGFloat) -> CGRect {
        
        let offset = max(keyboardHeight, self.toolbarView.frame.height )
        let height = self.view.frame.height - self.chatTableView.frame.origin.y - offset
        var newFrame = self.chatTableView.frame
        newFrame.size.height = height
        return newFrame
    }
    
    func recountTableSize() {
        let newFrame = recountChatTableFrame(keyboardHeight: 0)
        self.chatTableView.frame = newFrame
        var scrollButtonFrame = self.scrollButton.frame
        scrollButtonFrame.origin.y = newFrame.size.height - 50
        self.scrollButton.frame = scrollButtonFrame
        self.view.setNeedsDisplay()
        self.view.setNeedsLayout()
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let offset = max(keyboardHeight, self.toolbarView.frame.height)
            scrollView.contentOffset = CGPoint(x: 0, y: offset)
        }
    }
}

extension ChatViewController: ChatTestViewDelegate {
    
    func getSearchMessageText() -> String {
        let searchText = self.toolbarView.messageView.getMessage()
        self.toolbarView.messageView.setMessageText("")
        return searchText
    }
    
    func toogleAutotest() -> Bool {
        return self.toggleAutotest()
    }
    
    func showSearchResult(searcMessages: [Message]?) {
        showSearchResult(messages: searcMessages)
    }
    
    func clearHistory() {
        removedAllMessages()
    }
}

extension ChatViewController: WMNewMessageViewDelegate {
    func inputTextChanged() {
        self.view.layoutIfNeeded()
        WebimServiceController.currentSession.setVisitorTyping(draft: self.toolbarView.messageView.getMessage())
    }
    
    func sendMessage() {
        let messageText = self.toolbarView.messageView.getMessage()
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if self.toolbarView.quoteBarIsVisible() {
            if self.toolbarView.quoteView.currentMode() == .edit {
                if messageText.trimmingCharacters(in: .whitespacesAndNewlines) !=
                    self.toolbarView.quoteView.currentMessage().trimmingCharacters(in: .whitespacesAndNewlines) {
                    self.editMessage(messageText)
                }
            } else {
                self.replyToMessage(messageText)
            }
            self.toolbarView.removeQuoteEditBar()
        } else {
            self.sendMessage(messageText)
        }
        self.scrollToBottom(animated: true)
        self.toolbarView.messageView.setMessageText("")
        self.selectedMessage = nil
    }
    
    func showSendFileMenu(_ sender: UIButton) { // Send file button pressed
        filePicker.showSendFileMenu(from: sender)
    }
}
