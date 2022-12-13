//
//  FAQStructureItemTests.swift
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

class FAQStructureItemTests: XCTestCase {

    var sut: FAQStructureItem!
    let FAQStructureItemJSON = """
    {
        "title" : "expectedTitle",
        "type" : "item",
        "id" : "expectedID",
        "childs" : [
           { "title" : "expectedTitle",
            "type" : "item",
            "id" : "expectedID",
            "childs" : []
           },
           { "title" : "expectedTitle",
            "type" : "item",
            "id" : "expectedID",
            "childs" : []
           }
    ]
    }
    """

    private func convertJSONToDict(json: String) -> [String: Any?] {
        let dict = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!,
                                                     options: []) as? [String : Any?] ?? [:]
        return dict
    }

    override func setUp() {
        super.setUp()
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    func testInitTitle() {
        let expectedTitle = "expectedTitle"
        XCTAssertEqual(sut.getTitle(), expectedTitle)
    }

    func testInitTypeItem() {
        let expectedType = RootType.item
        XCTAssertEqual(sut.getType(), expectedType)
    }

    func testInitID() {
        let expectedID = "expectedID"
        XCTAssertEqual(sut.getID(), expectedID)
    }

    func testInitEmptyChildren() {
        let expectedChildrenCount = 2
        XCTAssertEqual(sut.getChildren().count, expectedChildrenCount)
    }

    func testInitTypeCategory() {
        let FAQStructureItemJSON = """
        {
            "title" : "expectedTitle",
            "type" : "category",
            "id" : 1,
            "childs" : []
        }
        """
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))

        let expectedID = "1"
        XCTAssertEqual(sut.getID(), expectedID)
    }

    func testGetIDNullValue() {
        let FAQStructureItemJSON = """
        {
            "title" : "expectedTitle",
            "type" : "category",
            "id" : null,
            "childs" : []
        }
        """
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))

        XCTAssertTrue(sut.getID().isEmpty)
    }

    func testGetTypeNullValue() {
        let FAQStructureItemJSON = """
        {
            "title" : "expectedTitle",
            "type" : null,
            "id" : 1,
            "childs" : []
        }
        """
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))

        XCTAssertEqual(sut.getType(), .unknown)
    }

    func testGetChildrenNullValue() {
        let FAQStructureItemJSON = """
        {
            "title" : "expectedTitle",
            "type" : "category",
            "id" : 1,
            "childs" : null
        }
        """
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))

        XCTAssertTrue(sut.getChildren().isEmpty)
    }

    func testGetTitleNullValue() {
        let FAQStructureItemJSON = """
        {
            "title" : null,
            "type" : "category",
            "id" : 1,
            "childs" : []
        }
        """
        sut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSON))

        XCTAssertTrue(sut.getTitle().isEmpty)
    }

    func testEqualOperation() {
        let FAQStructureItemJSONFirst = """
        {
            "title" : "some value 2",
            "type" : "category",
            "id" : 1,
            "childs" : []
        }
        """

        let FAQStructureItemJSONSecond = """
        {
            "title" : "some value 1",
            "type" : "item",
            "id" : "1",
            "childs" : []
        }
        """
        let firstSut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSONFirst))
        let secondSut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSONSecond))

        let expectedResult = true

        XCTAssertEqual(firstSut == secondSut, expectedResult)
    }

    func testNotEqualOperation() {
        let FAQStructureItemJSONFirst = """
        {
            "title" : "some value 2",
            "type" : "category",
            "id" : 1,
            "childs" : []
        }
        """

        let FAQStructureItemJSONSecond = """
        {
            "title" : "some value 1",
            "type" : "item",
            "id" : 5,
            "childs" : []
        }
        """
        let firstSut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSONFirst))
        let secondSut = FAQStructureItem(jsonDictionary: convertJSONToDict(json: FAQStructureItemJSONSecond))

        let expectedResult = false

        XCTAssertEqual(firstSut == secondSut, expectedResult)
    }


}
