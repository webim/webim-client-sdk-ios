//
//  OperatorItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.02.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import WebimMobileSDK
import XCTest

// MARK: - Global constants
let OPERATOR_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33201.png",
    "fullname" : "Administrator",
    "id" : 33201,
    "additionalInfo" : "additionalInfo",
    "title" : "AnyTitle",
    "departmentKeys" : [
        "telegram",
        "test3",
        "test2"
    ],
    "langToFullname" : { },
    "sip" : "10002715000033201"
}
"""

class OperatorItemTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        let operatorItem = OperatorItem(jsonDictionary: convertToDict(OPERATOR_ITEM_JSON_STRING))!
        
        XCTAssertEqual(operatorItem.getID(), "33201")
        XCTAssertEqual(operatorItem.getFullName(), "Administrator")
        XCTAssertEqual(operatorItem.getInfo(), "additionalInfo")
        XCTAssertEqual(operatorItem.getTitle(), "AnyTitle")
        XCTAssertEqual(operatorItem.getAvatarURLString(), "/webim/images/avatar/demo_33201.png")
    }
    
    func test_InitFails_NullID() {
        let incorrectOperatorJSONString = """
        {
            "avatar" : "/webim/images/avatar/demo_33201.png",
            "fullname" : "Administrator",
            "id" : null,
            "departmentKeys" : [
                "telegram",
                "test3",
                "test2"
            ],
            "langToFullname" : { },
            "sip" : "10002715000033201"
        }
        """

        XCTAssertNil(OperatorItem(jsonDictionary: convertToDict(incorrectOperatorJSONString)))
    }

    func test_InitFails_NullFullName() {
        let incorrectOperatorJSONString = """
        {
            "avatar" : "/webim/images/avatar/demo_33201.png",
            "fullname" : null,
            "id" : 33201,
            "departmentKeys" : [
                "telegram",
                "test3",
                "test2"
            ],
            "langToFullname" : { },
            "sip" : "10002715000033201"
        }
        """

        XCTAssertNil(OperatorItem(jsonDictionary: convertToDict(incorrectOperatorJSONString)))
    }

}

fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}
