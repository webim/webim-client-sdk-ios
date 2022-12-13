//
//  ProvidedVisitorFieldsTests.swift
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

class ProvidedVisitorFieldsTests: XCTestCase {
    //MARK: Properties
    var logger: WebimLoggerMock!
    let defaultLogMessage = "Error serializing provided visitor fields:"

    //MARK: Methods
    override func setUp() {
        super.setUp()
        logger = WebimLoggerMock()
        WebimInternalLogger.setup(webimLogger: logger,
                                  verbosityLevel: .verbose,
                                  availableLogTypes: [.undefined,
                                                      .networkRequest,
                                                      .messageHistory,
                                                      .manualCall])
    }

    override func tearDown() {
        logger = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_InitWithString() {
        let jsonString = """
        {
            "id" : "1234567890987654321",
            "display_name" : "Никита",
            "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
        }
        """

        let sut = ProvidedVisitorFields(withJSONString: jsonString)

        XCTAssertEqual(jsonString, sut?.getJSONString())
    }

    func test_InitWithData() {
        let jsonString = """
        {
            "id" : "1234567890987654321",
            "display_name" : "Никита",
            "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
        }
        """

        let sut = ProvidedVisitorFields(withJSONObject: jsonString.data(using: .utf8)!)

        XCTAssertEqual(jsonString, sut?.getJSONString())
    }

    func test_Init_HasFieldsKeyValue() {
        let jsonString = """
        {
            "fields" : {
                "id" : "expectedId"
            }
        }
        """

        let sut = ProvidedVisitorFields(withJSONString: jsonString)

        XCTAssertEqual(jsonString, sut?.getJSONString())
    }

    func test_Init_HasFieldsKey_WrongValue() {
        logger.reset()
        let jsonString = """
        {
            "fields" : {
                "someKey" : "anyValue"
            }
        }
        """

        let sut = ProvidedVisitorFields(withJSONString: jsonString)

        XCTAssertNil(sut)
        XCTAssertTrue(logger.logText.contains(defaultLogMessage))
    }

    func test_Init_WrongJson() {
        logger.reset()
        let jsonString = "someWrongJson"

        let sut = ProvidedVisitorFields(withJSONString: jsonString)

        XCTAssertNil(sut)
        XCTAssertTrue(logger.logText.contains(defaultLogMessage))
    }
}
