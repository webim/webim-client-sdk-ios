//
//  VisitorItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 19.02.18.
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

import UIKit
@testable import WebimMobileSDK
import XCTest

class VisitorItemTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        let visitorItemJSONString = """
{
    "fields" : {
        "name" : "Посетитель"
        },
    "channelType" : null,
    "channelId" : null,
    "id" : "877a920ede7082412656ac1cdec7ecde",
    "icon" : {
        "color" : "#5fa0ea",
        "shape" : "rhombus"
    },
    "modificationTs" : 1518790888.5528669,
    "creationTs" : 1518790888.5528669,
    "hasProvidedFields" : true,
    "channelUserName" : null,
    "tags" : [ ],
    "channelUserId" : null
}
"""
        let visitorItemDictionary = try! JSONSerialization.jsonObject(with: visitorItemJSONString.data(using: .utf8)!,
                                                                      options: []) as! [String : Any?]
        let visitorItem = VisitorItem(jsonDictionary: visitorItemDictionary)!
        
        XCTAssertEqual(visitorItem.getID(),
                       "877a920ede7082412656ac1cdec7ecde")
        
        XCTAssertEqual(visitorItem.getIcon()!.getColor(),
                       UIColor(hexString: "#5fa0ea")!)
        XCTAssertEqual(visitorItem.getIcon()!.getShape(),
                       "rhombus")
        
        XCTAssertEqual(visitorItem.getVisitorFields().getName(),
                       "Посетитель")
        XCTAssertNil(visitorItem.getVisitorFields().getEmail())
        XCTAssertNil(visitorItem.getVisitorFields().getPhone())
    }
    
    func testInitFails() {
        let visitorItemJSONString = """
{
    "fields" : {
        "name" : "Посетитель"
        },
    "channelType" : null,
    "channelId" : null,
    "icon" : {
        "color" : "#5fa0ea",
        "shape" : "rhombus"
    },
    "modificationTs" : 1518790888.5528669,
    "creationTs" : 1518790888.5528669,
    "hasProvidedFields" : true,
    "channelUserName" : null,
    "tags" : [ ],
    "channelUserId" : null
}
"""
        let visitorItemDictionary = try! JSONSerialization.jsonObject(with: visitorItemJSONString.data(using: .utf8)!,
                                                                      options: []) as! [String : Any?]
        
        XCTAssertNil(VisitorItem(jsonDictionary: visitorItemDictionary))
    }
    
    func testNilIcon() {
        let visitorItemJSONString = """
{
    "fields" : {
        "name" : "Посетитель"
        },
    "channelType" : null,
    "channelId" : null,
    "id" : "877a920ede7082412656ac1cdec7ecde",
    "icon" : {
        "shape" : "rhombus"
    },
    "modificationTs" : 1518790888.5528669,
    "creationTs" : 1518790888.5528669,
    "hasProvidedFields" : true,
    "channelUserName" : null,
    "tags" : [ ],
    "channelUserId" : null
}
"""
        let visitorItemDictionary = try! JSONSerialization.jsonObject(with: visitorItemJSONString.data(using: .utf8)!,
                                                                      options: []) as! [String : Any?]
        let visitorItem = VisitorItem(jsonDictionary: visitorItemDictionary)!
        
        XCTAssertNil(visitorItem.getIcon())
    }
    
    func testNilFields() {
        let visitorItemJSONString = """
{
    "fields" : { },
    "channelType" : null,
    "channelId" : null,
    "id" : "877a920ede7082412656ac1cdec7ecde",
    "icon" : {
        "shape" : "rhombus"
    },
    "modificationTs" : 1518790888.5528669,
    "creationTs" : 1518790888.5528669,
    "hasProvidedFields" : true,
    "channelUserName" : null,
    "tags" : [ ],
    "channelUserId" : null
}
"""
        let visitorItemDictionary = try! JSONSerialization.jsonObject(with: visitorItemJSONString.data(using: .utf8)!,
                                                                      options: []) as! [String : Any?]
        
        XCTAssertNil(VisitorItem(jsonDictionary: visitorItemDictionary))
    }
    
}
