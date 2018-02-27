//
//  RatingItemTests.swift
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

class RatingItemTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        let ratingItemJSONString = """
{
    "operatorId" : 33201,
    "rating" : 2
}
"""
        let ratingItemDictionary = try! JSONSerialization.jsonObject(with: ratingItemJSONString.data(using: .utf8)!,
                                                                     options: []) as! [String : Any?]
        let ratingItem = RatingItem(jsonDictionary: ratingItemDictionary)
        
        XCTAssertEqual(ratingItem!.getOperatorID(),
                       "33201")
        XCTAssertEqual(ratingItem!.getRating(),
                       2)
    }
    
    func testInitFails() {
        let ratingItemJSONString = """
{
    "operatorId" : 33201
}
"""
        let ratingItemDictionary = try! JSONSerialization.jsonObject(with: ratingItemJSONString.data(using: .utf8)!,
                                                                     options: []) as! [String : Any?]
        
        XCTAssertNil(RatingItem(jsonDictionary: ratingItemDictionary))
    }
    
}
