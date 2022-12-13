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
@testable import FirebaseCoreInternal

class MessageItemTests: XCTestCase {

    var sut: MessageItem!
    
    // MARK: - Constants
    private let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "deleted": false,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "reaction": "someReaction",
    "canVisitorReact": true,
    "canVisitorChangeReaction": false,
    "text" : "42",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Евгения Техподдержка",
    "read" : true
}
"""
    private let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_1 = """
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
    private let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_2 = """
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
    private let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_3 = """
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
    private let MESSAGE_ITEM_TO_COMPARE_JSON_STRING_4 = """
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

    override func setUp() {
        super.setUp()
        sut = MessageItem(jsonDictionary: convertToDict(MESSAGE_ITEM_JSON_STRING))
    }


    
    // MARK: - Tests
    func testInit() {
        
        XCTAssertEqual(sut.getClientSideID(), "84e51d5638524ee7833a1fe19a1f2448")
        XCTAssertEqual(sut.getID(), "26871")
        XCTAssertEqual(sut.getText(), "42")
        XCTAssertEqual(sut.getSenderID(), "33202")
        XCTAssertEqual(sut.getSenderAvatarURLString(), "/webim/images/avatar/demo_33202.png")
        XCTAssertNil(sut.getData())
        XCTAssertFalse(sut.isDeleted())
        XCTAssertEqual(sut.getKind(), MessageItem.MessageKind.operatorMessage)
        XCTAssertEqual(sut.getSenderName(), "Евгения Техподдержка")
        XCTAssertEqual(sut.getTimeInMicrosecond(), 1518609964579372)
        XCTAssertEqual(sut.getReaction(), "someReaction")
        XCTAssertTrue(sut.getCanVisitorReact())
        XCTAssertFalse(sut.getCanVisitorChangeReaction())
    }
    
    func testEquals() {
        let messageItemDictionary1 = MessageItem(jsonDictionary: convertToDict(MESSAGE_ITEM_TO_COMPARE_JSON_STRING_1))
        let messageItemDictionary2 = MessageItem(jsonDictionary: convertToDict(MESSAGE_ITEM_TO_COMPARE_JSON_STRING_2))
        let messageItemDictionary3 = MessageItem(jsonDictionary: convertToDict(MESSAGE_ITEM_TO_COMPARE_JSON_STRING_3))
        let messageItemDictionary4 = MessageItem(jsonDictionary: convertToDict(MESSAGE_ITEM_TO_COMPARE_JSON_STRING_4))
        
        XCTAssertEqual(sut, messageItemDictionary1)
        XCTAssertNotEqual(sut, messageItemDictionary2)
        XCTAssertNotEqual(sut, messageItemDictionary3)
        XCTAssertNotEqual(sut, messageItemDictionary4)
    }

    func testSetRead() {
        sut.setRead(read: false)
        XCTAssertFalse(sut.getRead() == true)
        sut.setRead(read: true)
        XCTAssertTrue(sut.getRead() == true)
    }

    func test_Init_MessageKind_FromMessageType() {
        XCTAssertEqual(MessageItem.MessageKind(messageType: .actionRequest), .actionRequest)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .contactInformationRequest), .contactInformationRequest)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .fileFromOperator), .fileFromOperator)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .fileFromVisitor), .fileFromVisitor)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .info), .info)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .keyboard), .keyboard)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .keyboardResponse), .keyboardResponse)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .operatorMessage), .operatorMessage)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .operatorBusy), .operatorBusy)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .visitorMessage), .visitorMessage)
        XCTAssertEqual(MessageItem.MessageKind(messageType: .stickerVisitor), .stickerVisitor)
    }
}

class QuoteItemTests: XCTestCase {
    let quoteItemJson = """
    {
        "state": "filled",
        "message" : {
            "kind": "action_request",
            "authorId": 12345,
            "id": "someId",
            "name": "someName",
            "text": "someText",
            "ts": 99
        }
    }
    """

    func test_Init_QuoteStateItem_FromQuoteState() {
        XCTAssertEqual(QuoteItem.QuoteStateItem(quoteState: .filled), .filled)
        XCTAssertEqual(QuoteItem.QuoteStateItem(quoteState: .notFound), .notFound)
        XCTAssertEqual(QuoteItem.QuoteStateItem(quoteState: .pending), .pending)
    }

    func testInit() {
        let sut = QuoteItem(jsonDictionary: convertToDict(quoteItemJson))

        XCTAssertEqual(sut.getState(), .filled)
        XCTAssertEqual(sut.getMessageKind(), .actionRequest)
        XCTAssertEqual(sut.getAuthorID(), "12345")
        XCTAssertEqual(sut.getID(), "someId")
        XCTAssertEqual(sut.getSenderName(), "someName")
        XCTAssertEqual(sut.getTimeInMicrosecond(), Int64(99 * 1_000_000))
    }

    func testToDictionary() {
        let quote = QuoteImpl(state: .filled,
                              authorID: "12345",
                              messageAttachment: nil,
                              messageID: "someId",
                              messageType: .actionRequest,
                              senderName: "someName",
                              text: "someText",
                              rawText: "someRawText",
                              timestamp: 762861924123)

        let sut = QuoteItem.toDictionary(quote: quote)
        let messageDict = sut["message"] as? [String: Any?]

        XCTAssertEqual(sut["state"] as? String, "filled")
        XCTAssertEqual(messageDict?["authorId"] as? String, "12345")
        XCTAssertEqual(messageDict?["ts"] as? Int64, 762861)
        XCTAssertEqual(messageDict?["id"] as? String, "someId")
        XCTAssertEqual(messageDict?["text"] as? String, "someText")
        XCTAssertEqual(messageDict?["kind"] as? String, "action_request")
        XCTAssertEqual(messageDict?["name"] as? String, "someName")
    }
}

class MessageDataItemTests: XCTestCase {
    let messageDataItemjson = """
    {
       "file":{
          "state":"ready",
          "page_id":"ef5ab2a543c243c0a20df4b0cac6c073",
          "desc":{
             "content_type":"text/plain",
             "size":2200395,
             "filename":"WebimLog.txt",
             "client_content_type":"text/plain",
             "visitor_id":"699a9491aa31477d93647af288401ba0",
             "guid":"8b946ea3f709403599067487b5168d76"
          },
          "progress":100
       }
    }
    """

    func testInit() {
        let expectedPageId = FileItem.FileStateItem.ready

        let sut = MessageDataItem(jsonDictionary: convertToDict(messageDataItemjson))

        XCTAssertEqual(sut.getFile()?.getState() , expectedPageId)
    }

    func testInitWrongValue() {
        let sut = MessageDataItem(jsonDictionary: [:])

        XCTAssertNil(sut.getFile())
    }
}

class FileItemTests: XCTestCase {
    let fileItemJson = """
    {
       "state":"ready",
       "page_id":"ef5ab2a543c243c0a20df4b0cac6c073",
       "desc":{
          "content_type":"text/plain",
          "size":2200395,
          "filename":"WebimLog.txt",
          "client_content_type":"text/plain",
          "visitor_id":"699a9491aa31477d93647af288401ba0",
          "guid":"8b946ea3f709403599067487b5168d76"
       },
       "progress":100
    }
    """

    func testInit() {
        let expectedState = FileItem.FileStateItem.ready
        let expectedProgress: Int64 = 100
        let expectedPropertiesContentType = "text/plain"

        let sut = FileItem(jsonDictionary: convertToDict(fileItemJson))

        XCTAssertEqual(sut.getState(), expectedState)
        XCTAssertEqual(sut.getDownloadProgress(), expectedProgress)
        XCTAssertEqual(sut.getProperties()?.getContentType(), expectedPropertiesContentType)
        XCTAssertNil(sut.getErrorType())
        XCTAssertNil(sut.getErrorMessage())
    }

    func test_Init_FileStateItem_FromFileState() {
        XCTAssertEqual(FileItem.FileStateItem(fileState: .ready), .ready)
        XCTAssertEqual(FileItem.FileStateItem(fileState: .externalChecks), .externalChecks)
        XCTAssertEqual(FileItem.FileStateItem(fileState: .upload), .upload)
        XCTAssertEqual(FileItem.FileStateItem(fileState: .error), .error)
    }
}

fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}
