//
//  WebimClientBuilderTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 01.09.2022.
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
@testable import WebimClientLibrary

class WebimClientBuilderTests: XCTestCase {

    let sut = WebimClientBuilder()
    var executor: ExecIfNotDestroyedHandlerExecutor!
    var deltaCallback: DeltaCallback!
    let internalErrorListener = InternalErrorListenerForTests()
    let notFatalErrorHandler = NotFatalErrorHandlerMock()

    let baseUrl = "https://demo.webim.ru"
    let title = "expectedTitle"
    let location = "expectedLocation"
    let deviceID = "expectedDeviceID"
    let deltaCallbackUserDefaults = "WebimClientBuilderTests_deltaCallback"
    let sessionDestroyerUserDefaults = "WebimClientBuilderTests_sessionDestroyer"

    override func setUp() {
        super.setUp()
        let defaultQueue = DispatchQueue.main
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: sessionDestroyerUserDefaults)
        let messageMapper = MessageMapper(withServerURLString: baseUrl)
        executor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer, queue: defaultQueue)
        deltaCallback = DeltaCallback(currentChatMessageMapper: messageMapper,
                                      historyMessageMapper: messageMapper,
                                      userDefaultsKey: deltaCallbackUserDefaults)

    }

    override func tearDown() {
        let _ = WMKeychainWrapper.removeObject(key: deltaCallbackUserDefaults)
        let _ = WMKeychainWrapper.removeObject(key: sessionDestroyerUserDefaults)
        super.tearDown()
    }

    //MARK: Tests
    func test_Build_WithMinimumProperties() {
        let webimClient = sut
            .set(completionHandlerExecutor: executor)
            .set(internalErrorListener: internalErrorListener)
            .set(deltaCallback: deltaCallback)
            .set(baseURL: baseUrl)
            .set(title: title)
            .set(location: location)
            .set(deviceID: deviceID)
            .build()

        XCTAssertNotNil(webimClient)
    }
}
