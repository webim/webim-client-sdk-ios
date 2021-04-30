//
//  MessageStreamImplTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 22.02.18.
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

class MessageStreamImplTests: XCTestCase {
    
    // MARK: - Constants
    private static let userDefaultsKey = "userDefaultsKey"
    
    // MARK: - Properties
    var messageStream: MessageStreamImpl?
    var webimActions: WebimActions?
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        let serverURLString = "https://demo.webim.ru"
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: MessageStreamImplTests.userDefaultsKey)
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        let queue = DispatchQueue.main
        webimActions = WebimActions(baseURL: serverURLString,
                                    actionRequestLoop: ActionRequestLoopForTests(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                                                                                              queue: queue),
                                                                                 internalErrorListener: InternalErrorListenerForTests()))
        messageStream = MessageStreamImpl(serverURLString: serverURLString,
                                          currentChatMessageFactoriesMapper: CurrentChatMessageMapper(withServerURLString: serverURLString),
                                          sendingMessageFactory: SendingFactory(withServerURLString: serverURLString),
                                          operatorFactory: OperatorFactory(withServerURLString: serverURLString),
                                          surveyFactory: SurveyFactory(),
                                          accessChecker: accessChecker,
                                          webimActions: webimActions!,
                                          messageHolder: MessageHolder(accessChecker: accessChecker,
                                                                       remoteHistoryProvider: RemoteHistoryProvider(webimActions: webimActions!,
                                                                                                                    historyMessageMapper: HistoryMessageMapper(withServerURLString: serverURLString),
                                                                                                                    historyMetaInformationStorage: MemoryHistoryMetaInformationStorage()),
                                                                       historyStorage: MemoryHistoryStorage(),
                                                                       reachedEndOfRemoteHistory: true),
                                          messageComposingHandler: MessageComposingHandler(webimActions: webimActions!,
                                                                                           queue: queue),
                                          locationSettingsHolder: LocationSettingsHolder(userDefaultsKey: "key"))
    }
    
    // MARK: - Tests
    
    func testSetVisitSessionState() {
        messageStream!.set(visitSessionState: .chat)
        
        XCTAssertEqual(messageStream!.getVisitSessionState(),
                       VisitSessionState.chat)
    }
    
    func testSetUnreadByOperatorTimestamp() {
        let date = Date()
        messageStream!.set(unreadByOperatorTimestamp: date)
        
        XCTAssertEqual(messageStream!.getUnreadByOperatorTimestamp(),
                       date)
    }
    
    func testSetUnreadByVisitorTimestamp() {
        let date = Date()
        messageStream!.set(unreadByVisitorTimestamp: date)
        
        XCTAssertEqual(messageStream!.getUnreadByVisitorTimestamp(),
                       date)
    }
    
    func testOnReceivingDepartmentList() {
        let departmentItemDictionary = try! JSONSerialization.jsonObject(with: DEPARTMENT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
        let departmentItem = DepartmentItem(jsonDictionary: departmentItemDictionary)!
        messageStream!.onReceiving(departmentItemList: [departmentItem])
        
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getKey(),
                       "mobile_test_1")
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getName(),
                       "Mobile Test 1")
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getDepartmentOnlineStatus(),
                       DepartmentOnlineStatus.offline)
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getOrder(),
                       100)
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getLocalizedNames()!,
                       ["ru" : "Mobile Test 1"])
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getLogoURL()!,
                       URL(string: "https://demo.webim.ru/webim/images/department_logo/wmtest2_1.png")!)
    }
    
    func testGetChatState() {
        XCTAssertEqual(messageStream!.getChatState(),
                       ChatState.unknown)
    }
    
    func testGetLocationSettings() {
        XCTAssertFalse(messageStream!.getLocationSettings().areHintsEnabled()) // Initial value must be false.
    }
    
    func testGetCurrentOperator() {
        XCTAssertNil(messageStream!.getCurrentOperator()) // Initially operator does not exist.
    }
    
    func testSetVisitSessionStateListener() {
        let visitSessionStateListener = VisitSessionStateListenerForTests()
        messageStream!.set(visitSessionStateListener: visitSessionStateListener)
        
        messageStream!.set(visitSessionState: .chat)
        
        XCTAssertTrue(visitSessionStateListener.called)
        XCTAssertEqual(visitSessionStateListener.state!,
                       VisitSessionState.chat)
    }
    
    func testSetOnlineStatusChangeListener() {
        let onlineStatusChangeListener = OnlineStatusChangeListenerForTests()
        messageStream!.set(onlineStatusChangeListener: onlineStatusChangeListener)
        
        messageStream!.set(onlineStatus: .busyOnline)
        XCTAssertFalse(onlineStatusChangeListener.called)
        
        messageStream!.onOnlineStatusChanged(to: .busyOffline)
        
        XCTAssertTrue(onlineStatusChangeListener.called)
        XCTAssertEqual(onlineStatusChangeListener.status!,
                       OnlineStatus.busyOffline)
    }
    
    func testChangingChatState() {
        let chatItemDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.CHAT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                   options: []) as! [String : Any?]
        let chatItem = ChatItem(jsonDictionary: chatItemDictionary)
        messageStream!.changingChatStateOf(chat: chatItem)
        
        XCTAssertEqual(messageStream!.getChatState(),
                       ChatState.chatting)
        XCTAssertNil(messageStream!.getUnreadByOperatorTimestamp())
        XCTAssertNil(messageStream!.getUnreadByVisitorTimestamp())
        XCTAssertEqual(messageStream!.getCurrentOperator()!.getID(), "33201")
    }
    
    func testGetWebimActions() {
        XCTAssertTrue(webimActions! === messageStream!.getWebimActions())
    }
    
}

// MARK: -
fileprivate class VisitSessionStateListenerForTests: VisitSessionStateListener {
    
    // MARK: - Properties
    var called = false
    var state: VisitSessionState?
    
    // MARK: - Methods
    // MARK: VisitSessionStateListener protocol methods
    func changed(state previousState: VisitSessionState,
                 to newState: VisitSessionState) {
        called = true
        state = newState
    }
    
}

// MARK: -
fileprivate class OnlineStatusChangeListenerForTests: OnlineStatusChangeListener {
    
    // MARK: - Properties
    var called = false
    var status: OnlineStatus?
    
    // MARK: - Methods
    // MARK: OnlineStatusChangeListener protocol methods
    func changed(onlineStatus previousOnlineStatus: OnlineStatus,
                 to newOnlineStatus: OnlineStatus) {
        called = true
        status = newOnlineStatus
    }
    
 
}
