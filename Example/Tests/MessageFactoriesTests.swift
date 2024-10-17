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
@testable import WebimMobileSDK
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


    func testCreateTextMessageToSendWithQuoteWith() {
        let message = MessageImpl(serverURLString: "Some",
                                  clientSideID: "Some",
                                  serverSideID: nil,
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: "Some",
                                  senderName: "Some",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Some",
                                  timeInMicrosecond: 12,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil,
                                  group: nil)

        let messageToSend = sendingFactory.createTextMessageToSendWithQuoteWith(
            id: "someMessageID",
            text: "reply message",
            repliedMessage: message)

        XCTAssertNotNil(messageToSend)
    }

    func testCreateFileMessageToSendWith() {
        let messageToSend = sendingFactory.createFileMessageToSendWith(id: "someID")

        XCTAssertNotNil(messageToSend)
        XCTAssertEqual(messageToSend.getType(), .fileFromVisitor)
    }

    func testCreateStickerMessageToSendWith() {

        let messageToSend = sendingFactory.createStickerMessageToSendWith(id: "someID", stickerId: .zero)

        XCTAssertNotNil(messageToSend)
        XCTAssertNotNil(messageToSend.getSticker())
        XCTAssertEqual(messageToSend.getType(), .stickerVisitor)
    }
    
}

class MessageMapperTests: XCTestCase {

    let messageMapper = MessageMapper(withServerURLString: "https://example.com")

    private func messageItemDictionary(_ kind: MessageItem.MessageKind) -> MessageItem {
        let jsonDict = """
{
"avatar" : "/webim/images/avatar/demo_33202.png",
"chatId" : "2489",
"authorId" : 33202,
"data" : null,
"id" : "26871",
"ts_m" : 1518609964579372,
"text" : "55",
"clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
"kind" : "\(kind.rawValue)",
"name" : "Евгения Техподдержка"
}
"""
        return MessageItem(jsonDictionary: try! JSONSerialization.jsonObject(
            with: jsonDict.data(using: .utf8)!,
            options: []) as! [String : Any?])
    }

    private func getMessageImpl(_ kind: MessageItem.MessageKind,
                                _ text: String = "Some text") -> MessageImpl? {
        messageMapper.convert(messageItem: messageItemDictionary(kind), historyMessage: false)
    }

    func testConvertMessageKind() {
        XCTAssertEqual(MessageMapper.convert(messageKind: .actionRequest), MessageType.actionRequest)
        XCTAssertEqual(MessageMapper.convert(messageKind: .contactInformationRequest), MessageType.contactInformationRequest)
        XCTAssertEqual(MessageMapper.convert(messageKind: .fileFromOperator), MessageType.fileFromOperator)
        XCTAssertEqual(MessageMapper.convert(messageKind: .fileFromVisitor), MessageType.fileFromVisitor)
        XCTAssertEqual(MessageMapper.convert(messageKind: .info), MessageType.info)
        XCTAssertEqual(MessageMapper.convert(messageKind: .keyboard), MessageType.keyboard)
        XCTAssertEqual(MessageMapper.convert(messageKind: .keyboardResponse), MessageType.keyboardResponse)
        XCTAssertEqual(MessageMapper.convert(messageKind: .operatorMessage), MessageType.operatorMessage)
        XCTAssertEqual(MessageMapper.convert(messageKind: .operatorBusy), MessageType.operatorBusy)
        XCTAssertEqual(MessageMapper.convert(messageKind: .visitorMessage), MessageType.visitorMessage)
        XCTAssertEqual(getMessageImpl(.stickerVisitor)?.getType(), .stickerVisitor)

        XCTAssertNil(MessageMapper.convert(messageKind: .contactInformation))
        XCTAssertNil(MessageMapper.convert(messageKind: .forOperator))
    }

