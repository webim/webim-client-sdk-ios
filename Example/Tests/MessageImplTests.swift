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
@testable import WebimMobileSDK
import XCTest

fileprivate let pageID = "page_id"
fileprivate let authorizationToken = "auth_token"
fileprivate let SERVER_URL_STRING = "https://demo.webim.ru"
fileprivate let userDefaultsKey = "userDefaultsKey"
fileprivate let internalErrorListener = InternalErrorListenerForTests()
fileprivate var authorizationData: AuthorizationData!
fileprivate var execIfNotDestroyedHandlerExecutor: ExecIfNotDestroyedHandlerExecutor!
fileprivate var actionRequestLoop: ActionRequestLoopForTests!
fileprivate var deltaRequestLoop: DeltaRequestLoop!
fileprivate var webimClient: WebimClient!
fileprivate var fileUrlCreator: FileUrlCreator!
fileprivate var imageInfo: ImageInfo!
fileprivate var fileInfoImpl: FileInfoImpl!
fileprivate var messageAttachment: MessageAttachmentImpl!

fileprivate let keyboardJsonPendingState = """
{
   "buttons":[
      [
         {
            "id":"1",
            "text":"text1",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         },
         {
            "id":"2",
            "text":"text2",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         }
      ],
      [
         {
            "id":"3",
            "text":"text3",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         }
      ]
   ],
   "state":"pending",
   "response":{
      "buttonId":"responseButtonId",
      "messageId":"responseMessageId"
   }
}
"""

fileprivate let keyboardJsonCancelledState = """
{
   "buttons":[
      [
         {
            "id":"1",
            "text":"text1",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         },
         {
            "id":"2",
            "text":"text2",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         }
      ],
      [
         {
            "id":"3",
            "text":"text3",
            "config":{
              "active":true,
              "link":"someData",
              "state":"showing"
            }
         }
      ]
   ],
   "state":"canceled",
   "response":{
      "buttonId":"responseButtonId",
      "messageId":"responseMessageId"
   }
}
"""

fileprivate let keyboardButtonItemJson = """
{
   "id":"3",
   "text":"text3",
   "config":{
      "active":true,
      "link":"someData",
      "state":"showing"
   }
}
"""

fileprivate let keyboardResponseItemJson = """
{
    "buttonId": "someButtonId",
    "messageId": "someMessageId"
}
"""

fileprivate let keyboardRequestItemJson = """
{
   "button":{
      "id":"3",
      "text":"someText",
      "config":null
   },
   "request":{
      "messageId":"someMessageId"
   }
}
"""

fileprivate let configItemJson = """
{
  "active":true,
  "link":"someData",
  "state":"showing"
}
"""

fileprivate let quoteItemJson = """
{
  "ref":{
     "msgId":"be252ae609f04ca4b5bf8cc13de433b5",
     "msgChannelSideId":null,
     "chatId":12428
  },
  "state":"filled",
  "message":{
     "id":"be252ae609f04ca4b5bf8cc13de433b5",
     "ts":1661234731,
     "authorId":223630,
     "text":"Susjsjss",
     "kind":"operator",
     "name":"Василий Админович",
     "channelSideId":null
  }
}
"""

fileprivate let quoteItemNullStateJson = """
{
  "ref":{
     "msgId":"be252ae609f04ca4b5bf8cc13de433b5",
     "msgChannelSideId":null,
     "chatId":12428
  },
  "state":null,
  "message":{
     "id":"be252ae609f04ca4b5bf8cc13de433b5",
     "ts":1661234731,
     "authorId":223630,
     "text":"Susjsjss",
     "kind":"operator",
     "name":"Василий Админович",
     "channelSideId":null
  }
}
"""

fileprivate let fileParametersJson = """
{
   "client_content_type":"image/jpeg",
   "image":{
      "size":{
         "width":700,
         "height":501
      }
   },
   "visitor_id":"877a920ede7082412656ac1cdec7ecde",
   "filename":"asset.JPG",
   "content_type":"image/png",
   "guid":"010a56da72ee41e2a78d0509155de755",
   "size":758611
}
"""

