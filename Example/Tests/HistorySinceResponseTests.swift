//
//  HistorySinceResponseTests.swift
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

class HistorySinceResponseTests: XCTestCase {
    
    // MARK: - Constants
    private static let HISTORY_SINCE_RESPONSE_JSON_STRING = """
{
    "result" : "ok",
    "data" : {
        "hasMore" : true,
        "revision" : "1519046942029554",
        "messages" : [
            {
                "avatar" : null,
                "chatId" : "2489",
                "authorId" : null,
                "data" : null,
                "id" : "26886",
                "ts_m" : 1518610821878678,
                "text" : "5",
                "clientSideId" : "4855e5fb4cf72970fd1ee6d055db165f",
                "kind" : "visitor",
                "name" : "Никита"
            },
            {
                "avatar" : null,
                "chatId" : "2489",
                "authorId" : null,
                "data" : null,
                "id" : "26887",
                "ts_m" : 1518610834493789,
                "text" : "Посетитель закрыл диалог",
                "clientSideId" : "f90565d2ae724a5f969f72687af7fd49",
                "kind" : "info",
                "name" : ""
            }
        ]
    }
}
"""
    
    // MARK: - Properties
    private let historySinceResponseDictionary = try! JSONSerialization.jsonObject(with: HistorySinceResponseTests.HISTORY_SINCE_RESPONSE_JSON_STRING.data(using: .utf8)!,
                                                                                   options: []) as! [String : Any?]
    
    // MARK: - Methods
    func testInit() {
        let historySinceResponse = HistorySinceResponse(jsonDictionary: historySinceResponseDictionary)
        
        XCTAssertEqual(historySinceResponse.getData()!.getMessages()!.count,
                       2)
        XCTAssertTrue(historySinceResponse.getData()!.isHasMore()!)
        XCTAssertEqual(historySinceResponse.getData()!.getRevision(),
                       "1519046942029554")
    }
    
}
