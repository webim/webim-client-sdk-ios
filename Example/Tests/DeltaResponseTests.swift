//
//  DeltaResponseTests.swift
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
@testable import WebimClientLibrary
import XCTest

class DeltaResponseTests: XCTestCase {
    
    // MARK: - Constants
    private static let DELTA_RESPONSE_JSON_STRING = """
{
    "revision" : 12,
    "deltaList" : [
        {
            "id" : "80a332f6fced40f290a5e8ace4a6d11c",
            "data" : null,
            "event" : "upd",
            "objectType" : "CHAT_OPERATOR"
        },
        {
            "id" : "80a332f6fced40f290a5e8ace4a6d11c",
            "data" : "queue",
            "event" : "upd",
            "objectType" : "CHAT_STATE"
        },
        {
            "id" : "80a332f6fced40f290a5e8ace4a6d11c_8",
            "data" : {
                "avatar" : null,
                "authorId" : null,
                "ts" : 1519046868.2501681,
                "sessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
                "id" : "80a332f6fced40f290a5e8ace4a6d11c_8",
                "text" : "11",
                "clientSideId" : "578150796321959ef8b445866738381b",
                "kind" : "visitor",
                "name" : "Никита"
            },
            "event" : "add",
            "objectType" : "CHAT_MESSAGE"
        }
    ]
}
"""
    
    // MARK: - Properties
    private let deltaResponseDictionary = try! JSONSerialization.jsonObject(with: DeltaResponseTests.DELTA_RESPONSE_JSON_STRING.data(using: .utf8)!,
                                                                            options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testInit() {
        let deltaResponseItem = DeltaResponse(jsonDictionary: deltaResponseDictionary)
        
        XCTAssertEqual(deltaResponseItem.getRevision(),
                       12)
        XCTAssertNil(deltaResponseItem.getFullUpdate())
        XCTAssertEqual(deltaResponseItem.getDeltaList()!.count,
                       3)
    }
    
}
