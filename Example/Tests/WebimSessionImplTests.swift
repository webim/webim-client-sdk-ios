//
//  WebimSessionImplTests.swift
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
import Security
@testable import WebimClientLibrary


class WebimSessionImplTests: XCTestCase {
    let webimLogger = WebimLoggerMock()

    override func setUp() {
        super.setUp()
        WebimInternalLogger.setup(webimLogger: webimLogger,
                                  verbosityLevel: .verbose,
                                  availableLogTypes: [.manualCall,.messageHistory,.networkRequest,.undefined])
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResume() {
        let sut = produceWebimSession()
        webimLogger.reset()
        let expectedLog = "Resume session in WebimSessionImpl - resume()"

        XCTAssertNoThrow(try sut.resume())
        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func testPause() throws {
        let sut = produceWebimSession()
        webimLogger.reset()
        let expectedLog = "Pause session in WebimSessionImpl - pause()"

        XCTAssertNoThrow(try sut.pause())
        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_Pause_AlreadyDestroyed() throws {
        let sut = produceWebimSession()
        try sut.destroy()
        webimLogger.reset()

        XCTAssertNoThrow(try sut.pause())
        XCTAssertTrue(webimLogger.logText.isEmpty)
    }

    func testDestroy() {
        let sut = produceWebimSession()
        webimLogger.reset()
        let expectedLog = "Destroy session in WebimSessionImpl - destroy()"

        XCTAssertNoThrow(try sut.destroy())
        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_Destroy_AlreadyDestroyed() throws {
        let sut = produceWebimSession()
        try sut.destroy()
        webimLogger.reset()

        XCTAssertNoThrow(try sut.destroy())
        XCTAssertTrue(webimLogger.logText.isEmpty)
    }

    func testSetDeviceToken() {
        let sut = produceWebimSession()
        XCTAssertNoThrow(try sut.set(deviceToken: "newDeviceToken"))
    }

    func test_DestroyWithClearVisitorData_Called() throws {
        let visitorJson = """
            {
                "id" : "test_DestroyWithClearVisitorData",
                "display_name" : "Никита",
                "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
            }
        """
        let expectedLog = "Clear visitor data in WebimSessionImpl - clearVisitorDataFor"
        let providedVisitorFields = ProvidedVisitorFields(withJSONString: visitorJson)
        let sut = produceWebimSession(providedFields: providedVisitorFields)
        let expectation = XCTestExpectation()
        webimLogger.clearVisitorDataForExpectation = expectation

        try sut.destroyWithClearVisitorData()
        wait(for: [expectation], timeout: 3)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_DestroyWithClearVisitorData_AlreadyDestroyed() throws {
        let sut = produceWebimSession()
        try sut.destroy()
        webimLogger.reset()
        let expectedLog = "Session already destroyed in WebimSessionImpl - destroyWithClearVisitorData()"

        XCTAssertNoThrow(try sut.destroyWithClearVisitorData())
        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func testNewInstanceWith() throws {
        let visitorJson = """
            {
                "id" : "testNewInstanceWith",
                "display_name" : "Никита",
                "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
            }
        """
        let providedVisitorFields = ProvidedVisitorFields(withJSONString: visitorJson)
        let sut = produceWebimSession(providedFields: providedVisitorFields)
        XCTAssertNotNil(sut)

        clearDataForKey(id: providedVisitorFields?.getID())
    }

    private func clearDataForKey(id: String?) {
        WMKeychainWrapper.standard.setDictionary([:], forKey: getUserDefaultsKey(id: id))
    }

    private func getUserDefaultsKey(id: String?) -> String {
        "ru.webim.WebimClientSDKiOS.visitor." + (id ?? "anonymous")
    }

    private func produceWebimSession(providedFields: ProvidedVisitorFields? = nil) -> WebimSessionImpl {
        WebimSessionImpl.newInstanceWith(accountName: "accountName",
                                               location: "location",
                                               appVersion: "appVersion",
                                               visitorFields: providedFields,
                                               providedAuthorizationTokenStateListener: nil,
                                               providedAuthorizationToken:  "providedAuthorizationToken",
                                               pageTitle: "pageTitle",
                                               fatalErrorHandler: nil,
                                               notFatalErrorHandler: nil,
                                               deviceToken: "deviceToken",
                                               remoteNotificationSystem: .apns,
                                               isLocalHistoryStoragingEnabled: true,
                                               isVisitorDataClearingEnabled: true,
                                               webimLogger: webimLogger,
                                               verbosityLevel: .verbose,
                                               availableLogTypes: [.manualCall,.messageHistory,.networkRequest,.undefined],
                                               prechat: nil,
                                               multivisitorSection: "multivisitorSection",
                                               onlineStatusRequestFrequencyInMillis: 12376123)
    }
}


