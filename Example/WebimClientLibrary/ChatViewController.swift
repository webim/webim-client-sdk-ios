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

class ChatViewController: UIViewController {
    
    // MARK: - Properties
    private var alreadyPutTextFromBufferString = false
    private var textInputTextViewBufferString: String?
    
    weak var chatTableViewController: ChatTableViewController?
    
    private lazy var filePicker = FilePicker(
        presentationController: self,
        delegate: self
    )
    
    // MARK: - Constraints
    private let buttonWidthHeight: CGFloat = 20
    private let fileButtonLeadingSpacing: CGFloat = 20
    private let fileButtonTrailingSpacing: CGFloat = 10
    private let textInputBackgroundViewTopBottomSpacing: CGFloat = 8
    
    // MARK: - Outletls
    @IBOutlet weak var tableViewControllerContainerView: UIView!
    @IBOutlet weak var bottomBarBackgroundView: UIView!
    
    // MARK: - Subviews
    // Scroll button
    lazy var scrollButton: UIButton = {
        return createUIButton(type: .system)
    }()
    
    // Top bar (top navigation bar)
    lazy var titleViewOperatorAvatarImageView: UIImageView = {
        return createUIImageView(contentMode: .scaleAspectFit)
    }()
    lazy var titleViewOperatorNameLabel: UILabel = {
        return createUILabel(systemFontSize: 15)
    }()
    lazy var titleViewOperatorStatusLabel: UILabel = {
        return createUILabel(systemFontSize: 13, systemFontWeight: .light)
    }()
    lazy var titleViewTypingIndicator: TypingIndicator = {
        let view = TypingIndicator()
        view.circleDiameter = 5.0
        view.circleColour = UIColor.white
        view.animationDuration = 0.5
        return view
    }()
    
    private var connectionErrorView: UIView!
    
    // Bottom bar
    lazy var separatorView: UIView = {
        return createUIView()
    }()
    lazy var fileButton: UIButton = {
        return createCustomUIButton(type: .system)
    }()
    lazy var textInputBackgroundView: UIView = {
        return createUIView()
    }()
    lazy var textInputTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    lazy var textInputTextViewPlaceholderLabel: UILabel = {
        return createUILabel(systemFontSize: 16, numberOfLines: 0)
    }()
    lazy var textInputButton: UIButton = {
        return createUIButton(type: .system)
    }()
    
    // Bottom bar quote/edit
    lazy var bottomBarQuoteBackgroundView: UIView = {
        return createUIView()
    }()
    lazy var bottomBarQuoteLineView: UIView = {
        return createUIView()
    }()
    lazy var bottomBarQuoteAttachmentImageView: UIImageView = {
        return createUIImageView(contentMode: .scaleAspectFill)
    }()
    lazy var bottomBarQuoteUsernameLabel: UILabel = {
        return createUILabel(systemFontSize: 16, systemFontWeight: .heavy)
    }()
    lazy var bottomBarQuoteBodyLabel: UILabel = {
        return createUILabel(systemFontSize: 15, systemFontWeight: .light)
    }()
    lazy var bottomBarQuoteCancelButton: UIButton = {
        return createCustomUIButton(type: .system)
    }()
    
