//
//  WMBotButtonsTableViewCell.swift
//  WebimClientLibrary_Example
//
//  Created by Anna Frolova on 22.03.2022.
//  Copyright © 2022 Webim. All rights reserved.
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

import Foundation
import WebimClientLibrary
import UIKit

class WMBotButtonsTableViewCell: WMMessageTableCell {
    
    @IBOutlet var borderView: UIView!
    @IBOutlet var buttonView: UIView!
    private let SPACING_CELL: CGFloat = 5.0
    private let SPACING_DEFAULT: CGFloat = 10.0
    
    lazy var buttonsVerticalStack: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            // stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = SPACING_CELL * 2
            return stackView
    }()
    
    private func emptyTheCell() {
        buttonsVerticalStack.removeFromSuperview()
        buttonsVerticalStack.removeAllArrangedSubviews()
    }
    
    override func setMessage(message: Message, tableView: UITableView) {
        emptyTheCell()
        buttonView.addSubview(buttonsVerticalStack)
        super.setMessage(message: message, tableView: tableView)
        fillButtonsCell(message: message, showFullDate: true)
    }
    
    private func fillButtonsCell(
            message: Message,
            showFullDate: Bool
        ) {
            
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
                        make.centerX.equalToSuperview()
                        
                    }
                }
            }
           cellLayoutConstraintButtons(showFullDate: showFullDate)
        }
    
    private func cellLayoutConstraintButtons(showFullDate: Bool) {
            // buttonsVerticalStack
            buttonsVerticalStack.snp.remakeConstraints { (make) -> Void in
                make.leading.trailing.top.bottom.equalToSuperview()
                    .inset(SPACING_DEFAULT)
            }
    }
    
    @objc
        private func sendButton(sender: UIButton) {
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
            sendKeyboardRequest(keyboardRequest: buttonInfoDictionary)
        }
}