fileprivate let fewFileParametersJson = """
[
   {
      "client_content_type":"image/jpeg",
      "image":{
         "size":{
            "width":700,
            "height":501
         }
      },
      "visitor_id":"877a920ede7082412656ac1cdec7ecde",
      "filename":"asset.JPG",
      "content_type":"image/png",
      "guid":"010a56da72ee41e2a78d0509155de755",
      "size":758611
   },
   {
      "client_content_type":"image/jpeg",
      "image":{
         "size":{
            "width":700,
            "height":501
         }
      },
      "visitor_id":"877a920ede7082412656ac1cdec7ecde",
      "filename":"asset.JPG",
      "content_type":"image/png",
      "guid":"010a56da72ee41e2a78d0509155de755",
      "size":758611
   }
]
"""

class MessageImplTests: XCTestCase {
    
    // MARK: - Tests
    func testToString() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
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
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertNil(message.getSenderAvatarFullURL())
    }
    
    func testGetSendStatus() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertEqual(message.getSendStatus(),
                       MessageSendStatus.sent)
    }
    
    func testIsEqual() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        let message1 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id1",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        let message2 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   serverSideID: nil,
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
                                   messageIsEdited: false,
                                   visitorReactionInfo: nil,
                                   visitorCanReact: nil,
                                   visitorChangeReaction: nil)
        let message3 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   serverSideID: nil,
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
                                   messageIsEdited: false,
                                   visitorReactionInfo: nil,
                                   visitorCanReact: nil,
                                   visitorChangeReaction: nil)
        let message4 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   serverSideID: nil,
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
                                   messageIsEdited: false,
                                   visitorReactionInfo: nil,
                                   visitorCanReact: nil,
                                   visitorChangeReaction: nil)
        let message5 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   serverSideID: nil,
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
                                   messageIsEdited: false,
                                   visitorReactionInfo: nil,
                                   visitorCanReact: nil,
                                   visitorChangeReaction: nil)
        let message6 = MessageImpl(serverURLString: "http://demo.webim.ru",
                                   id: "id",
                                   serverSideID: nil,
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
                                   messageIsEdited: true,
                                   visitorReactionInfo: nil,
                                   visitorCanReact: nil,
                                   visitorChangeReaction: nil)
        
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
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertNoThrow(try message.getSource().assertIsCurrentChat())
    }
    
    func testAssertIsHistory() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertThrowsError(try message.getSource().assertIsHistory())
    }
    
    func testGetHistoryID() {
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertNil(message.getHistoryID())
    }
    
    func testGetCurrentChatID() {
        let currentChatID = "id"
        let message = MessageImpl(serverURLString: "http://demo.webim.ru",
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertEqual(currentChatID,
                       message.getCurrentChatID())
    }
    
    func testGetSenderAvatarFullURL() {
        let baseURLString = "http://demo.webim.ru"
        let avatarURLString = "/image.jpg"
        let message = MessageImpl(serverURLString: baseURLString,
                                  id: "id",
                                  serverSideID: nil,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
        
        XCTAssertEqual(URL(string: (baseURLString + avatarURLString)),
                       message.getSenderAvatarFullURL())
    }

    func testDisableBotButtons() {
        let baseURLString = "http://demo.webim.ru"
        let keyboardImpl = KeyboardImpl(data: convertToDict(keyboardJsonPendingState))
        let message = MessageImpl(serverURLString: baseURLString,
                                  id: "id",
                                  serverSideID: nil,
                                  keyboard: keyboardImpl,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .keyboard,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)

        XCTAssertTrue(message.disableBotButtons())
    }

    func testDisableBotButtons_CancelledState() {
        let baseURLString = "http://demo.webim.ru"
        let keyboardImpl = KeyboardImpl(data: convertToDict(keyboardJsonCancelledState))
        let message = MessageImpl(serverURLString: baseURLString,
                                  id: "id",
                                  serverSideID: nil,
                                  keyboard: keyboardImpl,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: nil,
                                  senderName: "Name",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .fileFromOperator,
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
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)

        XCTAssertFalse(message.disableBotButtons())
    }
    
}

// MARK: -
class FileInfoImplTests: XCTestCase {

    override func setUp() {
        super.setUp()
        fillMessageAttachmentsProperties()
    }

    override func tearDown() {
        resetMessageAttachmentsProperties()
        super.tearDown()
    }


    // MARK: - Tests
    func testInit() {
        XCTAssertEqual(fileInfoImpl.getContentType(), "image/jpeg")
        XCTAssertEqual(fileInfoImpl.getFileName(), "image")
        XCTAssertEqual(fileInfoImpl.getSize(), 1)
        XCTAssertEqual(fileInfoImpl.getURL(), URL(string: "/image.jpg")!)
        XCTAssertEqual(fileInfoImpl.getGuid(), "image123")
        XCTAssertEqual(fileInfoImpl.getImageInfo()?.getThumbURL(), imageInfo.getThumbURL())
        XCTAssertEqual(fileInfoImpl.getURL()?.absoluteString, "/image.jpg")
    }

    func testGetAttachment() {
        let sut = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator, text: fileParametersJson)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.getContentType(), "image/png")
    }

    func test_GetAttachment_WrongText() {
        let sut = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator, text: "someWrongText")

        XCTAssertNil(sut)
    }

    func test_GetAttachment_WrongDictionary() {
        let text = """
        {
            "some": "some"
            "some2": 123
        }
        """
        let sut = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator, text: text)

        XCTAssertNil(sut)
    }

    func testGetAttachments() {
        let expectedFilesCount = 2

        let sut = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator, text: fewFileParametersJson)

        XCTAssertEqual(sut.count, expectedFilesCount)
    }

    func test_GetAttachments_WrongText() {
        let sut = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator, text: "someWrongText")

        XCTAssertTrue(sut.isEmpty)
    }

    func test_GetAttachments_WrongDictionary() {
        let text = """
        [
            "some": "some"
            "some2": 123
        ]
        """
        let sut = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator, text: text)

        XCTAssertTrue(sut.isEmpty)
    }
}

