//
//  WebimActionsTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 29.01.18.
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
import XCTest
@testable import WebimClientLibrary

class WebimActionsTests: XCTestCase {
    
    // MARK: - Constants
    private static let userDefaultsKey = "userDefaultsKey"
    
    // MARK: - Properties
    private let actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(userDefaultsKey: WebimActionsTests.userDefaultsKey),
                                                                                                                           queue: DispatchQueue.global()),
                                                              internalErrorListener: InternalErrorListenerForTests() as InternalErrorListener)
    private var webimActions: WebimActions?
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        
        webimActions = WebimActions(baseURL: "https://demo.webim.ru",
                                    actionRequestLoop: actionRequestLoop)
    }
    
    override func tearDown() {
        actionRequestLoop.webimRequest = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSendMessageRequestFormation() {
        // MARK: Test 1
        
        // Setup.
        var message = "Message"
        var clientSideID = "1"
        var dataJSONString = "{\"key\":\"value\"}"
        var isHintQuestion = true
        
        // When: Sending message.
        webimActions?.send(message: message,
                           clientSideID: clientSideID,
                           dataJSONString: dataJSONString,
                           isHintQuestion: isHintQuestion,
                           dataMessageCompletionHandler: nil)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        var expectedParametersDictionary = ["message" : message,
                                            "client-side-id" : clientSideID,
                                            "action" : "chat.message",
                                            "hint_question" : "1",
                                            "data" : dataJSONString] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["message"] as! String,
                       expectedParametersDictionary["message"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["client-side-id"] as! String,
                       expectedParametersDictionary["client-side-id"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["hint_question"] as! String,
                       expectedParametersDictionary["hint_question"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["data"] as! String,
                       expectedParametersDictionary["data"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        var expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
        XCTAssertNil(actionRequestLoop.webimRequest!.getDataMessageCompletionHandler())
        
        // MARK: Test 1
        
        // Setup.
        message = "Message"
        clientSideID = "1"
        dataJSONString = "{\"key\":\"value\"}"
        isHintQuestion = false
        
        // When: Sending message.
        webimActions?.send(message: message,
                           clientSideID: clientSideID,
                           dataJSONString: dataJSONString,
                           isHintQuestion: isHintQuestion,
                           dataMessageCompletionHandler: nil)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        expectedParametersDictionary = ["message" : message,
                                            "client-side-id" : clientSideID,
                                            "action" : "chat.message",
                                            "hint_question" : "0",
                                            "data" : dataJSONString] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["message"] as! String,
                       expectedParametersDictionary["message"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["client-side-id"] as! String,
                       expectedParametersDictionary["client-side-id"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["hint_question"] as! String,
                       expectedParametersDictionary["hint_question"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["data"] as! String,
                       expectedParametersDictionary["data"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testSendFileRequestFormation() {
        // Setup.
        let data = "1010".data(using: .utf8)!
        let fileName = "file.jpg"
        let mimeType = "image/jpeg"
        let clientSideID = "1"
        
        // When: Sending file.
        webimActions?.send(file: data,
                           filename: fileName,
                           mimeType: mimeType,
                           clientSideID: clientSideID,
                           completionHandler: nil)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["chat-mode" : "online",
                                            "client-side-id" : clientSideID] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["chat-mode"] as! String,
                       expectedParametersDictionary["chat-mode"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["client-side-id"] as! String,
                       expectedParametersDictionary["client-side-id"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getMessageID(),
                       clientSideID)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/upload"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
        
        XCTAssertNil(actionRequestLoop.webimRequest!.getSendFileCompletionHandler())
    }
    
    func testStartChatRequestFormation() {
        // Setup.
        let message = "Message"
        let clientSideID = "1"
        let departmentKey = "Department"
        
        // When: Starting chat.
        webimActions?.startChat(withClientSideID: clientSideID,
                                firstQuestion: message,
                                departmentKey: departmentKey)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["first-question" : message,
                                            "client-side-id" : clientSideID,
                                            "action" : "chat.start",
                                            "force-online" : "1",
                                            "department-key" : departmentKey] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["first-question"] as! String,
                       expectedParametersDictionary["first-question"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["client-side-id"] as! String,
                       expectedParametersDictionary["client-side-id"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["force-online"] as! String,
                       expectedParametersDictionary["force-online"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["department-key"] as! String,
                       expectedParametersDictionary["department-key"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testCloseChatRequestFormation() {
        // When: Closing chat.
        webimActions?.closeChat()
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["action" : "chat.close"] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testSetVisitorTypingRequestFormation() {
        // Setup.
        let message = "Message"
        let visitorTyping = true
        let deleteDraft = false
        
        // When: Setting visitor is typing a draft.
        webimActions?.set(visitorTyping: visitorTyping,
                          draft: message,
                          deleteDraft: deleteDraft)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["message-draft" : message,
                                            "action" : "chat.visitor_typing",
                                            "del-message-draft" : "0",
                                            "typing" : "1"] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["message-draft"] as! String,
                       expectedParametersDictionary["message-draft"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["del-message-draft"] as! String,
                       expectedParametersDictionary["del-message-draft"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["typing"] as! String,
                       expectedParametersDictionary["typing"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testSetVisitorTypingEndRequestFormation() {
        // Setup.
        let visitorTyping = false
        let deleteDraft = true
        
        // When: Setting visitor is typing a draft.
        webimActions?.set(visitorTyping: visitorTyping,
                          draft: nil,
                          deleteDraft: deleteDraft)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["action" : "chat.visitor_typing",
                                            "del-message-draft" : "1",
                                            "typing" : "0"] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["del-message-draft"] as! String,
                       expectedParametersDictionary["del-message-draft"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["typing"] as! String,
                       expectedParametersDictionary["typing"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testRequestHistorySinceFormation() {
        // Setup.
        let since = "1"
        
        // When: Requesting history since.
        let expectaion = XCTestExpectation()
        webimActions?.requestHistory(since: since) { data in
            expectaion.fulfill()
        }
        
        // Then: Request parameters should be like this.
        
        try! actionRequestLoop.webimRequest!.getCompletionHandler()!(nil)
        wait(for: [expectaion],
             timeout: 1.0)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.get)
        
        let expectedParametersDictionary = ["since" : since] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["since"] as! String,
                       expectedParametersDictionary["since"] as! String)
        
        XCTAssertNil(actionRequestLoop.webimRequest!.getContentType())
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/history"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testRequestHistoryBeforeFormation() {
        // Setup.
        let before = "1"
        
        // When: Requesting history before.
        let expectaion = XCTestExpectation()
        webimActions?.requestHistory(beforeMessageTimestamp: Int64(before)!) { data in
            expectaion.fulfill()
        }
        
        // Then: Request parameters should be like this.
        
        try! actionRequestLoop.webimRequest!.getCompletionHandler()!(nil)
        wait(for: [expectaion],
             timeout: 1.0)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.get)
        
        let expectedParametersDictionary = ["before-ts" : before] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["before-ts"] as! String,
                       expectedParametersDictionary["before-ts"] as! String)
        
        XCTAssertNil(actionRequestLoop.webimRequest!.getContentType())
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/history"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
    
    func testRateOperatorRequestFormation() {
        // Setup.
        let operatorID = "1"
        let rating = "2"
        let visitorNote = "RateNote"
        
        // When: Rating an operator.
        webimActions?.rateOperatorWith(id: operatorID,
                                       rating: Int(rating)!,
                                       visitorNote: visitorNote,
                                       completionHandler: nil)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["action" : "chat.operator_rate_select",
                                            "rate" : rating,
                                            "visitor_note" : visitorNote,
                                            "operator_id" : operatorID] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["rate"] as! String,
                       expectedParametersDictionary["rate"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["visitor_note"] as! String,
                       expectedParametersDictionary["visitor_note"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["operator_id"] as! String,
                       expectedParametersDictionary["operator_id"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
        
        XCTAssertNil(actionRequestLoop.webimRequest!.getRateOperatorCompletionHandler())
    }
    
    func testUpdateDeviceTokenRequestFormation() {
        // Setup.
        let deviceToken = "1"
        
        // When: Updating device token.
        webimActions?.update(deviceToken: deviceToken)
        
        // Then: Request parameters should be like this.
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getHTTPMethod(),
                       AbstractRequestLoop.HTTPMethods.post)
        
        let expectedParametersDictionary = ["action" : "set_push_token",
                                            "push-token" : deviceToken] as [String : Any]
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["action"] as! String,
                       expectedParametersDictionary["action"] as! String)
        XCTAssertEqual(actionRequestLoop.webimRequest!.getPrimaryData()["push-token"] as! String,
                       expectedParametersDictionary["push-token"] as! String)
        
        XCTAssertEqual(actionRequestLoop.webimRequest!.getContentType(),
                       WebimActions.ContentType.urlEncoded.rawValue)
        
        let expectedBaseURLString = "https://demo.webim.ru/l/v/m/action"
        XCTAssertEqual(actionRequestLoop.webimRequest!.getBaseURLString(),
                       expectedBaseURLString)
    }
}
