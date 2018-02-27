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
    
    // MARK: - Constants
    private static let PROVIDED_VISITOR_FIELDS_JSON_STRING = """
{
    "id" : "1234567890987654321",
    "display_name" : "Никита",
    "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
}
"""
    private static let PROVIDED_VISITOR_FIELDS_JSON_DATA = ProvidedVisitorFieldsTests.PROVIDED_VISITOR_FIELDS_JSON_STRING.data(using: .utf8)!
    private static let WRONG_PROVIDED_VISITOR_FIELDS_JSON_STRING = """
{
    "display_name" : "Никита",
    "crc" : "ffadeb6aa3c788200824e311b9aa44cb"
}
"""
    
    // MARK: - Tests
    
    func testInitWithString() {
        let providedVisitorFields = ProvidedVisitorFields(withJSONString: ProvidedVisitorFieldsTests.PROVIDED_VISITOR_FIELDS_JSON_STRING)!
        
        XCTAssertEqual(ProvidedVisitorFieldsTests.PROVIDED_VISITOR_FIELDS_JSON_STRING,
                       providedVisitorFields.getJSONString())
        XCTAssertEqual("1234567890987654321",
                       providedVisitorFields.getID())
    }
    
    func testInitWithData() {
        let providedVisitorFields = ProvidedVisitorFields(withJSONObject: ProvidedVisitorFieldsTests.PROVIDED_VISITOR_FIELDS_JSON_DATA)!
        
        XCTAssertEqual(ProvidedVisitorFieldsTests.PROVIDED_VISITOR_FIELDS_JSON_STRING,
                       providedVisitorFields.getJSONString())
        XCTAssertEqual("1234567890987654321",
                       providedVisitorFields.getID())
    }
    
    func testInitFailed() {
        XCTAssertNil(ProvidedVisitorFields(withJSONString: ProvidedVisitorFieldsTests.WRONG_PROVIDED_VISITOR_FIELDS_JSON_STRING))
    }
    
}
