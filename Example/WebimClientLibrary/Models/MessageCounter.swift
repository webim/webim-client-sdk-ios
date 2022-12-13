//
//  MessageCounter.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 25.07.2022.
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

protocol MessageCounterDelegate: AnyObject {
    func changed(newMessageCount: Int)
    func updateLastMessageIndex(completionHandler: ((Int) -> ())?)
    func updateLastReadMessageIndex(completionHandler: ((Int) -> ())?)
}

class MessageCounter {

    var lastReadMessageIndex: Int
    private var lastMessageIndex: Int
    private var actualNewMessageCount: Int

    private weak var delegate: MessageCounterDelegate?

    init(delegate: MessageCounterDelegate? = nil) {
        self.delegate = delegate
        self.lastMessageIndex = 0
        self.lastReadMessageIndex = 0
        self.actualNewMessageCount = 0
    }

    func set(lastReadMessageIndex: Int) {
        if lastReadMessageIndex > self.lastReadMessageIndex {
            self.lastReadMessageIndex = lastReadMessageIndex
            updateActualNewMessageCount()
        }
    }

    func set(lastMessageIndex: Int) {
        self.lastMessageIndex = lastMessageIndex
        updateActualNewMessageCount()
    }

    func getActualNewMessageCount() -> Int {
        return actualNewMessageCount
    }

    func hasNewMessages() -> Bool {
        return actualNewMessageCount > 0
    }

    func firstUnreadMessageIndex() -> Int {
        return lastReadMessageIndex + 1
    }

    func increaseLastReadMessageIndex(with count: Int) {
        self.lastReadMessageIndex += count
    }

    private func updateActualNewMessageCount() {
        if actualNewMessageCount != lastMessageIndex - lastReadMessageIndex {
            actualNewMessageCount = max(lastMessageIndex - lastReadMessageIndex, 0)
            delegate?.changed(newMessageCount: actualNewMessageCount)
        }
    }
}

extension MessageCounter: UnreadByVisitorMessageCountChangeListener {
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        delegate?.updateLastMessageIndex() { [weak self] index in
            self?.set(lastMessageIndex: index)
        }
        delegate?.updateLastReadMessageIndex() { [weak self] index in
            self?.set(lastReadMessageIndex: index)
        }
    }
}
