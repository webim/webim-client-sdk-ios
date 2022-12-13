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
import WebimClientLibrary

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
        var safeAreaInsets = 0.0
        if #available(iOS 11.0, *) {
            safeAreaInsets = view.safeAreaInsets.bottom
        }
        self.chatTableView.contentInset.bottom = safeAreaInsets + toolbarBackgroundView.frame.height
        self.chatTableView.contentOffset.y = self.chatTableView.contentInset.bottom
        self.view.setNeedsLayout()
    }

    func setupNavigationControllerManager() {
        navigationControllerManager.setAdditionalHeight()
        navigationControllerManager.set(isNavigationBarVisible: true)
        navigationControllerManager.removeOriginBorder()
        setupNavigationAdditionalView()
    }
    
    func addDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissViewKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @objc func functionTap() {
        dismissViewKeyboard()
        clearTextViewSelection()
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(functionTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        titleViewOperatorNameLabel.text = "Webim chat".localized
        titleViewOperatorNameLabel.textColor = .white
        titleViewOperatorNameLabel.highlightedTextColor = .lightGray
        
        let customViewForOperatorNameAndStatus = CustomUIView()
        customViewForOperatorNameAndStatus.isUserInteractionEnabled = true
        customViewForOperatorNameAndStatus.translatesAutoresizingMaskIntoConstraints = false

        customViewForOperatorNameAndStatus.addSubview(titleViewOperatorNameLabel)
        titleViewOperatorNameLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(titleViewTapAction)
        )
        customViewForOperatorNameAndStatus.addGestureRecognizer(gestureRecognizer)
        navigationItem.titleView = customViewForOperatorNameAndStatus
    }

    private func setupNavigationAdditionalView() {
        let additionalView = navigationControllerManager.getAdditionalView()

        titleViewOperatorStatusLabel.text = "No agent".localized
        titleViewOperatorStatusLabel.textColor = .white
        titleViewOperatorStatusLabel.highlightedTextColor = .lightGray
        titleViewOperatorStatusLabel.textAlignment = .center

        additionalView.addSubview(titleViewOperatorStatusLabel)
        titleViewOperatorStatusLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        additionalView.addSubview(titleViewTypingIndicator)
        titleViewTypingIndicator.snp.remakeConstraints { make in
            make.width.equalTo(30.0)
            make.height.equalTo(titleViewTypingIndicator.snp.width).multipliedBy(0.5)
            make.trailing.equalTo(titleViewOperatorStatusLabel.snp.leading).inset(2)
            make.centerY.equalToSuperview()
        }

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
        recountNetworkErrorViewFrame()
        self.connectionErrorView.alpha = 0
        self.view.addSubviewWithSameWidth(connectionErrorView)
    }

    func recountNetworkErrorViewFrame() {
        let insetY: CGFloat
        if #available(iOS 11, *) {
            insetY = additionalSafeAreaInsets.top
        } else {
            insetY = 22
        }
        self.connectionErrorView.frame = CGRect(x: 0, y: insetY, width: self.view.frame.width, height: 25)
    }
    
    func configureThanksView() {
        self.view.addSubviewWithSameWidth(thanksView)
        self.thanksView.hideWithoutAnimation()
    }
    
    func setupScrollButton() {
        view.addSubview(scrollButtonView)
        scrollButtonView.initialSetup()
        scrollButtonView.setScrollButtonBackgroundImage(scrollButtonImage, state: .normal)
        scrollButtonView.addTarget(
            self,
            action: #selector(scrollToUnreadMessage(_:)),
            for: .touchUpInside)
        scrollButtonView.setScrollButtonViewState(.hidden)
        setupScrollButtonViewConstraints()
    }

    private func setupScrollButtonViewConstraints() {
        scrollButtonView.snp.makeConstraints { make in
            let scrollButtonPadding: CGFloat = 22
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(view.safeAreaLayoutGuide).inset(scrollButtonPadding)
            } else {
                make.trailing.equalToSuperview().inset(scrollButtonPadding)
            }
            make.bottom.equalToSuperview().inset(toolbarView.frame.height + scrollButtonPadding)
            make.height.equalTo(scrollButtonView.snp.width)
            make.width.equalTo(34)
        }
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
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
         
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    func setupServerSideSettingsManager() {
        webimServerSideSettingsManager.getServerSideSettings()
    }

    func setupAlreadyRatedOperators() {
        guard let alreadyRatedOperatorsDictionary = WMKeychainWrapper.standard.dictionary(
            forKey: keychainKeyRatedOperators) as? [String: Bool] else {
            return
        }
        alreadyRatedOperators = alreadyRatedOperatorsDictionary
    }
    
    @objc func adjustContentForKeyboard(shown: Bool, notification: NSNotification) {
        guard shouldAdjustForKeyboard else {
            return
        }
        let frameEnd = notification.userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeight = shown ? frameEnd.size.height : toolbarBackgroundView.frame.height
        if chatTableView.contentInset.top == keyboardHeight {
            return
        }
        var safeAreaBottom = 0.0
        if #available(iOS 11.0, *) {
            safeAreaBottom = view.safeAreaInsets.bottom
        }
        var insets = chatTableView.contentInset
        insets.bottom = (keyboardHeight - toolbarBackgroundView.frame.height + (insets.bottom == 0.0 ? -safeAreaBottom : safeAreaBottom)).rounded()
        if chatTableView.contentInset.bottom == insets.bottom {
            return
        }
        var offset = chatTableView.contentOffset
        if self.chatTableView.contentInset.bottom == safeAreaBottom {
            insets.bottom -= safeAreaBottom
            offset.y += insets.bottom - safeAreaBottom
        } else {
            offset.y += safeAreaBottom - self.chatTableView.contentInset.bottom
        }
       
        self.chatTableView.contentOffset = offset
        self.chatTableView.contentInset = insets
        let scrollButtonConstraints = insets.bottom + self.toolbarBackgroundView.frame.height
        self.updateScrollButtonConstraints(scrollButtonConstraints)
      
    }
    @objc func keyboardWillShow(_ notification: NSNotification) {
        adjustContentForKeyboard(shown: true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        adjustContentForKeyboard(shown: false, notification: notification)
    }
}