class MessageAttachmentImplTests: XCTestCase {

    override func setUp() {
        super.setUp()
        fillMessageAttachmentsProperties()
    }

    override func tearDown() {
        resetMessageAttachmentsProperties()
        super.tearDown()
    }

    // MARK: - Tests
    func testInit() {
        let expectedFileInfoName = fileInfoImpl.getFileName()
        let expectedFilesInfoCount = 3
        let expectedState = AttachmentState.ready
        let expectedDownloadProgress: Int64 = 12
        let expectedErrorType = "someErrorType"
        let expectedErrorMessage = "someErrorMessage"

        XCTAssertEqual(messageAttachment.getFileInfo().getFileName(), expectedFileInfoName)
        XCTAssertEqual(messageAttachment.getFilesInfo().count, expectedFilesInfoCount)
        XCTAssertEqual(messageAttachment.getState(), expectedState)
        XCTAssertEqual(messageAttachment.getDownloadProgress(), expectedDownloadProgress)
        XCTAssertEqual(messageAttachment.getErrorType(), expectedErrorType)
        XCTAssertEqual(messageAttachment.getErrorMessage(), expectedErrorMessage)
    }
}

class ImageInfoImplTests: XCTestCase {
    override func setUp() {
        super.setUp()
        fillMessageAttachmentsProperties()
    }

    override func tearDown() {
        super.tearDown()
        resetMessageAttachmentsProperties()
    }
    
    // MARK: - Tests
    func testInit() {
        let imageInfo = ImageInfoImpl(withThumbURLString: "https://demo.webim.ru/thumb.jpg",
                                      fileUrlCreator: fileUrlCreator,
                                      filename: "thumb.jpg",
                                      guid: "123",
                                      width: 100,
                                      height: 200)
        XCTAssertEqual(imageInfo.getWidth(),
                       100)
        XCTAssertEqual(imageInfo.getHeight(),
                       200)
    }
}

class MessageDataImplTests: XCTestCase {
    override func setUp() {
        super.setUp()
        fillMessageAttachmentsProperties()
    }

    override func tearDown() {
        super.tearDown()
        resetMessageAttachmentsProperties()
    }

