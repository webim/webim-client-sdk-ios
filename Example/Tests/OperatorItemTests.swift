//
//  OperatorItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.02.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import WebimClientLibrary
import XCTest

// MARK: - Global constants
let OPERATOR_ITEM_JSON_STRING = """
{
    "avatar" : "/webim/images/avatar/demo_33201.png",
    "fullname" : "Administrator",
    "id" : 33201,
    "robotType" : null,
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
        let operatorItemDictionary = try! JSONSerialization.jsonObject(with: OPERATOR_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        let operatorItem = OperatorItem(jsonDictionary: operatorItemDictionary)!
        
        XCTAssertEqual(operatorItem.getID(),
                       "33201")
        XCTAssertEqual(operatorItem.getFullName(),
                       "Administrator")
        XCTAssertEqual(operatorItem.getAvatarURLString(),
                       "/webim/images/avatar/demo_33201.png")
    }
    
    func testInitFails() {
        let incorrectOperatorJSONString = """
{
    "avatar" : "/webim/images/avatar/demo_33201.png",
    "fullname" : "Administrator",
    "robotType" : null,
    "departmentKeys" : [
        "telegram",
        "test3",
        "test2"
    ],
    "langToFullname" : { },
    "sip" : "10002715000033201"
}
"""
        let operatorItemDictionary = try! JSONSerialization.jsonObject(with: incorrectOperatorJSONString.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        
        XCTAssertNil(OperatorItem(jsonDictionary: operatorItemDictionary))
    }
    
}
