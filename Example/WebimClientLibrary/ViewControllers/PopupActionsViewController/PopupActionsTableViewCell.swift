//
//  PopoverActionTableViewCell.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 02/10/2019.
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

class PopupActionsTableViewCell: UITableViewCell {
    
    // MARK: - Subviews
    private lazy var actionNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var actionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Methods
    func setupCell(forAction action: PopupAction) {
        self.addSubview(actionNameLabel)
        self.addSubview(actionImageView)
        
        setupConstraints()
        
        actionNameLabel.textColor = .white
        
        switch action {
        case .reply:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: replyImage
            )
        case .copy:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: copyImage
            )
        case .edit:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: editImage
            )
        case .delete:
            actionNameLabel.textColor = actionColourDelete
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: deleteImage
            )
        }
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        actionNameLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            // For some reason this layout only works for iOS 13+ only, not iOS 11+ as supposed to
            if #available(iOS 13.0, *) {
                make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
                    .inset(10)
            } else {
                make.leading.equalToSuperview()
                    .inset(10)
            }
        }
        
        actionImageView.snp.remakeConstraints { (make) in
            // For some reason this layout only works for iOS 13+ only, not iOS 11+ as supposed to
            if #available(iOS 13.0, *) {
                make.trailing.equalTo(self.safeAreaLayoutGuide)
                    .inset(10)
                make.top.bottom.equalTo(self.safeAreaLayoutGuide)
                    .inset(10)
                make.leading.equalTo(actionNameLabel.snp.trailing)
                    .offset(10)
            } else {
                make.trailing.bottom.equalToSuperview()
                    .inset(10)
                make.top.bottom.equalToSuperview()
                    .inset(10)
            }
            make.centerY.equalTo(actionNameLabel.snp.centerY)
            make.width.equalTo(actionImageView.snp.height)
        }
    }
    
    private func fillCell(actionText: String, actionImage: UIImage) {
        actionNameLabel.text = actionText
        actionImageView.image = actionImage
        actionImageView.tintColor = nil
    }
}
