//
//  MessageFactoriesTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 19.02.18.
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

// MARK: - Global constants
fileprivate let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "42",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
"""
fileprivate let MESSAGE_ITEM_DICTIONARY = try! JSONSerialization.jsonObject(with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                            options: []) as! [String : Any?]
fileprivate let MESSAGE_ITEM = MessageItem(jsonDictionary: MESSAGE_ITEM_DICTIONARY)

class CurrentChatMapperTests: XCTestCase {
    
    // MARK: - Properties
    let currentChatMapper = CurrentChatMessageMapper(withServerURLString: "http://demo.webim.ru")
    
    // MARK: - Tests
    
    func testMap() {
        let message = currentChatMapper.map(message: MESSAGE_ITEM)!
        
        XCTAssertEqual(message.getType(),
                       MessageType.operatorMessage)
        XCTAssertNil(message.getData()?.getAttachment())
        XCTAssertEqual(message.getText(),
                       "42")
        XCTAssertNil(message.getRawText())
        XCTAssertEqual(message.getOperatorID(),
                       "33202")
        XCTAssertEqual(message.getSenderAvatarURLString(),
                       "/webim/images/avatar/demo_33202.png")
        XCTAssertEqual(message.getSenderName(),
                       "Евгения Техподдержка")
        XCTAssertEqual(message.getTimeInMicrosecond(),
                       1518609964579372)
        XCTAssertFalse(message.hasHistoryComponent())
    }
    
    func testMapAll() {
        XCTAssertEqual(currentChatMapper.mapAll(messages: [MESSAGE_ITEM]).count,
                       1)
    }
    
}

class HistoryMapperTests: XCTestCase {
    
    // MARK: - Properties
    let historyMapper = HistoryMessageMapper(withServerURLString: "http://demo.webim.ru")
    
    // MARK: - Tests
    func testMap() {
        let message = historyMapper.map(message: MESSAGE_ITEM)!
        
        XCTAssertEqual(message.getType(),
                       MessageType.operatorMessage)
        XCTAssertNil(message.getData()?.getAttachment())
        XCTAssertEqual(message.getText(),
                       "42")
        XCTAssertNil(message.getRawText())
        XCTAssertEqual(message.getOperatorID(),
                       "33202")
        XCTAssertEqual(message.getSenderAvatarURLString(),
                       "/webim/images/avatar/demo_33202.png")
        XCTAssertEqual(message.getSenderName(),
                       "Евгения Техподдержка")
        XCTAssertEqual(message.getTimeInMicrosecond(),
                       1518609964579372)
        XCTAssertTrue(message.hasHistoryComponent())
    }
    
}

class SendingFactoryTests: XCTestCase {
    
    // MARK: - Properties
    let sendingFactory = SendingFactory(withServerURLString: "http://demo.webim.ru")
    
    // MARK: - Tests
    
    func testCreateTextMessage() {
        let message = sendingFactory.createTextMessageToSendWith(id: "1",
                                                                 text: "Text")
        
        XCTAssertEqual(message.getID(),
                       "1")
        XCTAssertTrue(message.getSenderName().isEmpty)
        XCTAssertEqual(message.getType(),
                       MessageType.visitorMessage)
        XCTAssertEqual(message.getText(),
                       "Text")
    }
    
    func testCreateFileMessage() {
        let message = sendingFactory.createFileMessageToSendWith(id: "1")
        
        XCTAssertEqual(message.getID(),
                       "1")
        XCTAssertTrue(message.getSenderName().isEmpty)
        XCTAssertEqual(message.getType(),
                       MessageType.fileFromVisitor)
        XCTAssertTrue(message.getText().isEmpty)
    }
    
}
