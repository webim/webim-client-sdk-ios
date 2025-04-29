//
//  DepartmentFactoryTests.swift
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
@testable import WebimMobileSDK
import XCTest

class DepartmentFactoryTests: XCTestCase {
    
    // MARK: - Constants
    
    private static let SERVER_URL_STRING = "https://demo.webim.ru"
    
    // MARK: - Properties
    
    private let departmentFactory = DepartmentFactory(serverURLString: DepartmentFactoryTests.SERVER_URL_STRING)
    private let departmentItemDictionary = try! JSONSerialization.jsonObject(with: DEPARTMENT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                     options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testConvert() {
        let departmentItem = DepartmentItem(jsonDictionary: departmentItemDictionary)!
        let department = departmentFactory.convert(departmentItem: departmentItem)
        
        XCTAssertEqual(department.getDepartmentOnlineStatus(),
                       DepartmentOnlineStatus.offline)
        XCTAssertEqual(department.getKey(),
                       "mobile_test_1")
        XCTAssertEqual(department.getLocalizedNames()!.count,
                       1)
        XCTAssertEqual(department.getLogoURL()!,
                       URL(string: DepartmentFactoryTests.SERVER_URL_STRING + "/webim/images/department_logo/wmtest2_1.png")!)
        XCTAssertEqual(department.getName(),
                       "Mobile Test 1")
        XCTAssertEqual(department.getOrder(),
                       100)
    }
    
}
