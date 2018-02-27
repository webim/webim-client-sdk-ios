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
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        let expectedString = """
MessageImpl {
    serverURLString = http://demo.webim.ru,
    ID = id,
    operatorID = nil,
    senderAvatarURLString = nil,
    senderName = Name,
    type = VISITOR,
    text = Text,
    timeInMicrosecond = 0,
    attachment = nil,
    historyMessage = false,
    currentChatID = nil,
    historyID = nil,
    rawText = nil
}
"""
        
        XCTAssertEqual(message.toString(),
                       expectedString)
    }
    
    func testGetSenderAvatarURL() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        
        XCTAssertNil(message.getSenderAvatarFullURL())
    }
    
    func testGetSendStatus() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        
        XCTAssertEqual(message.getSendStatus(),
                       MessageSendStatus.SENT)
    }
    
    func testIsEqual() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        
        let message1 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id1",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        let message2 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   operatorID: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name1",
                                   sendStatus: .SENT,
                                   type: .VISITOR,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   attachment: nil,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil)
        let message3 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   operatorID: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .SENT,
                                   type: .VISITOR,
                                   data: nil,
                                   text: "Text1",
                                   timeInMicrosecond: 0,
                                   attachment: nil,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil)
        let message4 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   operatorID: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .SENT,
                                   type: .OPERATOR,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   attachment: nil,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil)
        let message5 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   operatorID: nil,
                                   senderAvatarURLString: nil,
                                   senderName: "Name",
                                   sendStatus: .SENT,
                                   type: .VISITOR,
                                   data: nil,
                                   text: "Text",
                                   timeInMicrosecond: 0,
                                   attachment: nil,
                                   historyMessage: false,
                                   internalID: nil,
                                   rawText: nil)
        
        XCTAssertFalse(message.isEqual(to: message1))
        XCTAssertFalse(message.isEqual(to: message2))
        XCTAssertFalse(message.isEqual(to: message3))
        XCTAssertFalse(message.isEqual(to: message4))
        XCTAssertTrue(message.isEqual(to: message5))
    }
    
    // MARK: MessageSource tests
    
    func testAssertIsCurrentChat() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        
        XCTAssertNoThrow(try message.getSource().assertIsCurrentChat())
    }
    
    func testAssertIsHistory() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  operatorID: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .SENT,
                                  type: .VISITOR,
                                  data: nil,
                                  text: "Text",
                                  timeInMicrosecond: 0,
                                  attachment: nil,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil)
        
        XCTAssertThrowsError(try message.getSource().assertIsHistory())
    }
    
}

// MARK: -
class MessageAttachmentTests: XCTestCase {
    
    // MARK: - Tests
    func testInit() {
        let messageAttachment = MessageAttachmentImpl(urlString: "/image.jpg",
                                                      size: 1,
                                                      filename: "image",
                                                      contentType: "image/jpeg",
                                                      imageInfo: nil)
        
        XCTAssertEqual(messageAttachment.getContentType(),
                       "image/jpeg")
        XCTAssertEqual(messageAttachment.getFileName(),
                       "image")
        XCTAssertNil(messageAttachment.getImageInfo())
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
