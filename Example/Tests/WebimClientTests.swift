//
//  WebimClientTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 12.03.18.
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

class WebimClientTests: XCTestCase {
    
    // MARK: - Constants
    private static let userDefaultsKey = "userDefaultsKey"
    
    // MARK: - Tests
    func testGetDeltaRequestLoop() {
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(userDefaultsKey: WebimClientTests.userDefaultsKey),
                                                                                  queue: DispatchQueue.main)
        let internalErrorListener = InternalErrorListenerForTests()
        let actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                          internalErrorListener: internalErrorListener)
        let urlString = "http://webim.ru"
        let deltaRequestLoop = DeltaRequestLoop(deltaCallback: DeltaCallback(currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: urlString),
                                                historyMessageMapper: HistoryMessageMapper(withServerURLString: urlString),
                                                userDefaultsKey: WebimClientTests.userDefaultsKey),
                                                completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                sessionParametersListener: nil,
                                                internalErrorListener: internalErrorListener,
                                                baseURL: urlString,
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
                                                authorizationData: nil)
        
        let webimClient = WebimClient(withActionRequestLoop: actionRequestLoop,
                                      deltaRequestLoop: deltaRequestLoop,
                                      webimActions: WebimActionsImpl(baseURL: urlString,
                                                                     actionRequestLoop: actionRequestLoop))
        
        XCTAssertTrue(deltaRequestLoop === webimClient.getDeltaRequestLoop())
    }
    
    func testGetActions() {
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(userDefaultsKey: WebimClientTests.userDefaultsKey),
                                                                                  queue: DispatchQueue.main)
        let internalErrorListener = InternalErrorListenerForTests()
        let actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                          internalErrorListener: internalErrorListener)
        let urlString = "http://webim.ru"
        let webimActions = WebimActionsImpl(baseURL: urlString,
                                            actionRequestLoop: actionRequestLoop)
        
        let webimClient = WebimClient(withActionRequestLoop: actionRequestLoop,
                                      deltaRequestLoop: DeltaRequestLoop(deltaCallback: DeltaCallback(currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: urlString),
                                                                         historyMessageMapper: HistoryMessageMapper(withServerURLString: urlString),
                                                                         userDefaultsKey: WebimClientTests.userDefaultsKey),
                                                                         completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                                         sessionParametersListener: nil,
                                                                         internalErrorListener: internalErrorListener,
                                                                         baseURL: urlString,
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
                                                                         authorizationData: nil),
                                      webimActions: webimActions)
        
        XCTAssertTrue(webimActions === webimClient.getActions())
    }
}
