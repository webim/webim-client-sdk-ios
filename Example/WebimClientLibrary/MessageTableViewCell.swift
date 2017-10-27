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
class MessageTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Size: CGFloat {
        case AVATAR = 40.0
    }
    
    
    // MARK: - Properties
    private static var imageCache = [String : UIImage]()
    lazy var avatarImageView = UIImageView()
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.numberOfLines = 0
        return label
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
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
    
    func setContent(withMessage message: Message) {
        // MARK: WEBIM: Using message type.
        let messageType = message.getType()
        
        switch messageType {
        case .ACTION_REQUEST:
            layoutActionRequest(message: message)
        case .FILE_FROM_OPERATOR:
            layoutFileFromOperator(message: message)
        case .FILE_FROM_VISITOR:
            layoutFileFromVisitor(message: message)
        case .INFO:
            layoutInfo(message: message)
        case .OPERATOR:
            layoutOperator(message: message)
        case .OPERATOR_BUSY:
            layoutOperatorBusy(message: message)
        case .VISITOR:
            layoutVisitor(message: message)
        }
    }
    
    // MARK: Private methods
    
    private func configureSubviews() {
        self.addSubview(avatarImageView)
        self.addSubview(nameLabel)
        self.addSubview(bodyLabel)
        
        avatarImageView.snp.makeConstraints { constraintsMaker in
            constraintsMaker.height.equalTo(Size.AVATAR.rawValue)
            constraintsMaker.width.equalTo(avatarImageView.snp.height)
            constraintsMaker.top.equalTo(self).offset(10)
            constraintsMaker.left.equalTo(self).offset(20)
        }
        
        nameLabel.snp.makeConstraints { constraintsMaker in
            constraintsMaker.top.equalTo(self).offset(10)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
        }
        
        bodyLabel.snp.makeConstraints { constraintsMaker in
            constraintsMaker.top.equalTo(nameLabel.snp.bottom).offset(1)
            constraintsMaker.left.equalTo(avatarImageView.snp.right).offset(10)
            constraintsMaker.right.equalTo(self).offset(-20)
            constraintsMaker.bottom.equalTo(self).offset(-10)
        }
    }
    
    private func layoutActionRequest(message: Message) {
        // Action request messages are kind of customization. There's no such messages at demo account.
    }
    
    private func layoutFileFromOperator(message: Message) {
        bodyLabel.text = message.getAttachment()?.getFileName()
        bodyLabel.textColor = .darkGray
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
    }
    
    private func layoutFileFromVisitor(message: Message) {
        bodyLabel.text = message.getAttachment()?.getFileName()
        bodyLabel.textColor = .darkGray
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        
        avatarImageView.image = #imageLiteral(resourceName: "VisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
    }
    
    private func layoutInfo(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .darkGray
        selectionStyle = .none
        
        nameLabel.text = ""
        
        avatarImageView.isHidden = true
        nameLabel.textColor = .visitorName
    }
    
    private func layoutOperator(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .black
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = .operatorName
        
        getOperatorAvatar(forImageView: avatarImageView,
                          message: message)
    }
    
    private func layoutOperatorBusy(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .darkGray
        selectionStyle = .none
        
        nameLabel.text = ""
        
        avatarImageView.isHidden = true
    }
    
    private func layoutVisitor(message: Message) {
        bodyLabel.text = message.getText()
        bodyLabel.textColor = .black
        selectionStyle = .none
        
        nameLabel.text = message.getSenderName()
        nameLabel.textColor = .visitorName
        
        avatarImageView.image = #imageLiteral(resourceName: "VisitorAvatar")
        avatarImageView.isHidden = false
        avatarImageView.isUserInteractionEnabled = false
    }
    
    private func getOperatorAvatar(forImageView imageView: UIImageView,
                                   message: Message) {
        imageView.image = #imageLiteral(resourceName: "DefaultAvatar")
        imageView.isHidden = false
        imageView.isUserInteractionEnabled = true
        if let avatarURLString = message.getSenderAvatarFullURLString() {
            if let image = MessageTableViewCell.imageCache[avatarURLString] {
                imageView.image = image
            } else {
                let avatarURL = URL(string: avatarURLString)!
                imageView.loadImageAsynchronouslyFrom(url: avatarURL,
                                                     rounded: true) { image in
                                                        MessageTableViewCell.imageCache[avatarURLString] = image
                }
            }
        }
    }
    
}
