//
//  MemoryHistoryStorageTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 20.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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
import XCTest

class MemoryHistoryStorageTests: XCTestCase {
    
    // MARK: - Constants
    private static let SERVER_URL_STRING = "http://demo.webim.ru"
    
    // MARK: - Methods
    // MARK: Private methods
    private static func generateMessages(ofCount numberOfMessages: Int) -> [MessageImpl] {
        var messages = [MessageImpl]()
        
        for index in 1 ... numberOfMessages {
            messages.append(MessageImpl(serverURLString: MemoryHistoryStorageTests.SERVER_URL_STRING,
                                        id: String(index),
                                        keyboard: nil,
                                        keyboardRequest: nil,
                                        operatorID: "1",
                                        quote: nil,
                                        senderAvatarURLString: nil,
                                        senderName: "Name",
                                        sticker: nil,
                                        type: .operatorMessage,
                                        rawData: nil,
                                        data: nil,
                                        text: "Text",
                                        timeInMicrosecond: Int64(index),
                                        historyMessage: true,
                                        internalID: String(index),
                                        rawText: nil,
                                        read: false,
                                        messageCanBeEdited: false,
                                        messageCanBeReplied: false,
                                        messageIsEdited: false))
        }
        
        return messages
    }
    
    // MARK: - Tests
    func testGetFullHistory() {
        let memoryHistoryStorage = MemoryHistoryStorage()
        let messagesCount = 10
        memoryHistoryStorage.receiveHistoryBefore(messages: MemoryHistoryStorageTests.generateMessages(ofCount: messagesCount),
                                                  hasMoreMessages: false)
        
        let expectation = XCTestExpectation()
        var gettedMessages = [Message]()
        memoryHistoryStorage.getFullHistory() { messages in
            gettedMessages = messages
            
            expectation.fulfill()
        }
        wait(for: [expectation],
             timeout: 1.0)
        
        XCTAssertEqual(gettedMessages.count,
                       messagesCount)
    }
}
