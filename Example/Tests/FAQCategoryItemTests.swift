//
//  FAQCategoryItemTests.swift
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

class FAQCategoryItemTests: XCTestCase {

    var sut: FAQCategoryItem!
    var nullSut: FAQCategoryItem!

    let defaultFAQCategoryItemJSON = """
    {
       "title":"expectedTitle",
       "categoryid":5,
       "childs":[
          {
             "title":"1 child title",
             "type":"item",
             "data":{
                "id":1,
                "title":"someTitle"
             }
          },
          {
             "title":"2 child title",
             "type":"item",
             "data":{
                "id":2,
                "title":"someTitle"
             }
          },
          {
             "title":"3 child title",
             "type":"category",
             "data":{
                "id":3,
                "title":"someTitle"
             }
          }
       ]
    }
    """

    let nullFAQCategoryItemJSON = """
    {
       "title":null,
       "categoryid":null,
       "childs":null
    }
    """

    private func convertJSONToDict(json: String) -> [String: Any?] {
        let dict = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!,
                                                     options: []) as? [String : Any?] ?? [:]
        return dict
    }

    override func setUp() {
        super.setUp()
        sut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: defaultFAQCategoryItemJSON))
        nullSut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: nullFAQCategoryItemJSON))
    }

    override func tearDown() {
        sut = nil
        nullSut = nil
        super.tearDown()
    }

    func testInitID() {
        let expectedID = "5"

        XCTAssertEqual(sut.getID(), expectedID)
    }

    func testInitIDNullValue() {
        XCTAssertTrue(nullSut.getID().isEmpty)
    }

    func testInitTitle() {
        let expectedTitle = "expectedTitle"

        XCTAssertEqual(sut.getTitle(), expectedTitle)
    }

    func testInitTitleNullValue() {
        XCTAssertTrue(nullSut.getTitle().isEmpty)
    }

    func testInitChilds() {
        let expectedChildsCount = 2

        XCTAssertEqual(sut.getItems().count, expectedChildsCount)
    }

    func testInitChildsNullValue() {
        XCTAssertTrue(nullSut.getItems().isEmpty)
    }

    func testGetSubcategories() {
        let expectedSubcategoriesCount = 1

        XCTAssertEqual(sut.getSubcategories().count, expectedSubcategoriesCount)
    }

    func testEqualOperation() {
        let firstFAQCategoryItemJSON = """
        {
           "title":"expectedTitle",
           "categoryid":1,
           "childs":[]
        }
        """
        let secondFAQCategoryItemJSON = """
        {
           "title":"someTitle",
           "categoryid":1,
           "childs":[]
        }
        """
        let firstSut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: firstFAQCategoryItemJSON))
        let secondSut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: secondFAQCategoryItemJSON))

        XCTAssertTrue(firstSut == secondSut)
    }

    func testNotEqualOperation() {
        let firstFAQCategoryItemJSON = """
        {
           "title":"expectedTitle",
           "categoryid":1,
           "childs":[]
        }
        """
        let secondFAQCategoryItemJSON = """
        {
           "title":"someTitle",
           "categoryid":5,
           "childs":[]
        }
        """
        let firstSut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: firstFAQCategoryItemJSON))
        let secondSut = FAQCategoryItem(jsonDictionary: convertJSONToDict(json: secondFAQCategoryItemJSON))

        XCTAssertFalse(firstSut == secondSut)
    }
}
