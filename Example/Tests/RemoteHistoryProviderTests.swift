//
//  RemoteHistoryProviderTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 30.08.2022.
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

class RemoteHistoryProviderTests: XCTestCase {

    var sut: RemoteHistoryProvider!
    var actionRequestLoop: ActionRequestLoopForTests!
    let sessionDestroyer_UserDefaultsKey = "RemoteHistoryProviderTests_sessionDestroyer"


    override func setUp() {
        super.setUp()
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: sessionDestroyer_UserDefaultsKey)
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                                  queue: DispatchQueue.main)
        actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                  internalErrorListener: InternalErrorListenerForTests())
        let webimActions = WebimActionsImpl(baseURL: MessageImplMockData.serverURLString.rawValue,
                                            actionRequestLoop: actionRequestLoop)
        let messageMapper = MessageMapper(withServerURLString: MessageImplMockData.serverURLString.rawValue)
        let historyMetaInformationStorage = MemoryHistoryMetaInformationStorage()

        sut = RemoteHistoryProvider(webimActions: webimActions,
                                    historyMessageMapper: messageMapper,
                                    historyMetaInformationStorage: historyMetaInformationStorage)
    }



    func testRequestHistory() {
        actionRequestLoop.enqueueCalled = false
        let beforeTS: Int64 = 50

        sut.requestHistory(beforeTimestamp: beforeTS) { _, _ in }
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertTrue(actionRequestLoop.enqueueCalled)
        XCTAssertEqual(primaryData?[Parameter.beforeTimestamp.rawValue] as? Int64, beforeTS)
    }
}
