//
//  UploadedFileImplTests.swift
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
@testable import WebimMobileSDK

class UploadedFileImplTests: XCTestCase {

    private var sut: UploadedFileImpl!
    private var imageParameters: ImageParameters!
    private let size: Int64 = 777
    private let guid = "expectedGuid"
    private let contentType = "image/heic"
    private let fileName = "expectedFileName"
    private let visitorId = "expectedVisitorId"
    private let clientContentType = "expectedContentType"
    private let imageJsonString = """
    {
        "size" : {
            "width" : 15,
            "height" : 99
        }
    }
    """

    //MARK: Methods
    override func setUp() {
        super.setUp()
        imageParameters = ImageParameters(jsonDictionary: convertToDict(imageJsonString))
        sut = UploadedFileImpl(size: size,
                               guid: guid,
                               contentType: contentType,
                               filename: fileName,
                               visitorID: visitorId,
                               clientContentType: clientContentType,
                               imageParameters: imageParameters)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    //MARK: Tests
    func testInit() {
        let expectedImageWidth = 15
        let expectedImageHeight = 99
        XCTAssertEqual(sut.getSize(), size)
        XCTAssertEqual(sut.getGuid(), guid)
        XCTAssertEqual(sut.getFileName(), fileName)
        XCTAssertEqual(sut.getContentType(), contentType)
        XCTAssertEqual(sut.getVisitorID(), visitorId)
        XCTAssertEqual(sut.getClientContentType(), clientContentType)
        XCTAssertEqual(sut.getImageInfo()?.getWidth(), expectedImageWidth)
        XCTAssertEqual(sut.getImageInfo()?.getHeight(), expectedImageHeight)
    }

    func testDescription() {
        let expectedValue = "{\"client_content_type\":\"expectedContentType\"" +
        ",\"visitor_id\":\"expectedVisitorId\"" +
        ",\"filename\":\"expectedFileName\"" +
        ",\"content_type\":\"image/heic\"" +
        ",\"guid\":\"expectedGuid\"" +
        ",\"image\":{\"size\":{\"width\":15,\"height\":99}}" +
        ",\"size\":777}"

        XCTAssertEqual(sut.description, expectedValue)
    }

    func testDescription_ImageSizeNil() {
        sut = UploadedFileImpl(size: size,
                               guid: guid,
                               contentType: contentType,
                               filename: fileName,
                               visitorID: visitorId,
                               clientContentType: clientContentType,
                               imageParameters: nil)

        let expectedValue = "{\"client_content_type\":\"expectedContentType\"" +
        ",\"visitor_id\":\"expectedVisitorId\"" +
        ",\"filename\":\"expectedFileName\"" +
        ",\"content_type\":\"image/heic\"" +
        ",\"guid\":\"expectedGuid\"" +
        ",\"size\":777}"

        XCTAssertEqual(sut.description, expectedValue)
    }
}

fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}


