//
//  VisitorFieldsItemTests.swift
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

class VisitorFieldsItemTests: XCTestCase {
    var sut: VisitorFieldsItem!

    let expectedName = "expectedName"
    let expectedEmail = "expectedEmail"
    let expectedPhone = "expectedPhone"

    //MARK: Methods
    override func setUp() {
        super.setUp()
        let jsonDict: [String: Any?] = [
            "name": expectedName,
            "email": expectedEmail,
            "phone": expectedPhone
        ]
        sut = VisitorFieldsItem(jsonDictionary: jsonDict)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func testInit() {
        XCTAssertEqual(sut.getName(), expectedName)
        XCTAssertEqual(sut.getEmail(), expectedEmail)
        XCTAssertEqual(sut.getPhone(), expectedPhone)
    }

    func test_Init_WrongName() {
        let jsonDict: [String: Any?] = [
            "name": 15,
            "email": expectedEmail,
            "phone": expectedPhone
        ]

        sut = VisitorFieldsItem(jsonDictionary: jsonDict)

        XCTAssertNil(sut)
    }

    func test_Init_WrongMail() {
        let jsonDict: [String: Any?] = [
            "name": expectedName,
            "email": 88,
            "phone": expectedPhone
        ]

        sut = VisitorFieldsItem(jsonDictionary: jsonDict)

        XCTAssertNotNil(sut)
    }

    func test_Init_WrongPhone() {
        let jsonDict: [String: Any?] = [
            "name": expectedName,
            "email": expectedEmail,
            "phone": 99
        ]

        sut = VisitorFieldsItem(jsonDictionary: jsonDict)

        XCTAssertNotNil(sut)
    }
}
