//
//  HistoryPollerTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 03.09.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
@testable import WebimMobileSDK

class HistoryPollerTests: XCTestCase {
    var sut: HistoryPoller!
    let webimLogger = WebimLoggerMock()
    var actionRequestLoop: ActionRequestLoopForTests!
    var sessionDestroyer: SessionDestroyer!
    let userDefaultsKey = "HistoryPollerTests"
    let serverURLString = "https://demo.webim.ru"


    override func setUp() {
        super.setUp()
        WMKeychainWrapper.standard.setDictionary([:], forKey: userDefaultsKey)
        WebimInternalLogger.setup(webimLogger: webimLogger,
                                  verbosityLevel: .verbose,
                                  availableLogTypes: [.undefined,.networkRequest,.messageHistory,.manualCall])
        sessionDestroyer = SessionDestroyer(userDefaultsKey: userDefaultsKey)
        let queue = DispatchQueue.main
        let messageMapper = MessageMapper(withServerURLString: serverURLString)
        let executor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer, queue: queue)
        let internalErrorListener = InternalErrorListenerForTests()
        actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: executor,
                                                          internalErrorListener: internalErrorListener,
                                                      requestHeader: nil,
                                                      baseURL: MessageImplMockData.serverURLString.rawValue)
        let accessChecker = AccessChecker(thread: Thread.current, sessionDestroyer: sessionDestroyer)

        let webimActions = WebimActionsImpl(actionRequestLoop: actionRequestLoop)
        let remoteHistoryProvider = RemoteHistoryProviderMock(withWebimActions: webimActions,
                                                                  historyMessageMapper: HistoryMessageMapper(withServerURLString: MessageImplMockData.serverURLString.rawValue),
                                                                  historyMetaInformation: MemoryHistoryMetaInformationStorage(),
                                                                  history: [defaultMessage, defaultMessage_2])

        let messageHolder = MessageHolder(accessChecker: accessChecker,
                                          remoteHistoryProvider: remoteHistoryProvider,
                                          historyStorage: MemoryHistoryStorage(),
                                          reachedEndOfRemoteHistory: false)

        let historyMetaInfoStorage = MemoryHistoryMetaInformationStorage()

        sut = HistoryPoller(withSessionDestroyer: sessionDestroyer,
                            queue: queue,
                            historyMessageMapper: messageMapper,
                            webimActions: webimActions,
                            messageHolder: messageHolder,
                            historyMetaInformationStorage: historyMetaInfoStorage)
    }


    func testResume() {
        webimLogger.reset()
        let expectedLog = "Request history"

        sut.resume()

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_UpdateReadBeforeTimestamp() {
        sut.updateReadBeforeTimestamp(timestamp: 777, byWMKeychainWrapperKey: userDefaultsKey)
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)

        XCTAssertEqual(userDefaults?["read_before_timestamp"] as? Int64, 777)
    }

    func test_GetReadBeforeTimestamp() {
        sut.updateReadBeforeTimestamp(timestamp: 888, byWMKeychainWrapperKey: userDefaultsKey)

        XCTAssertEqual(sut.getReadBeforeTimestamp(byWMKeychainWrapperKey: userDefaultsKey), 888)
    }

    func test_GetReadBeforeTimestamp_WrongValue() {
        WMKeychainWrapper.standard.setDictionary(["read_before_timestamp":"wrongValue"], forKey: userDefaultsKey)

        XCTAssertEqual(sut.getReadBeforeTimestamp(byWMKeychainWrapperKey: userDefaultsKey), -1)
    }

    func test_RequestHistory() {
        sut.resume()
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        sut.requestHistory(since: "since")

        XCTAssertNotNil(actionRequestLoop.webimRequest)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_RequestHistory_SinceCompletionHandlerNil() {
        webimLogger.reset()
        let expectedLog = "History Since Completion Handler is nil in WebimSessionImpl."

        sut.requestHistory(since: "since")

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_InsertMessageInDB() {
        webimLogger.reset()
        let expectedLog = "Insert message \(defaultMessage.getText()) in DB"

        sut.insertMessageInDB(message: defaultMessage)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_InsertMessageInDB_SessionAlreadyDestroyed() {
        sessionDestroyer.destroy()
        webimLogger.reset()
        let expectedLog = "Current session is destroyed in WebimSessionImpl - insertMessageInDB"

        sut.insertMessageInDB(message: defaultMessage)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_DeleteMessageFromDB() {
        webimLogger.reset()
        let expectedLog = "Delete message message in DB"

        sut.deleteMessageFromDB(message: "message")

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_DeleteMessageFromDB_SessionAlreadyDestroyed() {
        sessionDestroyer.destroy()
        webimLogger.reset()
        let expectedLog = "Current session is destroyed"

        sut.deleteMessageFromDB(message: "message")

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }
}
