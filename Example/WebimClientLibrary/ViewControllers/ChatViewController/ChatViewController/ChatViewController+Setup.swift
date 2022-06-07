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
extension UILabel {
    static func createUILabel(
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
}

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
    
    func setupNavigationBar() {
        setupTitleView()
        setupRightBarButtonItem()
    }
    
    func addDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissViewKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func setupTestView() {
        if WMTestManager.testModeEnabled() {
            chatTestView.setupView(delegate: self)
            self.view.addSubview(chatTestView)
            chatTestView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            chatTestView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            chatTestView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.view.bringSubviewToFront(chatTestView)
        }
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
        navigationItem.rightBarButtonItem?.action = #selector(titleViewTapAction)
    }
    
    func configureNetworkErrorView() {
        
        self.connectionErrorView = ConnectionErrorView.loadXibView()
        self.connectionErrorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25)
        self.connectionErrorView.alpha = 0
        self.view.addSubviewWithSameWidth(connectionErrorView)
    }
    
    func configureThanksView() {
        
        self.thanksView = WMThanksAlertView.loadXibView()
        self.view.addSubviewWithSameWidth(thanksView)
        self.thanksView.hideWithoutAnimation()
    }
    
    func setupScrollButton() {
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
                    .inset(20)
                make.bottom.equalTo(self.toolbarView.bounds.maxY)
            } else {
                make.trailing.equalTo(self.view)
                    .inset(20)
                make.bottom.equalTo(self.toolbarView.bounds.maxY)
            }
            make.height.equalTo(self.scrollButton.snp.width)
            make.width.equalTo(30)
        }
        
        scrollButton.isHidden = true
    }
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            chatTableView?.refreshControl = newRefreshControl
        } else {
            chatTableView?.addSubview(newRefreshControl)
        }
        newRefreshControl.layer.zPosition -= 1
        newRefreshControl.addTarget(
            self,
            action: #selector(requestMessages),
            for: .valueChanged
        )
        newRefreshControl.tintColor = refreshControlTintColour
        let attributes = [NSAttributedString.Key.foregroundColor: refreshControlTextColour]
        newRefreshControl.attributedTitle = NSAttributedString(
            string: "Fetching more messages...".localized,
            attributes: attributes
        )
    }
    
    func configureNotifications() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
}
