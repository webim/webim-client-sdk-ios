//
//  HistoryBeforeResponseTests.swift
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

class HistoryBeforeResponseTests: XCTestCase {
    
    // MARK: - Constants
    private static let HISTORY_BEFORE_RESPONSE_JSON_STRING = """
{
    "result" : "ok",
    "data" : {
        "hasMore" : true,
        "messages" : [
            {
                "avatar" : "/webim/images/avatar/demo_33201.png",
                "chatId" : "2470",
                "authorId" : 33201,
                "data" : null,
                "id" : "26066",
                "ts_m" : 1518178864048925,
                "text" : "5",
                "clientSideId" : "2b29154364e14cf8b3823267740ac090",
                "kind" : "operator",
                "name" : "Administrator"
            },
            {
                "avatar" : null,
                "chatId" : "2470",
                "authorId" : null,
                "data" : null,
                "id" : "26068",
                "ts_m" : 1518181740640531,
                "text" : "Text",
                "clientSideId" : "b91d616953a4d05c3df82f63359ebb58",
                "kind" : "file_visitor",
                "name" : "Никита"
            }
        ]
    }
}
"""
    
    // MARK: - Properties
    private let historyBeforeResponseDictionary = try! JSONSerialization.jsonObject(with: HistoryBeforeResponseTests.HISTORY_BEFORE_RESPONSE_JSON_STRING.data(using: .utf8)!,
                                                                                    options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testInit() {
        let historyBeforeItem = HistoryBeforeResponse(jsonDictionary: historyBeforeResponseDictionary)
        
        XCTAssertTrue(historyBeforeItem.getData()!.isHasMore())
        XCTAssertEqual(historyBeforeItem.getData()!.getMessages()!.count,
                       2)
    }
    
}
