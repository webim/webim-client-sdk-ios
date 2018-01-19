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


import UIKit

import SnapKit
import WebimClientLibrary


// Custom colors for MessageTableViewCell objects.
extension UIColor {
    
    static var operatorName: UIColor {
        return UIColor(red: (128.0 / 255.0),
                       green: (0.0 / 255.0),
                       blue: (64.0 / 255.0),
                       alpha: 1.0)
    }
    static var visitorName: UIColor {
        return UIColor(red: (0.0 / 255.0),
                       green: (128.0 / 255.0),
                       blue: (64.0 / 255.0),
                       alpha: 1.0)
    }
    
}


// MARK: -
/**
 Custom cell representation for ChatViewController.
 - SeeAlso:
 `ChatViewController` class.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class MessageTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Size: CGFloat {
        case AVATAR = 40.0
    }
    
    
    // MARK: - Properties
    private static var imageCache = [URL: UIImage]()
    private static let dateFormatter: DateFormatter = {
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
    
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Methods
    
    /**
     Manages content layout of the cell.
     - SeeAlso:
     `layoutActionRequest(message:)` method.
     `layoutFileFromOperator(message:)` method.
     `layoutFileFromVisitor(message:)` method.
     `layoutInfo(message:)` method.
     `layoutOperator(message:)` method.
     `layoutOperatorBusy(message:)` method.
     `layoutVisitor(message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func setContent(withMessage message: Message) {
        // MARK: WEBIM: Using message type.
        let messageType = message.getType()
        
        switch messageType {
        case .ACTION_REQUEST:
            layoutActionRequest(message: message)
            
            break
        case .CONTACTS_REQUEST:
            layoutOperator(message: message)
            
            break
        case .FILE_FROM_OPERATOR:
            layoutFileFromOperator(message: message)
            
            break
        case .FILE_FROM_VISITOR:
            layoutFileFromVisitor(message: message)
            
            break
        case .INFO:
            layoutInfo(message: message)
            
            break
        case .OPERATOR:
            layoutOperator(message: message)
            
            break
        case .OPERATOR_BUSY:
            layoutOperatorBusy(message: message)
            
            break
        case .VISITOR:
            layoutVisitor(message: message)
            
            break
        }
    }
    
    // MARK: Private methods
    
    /**
     Layouts subviews of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func configureSubviews() {
        self.addSubview(avatarImageView)
        self.addSubview(nameLabel)
        self.addSubview(bodyLabel)
        self.addSubview(timeLabel)
        
        avatarImageView.snp.makeConstraints { [weak self] constraintsMaker in
            guard let `self` = self else {
                return
            }
            
            constraintsMaker.height.equalTo(Size.AVATAR.rawValue)
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
            
            constraintsMaker.top.equalTo(bodyLabel.snp.bottom).offset(1)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
            constraintsMaker.bottom.equalTo(self).offset(-10)
        }
    }
    
    /**
     Configure content layout of the cell when message type is action request.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutActionRequest(message: Message) {
        // Action request messages are kind of customization. There's no such messages at demo account.
    }
    
    /**
     Configure content layout of the cell when message type is file from operator.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutFileFromOperator(message: Message) {
        if let fileName = message.getAttachment()?.getFileName() {
            bodyLabel.text = fileName
        } else {
            bodyLabel.text = NSLocalizedString(FileMessage.FILE_UNAVAILABLE.rawValue,
                                               comment: "")
        }
        bodyLabel.textColor = .blue
        bodyLabel.isUserInteractionEnabled = true
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        timeLabel.text = getTime(forMessage: message)
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
        avatarImageView.accessibilityLabel = NSLocalizedString(Avatar.ACCESSIBILITY_LABEL.rawValue,
                                                               comment: "")
        avatarImageView.accessibilityHint = NSLocalizedString(Avatar.ACCESSIBILITY_HINT_FOR_OPERATOR.rawValue,
                                                              comment: "")
    }
    
    /**
     Configure content layout of the cell when message type is file from visitor.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutFileFromVisitor(message: Message) {
        if let fileName = message.getAttachment()?.getFileName() {
            bodyLabel.text = fileName
        } else {
            bodyLabel.text = NSLocalizedString(FileMessage.FILE_UNAVAILABLE.rawValue,
                                               comment: "") 
        }
        bodyLabel.textColor = .blue
        bodyLabel.isUserInteractionEnabled = true
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        timeLabel.text = getTime(forMessage: message)
        
        avatarImageView.image = #imageLiteral(resourceName: "VisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
        avatarImageView.accessibilityLabel = NSLocalizedString(Avatar.ACCESSIBILITY_LABEL.rawValue,
                                                               comment: "")
    }
    
    /**
     Configure content layout of the cell when message type is info.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutInfo(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .darkGray
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = ""
        
        timeLabel.text = ""
        
        avatarImageView.isHidden = true
        nameLabel.textColor = .visitorName
    }
    
    /**
     Configure content layout of the cell when message type is operator text message.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutOperator(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .black
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = .operatorName
        
        timeLabel.text = getTime(forMessage: message)
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
        avatarImageView.accessibilityLabel = NSLocalizedString(Avatar.ACCESSIBILITY_LABEL.rawValue,
                                                               comment: "")
        avatarImageView.accessibilityHint = NSLocalizedString(Avatar.ACCESSIBILITY_HINT_FOR_OPERATOR.rawValue,
                                                              comment: "")
    }
    
    /**
     Configure content layout of the cell when message type is operator is busy info message.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutOperatorBusy(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .darkGray
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = ""
        
        timeLabel.text = ""
        
        avatarImageView.isHidden = true
    }
    
    /**
     Configure content layout of the cell when message type is visitor text message.
     - SeeAlso:
     `setContent(withMessage message:)` method.
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Current message which is influenced layout of the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func layoutVisitor(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .black
        bodyLabel.isUserInteractionEnabled = false
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = .visitorName
        
        timeLabel.text = getTime(forMessage: message)
        
        avatarImageView.image = #imageLiteral(resourceName: "VisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
        avatarImageView.accessibilityLabel = NSLocalizedString(Avatar.ACCESSIBILITY_LABEL.rawValue,
                                                               comment: "") 
    }
    
    /**
     Loads operator avatar into appropriate image view of the cell.
     - SeeAlso:
     `Message` protocol of WebimClientLibrary.
     - parameter imageView:
     Image view which is supposed to show operator avater.
     - parameter message:
     Message that is appropriate to the cell.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func getOperatorAvatar(forImageView imageView: UIImageView,
                                   message: Message) {
        // FIXME: Could load wrong image to cell due to cell reuse mechanism.
        
        imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
        imageView.isHidden = false
        imageView.isUserInteractionEnabled = true
        if let avatarURL = message.getSenderAvatarFullURL() {
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
    
    /**
     Gets time string of the message.
     - SeeAlso:
     `Message` protocol of WebimClientLibrary.
     - parameter message:
     Message that is appropriate to the cell.
     - returns:
     Formatted message date and time string.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func getTime(forMessage message: Message) -> String {
        return MessageTableViewCell.dateFormatter.string(from: message.getTime())
    }
    
}
