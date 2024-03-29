//
//  DictionaryTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 18.08.2022.
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

class DictionaryTests: XCTestCase {

    // MARK: - Tests
    func testStringFromHTTPParameters() {
        //Given
        let dictionary = ["parameter1" : "value1",
                          "parameter2" : "1"] as [String : String]
        let expectedString1 = "parameter1=value1&parameter2=1"
        let expectedString2 = "parameter2=1&parameter1=value1"

        //When
        let dictionaryString = dictionary.stringFromHTTPParameters()

        //Then
        XCTAssertTrue(dictionaryString == expectedString1 || dictionaryString == expectedString2)
    }

    func testStringFromHTTPParametersWrongKey() {
        //Given
        let dictionary: [AnyHashable : String] = [12 : "value1", 123.812412 : "5"]

        //When
        let dictionaryString = dictionary.stringFromHTTPParameters()

        //Then
        XCTAssertEqual(dictionaryString, "&")
    }
}
