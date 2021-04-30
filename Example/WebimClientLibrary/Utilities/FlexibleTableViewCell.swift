//
//  FlexibleTableViewCell.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 24/09/2019.
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

import UIKit
import WebimClientLibrary
import SnapKit
import Nuke

class FlexibleTableViewCell: UITableViewCell {

    // MARK: - Size constants
    private let CHAT_BUBBLE_MAX_WIDTH: CGFloat = {
        let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        return width < 350 ? 253.0 : 265.0
    }()
    private let CHAT_BUBBLE_MIN_WIDTH: CGFloat = 55.0
    private let SPACING_DEFAULT: CGFloat = 10.0
    private let SPACING_CELL: CGFloat = 5.0
    private let USERAVATARIMAGEVIEW_WIDTH: CGFloat = 40.0
    
    // MARK: - Properties
    public var hasImageAsDocument: Bool { imageAsDocument }
    
    // MARK: - Private Properties
    private var isForOperator = false
    private var imageAsDocument = false
    private var messageFromCell: Message?
    
    private lazy var urlSession = URLSession()
    private lazy var downloadTask = URLSessionDownloadTask()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    private let calendar: Calendar = {
        let calendar = Calendar.current
        return calendar
    }()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return dateFormatter
    }()
    private let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    private let byteCountFormatter: ByteCountFormatter = {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = .useAll
        byteCountFormatter.countStyle = .file
        byteCountFormatter.includesUnit = true
        byteCountFormatter.isAdaptive = true
        return byteCountFormatter
    }()
    
    // MARK: - Subviews
    lazy var dateLabel: UILabel = {
        let label = createUILabel(
            textAlignment: .center,
            systemFontSize: 15,
            systemFontWeight: .light
        )
        label.textColor = dateLabelColour
        return label
    }()
    
    // Message
    lazy var messageUsernameLabel: UILabel = {
        return createUILabel(systemFontSize: 15)
    }()
    
    lazy var messageBodyLabel: UILabel = {
        return createUILabel(systemFontSize: 17, numberOfLines: 0)
    }()
    
    lazy var messageBackgroundView: UIView = {
        return createUIView()
    }()
    
    // Document
    lazy var documentFileNameLabel: UILabel = {
        return createUILabel(systemFontSize: 17)
    }()

    lazy var documentFileDescriptionLabel: UILabel = {
       return createUILabel(systemFontSize: 15, systemFontWeight: .light, numberOfLines: 0)
    }()
    
    lazy var documentFileStatusPercentageIndicator: CircleProgressIndicator = {
        let indicator = CircleProgressIndicator()
        indicator.lineWidth = 1
        indicator.strokeColor = documentFileStatusPercentageIndicatorColour
        indicator.isUserInteractionEnabled = false
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var documentFileCancelDownloadButton: UIButton = {
        let button = createUIButton(type: .system)
        button.setBackgroundImage(closeButtonImage, for: .normal)
        button.addTarget(
            self,
            action: #selector(cancelDownload),
            for: .touchUpInside
        )
        button.isHidden = true
        return button
    }()
    
    lazy var documentFileStatusButton: UIButton = {
        return createUIButton(type: .system)
    }()
    
    // Image
    lazy var imageUsernameLabel: UILabel = {
        return createUILabel(systemFontSize: 15)
    }()
    
    lazy var imageUsernameLabelBackgroundView: UIView = {
        return createUIView()
    }()
    
    lazy var imageImageView: UIImageView = {
        return createUIImageView()
    }()
    
    // Quote
    lazy var quoteLineView: UIView = {
        return createUIView()
    }()
    
    lazy var quoteAttachmentImageView: UIImageView = {
        return createUIImageView(contentMode: .scaleAspectFill)
    }()
    
    lazy var quoteUsernameLabel: UILabel = {
        return createUILabel(systemFontSize: 17, systemFontWeight: .heavy)
    }()
    
    lazy var quoteBodyLabel: UILabel = {
        return createUILabel(systemFontSize: 15, systemFontWeight: .light)
    }()
    
    // Time
    lazy var timeLabel: UILabel = {
        let label = createUILabel(systemFontSize: 15, systemFontWeight: .light)
        label.textColor = timeLabelColour
        return label
    }()
    
    lazy var messageStatusImageView: UIImageView = {
        return createUIImageView()
    }()
    
    lazy var messageStatusIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
//        indicator.strokeColor = messageStatusIndicatorColour
        indicator.stopAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var messageStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 15)
        label.textColor = timeLabelColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Avatar
    lazy var userAvatarImageView: UIImageView = {
        return createUIImageView()
    }()
    
    // MARK: - Methods
    func configureTheCell(
        forMessage message: Message,
        showFullDate: Bool,
        shouldShowOperatorInfo: Bool = false,
        isEdited: Bool = false
    ) {
        switch message.getType() {

        // Keyboard message layout
        case .keyboard:

            cellLayoutButtons(
                forMessage: message,
                showFullDate: showFullDate
            )

        // System message layout
        case .actionRequest,
             .contactInformationRequest,
             .info,
             .operatorBusy,
             .keyboardResponse:
            
            cellLayoutSystem(
                forMessage: message,
                showFullDate: showFullDate
            )
    
        // Visitor message layout
        case .visitorMessage,
             .fileFromVisitor:
            
            cellLayoutOther(
                forMessage: message,
                showFullDate: showFullDate,
                forOperator: false,
                isEdited: isEdited
            )
            
        // Operator message layout
        case .operatorMessage,
             .fileFromOperator:
            
            cellLayoutOther(
                forMessage: message,
                showFullDate: showFullDate,
                forOperator: true,
                shouldShowOperatorInfo: shouldShowOperatorInfo,
                isEdited: isEdited
            )
            
        case .stickerVisitor:
            break
        }
    }
    
    // MARK: - Private methods
    private func calculateImageViewSize(
        imageHeight: CGFloat,
        imageWidth: CGFloat,
        forOperator: Bool
    ) -> CGSize {
        guard imageHeight >= CHAT_BUBBLE_MIN_WIDTH else { return CGSize() }
        
        if forOperator {
            guard imageWidth >= CHAT_BUBBLE_MIN_WIDTH * 2 else { return CGSize() }
        } else {
            guard imageWidth >= CHAT_BUBBLE_MIN_WIDTH else { return CGSize() }
        }
        
        var biggerSide = imageWidth
        var lesserSide = imageHeight
        
        if imageHeight > imageWidth {
            biggerSide = imageHeight
            lesserSide = imageWidth
        }
        
        if biggerSide > CHAT_BUBBLE_MAX_WIDTH {
            let resizeRatio = biggerSide / CHAT_BUBBLE_MAX_WIDTH
            biggerSide = CHAT_BUBBLE_MAX_WIDTH
            lesserSide /= resizeRatio
        }
        
        if imageHeight > imageWidth {
            return CGSize(width: lesserSide, height: biggerSide)
        }
        return CGSize(width: biggerSide, height: lesserSide)
        
    }
    
    private func emptyTheCell() {
        dateLabel.removeFromSuperview()
        messageUsernameLabel.removeFromSuperview()
        messageBodyLabel.removeFromSuperview()
        documentFileNameLabel.removeFromSuperview()
        documentFileDescriptionLabel.removeFromSuperview()
        documentFileStatusPercentageIndicator.removeFromSuperview()
        documentFileCancelDownloadButton.removeFromSuperview()
        documentFileStatusButton.removeFromSuperview()
        imageImageView.removeFromSuperview()
        imageUsernameLabel.removeFromSuperview()
        imageUsernameLabelBackgroundView.removeFromSuperview()
        quoteLineView.removeFromSuperview()
        quoteAttachmentImageView.removeFromSuperview()
        quoteUsernameLabel.removeFromSuperview()
        quoteBodyLabel.removeFromSuperview()
        timeLabel.removeFromSuperview()
        messageStatusIndicator.removeFromSuperview()
        messageStatusImageView.removeFromSuperview()
        messageStatusLabel.removeFromSuperview()
        userAvatarImageView.removeFromSuperview()
        buttonsVerticalStack.removeFromSuperview()
    }
    
    private func configureURLSession() {
        // FIXME: Impossible to create another background session to handle background download?
        // Somehow it works now, but feels like it should not work
        let configuration = URLSessionConfiguration.default
//         let configuration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier ?? "").background")
//         configuration.isDiscretionary = true
//         configuration.sessionSendsLaunchEvents = true
        urlSession = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
    }

    lazy var buttonsVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = SPACING_CELL * 2
        return stackView
    }()
    
    // MARK: - LAYOUT METHODS
    private func cellLayoutSystem(
        forMessage message: Message,
        showFullDate: Bool
    ) {
        emptyTheCell()
        self.messageFromCell = message
        
        if showFullDate {
            // dateLabel
            self.addSubview(dateLabel)
        }
        
        // messageBodylabel
        messageBackgroundView.addSubview(messageBodyLabel)
        /// Attributes
        messageBodyLabel.textAlignment = .center
        messageBodyLabel.textColor = messageBodyLabelColourSystem
        
        // messageBackgroundView
        self.addSubview(messageBackgroundView)
        /// Set round corners
        messageBackgroundView.roundCorners(
            [.layerMinXMinYCorner,
             .layerMaxXMinYCorner,
             .layerMaxXMaxYCorner,
             .layerMinXMaxYCorner],
            radius: 15
        )
        /// Set colour
        messageBackgroundView.backgroundColor = messageBackgroundViewColourSystem
        
        // timeLabel
        self.addSubview(timeLabel)
        
        fillSystemCell(
            message: message,
            showFullDate: showFullDate
        )
    }
    
    private func cellLayoutButtons(
        forMessage message: Message,
        showFullDate: Bool
    ) {
        emptyTheCell()
        buttonsVerticalStack.removeAllArrangedSubviews()
        self.messageFromCell = message
        
        if showFullDate {
            // dateLabel
            self.addSubview(dateLabel)
        }
        
        // buttonsVerticalStack
        messageBackgroundView.addSubview(buttonsVerticalStack)
        
        // timeLabel
        messageBackgroundView.addSubview(timeLabel)
        
        // messageBackgroundView
        self.addSubview(messageBackgroundView)
        
        /// Set round corners
        messageBackgroundView.layer.cornerRadius = 0
        
        /// Set colour
        messageBackgroundView.backgroundColor = messageBackgroundViewColourSystem
        
        fillButtonsCell(
            message: message,
            showFullDate: showFullDate
        )
    }

    private func cellLayoutOther(
        forMessage message: Message,
        showFullDate: Bool,
        forOperator: Bool,
        shouldShowOperatorInfo: Bool = false,
        isEdited: Bool = false
    ) {
        emptyTheCell()
        if message.getData()?.getAttachment() != nil {
            configureURLSession()
        }
        self.messageFromCell = message
                
        var hasQuote = false
        var hasQuoteAttachment = false
        var hasQuoteImage = false
        var hasAttachment = false
        var hasImage = false
        var hasSendingFile = false
        var imageViewSize = CGSize()
        
        self.isForOperator = forOperator
        
        if showFullDate {
            // dateLabel
            self.addSubview(dateLabel)
        }
        
        if forOperator {
            // userAvatarImageView
            self.addSubview(userAvatarImageView)
            userAvatarImageView.clipsToBounds = true
           userAvatarImageView.roundCorners(
                [.layerMinXMinYCorner,
                 .layerMaxXMinYCorner,
                 .layerMinXMaxYCorner,
                 .layerMaxXMaxYCorner],
                radius: 20
            )

            // documentFileStatusPercentageIndicator
            userAvatarImageView.addSubview(documentFileStatusPercentageIndicator)
            
            // messageUsernameLabel
            messageBackgroundView.addSubview(messageUsernameLabel)
            /// Text
            messageUsernameLabel.textColor = messageUsernameLabelColourOperator
        }
        
        if let quote = message.getQuote() { // Quote
            hasQuote = true
            
            if let quoteAttachment = quote.getMessageAttachment(),
                let contentType = quoteAttachment.getContentType() {
                hasQuoteAttachment = true
                
                if isImage(contentType: contentType) {
                    hasQuoteImage = true
                }
                
                // messageBackgroundView
                messageBackgroundView.addSubview(quoteAttachmentImageView)
                
                // documentFileStatusPercentageIndicator
                quoteAttachmentImageView.addSubview(documentFileStatusPercentageIndicator)
                
                // Attributes
                quoteAttachmentImageView.clipsToBounds = false
            }
            // quoteLineView
            messageBackgroundView.addSubview(quoteLineView)
            /// Set colour
            
            if forOperator {
                quoteLineView.backgroundColor = quoteLineViewColourOperator
            } else {
                quoteLineView.backgroundColor = quoteLineViewColourVisitor
            }
            
            // quoteUsernameLabel
            messageBackgroundView.addSubview(quoteUsernameLabel)
            
            // quoteBodyLabel
            messageBackgroundView.addSubview(quoteBodyLabel)
        }
        if let attachment = message.getData()?.getAttachment(),
            let contentType = attachment.getFileInfo().getContentType() {
            let fileInfo = attachment.getFileInfo()
                
            hasAttachment = true
            
            if isImage(contentType: contentType) {
                hasImage = true
                
                guard let imageHeight = fileInfo.getImageInfo()?.getHeight(),
                    let imageWidth = fileInfo.getImageInfo()?.getWidth()
                    else { return }
                
                imageViewSize = calculateImageViewSize(
                    imageHeight: CGFloat(imageHeight),
                    imageWidth: CGFloat(imageWidth),
                    forOperator: forOperator
                )

                if imageViewSize == CGSize() { // Image is too small to display it properly
                    self.imageAsDocument = true
                }
            }
            
            if hasImage && !hasImageAsDocument {
                // imageImageView
                messageBackgroundView.addSubview(imageImageView)
                
                // documentFileStatusPercentageIndicator
                imageImageView.addSubview(documentFileStatusPercentageIndicator)
                
                /// Attributes
                imageImageView.clipsToBounds = false
                
                if forOperator {
                    // imageUsernameLabel
                    imageUsernameLabelBackgroundView.addSubview(imageUsernameLabel)
                    /// Text
                    imageUsernameLabel.textColor = imageUsernameLabelColourOperator
                    
                    // imageUsernamaLabelBackgroundView
                    messageBackgroundView.addSubview(imageUsernameLabelBackgroundView)
                    imageUsernameLabelBackgroundView.backgroundColor = imageUsernameLabelBackgroundViewColourOperator
                    imageUsernameLabelBackgroundView.roundCorners(
                        [.layerMinXMinYCorner,
                         .layerMaxXMinYCorner,
                         .layerMinXMaxYCorner,
                         .layerMaxXMaxYCorner],
                        radius: 15
                    )
                }
                
                // messageBackgroundView
                /// Set colour
                messageBackgroundView.backgroundColor = messageBackgroundViewColourClear
            } else {
                // documentFileNameLabel
                messageBackgroundView.addSubview(documentFileNameLabel)
                
                // documentFileDescriptionLabel
                messageBackgroundView.addSubview(documentFileDescriptionLabel)
                
                // documentFileStatusPercentageIndicator
                documentFileStatusButton.addSubview(documentFileStatusPercentageIndicator)
                
                // documentFileCancelDownloadButton
                documentFileStatusButton.addSubview(documentFileCancelDownloadButton)
                
                // documentFileStatusButton
                messageBackgroundView.addSubview(documentFileStatusButton)
                
                // messageBackgroundView
                /// Set colour
                if forOperator {
                    messageBackgroundView.backgroundColor = messageBackgroundViewColourOperator
                } else {
                    messageBackgroundView.backgroundColor = messageBackgroundViewColourVisitor
                }
            }
        } else {
            // messageBodyLabel
            messageBackgroundView.addSubview(messageBodyLabel)
            /// Text
            messageBodyLabel.textAlignment = .left
            if forOperator {
                messageBodyLabel.textColor = messageBodyLabelColourOperator
            } else {
                messageBodyLabel.textColor = messageBodyLabelColourVisitor
            }
            
            // messageBackgroundView
            /// Set colour
            if forOperator {
                messageBackgroundView.backgroundColor = messageBackgroundViewColourOperator
            } else {
                messageBackgroundView.backgroundColor = messageBackgroundViewColourVisitor
            }
        }
        
        // messageBackgroundView
        self.addSubview(messageBackgroundView)
        roundCornersForMessage(on: messageBackgroundView, forOperator: forOperator)
        
        // timeLabel
        self.addSubview(timeLabel)
        
        // messageStatusImageView
        self.addSubview(messageStatusImageView)
         
        if !forOperator {
            // messageStatusIndicator
            self.addSubview(messageStatusIndicator)
        }
        
        // messageStatusLabel
        self.addSubview(messageStatusLabel)
        
        if message.getType() == .fileFromVisitor && message.getSendStatus() == .sending {
            hasSendingFile = true
            messageBackgroundView.addSubview(documentFileNameLabel)
            messageBackgroundView.addSubview(documentFileDescriptionLabel)
            messageBackgroundView.addSubview(documentFileStatusButton)
        }
        
        fillOtherCell(
            showFullDate: showFullDate,
            forOperator: forOperator,
            message: message,
            hasQuote: hasQuote,
            hasQuoteAttachment: hasQuoteAttachment,
            hasQuoteImage: hasQuoteImage,
            hasAttachment: hasAttachment,
            hasImage: hasImage,
            hasSendingFile: hasSendingFile,
            imageViewSize: imageViewSize,
            shouldShowOperatorInfo: shouldShowOperatorInfo,
            isEdited: isEdited
        )
    }
    
    // MARK: - SET CONTENT METHODS
    private func fillSystemCell(
        message: Message,
        showFullDate: Bool
    ) {
        if showFullDate {
            if calendar.isDateInToday(message.getTime()) {
                dateLabel.text = "Today".localized
            } else if calendar.isDateInYesterday(message.getTime()) {
                dateLabel.text = "Yesterday".localized
            } else {
                dateLabel.text = dateFormatter.string(from: message.getTime())
            }
        }
        
        var messageText = message.getText()
        if message.getType() == .keyboardResponse,
            let buttonText = message.getKeyboardRequest()?.getButton().getText() {
            messageText += " \"\(buttonText)\""
        }
        messageBodyLabel.text = messageText
        
        timeLabel.text = timeFormatter.string(from: message.getTime())
        
        cellLayoutConstraintSystem(showFullDate: showFullDate)
    }
    
    private func fillButtonsCell(
        message: Message,
        showFullDate: Bool
    ) {
        if showFullDate {
            if calendar.isDateInToday(message.getTime()) {
                dateLabel.text = "Today".localized
            } else if calendar.isDateInYesterday(message.getTime()) {
                dateLabel.text = "Yesterday".localized
            } else {
                dateLabel.text = dateFormatter.string(from: message.getTime())
            }
        }
        
        guard let keyboard = message.getKeyboard() else { return }
        let buttonsArray = keyboard.getButtons()
        
        var response: KeyboardResponse?
        var isActive = false
        
        switch keyboard.getState() {
        case .pending:
            isActive = true
        case .canceled:
            isActive = false
        case .completed:
            isActive = false
            response = keyboard.getResponse()
        }
        
        for buttonsStack in buttonsArray {
            for button in buttonsStack {
                let uiButton = UIButton(type: .system),
                    buttonID = button.getID(),
                    buttonText = button.getText()
                
                uiButton.accessibilityIdentifier = buttonID
                uiButton.setTitle(buttonText, for: .normal)
                
                /// add buttons only with text
                guard let titleLabel = uiButton.titleLabel else {
                    continue
                }
                titleLabel.font = UIFont.systemFont(ofSize: 17.0)
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 0
                
                /// button text insets
                titleLabel.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview().inset(10)
                    make.left.right.equalToSuperview().inset(16)
                    make.height.greaterThanOrEqualTo(20)
                }
                
                uiButton.clipsToBounds = true
                uiButton.translatesAutoresizingMaskIntoConstraints = false
                uiButton.layer.cornerRadius = 20
                
                if isActive {
                    uiButton.addTarget(
                        self,
                        action: #selector(sendButton),
                        for: .touchUpInside
                    )
                }
                
                if isActive {
                    // set default buttons
                    uiButton.backgroundColor = buttonDefaultBackgroundColour
                    uiButton.tintColor = buttonDefaultTitleColour
                } else {
                    if let response = response,
                        response.getButtonID() == buttonID {
                        // set choosen button
                        uiButton.backgroundColor = buttonChoosenBackgroundColour
                        uiButton.tintColor = buttonChoosenTitleColour
                    } else {
                        // set inactive button
                        uiButton.backgroundColor = buttonCanceledBackgroundColour
                        uiButton.tintColor = buttonCanceledTitleColour
                    }
                }
                
                buttonsVerticalStack.addArrangedSubview(uiButton)
                uiButton.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                }
            }
        }
        timeLabel.text = timeFormatter.string(from: message.getTime())
        cellLayoutConstraintButtons(showFullDate: showFullDate)
    }
    
    private func fillOtherCell(
        showFullDate: Bool,
        forOperator: Bool,
        message: Message,
        hasQuote: Bool,
        hasQuoteAttachment: Bool,
        hasQuoteImage: Bool,
        hasAttachment: Bool,
        hasImage: Bool,
        hasSendingFile: Bool,
        imageViewSize: CGSize,
        shouldShowOperatorInfo: Bool = false,
        isEdited: Bool = false
    ) {
        if showFullDate {
            if calendar.isDateInToday(message.getTime()) {
                dateLabel.text = "Today".localized
            } else if calendar.isDateInYesterday(message.getTime()) {
                dateLabel.text = "Yesterday".localized
            } else {
                dateLabel.text = dateFormatter.string(from: message.getTime())
            }
        }
        
        if hasAttachment,
            let attachment = message.getData()?.getAttachment(),
            let url = attachment.getFileInfo().getURL(),
            let contentType = attachment.getFileInfo().getContentType() {
            let fileInfo = attachment.getFileInfo()
            
            if hasImageAsDocument {
                let request = ImageRequest(url: url)
                if ImageCache.shared[request] != nil {
                    self.documentFileStatusPercentageIndicator.isHidden = true
                    if forOperator {
                        documentFileStatusButton.setBackgroundImage(
                            documentFileStatusButtonDownloadSuccessOperator,
                            for: .normal
                        )
                    } else {
                        documentFileStatusButton.setBackgroundImage(
                            documentFileStatusButtonDownloadSuccessVisitor,
                            for: .normal
                        )
                    }
                } else {
                    if forOperator {
                        documentFileStatusButton.setBackgroundImage(
                            documentFileStatusButtonDownloadOperator,
                            for: .normal
                        )
                    } else {
                        documentFileStatusButton.setBackgroundImage(
                            documentFileStatusButtonDownloadVisitor,
                            for: .normal
                        )
                    }
                    Nuke.ImagePipeline.shared.loadImage(
                        with: url,
                        progress: { _, completed, total in
                            self.updateImageDownloadProgress(completed: completed, total: total)
                        },
                        completion: { _ in
                            if forOperator {
                                self.documentFileStatusButton.setBackgroundImage(
                                    documentFileStatusButtonDownloadSuccessOperator,
                                    for: .normal
                                )
                            } else {
                                self.documentFileStatusButton.setBackgroundImage(
                                    documentFileStatusButtonDownloadSuccessVisitor,
                                    for: .normal
                                )
                            }
                            self.documentFileStatusPercentageIndicator.isHidden = true
                        }
                    )
                }
            }
            
            if hasImage && !hasImageAsDocument {
                if forOperator && shouldShowOperatorInfo {
                    imageUsernameLabel.text = message.getSenderName()
                } else {
                    imageUsernameLabel.text = nil
                }
                
                imageImageView.clipsToBounds = true
                roundCornersForMessage(on: imageImageView, forOperator: forOperator)
                
                let request = ImageRequest(url: url)
                if let image = ImageCache.shared[request] {
                    self.documentFileStatusPercentageIndicator.isHidden = true
                    self.imageImageView.image = image
                } else {
                    self.imageImageView.image = loadingPlaceholderImage

                    Nuke.ImagePipeline.shared.loadImage(
                        with: url,
                        progress: { _, completed, total in
                            self.updateImageDownloadProgress(
                                completed: completed,
                                total: total
                            )
                        },
                        completion: { _ in
                            self.imageImageView.image = ImageCache.shared[request]
                            self.documentFileStatusPercentageIndicator.isHidden = true
                        }
                    )
                }
            } else {
                documentFileNameLabel.text = fileInfo.getFileName()
                documentFileDescriptionLabel.text =
                    byteCountFormatter.string(fromByteCount: fileInfo.getSize() ?? 0)
                
                if forOperator {
                    documentFileNameLabel.textColor = documentFileNameLabelColourOperator
                    documentFileDescriptionLabel.textColor = documentFileDescriptionLabelColourOperator
                } else {
                    documentFileNameLabel.textColor = documentFileNameLabelColourVisitor
                    documentFileDescriptionLabel.textColor = documentFileDescriptionLabelColourVisitor
                }
                
                if isAcceptableFile(contentType: contentType) {
                    if isFileExist(fileName: fileInfo.getFileName()) {
                        if forOperator {
                            documentFileStatusButton.setBackgroundImage(
                                documentFileStatusButtonDownloadSuccessOperator,
                                for: .normal
                            )
                        } else {
                            documentFileStatusButton.setBackgroundImage(
                                documentFileStatusButtonDownloadSuccessVisitor,
                                for: .normal
                            )
                        }
                        
                    } else {
                        if forOperator {
                            documentFileStatusButton.setBackgroundImage(
                                documentFileStatusButtonDownloadOperator,
                                for: .normal
                            )
                        } else {
                            documentFileStatusButton.setBackgroundImage(
                                documentFileStatusButtonDownloadVisitor,
                                for: .normal
                            )
                        }
                    }
                } else if !hasImageAsDocument {
                    documentFileStatusButton.setBackgroundImage(
                        documentFileStatusButtonDownloadError,
                        for: .normal)
                }
                if !hasImageAsDocument {
                    documentFileStatusButton.addTarget(
                        self,
                        action: #selector(downloadFile),
                        for: .touchUpInside
                    )
                }
            }
        } else {
            messageBodyLabel.text = message.getText()
            if hasQuote {
                
                if hasQuoteAttachment,
                    let attachment = message.getQuote()?.getMessageAttachment(),
                    let url = attachment.getURL() {
                    
                    if hasQuoteImage {
                        quoteAttachmentImageView.clipsToBounds = true
                        quoteAttachmentImageView.roundCorners(
                            [.layerMinXMinYCorner,
                             .layerMaxXMinYCorner,
                             .layerMinXMaxYCorner,
                             .layerMaxXMaxYCorner],
                            radius: 5
                        )
                        
                        let request = ImageRequest(url: url)
                        if let image = ImageCache.shared[request] {
                            self.documentFileStatusPercentageIndicator.isHidden = true
                            self.quoteAttachmentImageView.image = image
                        } else {
                            self.quoteAttachmentImageView.image = loadingPlaceholderImage

                            Nuke.ImagePipeline.shared.loadImage(
                                with: url,
                                progress: { _, completed, total in
                                    self.updateImageDownloadProgress(
                                        completed: completed,
                                        total: total
                                    )
                                },
                                completion: { _ in
                                    self.quoteAttachmentImageView.image = ImageCache.shared[request]
                                    self.documentFileStatusPercentageIndicator.isHidden = true
                                }
                            )
                        }
                    } else {
                        quoteAttachmentImageView.image = nil
                    }
                }
                
                if message.getQuote()?.getSenderName() == "Посетитель" {
                    quoteUsernameLabel.text = "HardcodedVisitorMessageName".localized
                } else {
                    quoteUsernameLabel.text = message.getQuote()?.getSenderName()
                }
                
                quoteBodyLabel.text = message.getQuote()?.getMessageText()?.replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
                if forOperator {
                    quoteUsernameLabel.textColor = quoteUsernameLabelColourOperator
                    quoteBodyLabel.textColor = quoteBodyLabelColourOperator
                } else {
                    quoteUsernameLabel.textColor = quoteUsernameLabelColourVisitor
                    quoteBodyLabel.textColor = quoteBodyLabelColourVisitor
                }
            }
        }
        
        timeLabel.text = timeFormatter.string(from: message.getTime())
        timeLabel.textColor = timeLabelColour
        
        if forOperator {
            messageStatusImageView.image = messageStatusImageViewImageRead
            
            if shouldShowOperatorInfo && !hasImage {
                messageUsernameLabel.text = message.getSenderName()
            } else {
                messageUsernameLabel.text = nil
            }
            
            if shouldShowOperatorInfo {
                if let url = message.getSenderAvatarFullURL() {
                    let request = ImageRequest(url: url)
                    if let image = ImageCache.shared[request] {
                        self.documentFileStatusPercentageIndicator.isHidden = true
                        self.userAvatarImageView.image = image
                    } else {
                        self.userAvatarImageView.image = loadingPlaceholderImage

                        Nuke.ImagePipeline.shared.loadImage(
                            with: url,
                            progress: { _, completed, total in
                                self.updateImageDownloadProgress(
                                    completed: completed,
                                    total: total
                                )
                            },
                            completion: { _ in
                                self.userAvatarImageView.image = ImageCache.shared[request]
                                self.documentFileStatusPercentageIndicator.isHidden = true
                            }
                        )
                    }
                } else {
                    userAvatarImageView.image = userAvatarImagePlaceholder
                }
            } else {
                userAvatarImageView.image = nil
            }
        } else {
            if message.getSendStatus() == .sending {
                messageStatusIndicator.startAnimating()
                messageStatusImageView.image = nil
                if hasSendingFile {
                    documentFileNameLabel.text = "Uploading file".localized
                    documentFileDescriptionLabel.text = "Counting".localized
                    documentFileNameLabel.textColor = documentFileNameLabelColourVisitor
                    documentFileDescriptionLabel.textColor = documentFileDescriptionLabelColourVisitor
                    documentFileStatusButton.setBackgroundImage(
                        documentFileStatusButtonUploadVisitor,
                        for: .normal
                    )
                }
            } else {
                messageStatusIndicator.stopAnimating()
                if message.isReadByOperator() {
                    self.messageStatusImageView.image = messageStatusImageViewImageRead
                } else {
                    messageStatusImageView.image = messageStatusImageViewImageSent
                }
            }
        }
        
        if isEdited {
            messageStatusLabel.text = "edited".localized
        } else {
            messageStatusLabel.text = ""
        }
        
       cellLayoutConstraintOther(
            showFullDate: showFullDate,
            forOperator: forOperator,
            hasQuote: hasQuote,
            hasQuoteAttachment: hasQuoteAttachment,
            hasQuoteImage: hasQuoteImage,
            hasAttachment: hasAttachment,
            hasImage: hasImage,
            hasSendingFile: hasSendingFile,
            imageViewSize: imageViewSize,
            shouldShowOperatorInfo: shouldShowOperatorInfo
        )
    }
    
    // MARK: - CONSTRAINT LAYOUT METHODS
    private func cellLayoutConstraintSystem(showFullDate: Bool) {
        if showFullDate {
            // dateLabel
            dateLabel.snp.remakeConstraints { (make) -> Void in
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                        .inset(SPACING_CELL)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_CELL)
                }
            }
        }
        
        // messageBodyLabel
        messageBodyLabel.snp.remakeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
                .inset(SPACING_DEFAULT)
        }
        
        // messageBackgroundView
        messageBackgroundView.snp.remakeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
                    .inset(SPACING_DEFAULT)
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                        .inset(SPACING_CELL)
                }
            } else {
                make.leading.trailing.equalToSuperview()
                    .inset(SPACING_DEFAULT)
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_CELL)
                }
            }
        }
        
        // timeLabel
        timeLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(messageBackgroundView.snp.centerX)
            make.top.equalTo(messageBackgroundView.snp.bottom)
                .offset(SPACING_CELL)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide)
                    .inset(SPACING_CELL)
            } else {
                make.bottom.equalToSuperview()
                    .inset(SPACING_CELL)
            }
        }
        
    }
    
    private func cellLayoutConstraintButtons(showFullDate: Bool) {
        
        if showFullDate {
            // dateLabel
            dateLabel.snp.remakeConstraints { (make) -> Void in
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                        .inset(SPACING_CELL)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_CELL)
                }
            }
        }
        
        // buttonsVerticalStack
        buttonsVerticalStack.snp.remakeConstraints { (make) -> Void in
            make.leading.trailing.top.equalToSuperview()
                .inset(SPACING_DEFAULT)
        }
        
        // timeLabel
        timeLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(messageBackgroundView.snp.centerX)
            make.top.equalTo(buttonsVerticalStack.snp.bottom)
                .offset(SPACING_CELL)
            make.bottom.equalToSuperview()
                .inset(SPACING_CELL)
        }
        
        // messageBackgroundView
        messageBackgroundView.snp.remakeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
                
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                } else {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                }
            } else {
                make.leading.trailing.bottom.equalToSuperview()
                
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
        }
    }
    
    private func cellLayoutConstraintOther(
        showFullDate: Bool,
        forOperator: Bool,
        hasQuote: Bool,
        hasQuoteAttachment: Bool,
        hasQuoteImage: Bool,
        hasAttachment: Bool,
        hasImage: Bool,
        hasSendingFile: Bool,
        imageViewSize: CGSize,
        shouldShowOperatorInfo: Bool
    ) {
        if showFullDate {
            // dateLabel
            dateLabel.snp.remakeConstraints { (make) -> Void in
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                        .inset(SPACING_CELL)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_CELL)
                }
            }
        }
        
        if forOperator {
            // userAvatarImageView
            userAvatarImageView.snp.remakeConstraints { (make) -> Void in
                if #available(iOS 11.0, *) {
                    make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
                        .inset(SPACING_DEFAULT)
                } else {
                    make.leading.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
                make.bottom.equalTo(messageBackgroundView.snp.bottom)
                make.width.height.equalTo(USERAVATARIMAGEVIEW_WIDTH)
            }
            
            // documentFileStatusPercentageIndicator
            documentFileStatusPercentageIndicator.snp.remakeConstraints { (make) -> Void in
                make.edges.equalToSuperview()
                    .inset(5)
            }
        }
        
        // messageBackgroundView
        messageBackgroundView.snp.remakeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalTo(self.safeAreaLayoutGuide)
                        .inset(SPACING_CELL)
                }
                
                if !forOperator {
                    make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
                        .inset(SPACING_DEFAULT)
                }
            } else {
                if showFullDate {
                    make.top.equalTo(dateLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_CELL)
                }
                
                if !forOperator {
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
            }
            if forOperator {
                make.leading.equalTo(userAvatarImageView.snp.trailing)
                    .offset(SPACING_DEFAULT)
            }
            make.width.greaterThanOrEqualTo(CHAT_BUBBLE_MIN_WIDTH)
            make.width.lessThanOrEqualTo(CHAT_BUBBLE_MAX_WIDTH)
        }

        if forOperator && shouldShowOperatorInfo {
            // messageUsernameLabel
            messageUsernameLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalToSuperview()
                    .inset(SPACING_DEFAULT)
                make.trailing.leading.equalToSuperview()
                    .inset(SPACING_DEFAULT)
            }
        }
        
        // timeLabel
        timeLabel.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(messageBackgroundView.snp.bottom)
                .offset(SPACING_CELL)
            if #available(iOS 11.0, *) {
                 make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .inset(SPACING_CELL).priority(999)
            } else {
                make.bottom.equalToSuperview()
                    .inset(SPACING_CELL).priority(999)
            }
            
            if forOperator {
                make.leading.equalTo(messageBackgroundView.snp.leading)
                    .inset(5)
            }
        }
        
        // messageStatusImageView
        messageStatusImageView.snp.remakeConstraints { (make) -> Void in
            make.leading.equalTo(timeLabel.snp.trailing)
                .offset(5)
            if !forOperator {
                if #available(iOS 11.0, *) {
                     make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
                        .inset(15)
                } else {
                    make.trailing.equalToSuperview()
                        .inset(15)
                }
            }
            make.centerY.equalTo(timeLabel.snp.centerY)
            
            make.width.height.equalTo(15)
        }
        
        if !forOperator {
            // messageStatusIndicator
            messageStatusIndicator.snp.remakeConstraints { (make) -> Void in
                make.center.equalTo(messageStatusImageView)
                make.width.height.equalTo(messageStatusImageView.snp.width)
            }
        }
        
        // messageStatusLabel
        messageStatusLabel.snp.remakeConstraints { (make) -> Void in
            make.centerY.equalTo(timeLabel.snp.centerY)
            if forOperator {
                make.leading.equalTo(messageStatusImageView.snp.trailing)
                    .offset(5)
            } else {
                make.trailing.equalTo(timeLabel.snp.leading)
                    .offset(-5)
            }
        }
        
        if hasQuote {
            // quoteLineView
            quoteLineView.snp.remakeConstraints { (make) -> Void in
                make.height.equalTo(45)
                make.width.equalTo(2)
                make.leading.equalToSuperview()
                    .inset(SPACING_DEFAULT)
               
                if forOperator && shouldShowOperatorInfo {
                    make.top.equalTo(messageUsernameLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
            }
            
            if hasQuoteAttachment {
                if hasQuoteImage {
                    // quoteAttachmentImageView
                    quoteAttachmentImageView.snp.remakeConstraints { (make) -> Void in
                        make.height.width.equalTo(quoteLineView.snp.height)
                        if forOperator && shouldShowOperatorInfo {
                            make.top.equalTo(messageUsernameLabel.snp.bottom)
                                .offset(SPACING_DEFAULT)
                        } else {
                            make.top.equalToSuperview()
                                .inset(SPACING_DEFAULT)
                        }
                        make.leading.equalTo(quoteLineView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    }
                    
                    // documentFileStatusPercentageIndicator
                    documentFileStatusPercentageIndicator.snp.remakeConstraints { (make) -> Void in
                        make.edges.equalToSuperview()
                            .inset(5)
                    }
                }
                
                // quoteUsernameLabel
                quoteUsernameLabel.snp.remakeConstraints { (make) -> Void in
                   
                    if forOperator && shouldShowOperatorInfo {
                        make.top.equalTo(messageUsernameLabel.snp.bottom)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.top.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                    if hasQuoteImage {
                        make.leading.equalTo(quoteAttachmentImageView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.leading.equalTo(quoteLineView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    }
                }
                
                // quoteBodyLabel
                quoteBodyLabel.snp.remakeConstraints { (make) -> Void in
                    make.top.equalTo(quoteUsernameLabel.snp.bottom)
                        .offset(5)
                    if hasQuoteImage {
                        make.leading.equalTo(quoteAttachmentImageView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.leading.equalTo(quoteLineView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    }
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
                
            } else {
                // quoteUsernameLabel
                quoteUsernameLabel.snp.remakeConstraints { (make) -> Void in
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                   
                    if forOperator && shouldShowOperatorInfo {
                        make.top.equalTo(messageUsernameLabel.snp.bottom)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.top.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                    make.leading.equalTo(quoteLineView.snp.trailing)
                        .offset(SPACING_DEFAULT)
                }
                
                // quoteBodyLabel
                quoteBodyLabel.snp.remakeConstraints { (make) -> Void in
                    make.top.equalTo(quoteUsernameLabel.snp.bottom)
                        .offset(5)
                    make.leading.equalTo(quoteLineView.snp.trailing)
                        .offset(SPACING_DEFAULT)
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
            }
        }
        
        if hasAttachment {
            if hasImage && !hasImageAsDocument {
                if forOperator && shouldShowOperatorInfo {
                    // imageUsernameLabel
                    imageUsernameLabel.snp.remakeConstraints { (make) -> Void in
                        make.top.bottom.equalToSuperview()
                            .inset(5)
                        make.trailing.leading.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                    
                    // imageUsernameLabelBackgroundView
                    imageUsernameLabelBackgroundView.snp.remakeConstraints { (make) -> Void in
                        make.top.leading.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                }
                
                // imageImageView
                imageImageView.snp.remakeConstraints { (make) -> Void in
                    make.height.equalTo(imageViewSize.height)
                    make.width.equalTo(imageViewSize.width)
                    make.edges.equalToSuperview()
                }
                
                // documentFileStatusPercentageIndicator
                documentFileStatusPercentageIndicator.snp.remakeConstraints { (make) -> Void in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(45)
                    make.width.equalTo(45)
                }
                
                // Since imageImageView is a SubView of messageBackgroundView we have to delete (or remake) constraint with minWidth of the background.
                messageBackgroundView.snp.remakeConstraints { (make) -> Void in
                    if #available(iOS 11.0, *) {
                        if showFullDate {
                            make.top.equalTo(dateLabel.snp.bottom)
                                .offset(SPACING_DEFAULT)
                        } else {
                            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                                .inset(SPACING_CELL)
                        }
                       
                        if !forOperator {
                            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
                                .inset(SPACING_DEFAULT)
                        }
                    } else {
                        if showFullDate {
                            make.top.equalTo(dateLabel.snp.bottom)
                                .offset(SPACING_DEFAULT)
                        } else {
                            make.top.equalToSuperview()
                                .inset(SPACING_CELL)
                        }
                       
                        if !forOperator {
                            make.trailing.equalToSuperview()
                                .inset(SPACING_DEFAULT)
                        }
                    }
                    if forOperator {
                        make.leading.equalTo(userAvatarImageView.snp.trailing)
                            .offset(SPACING_DEFAULT)
                    }
                    make.width.lessThanOrEqualTo(CHAT_BUBBLE_MAX_WIDTH)
                }
            } else {
                // documentFileStatusPercentageIndicator
                documentFileStatusPercentageIndicator.snp.remakeConstraints { (make) -> Void in
                    make.edges.equalToSuperview()
                }
                
                // documentFileCancelDownloadButton
                documentFileCancelDownloadButton.snp.remakeConstraints { (make) -> Void in
                    make.edges.equalToSuperview()
                }
                
                // documentFileStatusImageView
                documentFileStatusButton.snp.remakeConstraints { (make) -> Void in
                    make.height.equalTo(45)
                    make.width.equalTo(45)
                    make.leading.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                   
                    if forOperator && shouldShowOperatorInfo {
                        make.top.equalTo(messageUsernameLabel.snp.bottom)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.top.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                }
                
                // documentFileNameLabel
                documentFileNameLabel.snp.remakeConstraints { (make) -> Void in
                    make.trailing.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                    
                    if forOperator && shouldShowOperatorInfo {
                        make.top.equalTo(messageUsernameLabel.snp.bottom)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.top.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                    make.leading.equalTo(documentFileStatusButton.snp.trailing)
                        .offset(SPACING_DEFAULT)
                }
                
                // documentFileDescriptionLabel
                documentFileDescriptionLabel.snp.remakeConstraints { (make) -> Void in
                    make.top.equalTo(documentFileNameLabel.snp.bottom)
                        .offset(5)
                    make.leading.equalTo(documentFileStatusButton.snp.trailing)
                        .offset(SPACING_DEFAULT)
                    make.trailing.bottom.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
            }
        } else if hasSendingFile {
            documentFileStatusButton.snp.remakeConstraints { (make) -> Void in
                make.height.equalTo(45)
                make.width.equalTo(45)
                make.leading.equalToSuperview()
                    .inset(SPACING_DEFAULT)
               
                if forOperator && shouldShowOperatorInfo {
                    make.top.equalTo(messageUsernameLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
            }
            
            // documentFileNameLabel
            documentFileNameLabel.snp.remakeConstraints { (make) -> Void in
                make.trailing.equalToSuperview()
                    .inset(SPACING_DEFAULT)
                
                if forOperator && shouldShowOperatorInfo {
                    make.top.equalTo(messageUsernameLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    make.top.equalToSuperview()
                        .inset(SPACING_DEFAULT)
                }
                make.leading.equalTo(documentFileStatusButton.snp.trailing)
                    .offset(SPACING_DEFAULT)
            }
            
            // documentFileDescriptionLabel
            documentFileDescriptionLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(documentFileNameLabel.snp.bottom)
                    .offset(5)
                make.leading.equalTo(documentFileStatusButton.snp.trailing)
                    .offset(SPACING_DEFAULT)
                make.trailing.bottom.equalToSuperview()
                    .inset(SPACING_DEFAULT)
            }
        } else {
            // messageBodyLabel
            messageBodyLabel.snp.remakeConstraints { (make) -> Void in
                if hasQuote {
                    make.top.equalTo(quoteBodyLabel.snp.bottom)
                        .offset(SPACING_DEFAULT)
                } else {
                    if forOperator && shouldShowOperatorInfo {
                        make.top.equalTo(messageUsernameLabel.snp.bottom)
                            .offset(SPACING_DEFAULT)
                    } else {
                        make.top.equalToSuperview()
                            .inset(SPACING_DEFAULT)
                    }
                
                }
                make.trailing.bottom.leading.equalToSuperview()
                    .inset(SPACING_DEFAULT)
            }
        }
    }
    
    @objc
    private func downloadFile(_ sender: UIButton) {
        guard let message = messageFromCell,
            let url = message.getData()?.getAttachment()?.getFileInfo().getURL()
            else { return }
        downloadTask = urlSession.downloadTask(with: url)
        
        guard let fullURL = downloadTask.originalRequest?.url,
            let documentsDirectory = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first
            else { return }
        
        let fileName = fullURL.lastPathComponent
        let fileDestinationURLString = documentsDirectory.appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: fileDestinationURLString) {
            // TODO: Compare files here before moving forward
            showFile(fileName: fileName)
        } else {
            // documentFileStatusButton.setBackgroundImage(UIImage(), for: .normal)
            downloadTask.resume()
        }
    }
    
    @objc
    private func cancelDownload(_ sender: UIButton) {
        downloadTask.cancel()
        
        DispatchQueue.main.async {
            if self.isForOperator {
                self.documentFileStatusButton.setBackgroundImage(
                    documentFileStatusButtonDownloadOperator,
                    for: .normal
                )
            } else {
                self.documentFileStatusButton.setBackgroundImage(
                    documentFileStatusButtonDownloadVisitor,
                    for: .normal
                )
            }
            self.documentFileStatusPercentageIndicator.isHidden = true
            self.documentFileCancelDownloadButton.isHidden = true
        }
    }
    
    @objc
    private func sendButton(sender: UIButton) {
        guard let message = messageFromCell else { return }
        
        let messageID = message.getID()
        guard let title = sender.titleLabel?.text,
            let id = sender.accessibilityIdentifier
            else { return }
        
        print("Buttton \(title) with tag\\ID \(id) of message \(messageID) was tapped!")
        print(message.getText())
        
        let buttonInfoDictionary = [
            "Message": messageID,
            "ButtonID": id,
            "ButtonTitle": title
        ]
        
        NotificationCenter.default.post(
            name: .shouldSendKeyboardRequest,
            object: nil,
            userInfo: buttonInfoDictionary
        )
    }
    
    private func isFileExist(fileName: String) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
            else { return false }
        
        let fileDestinationURLString = documentsDirectory.appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: fileDestinationURLString)
    }
    
    private func updateFileDownloadProgress(progress: Float) {
        if self.documentFileStatusPercentageIndicator.isHidden {
            self.documentFileCancelDownloadButton.isHidden = false
            
            self.documentFileStatusPercentageIndicator.isHidden = false
            self.documentFileStatusPercentageIndicator.enableRotationAnimation()
            self.documentFileStatusButton.setBackgroundImage(UIImage(), for: .normal)
        }
        self.documentFileStatusPercentageIndicator.setProgressWithAnimation(
            duration: 0.1,
            value: progress
        )
    }
    
    private func updateImageDownloadProgress(completed: Int64, total: Int64) {
        let progress = Float(completed) / Float(total)

        if self.documentFileStatusPercentageIndicator.isHidden {
            self.documentFileStatusPercentageIndicator.isHidden = false
            self.documentFileStatusPercentageIndicator.enableRotationAnimation()
        }
        self.documentFileStatusPercentageIndicator.setProgressWithAnimation(
            duration: 0.1,
            value: progress
        )
    }
    
    private func showFile(fileName file: String) {
        let filesDictionary = ["FullName": file]
        NotificationCenter.default.post(
            name: .shouldShowFile,
            object: nil,
            userInfo: filesDictionary
        )
    }
}

// MARK: - UI methods
extension FlexibleTableViewCell {
    func createUILabel(
        textAlignment: NSTextAlignment = .left,
        systemFontSize: CGFloat,
        systemFontWeight: UIFont.Weight = .regular,
        numberOfLines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.font = .systemFont(ofSize: systemFontSize, weight: systemFontWeight )
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createUIView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func createUIImageView(contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
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
    
    func roundCornersForMessage(on uiView: UIView, forOperator: Bool) {
        var cornerMask = CACornerMask()
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft && forOperator {
            cornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
        } else if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft || forOperator {
            cornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            cornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
        }
        uiView.roundCorners(cornerMask, radius: 15)
    }
}

// MARK: - URLSessionDownloadDelegate
extension FlexibleTableViewCell: URLSessionDownloadDelegate {
        
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse, httpResponse.statusCode >= 200,
            httpResponse.statusCode < 300
            else {
                print("Server error")
                return
        }
        
        // Create destination URL with original name
        guard let url = downloadTask.originalRequest?.url,
        let documentsDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        else { return }
        
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        // Delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        
        // Copy from temp to Cache
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
        
        // Cache location for debug
        // print("Save path: \(documentsDirectory)")
        
        DispatchQueue.main.async {
            if self.isForOperator {
                self.documentFileStatusButton.setBackgroundImage(
                    documentFileStatusButtonDownloadSuccessOperator,
                    for: .normal
                )
            } else {
                self.documentFileStatusButton.setBackgroundImage(
                    documentFileStatusButtonDownloadSuccessVisitor,
                    for: .normal
                )
            }
            self.documentFileStatusPercentageIndicator.isHidden = true
            self.documentFileCancelDownloadButton.isHidden = true
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.updateFileDownloadProgress(progress: calculatedProgress)
        }
    }
}
