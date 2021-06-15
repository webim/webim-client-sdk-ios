//
//  ChatViewController+UIView.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 11.05.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

extension ChatViewController {
    
    func createTypingIndicator() -> TypingIndicator {
        let view = TypingIndicator()
        view.circleDiameter = 5.0
        view.circleColour = UIColor.white
        view.animationDuration = 0.5
        return view
    }
    
    func createTextInputTextView() -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
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
    
    func configureSubviews() {
        configureNetworkErrorView()
        configureThanksView()
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
    
    func setupNavigationBar() {
        setupTitleView()
        setupRightBarButtonItem()
    }
    
    func setupTitleView() {
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
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(titleViewTapAction)
        )
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
    
}
