//
//  MessageTableViewCell.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 06.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//
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

import SnapKit
import UIKit
import WebimClientLibrary

// MARK: -
final class MessageTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Size: CGFloat {
        case avatar = 40.0
    }
    
    // MARK: - Properties
    private static var imageCache = [URL: UIImage]()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss"
        
        return dateFormatter
    }()
    
    // MARK: Subviews
    lazy var avatarImageView = UIImageView()
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        
        return label
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .lightGray
        label.textAlignment = .right
        
        return label
    }()
    lazy var quoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // UITableViewCell requirement.
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
        quoteLabel.text = nil
    }
    
    func setContent(withMessage message: Message) {
        switch message.getType() {
        case .actionRequest:
            layoutActionRequest(message: message)
            
        case .contactInformationRequest:
            layoutOperator(message: message)
            
        case .fileFromOperator:
            layoutFileFromOperator(message: message)
            
        case .fileFromVisitor:
            layoutFileFromVisitor(message: message)
            
        case .info:
            layoutInfo(message: message)
            
        case .keyboard,
             .keyboardResponse:
            layoutInfo(message: message)
            
        case .operatorMessage:
            layoutOperator(message: message)
            
        case .operatorBusy:
            layoutOperatorBusy(message: message)
            
        case .visitorMessage:
            layoutVisitor(message: message)
            
        case .stickerVisitor:
            layoutSticker(message: message)
            
        }
        
        backgroundColor = backgroundTableViewColor.color()
    }
    
    // MARK: Private methods
    
    private func configureSubviews() {
        self.addSubview(avatarImageView)
        self.addSubview(nameLabel)
        self.addSubview(bodyLabel)
        self.addSubview(timeLabel)
        self.addSubview(quoteLabel)
        
        avatarImageView.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.height.equalTo(Size.avatar.rawValue)
            constraintsMaker.width.equalTo(avatarImageView.snp.height)
            constraintsMaker.top.equalTo(self).offset(10)
            constraintsMaker.left.equalTo(self).offset(20)
        }
        
        nameLabel.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.top.equalTo(self).offset(10)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
        }
        
        bodyLabel.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.top.equalTo(nameLabel.snp.bottom).offset(1)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
        }
        
        timeLabel.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.top.equalTo(quoteLabel.snp.bottom).offset(1)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
            constraintsMaker.bottom.equalTo(self).offset(-10)
        }
        
        quoteLabel.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.top.equalTo(bodyLabel.snp.bottom).offset(1)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
        }
    }
    
    private func layoutActionRequest(message: Message) {
        // Action request messages are kind of customization. There's no such messages at demo account.
    }
    
    private func layoutFileFromOperator(message: Message) {
        if let fileName = message.getData()?.getAttachment()?.getFileInfo().getFileName() {
            bodyLabel.text = fileName
        } else {
            bodyLabel.text = FileMessage.fileUnavailable.rawValue.localized
        }
        bodyLabel.textColor = textTintColor.color()
        bodyLabel.isUserInteractionEnabled = true
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        timeLabel.text = dateFormatter.string(from: message.getTime())
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
        avatarImageView.accessibilityLabel = Avatar.accessibilityLabel.rawValue.localized
        avatarImageView.accessibilityHint = Avatar.accessibilityHintOperator.rawValue.localized
    }
    
    private func layoutFileFromVisitor(message: Message) {
        if let fileName = message.getData()?.getAttachment()?.getFileInfo().getFileName() {
            bodyLabel.text = fileName
        } else {
            bodyLabel.text = FileMessage.fileUnavailable.rawValue.localized
        }
        bodyLabel.textColor = textTintColor.color()
        bodyLabel.isUserInteractionEnabled = true
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        timeLabel.text = dateFormatter.string(from: message.getTime())
        
        avatarImageView.image = #imageLiteral(resourceName: "HardcodedVisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
        avatarImageView.accessibilityLabel = Avatar.accessibilityLabel.rawValue.localized
    }
    
    private func layoutInfo(message: Message) {
        bodyLabel.text = message.getText().decodePercentEscapedLinksIfPresent()
        bodyLabel.textColor = textSecondaryColor.color()
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = ""
        
        timeLabel.text = ""
        
        avatarImageView.isHidden = true
    }
    
    private func layoutOperator(message: Message) {
        bodyLabel.text = message.getText().decodePercentEscapedLinksIfPresent()
        bodyLabel.textColor = textMainColor.color()
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = textNameOperatorColor.color()
        
        timeLabel.text = dateFormatter.string(from: message.getTime())
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
        avatarImageView.accessibilityLabel = Avatar.accessibilityLabel.rawValue.localized
        avatarImageView.accessibilityHint = Avatar.accessibilityHintOperator.rawValue.localized
        
        if let quote = message.getQuote() {
            quoteLabel.text = "\(quote.getSenderName() ?? ""): \(quote.getMessageText() ?? "")"
        }
    }
    
    private func layoutOperatorBusy(message: Message) {
        bodyLabel.text = message.getText().decodePercentEscapedLinksIfPresent()
        bodyLabel.textColor = textSecondaryColor.color()
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = ""
        
        timeLabel.text = ""
        
        avatarImageView.isHidden = true
    }
    
    private func layoutSticker(message: Message) {
        layoutVisitor(message: message)
        bodyLabel.text = "sticker with id: \(String(describing: message.getSticker()?.getStickerId()))"
    }
    
    private func layoutVisitor(message: Message) {
        bodyLabel.text = message.getText().decodePercentEscapedLinksIfPresent()
        bodyLabel.textColor = textMainColor.color()
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = textNameVisitorColor.color()
        
        timeLabel.text = dateFormatter.string(from: message.getTime())
        
        avatarImageView.image = #imageLiteral(resourceName: "HardcodedVisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
        avatarImageView.accessibilityLabel = Avatar.accessibilityLabel.rawValue.localized
        
        if let quote = message.getQuote() {
            quoteLabel.text = "\(quote.getSenderName() ?? ""): \(quote.getMessageText() ?? "")"
        }
    }
    
    private func getOperatorAvatar(forImageView imageView: UIImageView,
                                   message: Message) {
        // FIXME: Could load wrong image to cell due to cell reuse mechanism.
        
        imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
        imageView.isHidden = false
        imageView.isUserInteractionEnabled = true
        
        guard let avatarURL = message.getSenderAvatarFullURL() else {
            return
        }
        
        if let image = MessageTableViewCell.imageCache[avatarURL] {
            imageView.image = image
        } else {
            imageView.loadImageAsynchronouslyFrom(url: avatarURL,
                                                  rounded: true) { image in
                                                    MessageTableViewCell.imageCache[avatarURL] = image
            }
        }
    }
    
}
