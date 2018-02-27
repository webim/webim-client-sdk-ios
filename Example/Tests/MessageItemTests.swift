//
//  MessageItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.02.18.
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

class MessageItemTests: XCTestCase {
    
    // MARK: - Constants
    private static let MESSAGE_ITEM_JSON_STRING = """
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
    private static let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_1 = """
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
""" // Same.
    private static let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_2 = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26872",
    "ts_m" : 1518609964579372,
    "text" : "42",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
""" // Different IDs.
    private static let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_3 = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "42",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2449",
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
""" // Different client side IDs.
    private static let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_4 = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "43",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
""" // Different texts.
    
    // MARK: - Properties
    private let messageItemDictionary = try! JSONSerialization.jsonObject(with: MessageItemTests.MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                          options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testInit() {
        let messageItem = MessageItem(jsonDictionary: messageItemDictionary)
        
        XCTAssertEqual(messageItem.getClientSideID(),
                       "84e51d5638524ee7833a1fe19a1f2448")
        XCTAssertEqual(messageItem.getID(),
                       "26871")
        XCTAssertEqual(messageItem.getText(),
                       "42")
        XCTAssertEqual(messageItem.getSenderID(),
                       "33202")
        XCTAssertEqual(messageItem.getSenderAvatarURLString(),
                       "/webim/images/avatar/demo_33202.png")
        XCTAssertNil(messageItem.getData())
        XCTAssertFalse(messageItem.isDeleted())
        XCTAssertEqual(messageItem.getKind(),
                       MessageItem.MessageKind.operatorMessage)
        XCTAssertEqual(messageItem.getSenderName(),
                       "Евгения Техподдержка")
        XCTAssertEqual(messageItem.getTimeInMicrosecond(),
                       1518609964579372)
    }
    
    func testEquals() {
        let messageItemDictionary1 = try! JSONSerialization.jsonObject(with: MessageItemTests.MESSAGE_ITEM_TO_COMPARE_JSON_STRING_1.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        let messageItemDictionary2 = try! JSONSerialization.jsonObject(with: MessageItemTests.MESSAGE_ITEM_TO_COMPARE_JSON_STRING_2.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        let messageItemDictionary3 = try! JSONSerialization.jsonObject(with: MessageItemTests.MESSAGE_ITEM_TO_COMPARE_JSON_STRING_3.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        let messageItemDictionary4 = try! JSONSerialization.jsonObject(with: MessageItemTests.MESSAGE_ITEM_TO_COMPARE_JSON_STRING_4.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        
        XCTAssertTrue(MessageItem(jsonDictionary: messageItemDictionary) == MessageItem(jsonDictionary: messageItemDictionary1))
        XCTAssertTrue(MessageItem(jsonDictionary: messageItemDictionary) != MessageItem(jsonDictionary: messageItemDictionary2))
        XCTAssertTrue(MessageItem(jsonDictionary: messageItemDictionary) != MessageItem(jsonDictionary: messageItemDictionary3))
        XCTAssertTrue(MessageItem(jsonDictionary: messageItemDictionary) != MessageItem(jsonDictionary: messageItemDictionary4))
    }
    
}
