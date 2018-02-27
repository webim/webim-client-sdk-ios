//
//  DepartmentItemTests.swift
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
@testable import WebimClientLibrary
import XCTest

// MARK: - Global constants
let DEPARTMENT_ITEM_JSON_STRING = """
{
    "localeToName" : {
        "ru" : "Mobile Test 1"
    },
    "key" : "mobile_test_1",
    "online" : "offline",
    "name" : "Mobile Test 1",
    "order" : 100,
    "logo" : "/webim/images/department_logo/wmtest2_1.png"
}
"""
let DEPARTMENT_ITEM_WITH_UNKNOWN_ONLINE_STATUS_JSON_STRING = """
{
    "localeToName" : {
        "ru" : "Mobile Test 1"
    },
    "key" : "mobile_test_1",
    "online" : "new_status",
    "name" : "Mobile Test 1",
    "order" : 100,
    "logo" : "/webim/images/department_logo/wmtest2_1.png"
}
"""
let INCORRECT_DEPARTMENT_ITEM_JSON_STRING = """
{
    "localeToName" : {
        "ru" : "Mobile Test 1"
    },
    "online" : "offline",
    "name" : "Mobile Test 1",
    "order" : 100,
    "logo" : "/webim/images/department_logo/wmtest2_1.png"
}
"""

class DepartmentItemTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        let departmentItemDictionary = try! JSONSerialization.jsonObject(with: DEPARTMENT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
        let departmentItem = DepartmentItem(jsonDictionary: departmentItemDictionary)
        
        XCTAssertEqual(departmentItem!.getKey(),
                       "mobile_test_1")
        XCTAssertEqual(departmentItem!.getName(),
                       "Mobile Test 1")
        XCTAssertEqual(departmentItem!.getOnlineStatus(),
                       DepartmentItem.InternalDepartmentOnlineStatus.offline)
        XCTAssertEqual(departmentItem!.getOrder(),
                       100)
        XCTAssertEqual(departmentItem!.getLocalizedNames()!,
                       ["ru" : "Mobile Test 1"])
        XCTAssertEqual(departmentItem!.getLogoURLString()!,
                       "/webim/images/department_logo/wmtest2_1.png")
    }
    
    func testUnknownOnlineStatus() {
        let departmentItemDictionary = try! JSONSerialization.jsonObject(with: DEPARTMENT_ITEM_WITH_UNKNOWN_ONLINE_STATUS_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
        let departmentItem = DepartmentItem(jsonDictionary: departmentItemDictionary)
        
        XCTAssertEqual(departmentItem!.getOnlineStatus(),
                       DepartmentItem.InternalDepartmentOnlineStatus.unknown)
    }
    
    func testInitFails() {
        let departmentItemDictionary = try! JSONSerialization.jsonObject(with: INCORRECT_DEPARTMENT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
        
        XCTAssertNil(DepartmentItem(jsonDictionary: departmentItemDictionary))
    }
    
}