    func testConvertToMessageImplWithNilKind() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "42",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : null,
    "name" : "Евгения Техподдержка"
}
"""
        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When
        let messageItem = MessageItem(jsonDictionary: messageItemDictionary)

        //Then
        XCTAssertNil(messageMapper.convert(messageItem: messageItem, historyMessage: true))

    }

    func testConvertToMessageImplSameKinds() {

        XCTAssertEqual(getMessageImpl(.actionRequest)?.getType(), .actionRequest)
        XCTAssertEqual(getMessageImpl(.contactInformationRequest)?.getType(), .contactInformationRequest)
        XCTAssertEqual(getMessageImpl(.info)?.getType(), .info)
        XCTAssertEqual(getMessageImpl(.keyboard)?.getType(), .keyboard)
        XCTAssertEqual(getMessageImpl(.keyboardResponse)?.getType(), .keyboardResponse)
        XCTAssertEqual(getMessageImpl(.operatorMessage)?.getType(), .operatorMessage)
        XCTAssertEqual(getMessageImpl(.operatorBusy)?.getType(), .operatorBusy)
        XCTAssertEqual(getMessageImpl(.visitorMessage)?.getType(), .visitorMessage)
        XCTAssertEqual(getMessageImpl(.actionRequest)?.getType(), .actionRequest)
        XCTAssertEqual(getMessageImpl(.stickerVisitor)?.getType(), .stickerVisitor)

        XCTAssertNil(getMessageImpl(.contactInformation))
        XCTAssertNil(getMessageImpl(.forOperator))
        XCTAssertNil(getMessageImpl(.fileFromOperator))
        XCTAssertNil(getMessageImpl(.fileFromVisitor))
    }

    func testNilMessageItemText() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : null,
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : null,
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
"""
        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: MessageItem text is nil
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl)
    }

    func testConvertWrongDataKeyboardKind() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeWrongData",
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "keyboard",
    "name" : "Евгения Техподдержка"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: Kind Keyboard && wrong data
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl?.getKeyboard())
    }

    func testConvertWrongDataKeyboardResponseKind() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeWrongData",
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "keyboardResponse",
    "name" : "Евгения Техподдержка"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: Kind keyboardResponse && wrong data
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl?.getKeyboardRequest())
    }

    func testConvertWrongDataStickerVisitor() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeWrongData",
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "stickerVisitor",
    "name" : "Евгения Техподдержка"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: Kind stickerVisitor && wrong data
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl?.getSticker())
    }

    func testConvertMessageItemWithQuote() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeData",
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "quote" : {
      "ref" : {
        "msgId" : "bec8cdd63dbb43fb97b843021d97fb94",
        "msgChannelSideId" : null,
        "chatId" : null
      },
      "state" : "pending"
    },
    "kind" : "stickerVisitor",
    "name" : "Евгения Техподдержка"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: MessageItem has quote
        let messageItem = MessageItem(jsonDictionary: messageItemDictionary)
        let messageImpl = messageMapper.convert(messageItem: messageItem, historyMessage: false)

        //Then
        XCTAssertEqual(messageItem.getQuote()?.getText(), messageImpl?.getQuote()?.getMessageText())
        XCTAssertEqual(messageItem.getQuote()?.getID(), messageImpl?.getQuote()?.getMessageID())
    }

    func testConvertMessageItemClientSideIDNil() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeData",
    "id" : null,
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : null,
    "kind" : "operator",
    "name" : "Евгения Техподдержка"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: cliendSideID && id is nil
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl)
    }

    func testConvertMessageItemSenderNameNil() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeData",
    "id" : "26871",
    "ts_m" : 1518609964579372,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : null
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: senderName is nil
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl)
    }

    func testConvertMessageItemTimeInMicrosecondNil() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : "SomeData",
    "id" : "26871",
    "ts_m" : null,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "operator",
    "name" : "Operator name"
}
"""

        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: timestamp in microsecond is nil
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNil(messageImpl)
    }

    func testConvertMessageItemKeyboardData() {
        //Given
        let MESSAGE_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33202.png",
    "chatId" : "2489",
    "authorId" : 33202,
    "data" : {
        "stickerId" : 123
    },
    "id" : "26871",
    "stickerId" : 154,
    "ts_m" : 124123,
    "text" : "SomeText",
    "clientSideId" : "84e51d5638524ee7833a1fe19a1f2448",
    "kind" : "sticker_visitor",
    "name" : "Operator name"
}
"""
        let messageItemDictionary = try! JSONSerialization.jsonObject(
            with: MESSAGE_ITEM_JSON_STRING.data(using: .utf8)!,
            options: []) as! [String : Any?]

        //When: Kind stickerVisitor && has stickerID
        let messageImpl = messageMapper.convert(
            messageItem: MessageItem(jsonDictionary: messageItemDictionary),
            historyMessage: false)

        //Then
        XCTAssertNotNil(messageImpl?.getSticker())
    }

}
