//
//  FileParametersItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.02.18.
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
@testable import WebimMobileSDK
import XCTest

class FileParametersItemTests: XCTestCase {
 
    // MARK: - Constants
    let defaultFileParametersItemJson = """
    {
    "client_content_type" : "image/jpeg",
    "image" : {
        "size" : {
            "width" : 700,
            "height" : 501
        }
    },
    "visitor_id" : "877a920ede7082412656ac1cdec7ecde",
    "filename" : "asset.JPG",
    "content_type" : "image/png",
    "guid" : "010a56da72ee41e2a78d0509155de755",
    "size" : 758611
    }
    """

    let nullFileParametersItemJson = """
    {
    "client_content_type" : null,
    "image" : null,
    "visitor_id" : null,
    "filename" : null,
    "content_type" : null,
    "guid" : null,
    "size" : null
    }
    """

    var sut: FileParametersItem!
    var nullSut: FileParametersItem!

    private func convertToDict(_ json: String) -> [String: Any?] {
        return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
    }

    override func setUp() {
        super.setUp()
        sut = FileParametersItem(jsonDictionary: convertToDict(defaultFileParametersItemJson))
        nullSut = FileParametersItem(jsonDictionary: convertToDict(nullFileParametersItemJson))
    }

    override func tearDown() {
        sut = nil
        nullSut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitContentType() {
        let expectedContentType = "image/png"

        XCTAssertEqual(sut.getContentType(), expectedContentType)
    }

    func testInitContenttypeNullValue() {
        XCTAssertNil(nullSut.getContentType())
    }

    func testInitClientContentType() {
        let expectedContentType = "image/jpeg"

        XCTAssertEqual(sut.getClientContentType(), expectedContentType)
    }

    func testInitClientContenttypeNullValue() {
        XCTAssertNil(nullSut.getClientContentType())
    }

    func testInitFileName() {
        let expectedClientContentType = "asset.JPG"

        XCTAssertEqual(sut.getFilename(), expectedClientContentType)
    }

    func testInitFileNameNullValue() {
        XCTAssertNil(nullSut.getFilename())
    }

    func testInitGuid() {
        let expectedGuidValue = "010a56da72ee41e2a78d0509155de755"

        XCTAssertEqual(sut.getGUID(), expectedGuidValue)
    }

    func testInitGuidNullValue() {
        XCTAssertNil(nullSut.getGUID())
    }

    func testInitImageParameters() {
        let expectedImageWidth = 700
        let expectedImageHeight = 501

        XCTAssertEqual(sut.getImageParameters()?.getSize()?.getWidth(), expectedImageWidth)
        XCTAssertEqual(sut.getImageParameters()?.getSize()?.getHeight(), expectedImageHeight)
    }

    func testInitImageParametersNullValue() {
        XCTAssertNil(nullSut.getImageParameters())
    }

    func testInitSize() {
        let expectedSize: Int64 = 758611

        XCTAssertEqual(sut.getSize(), expectedSize)
    }

    func testInitSizeNullValue() {
        XCTAssertNil(nullSut.getSize())
    }

    func testInitVisitorId() {
        let expectedVisitorID = "877a920ede7082412656ac1cdec7ecde"

        XCTAssertEqual(sut.getVisitorID(), expectedVisitorID)
    }

    func testInitVisitorIdNullValue() {
        XCTAssertNil(nullSut.getVisitorID())
    }
}