    // MARK: - View Life Cycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? ChatTableViewController {
            self.chatTableViewController = vc
            chatTableViewController = vc
            vc.chatViewController = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showScrollButton),
            name: .shouldShowScrollButton,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideScrollButton),
            name: .shouldHideScrollButton,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addQuoteEditBar),
            name: .shouldShowQuoteEditBar,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(removeQuoteEditBar),
            name: .shouldHideQuoteEditBar,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(copyMessage),
            name: .shouldCopyMessage,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteMessage),
            name: .shouldDeleteMessage,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateOperatorStatus),
            name: .shouldChangeOperatorStatus,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateOperatorInfo),
            name: .shouldUpdateOperatorInfo,
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        
        setupNavigationBar()
        configureSubviews()
        
        setupScrollButton()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    @objc
    func dismissKeyboardNow() {
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    private func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboardNow)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func keyboardWillChange(_ notification: Notification) {
        guard let animationDuration =
            notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
                as? TimeInterval,
            let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    as? NSValue
            else { return }
        let keyboardHeight: CGFloat = view.frame.maxY - keyboardFrame.cgRectValue.minY
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.bottomBarBackgroundView.snp.remakeConstraints { (make) -> Void in
                    make.leading.trailing.equalToSuperview()
                    
                    if keyboardHeight > 0 { // Keyboard is visible
                        make.bottom.equalToSuperview()
                            .inset(keyboardHeight)
                    } else { // Keyboard is hidden
                        if #available(iOS 11.0, *) {
                            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                        } else {
                            make.bottom.equalToSuperview()
                        }
                    }
                    
                    make.top.equalTo(self.tableViewControllerContainerView.snp.bottom)
                    make.height.lessThanOrEqualTo(self.view.snp.height).multipliedBy(0.5)
                }
                
                self.view.layoutIfNeeded()
                if keyboardHeight > 0 {
                    self.chatTableViewController?.scrollToBottom(animated: false)
                }
            },
            completion: nil
        )
    }

    private func setupNavigationBar() {
        setupTitleView()
        setupRightBarButtonItem()
    }
    
    private func setupTitleView() {
        // TitleView
        titleViewOperatorNameLabel.text = "Webim demo-chat".localized
        titleViewOperatorNameLabel.textColor = .white
        titleViewOperatorNameLabel.highlightedTextColor = .lightGray
        titleViewOperatorStatusLabel.text = "No agent".localized
        titleViewOperatorStatusLabel.textColor = .white
        titleViewOperatorStatusLabel.highlightedTextColor = .lightGray
        
        let customViewForOperatorNameAndStatus = CustomUIView()
        customViewForOperatorNameAndStatus.isUserInteractionEnabled = true
        customViewForOperatorNameAndStatus.translatesAutoresizingMaskIntoConstraints = false
        customViewForOperatorNameAndStatus.addSubview(titleViewOperatorNameLabel)
        titleViewOperatorNameLabel.snp.remakeConstraints { (make) -> Void in
            make.leading.top.trailing.equalToSuperview()
        }

        customViewForOperatorNameAndStatus.addSubview(titleViewOperatorStatusLabel)
        titleViewOperatorStatusLabel.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(titleViewOperatorNameLabel.snp.bottom)
                .offset(2)
        }
        
        customViewForOperatorNameAndStatus.addSubview(titleViewTypingIndicator)
        titleViewTypingIndicator.snp.remakeConstraints { (make) -> Void in
            make.width.equalTo(30.0)
            make.height.equalTo(titleViewTypingIndicator.snp.width).multipliedBy(0.5)
            make.centerY.equalTo(titleViewOperatorStatusLabel.snp.centerY)
            make.trailing.equalTo(titleViewOperatorStatusLabel.snp.leading)
                .inset(2)
        }
        
        let gestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(titleViewTapAction)
        )
        gestureRecognizer.minimumPressDuration = 0.05
        customViewForOperatorNameAndStatus.addGestureRecognizer(gestureRecognizer)
        
        navigationItem.titleView = customViewForOperatorNameAndStatus
    }
    
    private func setupRightBarButtonItem() {
        // RightBarButtonItem
        titleViewOperatorAvatarImageView.image = UIImage()

        let customViewForOperatorAvatar = createUIView()
        customViewForOperatorAvatar.addSubview(titleViewOperatorAvatarImageView)

        titleViewOperatorAvatarImageView.snp.remakeConstraints { (make) -> Void in
            make.trailing.equalToSuperview()
                .inset(-14)
            make.width.equalTo(titleViewOperatorAvatarImageView.snp.height)
            make.top.bottom.equalToSuperview()
                .inset(2)
        }
        
        let customRightBarButtonItem = UIBarButtonItem(
            customView: customViewForOperatorAvatar
        )

        navigationItem.rightBarButtonItem = customRightBarButtonItem
    }
    
    @objc
    private func titleViewTapAction(_ sender: UILongPressGestureRecognizer) {
    // Potentially could be anything, but for now only shows rating dialog
        if sender.state == .ended {
            titleViewOperatorNameLabel.isHighlighted = false
            titleViewOperatorStatusLabel.isHighlighted = false
            
            NotificationCenter.default.post(
                name: .shouldShowRatingDialog,
                object: nil
            )
            
        } else {
            titleViewOperatorNameLabel.isHighlighted = true
            titleViewOperatorStatusLabel.isHighlighted = true
        }
    }
    
    @objc
    private func updateOperatorStatus(sender: Notification) {
        guard let operatorStatus = sender.userInfo as? [String: String] else { return }
        let status = operatorStatus["Status"]
        
        DispatchQueue.main.async {
            if status == "typing".localized {
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
            self.titleViewOperatorStatusLabel.text = status
        }
    }
    
    @objc
    private func updateOperatorInfo(sender: Notification) {
        guard let operatorInfo = sender.userInfo as? [String: String] else { return }
        let operatorName = operatorInfo["OperatorName"]
        let operatorAvatarURL = operatorInfo["OperatorAvatarURL"]
        
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
                guard let string = operatorAvatarURL else { return }
                guard let url = URL(string: string) else { return }
                
                let imageDownloadIndicator = CircleProgressIndicator()
                imageDownloadIndicator.lineWidth = 1
                imageDownloadIndicator.strokeColor = documentFileStatusPercentageIndicatorColour
                imageDownloadIndicator.isUserInteractionEnabled = false
                imageDownloadIndicator.isHidden = true
                imageDownloadIndicator.translatesAutoresizingMaskIntoConstraints = false
                
                self.bottomBarQuoteAttachmentImageView.addSubview(imageDownloadIndicator)
                imageDownloadIndicator.snp.remakeConstraints { (make) -> Void in
                    make.edges.equalToSuperview()
                        .inset(5)
                }
                
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
                            self.bottomBarQuoteAttachmentImageView.image = ImageCache.shared[imageRequest]
                            imageDownloadIndicator.isHidden = true
                        }
                    }
                )
            }
        }
    }
    private func configureNetworkErrorView() {
        
        self.connectionErrorView = tableViewControllerContainerView.loadViewFromNib("ConnectionErrorView")
        self.connectionErrorView.frame = CGRect(x: 0, y: 0, width: tableViewControllerContainerView.frame.width, height: 25)
        self.connectionErrorView.alpha = 0
        tableViewControllerContainerView.addSubview(connectionErrorView)
    }
    
    private func configureSubviews() {
        configureNetworkErrorView()
        // tableViewControllerContainerView
        view.addSubview(tableViewControllerContainerView)
        tableViewControllerContainerView.snp.remakeConstraints { (make) -> Void in
            make.leading.top.trailing.equalToSuperview()
        }
        
        // fileButton
        bottomBarBackgroundView.addSubview(fileButton)
        fileButton.setBackgroundImage(fileButtonImage,
                                          for: .normal)
        fileButton.addTarget(
            self,
            action: #selector(showSendFileMenu),
            for: .touchUpInside
        )
        fileButton.snp.remakeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
                    .inset(fileButtonLeadingSpacing)
            } else {
                make.leading.equalToSuperview()
                    .inset(fileButtonLeadingSpacing)
            }
            
            make.bottom.equalToSuperview()
                .inset(buttonWidthHeight / 2 + textInputBackgroundViewTopBottomSpacing + 2)
            make.height.width.equalTo(buttonWidthHeight)
        }
        
        // textInputTextView
        textInputBackgroundView.addSubview(textInputTextView)
        textInputTextView.delegate = self
        textInputTextView.sizeToFit()
        textInputTextView.isScrollEnabled = true
        textInputTextView.snp.remakeConstraints { (make) -> Void in
            make.top.bottom.leading.equalToSuperview()
                .inset(5)
            make.height.equalTo(
                min(130.5, // MAX value
                    max(35.5, // MIN value
                        self.textInputTextView.contentSize.height
                    )
                )
            )
        }
        
        // textInputTextViewPlaceholderLabel
        textInputBackgroundView.addSubview(textInputTextViewPlaceholderLabel)
        textInputTextViewPlaceholderLabel.text = "Message".localized
        textInputTextViewPlaceholderLabel.textColor = textInputViewPlaceholderLabelTextColour
        textInputTextViewPlaceholderLabel.backgroundColor = textInputViewPlaceholderLabelBackgroundColour
        textInputTextViewPlaceholderLabel.snp.remakeConstraints { (make) -> Void in
            make.leading.equalToSuperview()
                .inset(10)
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                make.trailing.equalToSuperview()
                    .inset(10 + 30)
            } else {
                make.trailing.equalToSuperview()
                    .inset(10)
            }
            make.bottom.equalToSuperview()
                .inset(12)
        }
        
        // textInputButton
        textInputBackgroundView.addSubview(textInputButton)
        textInputButton.setBackgroundImage(textInputButtonImage, for: .normal)
        textInputButton.addTarget(
            self,
            action: #selector(sendMessage),
            for: .touchUpInside
        )
        
        textInputButton.snp.remakeConstraints { (make) -> Void in
            make.trailing.bottom.equalToSuperview()
                .inset(7)
            make.leading.equalTo(textInputTextView.snp.trailing)
            make.height.width.equalTo(30)
        }

        // textInputBackgroundView
        bottomBarBackgroundView.addSubview(textInputBackgroundView)
        textInputBackgroundView.layer.borderWidth = 1
        textInputBackgroundView.layer.borderColor = textInputBackgroundViewBorderColour
        textInputBackgroundView.roundCorners(
            [.layerMinXMinYCorner,
             .layerMaxXMinYCorner,
             .layerMaxXMaxYCorner,
             .layerMinXMaxYCorner],
            radius: 20
        )
        textInputBackgroundView.snp.remakeConstraints { (make) -> Void in
            make.top.equalToSuperview()
                .inset(textInputBackgroundViewTopBottomSpacing)
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
                    .inset(20)
            } else {
                make.trailing.equalToSuperview()
                    .inset(20)
            }
            make.bottom.equalToSuperview()
                .inset(textInputBackgroundViewTopBottomSpacing)
            make.leading.equalTo(fileButton.snp.trailing)
                .offset(fileButtonTrailingSpacing)
        }
        
        // bottomBarBackgroundView
        view.addSubview(bottomBarBackgroundView)
        bottomBarBackgroundView.backgroundColor = bottomBarBackgroundViewColour
        bottomBarBackgroundView.snp.remakeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.top.equalTo(tableViewControllerContainerView.snp.bottom)
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.5)
        }
    }
    
    @objc
    private func sendMessage(_ sender: UIButton) { // Right button pressed
        if !textInputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if var text: String = textInputTextView.text {
                text = text.trimWhitespacesIn()
                if bottomBarQuoteBackgroundView.isDescendant(of: self.view) {
                    // If bottomBarQuoteBackgroundView is a subview of self.view
                    // (i.e. is visible and present on the screen)
                    
                    if bottomBarQuoteUsernameLabel.text ==
                        "Edit Message".localized {
                        // Edit mode
                        if text.trimmingCharacters(in: .whitespacesAndNewlines) !=
                            bottomBarQuoteBodyLabel.text?
                                .trimmingCharacters(in: .whitespacesAndNewlines) {
                            chatTableViewController?.editMessage(text)
                        }
                    } else {
                        chatTableViewController?.replyToMessage(text)
                    }
                    removeQuoteEditBar()
                } else {
                    chatTableViewController?.sendMessage(text)
                }
                
                if !alreadyPutTextFromBufferString {
                    textInputTextView.updateText("")
                } else {
                    alreadyPutTextFromBufferString = false
                }
            } else {
                return
            }
        }
        chatTableViewController?.selectedCellRow = nil
    }
    
    @objc
    private func showSendFileMenu(_ sender: UIButton) { // Send file button pressed
        filePicker.showSendFileMenu(from: sender)
    }
    
    @objc
    private func addQuoteEditBar(sender: Notification) {
        guard let actions = sender.userInfo as? [String: PopupAction] else { return }
        let action = actions["Action"]
        
        guard let message = chatTableViewController?.getSelectedMessage()
        else { return }
        
        // Save text from input text view if there was some
        if !textInputTextView.text.isEmpty {
            textInputTextViewBufferString = textInputTextView.text
            alreadyPutTextFromBufferString = false
        }
        
        // bottomBarQuoteLineView
        bottomBarQuoteBackgroundView.addSubview(bottomBarQuoteLineView)
        bottomBarQuoteLineView.backgroundColor = bottomBarQuoteLineViewColour
        bottomBarQuoteLineView.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(45)
            make.width.equalTo(2)
            make.top.bottom.equalToSuperview()
                .inset(textInputBackgroundViewTopBottomSpacing)
            // TODO: Check this
            // make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
                .inset(
                    fileButtonLeadingSpacing +
                    fileButtonTrailingSpacing +
                    buttonWidthHeight + 5
            )
        }
        
        // bottomBarQuoteUsernameLabel
        bottomBarQuoteBackgroundView.addSubview(bottomBarQuoteUsernameLabel)
        
        if action == .reply {
            if message.getSenderName() == "Посетитель" {
                bottomBarQuoteUsernameLabel.text = "HardcodedVisitorMessageName".localized
            } else {
                bottomBarQuoteUsernameLabel.text = message.getSenderName()
            }
        } else {
            bottomBarQuoteUsernameLabel.text = "Edit Message".localized
            textInputTextView.text = message.getText()
            hidePlaceholderIfVisible()
        }
        
        bottomBarQuoteUsernameLabel.snp.remakeConstraints { (make) -> Void in
            make.top.equalToSuperview()
                .inset(10)
            make.leading.equalTo(bottomBarQuoteLineView.snp.trailing)
                .offset(10)
        }
        
        // bottomBarQuoteBodyLabel
        bottomBarQuoteBackgroundView.addSubview(bottomBarQuoteBodyLabel)
        bottomBarQuoteBodyLabel.text = message.getText().replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
        
        bottomBarQuoteBodyLabel.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(bottomBarQuoteUsernameLabel.snp.bottom)
                .offset(5)
            make.leading.equalTo(bottomBarQuoteLineView.snp.trailing)
                .offset(10)
            make.trailing.equalTo(bottomBarQuoteUsernameLabel.snp.trailing)
        }
        
        // bottomBarQuoteCancelButton
        bottomBarQuoteBackgroundView.addSubview(bottomBarQuoteCancelButton)
        bottomBarQuoteCancelButton.setBackgroundImage(
            closeButtonImage,
            for: .normal
        )
        bottomBarQuoteCancelButton.addTarget(
            self,
            action: #selector(removeQuoteEditBar),
            for: .touchUpInside
        )
        
        bottomBarQuoteCancelButton.snp.remakeConstraints { (make) -> Void in
            make.trailing.equalToSuperview()
                .inset(10)
            
            make.centerY.equalTo(bottomBarQuoteLineView.snp.centerY)
            make.height.width.equalTo(20)
            
            make.leading.equalTo(bottomBarQuoteUsernameLabel.snp.trailing)
                .offset(10)
        }
        
        // bottomBarQuoteAttachmentImageView
        if let contentType = message.getData()?.getAttachment()?.getFileInfo().getContentType(),
            let url = message.getData()?.getAttachment()?.getFileInfo().getURL() {
            
            bottomBarQuoteBackgroundView.addSubview(bottomBarQuoteAttachmentImageView)
            bottomBarQuoteAttachmentImageView.clipsToBounds = true
            bottomBarQuoteAttachmentImageView.roundCorners(
                [.layerMinXMinYCorner,
                 .layerMaxXMinYCorner,
                 .layerMinXMaxYCorner,
                 .layerMaxXMaxYCorner],
                radius: 5
            )
            
            bottomBarQuoteAttachmentImageView.snp.remakeConstraints { (make) -> Void in
                make.top.equalToSuperview()
                    .inset(10)
                make.leading.equalTo(bottomBarQuoteLineView.snp.trailing)
                    .offset(10)
                make.width.height.equalTo(bottomBarQuoteLineView.snp.height)
            }
            
            if isImage(contentType: contentType) {
                let imageDownloadIndicator = CircleProgressIndicator()
                imageDownloadIndicator.lineWidth = 1
                imageDownloadIndicator.strokeColor = documentFileStatusPercentageIndicatorColour
                imageDownloadIndicator.isUserInteractionEnabled = false
                imageDownloadIndicator.isHidden = true
                imageDownloadIndicator.translatesAutoresizingMaskIntoConstraints = false
                
                bottomBarQuoteAttachmentImageView.addSubview(imageDownloadIndicator)
                imageDownloadIndicator.snp.remakeConstraints { (make) -> Void in
                    make.edges.equalToSuperview()
                        .inset(5)
                }
                
                let request = ImageRequest(url: url)
                if let image = ImageCache.shared[request] {
                    imageDownloadIndicator.isHidden = true
                    bottomBarQuoteAttachmentImageView.image = image
                } else {
                    bottomBarQuoteAttachmentImageView.image = loadingPlaceholderImage

                    Nuke.ImagePipeline.shared.loadImage(
                        with: url,
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
                                self.bottomBarQuoteAttachmentImageView.image = ImageCache.shared[request]
                                imageDownloadIndicator.isHidden = true
                            }
                        }
                    )
                }
            } else {
                bottomBarQuoteAttachmentImageView.image = nil
            }
            // bottomBarQuoteUsernameLabel
            bottomBarQuoteUsernameLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalToSuperview()
                    .inset(10)
                if bottomBarQuoteAttachmentImageView.image != nil {
                    make.leading.equalTo(bottomBarQuoteAttachmentImageView.snp.trailing)
                        .offset(10)
                } else {
                    make.leading.equalTo(bottomBarQuoteLineView.snp.trailing)
                        .offset(10)
                }
            }
            
            // bottomBarQuoteBodyLabel
            bottomBarQuoteBodyLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(bottomBarQuoteUsernameLabel.snp.bottom)
                    .offset(5)
                if bottomBarQuoteAttachmentImageView.image != nil {
                    make.leading.equalTo(bottomBarQuoteAttachmentImageView.snp.trailing)
                        .offset(10)
                } else {
                    make.leading.equalTo(bottomBarQuoteLineView.snp.trailing)
                        .offset(10)
                }
                make.trailing.equalTo(bottomBarQuoteUsernameLabel.snp.trailing)
            }
        }
        // bottomBarQuoteBackgroundView
        bottomBarBackgroundView.addSubview(bottomBarQuoteBackgroundView)
        
        UIView.animate(withDuration: 0.1) {
            self.bottomBarQuoteBackgroundView.snp.remakeConstraints { (make) -> Void in
                make.top.leading.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
                        .inset(20)
                } else {
                    make.trailing.equalToSuperview()
                        .inset(20)
                }
                make.trailing.equalTo(self.bottomBarQuoteUsernameLabel.snp.trailing)
            }
            
            // textInputBackgroundView
            self.textInputBackgroundView.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(self.bottomBarQuoteBackgroundView.snp.bottom)
                    .offset(self.textInputBackgroundViewTopBottomSpacing)
                if #available(iOS 11.0, *) {
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
                        .inset(20)
                } else {
                    make.trailing.equalToSuperview()
                        .inset(20)
                }
                make.bottom.equalToSuperview()
                    .inset(self.textInputBackgroundViewTopBottomSpacing)
                make.leading.equalTo(self.fileButton.snp.trailing)
                    .offset(self.fileButtonTrailingSpacing)
            }
            
            self.view.layoutIfNeeded()
        }
        // bottomBarQuoteBackgroundView
        bottomBarBackgroundView.addSubview(bottomBarQuoteBackgroundView)
        
        chatTableViewController?.scrollToBottom(animated: true)
        textInputTextView.becomeFirstResponder()
    }

    @objc
    private func removeQuoteEditBar() {
        guard bottomBarQuoteBackgroundView.isDescendant(of: self.view) else { return }
        let typingDraftDictionary = ["DraftText": 123]
        NotificationCenter.default.post(
            name: .shouldSetVisitorTypingDraft,
            object: nil,
            userInfo: typingDraftDictionary
        )
        
        if bottomBarQuoteUsernameLabel.text == "Edit Message".localized {
            // Edit mode
            bottomBarQuoteUsernameLabel.text = ""
            if !textInputTextView.text.isEmpty {
                
                let newText: String = textInputTextViewBufferString ?? ""
                if textInputTextViewBufferString != nil {
                    textInputTextViewBufferString = nil
                    alreadyPutTextFromBufferString = true
                }
                textInputTextView.updateText(newText)
            }
        }
        
        bottomBarQuoteBackgroundView.removeFromSuperview()
        bottomBarQuoteLineView.removeFromSuperview()
        bottomBarQuoteAttachmentImageView.removeFromSuperview()
        bottomBarQuoteUsernameLabel.removeFromSuperview()
        bottomBarQuoteBodyLabel.removeFromSuperview()
        bottomBarQuoteCancelButton.removeFromSuperview()
        
        UIView.animate(withDuration: 0.1) {
            // textInputBackgroundView
            self.textInputBackgroundView.snp.remakeConstraints { (make) -> Void in
                make.top.equalToSuperview()
                    .inset(self.textInputBackgroundViewTopBottomSpacing)
            if #available(iOS 11.0, *) {
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
                        .inset(20)
                } else {
                    make.trailing.equalToSuperview()
                        .inset(20)
                }
                make.bottom.equalToSuperview()
                    .inset(self.textInputBackgroundViewTopBottomSpacing)
                make.leading.equalTo(self.fileButton.snp.trailing)
                    .offset(self.fileButtonTrailingSpacing)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func copyMessage(sender: Notification) {
        chatTableViewController?.copyMessage()
    }
    
    @objc
    private func deleteMessage(sender: Notification) {
        chatTableViewController?.deleteMessage()
    }
    
    private func setupScrollButton() {
        scrollButton.setBackgroundImage(scrollButtonImage, for: .normal)
        scrollButton.layoutIfNeeded()
        scrollButton.subviews.first?.contentMode = .scaleAspectFill
        scrollButton.addTarget(
            self,
            action: #selector(scrollTableView),
            for: .touchUpInside
        )
        self.view.addSubview(scrollButton)
        
        scrollButton.snp.remakeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(self.view.safeAreaLayoutGuide)
                    .inset(5)
            } else {
                make.trailing.equalTo(tableViewControllerContainerView)
                    .inset(5)
            }
            make.bottom.equalTo(tableViewControllerContainerView)
                .inset(5)
            make.height.equalTo(self.scrollButton.snp.width)
            make.width.equalTo(30)
        }
        
        scrollButton.isHidden = true
    }
    
    @objc
    private func scrollTableView(_ sender: UIButton) {
        chatTableViewController?.scrollToBottom(animated: true)
    }
    
    @objc
    private func showScrollButton(_ sender: Notification) {
        scrollButton.fadeIn()
    }
    
    @objc
    private func hideScrollButton(_ sender: Notification) {
        scrollButton.fadeOut()
    }
    
    private func hidePlaceholderIfVisible() {
        if !(self.textInputTextViewPlaceholderLabel.alpha == 0.0) {
            UIView.animate(withDuration: 0.1) {
                self.textInputTextViewPlaceholderLabel.alpha = 0.0
            }
        }
    }
    
    public func setConnectionStatus(connected: Bool) {
        DispatchQueue.main.async {
            if connected {
                self.navigationController?.navigationBar.barTintColor = navigationBarBarTintColour
            } else {
                self.navigationController?.navigationBar.barTintColor = navigationBarNoConnectionColour
            }
            self.connectionErrorView?.alpha = connected ? 0 : 1
        }
    }
}

