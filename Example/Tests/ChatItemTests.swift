//
//  ChatItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 15.02.18.
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
@testable import WebimMobileSDK
import XCTest

class ChatItemTests: XCTestCase {
    
    // MARK: - Constants
    static let CHAT_ITEM_JSON_STRING = """
{
    "readByVisitor" : true,
    "category" : null,
    "subject" : null,
    "operatorTyping" : false,
    "clientSideId" : "95f308d22be1a388c66e875fd71e466c",
    "state" : "chatting",
    "needToBeClosed" : false,
    "visitorTyping" : null,
    "messages" : [
        {
            "avatar" : null,
            "authorId" : null,
            "ts" : 1518713140.778348,
            "sessionId" : "72b6946234214a24b8d067a406ffcd53",
            "id" : "72b6946234214a24b8d067a406ffcd53_2",
            "text" : "Текст",
            "kind" : "info",
            "name" : ""
        },
        {
            "avatar" : null,
            "authorId" : null,
            "ts" : 1518713140.7789431,
            "sessionId" : "72b6946234214a24b8d067a406ffcd53",
            "id" : "72b6946234214a24b8d067a406ffcd53_3",
            "text" : "Пожалуйста, подождите немного, к Вам присоединится оператор..",
            "clientSideId" : "12af770c26754a5597ecd34b312ba758",
            "kind" : "info",
            "name" : ""
        }
    ],
    "offline" : false,
    "unreadByVisitorMsgCnt" : 5,
    "visitorMessageDraft" : null,
    "id" : 2530,
    "unreadByVisitorSinceTs" : 1518713140.778348,
    "operatorIdToRate" : {
        "firstOperatorId": {
            "operatorId":12,
            "rating":2
        },
        "secondOperatorId": {
            "operatorId":65,
            "rating":1
        }
    },
    "creationTs" : 1518713140.777204,
    "subcategory" : null,
    "requestedForm" : null,
    "unreadByOperatorSinceTs" : 1518713140.77720,
    "operator" : {
        "avatar" : "/webim/images/avatar/demo_33201.png",
        "fullname" : "Administrator",
        "id" : 33201,
        "robotType" : null,
        "departmentKeys" : [
            "telegram",
            "test3",
            "test2"
        ],
        "langToFullname" : { },
        "sip" : "10002715000033201"
    }
}
"""

    static let CHAT_ITEM_JSON_STRING_NULL_VALUES = """
{
    "readByVisitor" : null,
    "category" : null,
    "subject" : null,
    "operatorTyping" : null,
    "clientSideId" : null,
    "state" : null,
    "needToBeClosed" : null,
    "visitorTyping" : null,
    "messages" : null,
    "offline" : null,
    "unreadByVisitorMsgCnt" : null,
    "visitorMessageDraft" : null,
    "id" : null,
    "unreadByVisitorSinceTs" : null,
    "operatorIdToRate" : null,
    "creationTs" : null,
    "subcategory" : null,
    "requestedForm" : null,
    "unreadByOperatorSinceTs" : null,
    "operator" : null
}
"""


