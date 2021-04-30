//
//  MessageImplTests.swift
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

class MessageImplTests: XCTestCase {
    
    // MARK: - Tests
    func testToString() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        let expectedString = """
MessageImpl {
    serverURLString = http://demo.webim.ru,
    ID = id,
    operatorID = nil,
    senderAvatarURLString = nil,
    senderName = Name,
    type = visitorMessage,
    text = Text,
    timeInMicrosecond = 0,
    attachment = nil,
    historyMessage = false,
    currentChatID = nil,
    historyID = nil,
    rawText = nil,
    read = false
}
"""
        
        XCTAssertEqual(message.toString(),
                       expectedString)
    }
    
    func testGetSenderAvatarURL() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertNil(message.getSenderAvatarFullURL())
    }
    
    func testGetSendStatus() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertEqual(message.getSendStatus(),
                       MessageSendStatus.sent)
    }
    
    func testIsEqual() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        let message1 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id1",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        let message2 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   keyboard: nil,
                                   keyboardRequest: nil,
                                   operatorID: nil,
                                   quote: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name1",
                                   sendStatus: .sent,
                                   sticker: nil,
                                   type: .visitorMessage,
                                   rawData: nil,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil,
                                   read: false,
                                   messageCanBeEdited: false,
                                   messageCanBeReplied: false,
                                   messageIsEdited: false)
        let message3 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   keyboard: nil,
                                   keyboardRequest: nil,
                                   operatorID: nil,
                                   quote: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .sent,
                                   sticker: nil,
                                   type: .visitorMessage,
                                   rawData: nil,
                                   data: nil,
                                   text: "Text1",
                                   timeInMicrosecond: 0,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil,
                                   read: false,
                                   messageCanBeEdited: false,
                                   messageCanBeReplied: false,
                                   messageIsEdited: false)
        let message4 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   keyboard: nil,
                                   keyboardRequest: nil,
                                   operatorID: nil,
                                   quote: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .sent,
                                   sticker: nil,
                                   type: .operatorMessage,
                                   rawData: nil,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil,
                                   read: false,
                                   messageCanBeEdited: false,
                                   messageCanBeReplied: false,
                                   messageIsEdited: false)
        let message5 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   keyboard: nil,
                                   keyboardRequest: nil,
                                   operatorID: nil,
                                   quote: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .sent,
                                   sticker: nil,
                                   type: .visitorMessage,
                                   rawData: nil,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil,
                                   read: false,
                                   messageCanBeEdited: false,
                                   messageCanBeReplied: false,
                                   messageIsEdited: false)
        let message6 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   keyboard: nil,
                                   keyboardRequest: nil,
                                   operatorID: nil,
                                   quote: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .sent,
                                   sticker: nil,
                                   type: .visitorMessage,
                                   rawData: nil,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil,
                                   read: false,
                                   messageCanBeEdited: false,
                                   messageCanBeReplied: false,
                                   messageIsEdited: true)
        
        XCTAssertFalse(message.isEqual(to: message1))
        XCTAssertFalse(message.isEqual(to: message2))
        XCTAssertFalse(message.isEqual(to: message3))
        XCTAssertFalse(message.isEqual(to: message4))
        XCTAssertTrue(message.isEqual(to: message5))
        XCTAssertFalse(message.isEqual(to: message6))
    }
    
    // MARK: MessageSource tests
    
    func testAssertIsCurrentChat() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertNoThrow(try message.getSource().assertIsCurrentChat())
    }
    
    func testAssertIsHistory() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertThrowsError(try message.getSource().assertIsHistory())
    }
    
    func testGetHistoryID() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertNil(message.getHistoryID())
    }
    
    func testGetCurrentChatID() {
        let currentChatID = "id"
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: currentChatID,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertEqual(currentChatID,
                       message.getCurrentChatID())
    }
    
    func testGetSenderAvatarFullURL() {
        let baseURLString = "http://demo.webim.ru"
        let avatarURLString = "/image.jpg"
        let message = MessageImpl(serverURLString: baseURLString,
                                  id: "id",
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: avatarURLString,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false)
        
        XCTAssertEqual(URL(string: (baseURLString + avatarURLString)),
                       message.getSenderAvatarFullURL())
    }
    
}

// MARK: -
class MessageAttachmentTests: XCTestCase {
    
    // MARK: - Tests
    func testInit() {
        let messageAttachment = FileInfoImpl(urlString: "/image.jpg",
                                             size: 1,
                                             filename: "image",
                                             contentType: "image/jpeg")
        
        XCTAssertEqual(messageAttachment.getContentType(),
                       "image/jpeg")
        XCTAssertEqual(messageAttachment.getFileName(),
                       "image")
        XCTAssertEqual(messageAttachment.getSize(),
                       1)
        XCTAssertEqual(messageAttachment.getURL(),
                       URL(string: "/image.jpg")!)
    }
    
}

// MARK: -
class ImageInfoImplTests: XCTestCase {
    
    // MARK: - Tests
    func testInit() {
        let imageInfo = ImageInfoImpl(withThumbURLString: "https://demo.webim.ru/thumb.jpg",
                                      width: 100,
                                      height: 200)
        
        
        XCTAssertEqual(imageInfo.getThumbURL(),
                       URL(string: "https://demo.webim.ru/thumb.jpg"))
        XCTAssertEqual(imageInfo.getWidth(),
                       100)
        XCTAssertEqual(imageInfo.getHeight(),
                       200)
    }
 
}