// MARK: - UI methods
extension ChatViewController {
    func createUILabel(
        textAlignment: NSTextAlignment = .left,
        systemFontSize: CGFloat,
        systemFontWeight: UIFont.Weight = .regular,
        numberOfLines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.font = .systemFont(ofSize: systemFontSize, weight: .regular )
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createUIView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func createUIImageView(
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    func createUIButton(type: UIButton.ButtonType) -> UIButton {
        let button = UIButton(type: type)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func createCustomUIButton(type: UIButton.ButtonType) -> UIButton {
        let button = CustomUIButton(type: type)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

// MARK: - UITextViewDelegate methods
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if bottomBarQuoteUsernameLabel.text != "Edit Message".localized {
            // If in edit mode, don't setTypingDraft
            let typingDraftDictionary = ["DraftText": textView.text]
            NotificationCenter.default.post(
                name: .shouldSetVisitorTypingDraft,
                object: nil,
                userInfo: typingDraftDictionary as [AnyHashable: Any]
            )
        }
        
        if textView.text.isEmpty {
            UIView.animate(withDuration: 0.1) {
                self.textInputTextViewPlaceholderLabel.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.textInputTextViewPlaceholderLabel.alpha = 0.0
            }
        }
        
        textInputTextView.snp.remakeConstraints { (make) -> Void in
            make.top.bottom.leading.equalToSuperview()
                .inset(5)
            make.height.equalTo(min(130.5, max(35.5, textView.contentSize.height)))
        }
    }
}

// MARK: - FilePickerDelegate methods
extension ChatViewController: FilePickerDelegate {
    func didSelect(image: UIImage?, imageURL: URL?) {
        print("didSelect(image: \(String(describing: imageURL?.lastPathComponent)), imageURL: \(String(describing: imageURL)))")
        
        guard let imageToSend = image else { return }
        
        chatTableViewController?.sendImage(
            image: imageToSend,
            imageURL: imageURL
        )
    }
    func didSelect(file: Data?, fileURL: URL?) {
        print("didSelect(file: \(fileURL?.lastPathComponent ?? "nil")), fileURL: \(fileURL?.path ?? "nil"))")
        
        guard let fileToSend = file else { return }
        
        chatTableViewController?.sendFile(
            file: fileToSend,
            fileURL: fileURL
        )
    }
}
