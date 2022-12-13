//
//  ScrollButton.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 23.07.2022.
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

import UIKit

class ScrollButtonView: UIView {

    @IBOutlet private var scrollButton: UIButton!
    @IBOutlet private var unreadMessageCounterLabel: UILabel!

    func initialSetup() {
        unreadMessageCounterLabel.layer.cornerRadius = unreadMessageCounterLabel.bounds.width / 2
        unreadMessageCounterLabel.layer.borderWidth = 1
        unreadMessageCounterLabel.layer.borderColor = unreadMessagesBorderColour.cgColor
    }

    func setScrollButtonBackgroundImage(_ image: UIImage?, state: UIControl.State) {
        scrollButton.setBackgroundImage(image, for: state)
    }

    func addTarget(_ target: Any, action: Selector, for event: UIControl.Event) {
        scrollButton.addTarget(target, action: action, for: event)
    }

    func setScrollButtonViewState(_ state: ScrollButtonViewState) {
        switch state {
        case .hidden:
            isHidden = true
            scrollButton.isHidden = true
            unreadMessageCounterLabel.isHidden = true
        case .visible:
            isHidden = false
            scrollButton.isHidden = false
            unreadMessageCounterLabel.isHidden = true
        case .newMessage:
            isHidden = false
            scrollButton.isHidden = false
            unreadMessageCounterLabel.isHidden = false
        }
    }

    func setNewMessageCount(_ count: Int) {
        unreadMessageCounterLabel.text = "\(count)"
    }

    func unreadMessagesCount() -> Int {
        return Int(unreadMessageCounterLabel.text ?? "") ?? 0
    }
}


enum ScrollButtonViewState {
    case hidden
    case visible
    case newMessage
}
