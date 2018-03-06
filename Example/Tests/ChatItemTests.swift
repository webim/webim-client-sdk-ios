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
@testable import WebimClientLibrary
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
    "visitorMessageDraft" : null,
    "id" : 2530,
    "unreadByVisitorSinceTs" : null,
    "operatorIdToRate" : { },
    "creationTs" : 1518713140.777204,
    "subcategory" : null,
    "requestedForm" : null,
    "unreadByOperatorSinceTs" : null,
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
    private let chatItemDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.CHAT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
    
    // MARK: - Tests
    
    func testInit() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        XCTAssertFalse(chatItem.isOperatorTyping())
        XCTAssertEqual(chatItem.getState(),
                       ChatItem.ChatItemState.chatting)
        XCTAssertEqual(chatItem.getOperator()!.getID(),
                       "33201")
        XCTAssertTrue(chatItem.getReadByVisitor()!)
        XCTAssertTrue(chatItem.getOperatorIDToRate()!.isEmpty)
        XCTAssertNil(chatItem.getUnreadByVisitorTimestamp())
        XCTAssertNil(chatItem.getUnreadByOperatorTimestamp())
        XCTAssertTrue(chatItem.getOperatorIDToRate()!.isEmpty)
    }
    
    func testGetSetMessages() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        
        let messageDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.MESSAGE_JSON_STRING.data(using: .utf8)!,
                                                                  options: []) as! [String: Any?]
        let message = MessageItem(jsonDictionary: messageDictionary)
        chatItem.set(messages: [message])
        
        XCTAssertEqual(chatItem.getMessages(),
                       [message])
    }
    
    func testAddMessage() {
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        let messageDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.MESSAGE_JSON_STRING.data(using: .utf8)!,
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