    func testInit() {
        let sut = MessageDataImpl(attachment: messageAttachment)

        XCTAssertEqual(sut.getAttachment()?.getFileInfo().getFileName(), fileInfoImpl.getFileName())
    }
}

class KeyboardImplTests: XCTestCase {

    var sut: KeyboardImpl!

    override func setUp() {
        super.setUp()
        sut = KeyboardImpl(data: convertToDict(keyboardJsonPendingState))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitKeyboardItem() {
        let expectedKeyboardState = KeyboardState.pending

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.getState(), expectedKeyboardState)
    }

    func testGetKeyboard() {
        let expectedKeyboardState = KeyboardState.canceled
        let sut = KeyboardImpl.getKeyboard(jsonDictionary: convertToDict(keyboardJsonCancelledState))

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.getState(), expectedKeyboardState)
    }

    func testGetButtons() {
        let expectedButtonsCount = 2

        XCTAssertEqual(sut.getButtons().count, expectedButtonsCount)
    }

    func testGetResponse() {
        let expectedButtonId = "responseButtonId"

        XCTAssertEqual(sut.getResponse()?.getButtonID(), expectedButtonId)
    }
}

class StickerImplTests: XCTestCase {

    //MARK: Tests
    func testInitData() {
        let dataDict: [String: Any?] = ["stickerId" : 14]
        let expectedValue = 14

        let sut = StickerImpl(data: dataDict)

        XCTAssertEqual(sut?.getStickerId(), expectedValue)
    }

    func testInitStickerId() {
        let expectedValue = 4

        let sut = StickerImpl(stickerId: expectedValue)

        XCTAssertEqual(sut.getStickerId(), expectedValue)
    }

    func test_Init_DataNullValue() {
        let sut = StickerImpl(data: [:])

        XCTAssertNil(sut)
    }

    func testGetSticker() {
        let dataDict: [String: Any?] = ["stickerId" : 95]
        let expectedValue = 95

        let sut = StickerImpl.getSticker(jsonDictionary: dataDict)

        XCTAssertEqual(sut?.getStickerId(), expectedValue)
    }
}

class KeyboardButtonImplTests: XCTestCase {

    //MARK: Tests
    func testInit() {
        let buttonKeyboardItem = KeyboardButtonItem(jsonDictionary: convertToDict(keyboardButtonItemJson))
        let expectedId = "3"
        let expectedText = "text3"
        let expectedConfigState = ButtonState.showing

        let sut = KeyboardButtonImpl(data: buttonKeyboardItem)

        XCTAssertEqual(sut?.getID(), expectedId)
        XCTAssertEqual(sut?.getText(), expectedText)
        XCTAssertEqual(sut?.getConfiguration()?.getState(), expectedConfigState)
    }

    func testInitNullValue() {
        let sut = KeyboardButtonImpl(data: nil)

        XCTAssertNil(sut)
    }
}

class KeyboardResponseImplTests: XCTestCase {

    //MARK: Tests
    func testInit() {
        let keyboardResponseItem = KeyboardResponseItem(jsonDictionary: convertToDict(keyboardResponseItemJson))
        let expectedButtonId = "someButtonId"
        let expectedMessageId = "someMessageId"

        let sut = KeyboardResponseImpl(data: keyboardResponseItem)

        XCTAssertEqual(sut?.getButtonID(), expectedButtonId)
        XCTAssertEqual(sut?.getMessageID(), expectedMessageId)
    }

    func testInitNullValue() {
        let sut = KeyboardResponseImpl(data: nil)

        XCTAssertNil(sut)
    }
}

class KeyboardRequestImplTests: XCTestCase {

    //MARK: Tests
    func testInit() {
        let expectedButtonId = "3"
        let expectedMessageId = "someMessageId"

        let sut = KeyboardRequestImpl(data: convertToDict(keyboardRequestItemJson))

        XCTAssertEqual(sut?.getButton().getID(), expectedButtonId)
        XCTAssertEqual(sut?.getMessageID(), expectedMessageId)
    }

