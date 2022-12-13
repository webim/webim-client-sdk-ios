//
//  FAQCategoryInfoItemTests.swift
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
@testable import WebimClientLibrary

class FAQCategoryInfoItemTests: XCTestCase {

    let defaultFAQCategoryInfoItem = """
    {
        "title" : "expectedTitle",
        "id" : 1
    }
    """

    let nullFAQCategoryInfoItem = """
    {
        "title" : null,
        "id" : null
    }
    """

    private func convertJSONToDict(json: String) -> [String: Any?] {
        let dict = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!,
                                                     options: []) as? [String : Any?] ?? [:]
        return dict
    }



    func testInitID() {
        let sut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: defaultFAQCategoryInfoItem))

        let expectedID = "1"

        XCTAssertEqual(sut.getID(), expectedID)
    }

    func testInitIDNullValue() {
        let sut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: nullFAQCategoryInfoItem))

        XCTAssertTrue(sut.getID().isEmpty)
    }

    func testInitTitle() {
        let sut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: defaultFAQCategoryInfoItem))

        let expectedTitle = "expectedTitle"

        XCTAssertEqual(sut.getTitle(), expectedTitle)
    }

    func testInitTitleNullValue() {
        let sut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: nullFAQCategoryInfoItem))

        XCTAssertTrue(sut.getTitle().isEmpty)
    }

    func testEqualOperation() {
        let anotherFAQCategoryInfoItem = """
        {
            "title" : "some title",
            "id" : 1
        }
        """
        let firstSut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: defaultFAQCategoryInfoItem))
        let secondSut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: anotherFAQCategoryInfoItem))

        let expectedResult = true

        XCTAssertEqual(firstSut == secondSut, expectedResult)
    }

    func testNotEqualOperation() {
        let anotherFAQCategoryInfoItem = """
        {
            "title" : "expectedTitle",
            "id" : 5
        }
        """
        let firstSut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: defaultFAQCategoryInfoItem))
        let secondSut = FAQCategoryInfoItem(jsonDictionary: convertJSONToDict(json: anotherFAQCategoryInfoItem))

        let expectedResult = false

        XCTAssertEqual(firstSut == secondSut, expectedResult)
    }
}
