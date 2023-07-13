//
//  DeltaItemTests.swift
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

import Foundation
@testable import WebimMobileSDK
import XCTest

class DeltaItemTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        //Given
        let deltaItemDefaultJSONString = """
    {
    "id" : "80a332f6fced40f290a5e8ace4a6d11c_5",
    "data" : {
        "avatar" : null,
        "authorId" : null,
        "ts" : 1519043833.694463,
        "sessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
        "id" : "80a332f6fced40f290a5e8ace4a6d11c_5",
        "text" : "10",
        "clientSideId" : "fbaa9bb54d47008b5bf56a5830510c64",
        "kind" : "visitor",
        "name" : "Никита"
    },
    "event" : "add",
    "objectType" : "CHAT_MESSAGE"
    }
    """
        let deltaItemDictionary = try! JSONSerialization.jsonObject(with: deltaItemDefaultJSONString.data(using: .utf8)!,
                                                                    options: []) as! [String : Any?]

        //When
        let deltaItem = DeltaItem(jsonDictionary: deltaItemDictionary)!

        //Then
        XCTAssertEqual(deltaItem.getDeltaType(),
                       DeltaItem.DeltaType.chatMessage)
        XCTAssertEqual(deltaItem.getEvent(),
                       DeltaItem.Event.add)
        XCTAssertEqual(deltaItem.getID(),
                       "80a332f6fced40f290a5e8ace4a6d11c_5")
        XCTAssertNotNil(deltaItem.getData())
    }
    
    func testInitWithNullEvent() {
        //Given
        let deltaItemNullEventJSONString = """
    {
    "id" : "80a332f6fced40f290a5e8ace4a6d11c_5",
    "data" : {
        "avatar" : null,
        "authorId" : null,
        "ts" : 1519043833.694463,
        "sessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
        "id" : "80a332f6fced40f290a5e8ace4a6d11c_5",
        "text" : "10",
        "clientSideId" : "fbaa9bb54d47008b5bf56a5830510c64",
        "kind" : "visitor",
        "name" : "Никита"
    },
    "event" : null,
    "objectType" : "CHAT_MESSAGE"
    }
    """
        let deltaItemDictionary = try! JSONSerialization.jsonObject(with: deltaItemNullEventJSONString.data(using: .utf8)!,
                                                                    options: []) as! [String : Any?]

        //When
        let deltaItem = DeltaItem(jsonDictionary: deltaItemDictionary)

        //Then
        XCTAssertNil(deltaItem)
    }

    func testInitWithNullID() {
        //Given
        let deltaItemNullIDJSONString = """
    {
    "id" : null,
    "data" : {
        "avatar" : null,
        "authorId" : null,
        "ts" : 1519043833.694463,
        "sessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
        "id" : "80a332f6fced40f290a5e8ace4a6d11c_5",
        "text" : "10",
        "clientSideId" : "fbaa9bb54d47008b5bf56a5830510c64",
        "kind" : "visitor",
        "name" : "Никита"
    },
    "event" : "add",
    "objectType" : "CHAT_MESSAGE"
    }
    """
        let deltaItemDictionary = try! JSONSerialization.jsonObject(with: deltaItemNullIDJSONString.data(using: .utf8)!,
                                                                    options: []) as! [String : Any?]
        //When
        let deltaItem = DeltaItem(jsonDictionary: deltaItemDictionary)
        //Then
        XCTAssertNil(deltaItem)
    }
    
}
