//
//  LocationSettingsResponseTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 25.08.2022.
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

class LocationSettingsResponseTests: XCTestCase {

    //MARK: Methods
    private func convertToDict(_ json: String) -> [String: Any?] {
        return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
    }

    //MARK: Tests
    func test_Init_LocationSetting() {
        let firstKey = "someKey1"
        let secondKey = "someKey2"
        let defaultLocationSettingsResponseJson = """
        {
            "locationSettings": {
                "\(firstKey)": 12,
                "\(secondKey)": "someValue"
            }
        }
        """

        let sut = ServerSettingsResponse(jsonDictionary: convertToDict(defaultLocationSettingsResponseJson))

        XCTAssertEqual(sut.getLocationSettings()[firstKey] as? Int, 12)
        XCTAssertEqual(sut.getLocationSettings()[secondKey] as? String, "someValue")
    }

    func test_Init_LocationSettingNullValue() {
        let sut = ServerSettingsResponse(jsonDictionary: [:])

        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.getLocationSettings().isEmpty)
    }
}
