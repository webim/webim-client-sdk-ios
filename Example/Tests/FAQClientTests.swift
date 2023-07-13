//
//  FAQClientTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 23.08.2022.
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

class FAQClientTests: XCTestCase {

    var sut: FAQClient!
    var baseURL: String!
    var faqRequestLoop: FAQRequestLoopMock!
    var faqActions: FAQActions!

    let expectedApplication = "expectedApplication"
    let expectedDepartmentKey = "expectedDepartmentKey"
    let expectedLanguage = "expectedLanguage"

    override func setUp() {
        super.setUp()
        let destroyer = FAQDestroyer()
        let queue = DispatchQueue.global()
        let completionHandlerExecutor = ExecIfNotDestroyedFAQHandlerExecutor(faqDestroyer: destroyer, queue: queue)
        baseURL = "https://wmtest6.webim.ru/"
        faqRequestLoop = FAQRequestLoopMock(completionHandlerExecutor: completionHandlerExecutor)
        faqActions = FAQActions(baseURL: baseURL, faqRequestLoop: faqRequestLoop)


        sut = FAQClient(withFAQRequestLoop: faqRequestLoop,
                        faqActions: faqActions,
                        application: expectedApplication,
                        departmentKey: expectedDepartmentKey,
                        language: expectedLanguage)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testStart() {
        sut.start()
        sut.stop()

        XCTAssertFalse(faqRequestLoop.paused)
        XCTAssertFalse(faqRequestLoop.running)
    }

    func testResume() {
        sut.resume()
        sut.pause()
        sut.resume()

        XCTAssertFalse(faqRequestLoop.paused)
    }

    func testPause() {
        sut.resume()
        sut.pause()

        XCTAssertTrue(faqRequestLoop.paused)
    }

    func testStop() {
        sut.resume()
        sut.stop()

        XCTAssertFalse(faqRequestLoop.running)
        XCTAssertFalse(faqRequestLoop.paused)
    }

    func testGetApplication() {
        XCTAssertEqual(sut.getApplication(), expectedApplication)
    }

    func testGetDepartmentKey() {
        XCTAssertEqual(sut.getDepartmentKey(), expectedDepartmentKey)
    }

    func testGetLanguage() {
        XCTAssertEqual(sut.getLanguage(), expectedLanguage)
    }
}

class FAQClientBuilderTests: XCTestCase {

    var defaultCompletionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor!
    let defaultBaseURL = "baseURL"

    override func setUp() {
        super.setUp()
        let faqDestroyer = FAQDestroyer()
        let queue = DispatchQueue.global()
        defaultCompletionHandlerExecutor = ExecIfNotDestroyedFAQHandlerExecutor(faqDestroyer: faqDestroyer, queue: queue)
    }

    func testSetApplication() {
        let sut = FAQClientBuilder()
        let expectedApplication = "expectedApplication"

        let faqClient = sut
            .set(application: expectedApplication)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertEqual(faqClient.getApplication(), expectedApplication)
    }

    func testSetApplicationNilValue() {
        let sut = FAQClientBuilder()

        let faqClient = sut
            .set(application: nil)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertNil(faqClient.getApplication())
    }

    func testSetDepartmentKey() {
        let sut = FAQClientBuilder()
        let expectedDepartmentKey = "expectedDepartmentKey"

        let faqClient = sut
            .set(departmentKey: expectedDepartmentKey)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertEqual(faqClient.getDepartmentKey(), expectedDepartmentKey)
    }

    func testSetDepartmentKeyNilValue() {
        let sut = FAQClientBuilder()

        let faqClient = sut
            .set(departmentKey: nil)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertNil(faqClient.getDepartmentKey())
    }

    func testSetLanguage() {
        let sut = FAQClientBuilder()
        let expectedLanguage = "expectedLanguage"

        let faqClient = sut
            .set(language: expectedLanguage)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertEqual(faqClient.getLanguage(), expectedLanguage)
    }

    func testSetLanguageNilValue() {
        let sut = FAQClientBuilder()

        let faqClient = sut
            .set(language: nil)
            .set(completionHandlerExecutor: defaultCompletionHandlerExecutor)
            .set(baseURL: defaultBaseURL)
            .build()

        XCTAssertNil(faqClient.getLanguage())
    }
}
