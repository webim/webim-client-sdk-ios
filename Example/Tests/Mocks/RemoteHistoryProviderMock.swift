//
//  RemoteHistoryProviderMock.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 29.08.2022.
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
@testable import WebimClientLibrary

// MARK: - Mocking RemoteHistoryProvider
final class RemoteHistoryProviderMock: RemoteHistoryProvider {

    // MARK: - Properties
    var history: [MessageImpl]
    var numberOfCalls = 0

    // MARK: - Initialization
    init(withWebimActions webimActions: WebimActionsImpl,
         historyMessageMapper: MessageMapper,
         historyMetaInformation: HistoryMetaInformationStorage,
         history: [MessageImpl] = [MessageImpl]()) {
        self.history = history

        super.init(webimActions: webimActions,
                   historyMessageMapper: historyMessageMapper,
                   historyMetaInformationStorage: historyMetaInformation)
    }

    // MARK: - Methods
    override func requestHistory(beforeTimestamp: Int64,
                                 completion: @escaping ([MessageImpl], Bool) -> ()) {
        var beforeIndex = 0
        for (messageIndex, message) in history.enumerated() {
            if message.getTimeInMicrosecond() <= beforeTimestamp {
                beforeIndex = messageIndex

                continue
            } else {
                break
            }
        }

        let afterIndex = max(0, (beforeIndex - 100))

        numberOfCalls = numberOfCalls + 1

        completion((beforeIndex <= 0) ? [MessageImpl]() : Array(history[afterIndex ..< beforeIndex]), (afterIndex != 0))
    }

}