    private static let MESSAGE_JSON_STRING = """
{
    "avatar" : null,
    "authorId" : null,
    "ts" : 1518713140.778348,
    "sessionId" : "72b6946234214a24b8d067a406ffcd53",
    "id" : "72b6946234214a24b8d067a406ffcd53_2",
    "text" : "Текст",
    "kind" : "info",
    "name" : ""
}
"""
    private static let OPERATOR_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33201.png",
    "fullname" : "Administrator 2",
    "id" : 33201,
    "robotType" : null,
    "departmentKeys" : [
        "telegram",
        "test3",
        "test2"
    ],
    "langToFullname" : { },
    "sip" : "10002715000033201"
}
"""
    
    // MARK: - Properties
    private let chatItemDictionary = try! JSONSerialization.jsonObject(with:
                                                                        ChatItemTests.CHAT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]

    private let chatItemNullValuesDictionary = try! JSONSerialization.jsonObject(with:
                                                                                    ChatItemTests.CHAT_ITEM_JSON_STRING_NULL_VALUES.data(using: .utf8)!,
                                                                                 options: []) as! [String : Any?]
    
    // MARK: - Tests
    
    func testInit() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)

        XCTAssertEqual(chatItem.getMessages().count, 2)
        XCTAssertEqual(chatItem.isOperatorTyping(), false)
        XCTAssertEqual(chatItem.getState(), ChatItem.ChatItemState.chatting)
        XCTAssertEqual(chatItem.getOperator()!.getID(), "33201")
        XCTAssertEqual(chatItem.getReadByVisitor(), true)
        XCTAssertEqual(chatItem.getOperatorIDToRate()?.count, 2)
        XCTAssertEqual(chatItem.getUnreadByVisitorMessageCount(), 5)
        XCTAssertEqual(chatItem.getUnreadByVisitorTimestamp(), 1518713140.778348)
        XCTAssertEqual(chatItem.getUnreadByOperatorTimestamp(), 1518713140.77720)
    }

    func testInitWithNullJSONValues() {
        let chatItem = ChatItem(jsonDictionary: chatItemNullValuesDictionary)

        XCTAssertEqual(chatItem.getMessages().count, 0)
        XCTAssertEqual(chatItem.isOperatorTyping(), false)
        XCTAssertNil(chatItem.getState())
        XCTAssertNil(chatItem.getOperator())
        XCTAssertNil(chatItem.getReadByVisitor())
        XCTAssertTrue(chatItem.getOperatorIDToRate()?.isEmpty == true)
        XCTAssertEqual(chatItem.getUnreadByVisitorMessageCount(), 0)
        XCTAssertNil(chatItem.getUnreadByVisitorTimestamp())
        XCTAssertNil(chatItem.getUnreadByOperatorTimestamp())
        
    }
    
    func testGetSetMessages() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        let messageDictionary = try! JSONSerialization.jsonObject(with:
                                                                    ChatItemTests.MESSAGE_JSON_STRING.data(using: .utf8)!,
                                                                  options: []) as! [String: Any?]
        let message = MessageItem(jsonDictionary: messageDictionary)
        chatItem.set(messages: [message])
        
        XCTAssertEqual(chatItem.getMessages(),
                       [message])
    }
    
    func testAddMessage() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        let messageDictionary = try! JSONSerialization.jsonObject(with:
                                                                    ChatItemTests.MESSAGE_JSON_STRING.data(using: .utf8)!,
                                                                  options: []) as! [String: Any?]
        let message = MessageItem(jsonDictionary: messageDictionary)
        
        chatItem.add(message: message,
                     atPosition: chatItem.getMessages().count)
        XCTAssertTrue(message == chatItem.getMessages()[2])
        
        chatItem.add(message: message)
        XCTAssertTrue(message == chatItem.getMessages().last!)
    }
    
    func testSetOperatorTyping() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        XCTAssertFalse(chatItem.isOperatorTyping())
        
        chatItem.set(operatorTyping: true)
        XCTAssertTrue(chatItem.isOperatorTyping())
    }
    
    func testSetChatState() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        XCTAssertEqual(chatItem.getState(),
                       ChatItem.ChatItemState.chatting)
        
        chatItem.set(state: .closed)
        XCTAssertEqual(chatItem.getState(),
                       ChatItem.ChatItemState.closed)
    }
    
    func testSetOperator() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        XCTAssertEqual(chatItem.getOperator()?.getFullName(),
                       "Administrator")
        
        let operatorDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.OPERATOR_JSON_STRING.data(using: .utf8)!,
                                                                   options: []) as! [String: Any?]
        let operatorItem = OperatorItem(jsonDictionary: operatorDictionary)!
        chatItem.set(operator: operatorItem)
        XCTAssertEqual(chatItem.getOperator()?.getFullName(),
                       "Administrator 2")
    }
    
    func testSetReadByVisitor() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        XCTAssertTrue(chatItem.getReadByVisitor()!)
        
        chatItem.set(readByVisitor: false)
        XCTAssertFalse(chatItem.getReadByVisitor()!)
    }
    
    func testSetUnreadByOperatorTimestamp() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        chatItem.set(unreadByOperatorTimestamp: 1.0)
        
        XCTAssertEqual(chatItem.getUnreadByOperatorTimestamp(),
                       1.0)
    }

    func testSetRating() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        let ratingItemJsonDict = ["operatorId": 1, "rating": 5]
        let ratingItem = RatingItem(jsonDictionary: ratingItemJsonDict)!
        chatItem.set(rating: ratingItem, toOperatorWithId: "opID")

        XCTAssertTrue(chatItem.getOperatorIDToRate()!["opID"]! == ratingItem)
    }

    func testSetUnreadByVisitorMessageCount() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorMessageCount: 30)
        // Then
        XCTAssertEqual(chatItem.getUnreadByVisitorMessageCount(), 30)
    }

    func testSetNegativeUnreadByVisitorMessageCountShouldBeZero() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorMessageCount: -5)
        // Then
        XCTAssertEqual(chatItem.getUnreadByVisitorMessageCount(), 0)
    }

    func testSetUnreadByVisitorTimestamp() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorTimestamp: 12123.128412512)
        // Then
        XCTAssertEqual(chatItem.getUnreadByVisitorTimestamp(), 12123.128412512)
    }

    func testSetNegativeUnreadByVisitorTimestampShouldBeZero() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorTimestamp: -12123.128412512)
        // Then
        XCTAssertEqual(chatItem.getUnreadByVisitorTimestamp(), 0)
    }

    func testSetTooLargeUnreadByVisitorTimestamp() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorTimestamp: 9999999999999999999999999999999999999999999999999999999999999999999999999999999.999999999999999)
        // Then
        XCTAssertEqual(chatItem.getUnreadByVisitorTimestamp(), 9999999999999999999999999999999999999999999999999999999999999999999999999999999.999999999999999)
    }

    func testSetNilValueUnreadByVisitorTimeStamp() {
        // Given
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        // When
        chatItem.set(unreadByVisitorTimestamp: nil)
        // Then
        XCTAssertNil(chatItem.getUnreadByVisitorTimestamp())
    }
    
    // MARK: ChatItemState tests
    
    func testInitChatItemState() {
        XCTAssertEqual(ChatItem.ChatItemState(withType: "new_state").rawValue,
                       "unknown") // Some unsupported value.
    }
    
    func testIsClosed() {
        let chatItemState = ChatItem.ChatItemState(withType: "chatting")
        
        XCTAssertFalse(chatItemState.isClosed())
    }

}