    func testInitNullValue() {
        let sut = KeyboardRequestImpl(data: [:])

        XCTAssertNil(sut)
    }

    func testGetKeyboardRequest() {
        let expectedButtonId = "3"
        let expectedMessageId = "someMessageId"

        let sut = KeyboardRequestImpl.getKeyboardRequest(jsonDictionary: convertToDict(keyboardRequestItemJson))

        XCTAssertEqual(sut?.getButton().getID(), expectedButtonId)
        XCTAssertEqual(sut?.getMessageID(), expectedMessageId)
    }
}

class ConfigurationImplTests: XCTestCase {

    //MARK: Tests
    func testInit() {
        let configurationItem = ConfigurationItem(jsonDictionary: convertToDict(configItemJson))
        let expectedIsActive = true
        let expectedState = ButtonState.showing
        let expectedType = ButtonType.url
        let expectedData = "someData"

        let sut = ConfigurationImpl(data: configurationItem)

        XCTAssertEqual(sut?.isActive(), expectedIsActive)
        XCTAssertEqual(sut?.getState(), expectedState)
        XCTAssertEqual(sut?.getButtonType(), expectedType)
        XCTAssertEqual(sut?.getData(), expectedData)
    }

    func testInitNullValue() {
        let sut = ConfigurationImpl(data: nil)

        XCTAssertNil(sut)
    }
}

class QuoteImplTests: XCTestCase {

    var sut: QuoteImpl!

    private let expectedState = QuoteState.filled
    private let expectedAuthorId = "authorId"
    private let expectedMessageId = "messageID"
    private let expectedMessageType = MessageType.contactInformationRequest
    private let expectedSenderName = "senderName"
    private let expectedMessageText = "messageText"
    private let expectedRawText = "quoteRawText"

    override func setUp() {
        super.setUp()
        sut = QuoteImpl(state: expectedState,
                        authorID: expectedAuthorId,
                        messageAttachment: nil,
                        messageID: expectedMessageId,
                        messageType: expectedMessageType,
                        senderName: expectedSenderName,
                        text: expectedMessageText,
                        rawText: expectedRawText,
                        timestamp: 15123)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func testInit() {
        let expectedTimestamp = Date(timeIntervalSince1970: TimeInterval(15123 / 1_000_000))

        XCTAssertEqual(sut.getState(), expectedState)
        XCTAssertEqual(sut.getAuthorID(), expectedAuthorId)
        XCTAssertNil(sut.getMessageAttachment())
        XCTAssertEqual(sut.getMessageID(), expectedMessageId)
        XCTAssertEqual(sut.getState(), expectedState)
        XCTAssertEqual(sut.getMessageType(), expectedMessageType)
        XCTAssertEqual(sut.getSenderName(), expectedSenderName)
        XCTAssertEqual(sut.getMessageText(), expectedMessageText)
        XCTAssertEqual(sut.getRawText(), expectedRawText)
        XCTAssertEqual(sut.getMessageTimestamp(), expectedTimestamp)
    }

    func testGetQuote() {
        let quoteItem = QuoteItem(jsonDictionary: convertToDict(quoteItemJson))
        let expectedAuthorId = "223630"
        let expectedState = QuoteState.filled

        let sut = QuoteImpl.getQuote(quoteItem: quoteItem, messageAttachment: nil)

        XCTAssertEqual(sut?.getAuthorID(), expectedAuthorId)
        XCTAssertEqual(sut?.getState(), expectedState)

    }

    func test_GetQuote_NilValue() {
        let sut = QuoteImpl.getQuote(quoteItem: nil, messageAttachment: nil)

        XCTAssertNil(sut)
    }

    func test_GetQuote_NilState() {
        let quoteItem = QuoteItem(jsonDictionary: convertToDict(quoteItemNullStateJson))

        let sut = QuoteImpl.getQuote(quoteItem: quoteItem, messageAttachment: nil)

        XCTAssertNil(sut)
    }

    func test_GetMessageTimestamp_NullValue() {
        let sut = QuoteImpl(state: expectedState,
                        authorID: expectedAuthorId,
                        messageAttachment: nil,
                        messageID: expectedMessageId,
                        messageType: expectedMessageType,
                        senderName: expectedSenderName,
                        text: expectedMessageText,
                        rawText: expectedRawText,
                        timestamp: nil)

        XCTAssertNil(sut.getMessageTimestamp())
    }
}



fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}

fileprivate func fillMessageAttachmentsProperties() {
    authorizationData = AuthorizationData(pageID: pageID,
                                          authorizationToken: authorizationToken)

    execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(userDefaultsKey: userDefaultsKey), queue: DispatchQueue.main)

    actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                      internalErrorListener: internalErrorListener)
    deltaRequestLoop = DeltaRequestLoop(deltaCallback: DeltaCallback(currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: SERVER_URL_STRING),
                                            historyMessageMapper: HistoryMessageMapper(withServerURLString: SERVER_URL_STRING),
                                            userDefaultsKey: userDefaultsKey),
                                            completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                            sessionParametersListener: nil,
                                            internalErrorListener: internalErrorListener,
                                            baseURL: SERVER_URL_STRING,
                                            title: "title",
                                            location: "location",
                                            appVersion: nil,
                                            visitorFieldsJSONString: nil,
                                            providedAuthenticationTokenStateListener: nil,
                                            providedAuthenticationToken: nil,
                                            deviceID: "id",
                                            deviceToken: nil,
                                            remoteNotificationSystem: nil,
                                            visitorJSONString: nil,
                                            sessionID: nil,
                                            prechat: nil,
                                            authorizationData: authorizationData)

    webimClient = WebimClient(withActionRequestLoop: actionRequestLoop,
                                  deltaRequestLoop: deltaRequestLoop,
                                  webimActions: WebimActionsImpl(baseURL: SERVER_URL_STRING,
                                                                 actionRequestLoop: actionRequestLoop))
    fileUrlCreator =  FileUrlCreator(webimClient: webimClient, serverURL: SERVER_URL_STRING)
    imageInfo = ImageInfoImpl(withThumbURLString: "https://demo.webim.ru/thumb.jpg",
                                  fileUrlCreator: fileUrlCreator,
                                  filename: "thumb.jpg",
                                  guid: "123",
                                  width: 100,
                                  height: 200)
    fileInfoImpl = FileInfoImpl(urlString: "/image.jpg",
                       size: 1,
                       filename: "image",
                       contentType: "image/jpeg",
                       imageInfo: imageInfo,
                       guid: "image123",
                       fileUrlCreator: nil)

    messageAttachment = MessageAttachmentImpl(fileInfo: fileInfoImpl,
                                filesInfo: [fileInfoImpl, fileInfoImpl, fileInfoImpl],
                                state: .ready,
                                downloadProgress: 12,
                                errorType: "someErrorType",
                                errorMessage: "someErrorMessage")
}

fileprivate func resetMessageAttachmentsProperties() {
    authorizationData = nil
    execIfNotDestroyedHandlerExecutor = nil
    actionRequestLoop = nil
    deltaRequestLoop = nil
    webimClient = nil
    fileUrlCreator = nil
    imageInfo = nil
    fileInfoImpl = nil
    messageAttachment = nil
}

//MARK: Properties
let defaultMessage = MessageImpl(serverURLString: "https://demo.webim.ru",
                                 id: "id",
                                 serverSideID: nil,
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
                                 internalID: "internalId",
                                 rawText: nil,
                                 read: false,
                                 messageCanBeEdited: true,
                                 messageCanBeReplied: true,
                                 messageIsEdited: false,
                                 visitorReactionInfo: nil,
                                 visitorCanReact: true,
                                 visitorChangeReaction: nil)

let defaultMessage_2 = MessageImpl(serverURLString: "https://demo.webim.ru",
                                    id: "id",
                                    serverSideID: nil,
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
                                    historyMessage: true,
                                    internalID: "internalId",
                                    rawText: nil,
                                    read: false,
                                    messageCanBeEdited: true,
                                    messageCanBeReplied: true,
                                    messageIsEdited: false,
                                    visitorReactionInfo: nil,
                                    visitorCanReact: false,
                                    visitorChangeReaction: false)
