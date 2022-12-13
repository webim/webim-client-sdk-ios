//
//  OperatorImplTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 02.02.18.
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
import XCTest
@testable import WebimClientLibrary

class OperatorImplTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInit() {
        let `operator` = OperatorImpl(id: "id",
                                      name: "name",
                                      avatarURLString: nil,
                                      title: "title",
                                      info: "info")
        
        XCTAssertEqual(`operator`.getID(), "id")
        XCTAssertEqual(`operator`.getName(), "name")
        XCTAssertEqual(`operator`.getTitle(), "title")
        XCTAssertEqual(`operator`.getInfo(), "info")
        XCTAssertNil(`operator`.getAvatarURL())
    }
    
    func testEquals() {
        var operator1: OperatorImpl? = OperatorImpl(id: "id1",
                                                    name: "name1",
                                                    avatarURLString: "avatar1.jpg")
        var operator2: OperatorImpl? = OperatorImpl(id: "id1",
                                                    name: "name1",
                                                    avatarURLString: "avatar1.jpg")
        XCTAssertTrue(operator1 == operator2)
        
        operator1 = OperatorImpl(id: "id1",
                                 name: "name1",
                                 avatarURLString: "avatar1.jpg")
        operator2 = OperatorImpl(id: "id2",
                                 name: "name2",
                                 avatarURLString: "avatar2.jpg")
        XCTAssertFalse(operator1 == operator2)
        
        operator1 = OperatorImpl(id: "id1",
                                 name: "name1",
                                 avatarURLString: "avatar1.jpg")
        operator2 = OperatorImpl(id: "id2",
                                 name: "name1",
                                 avatarURLString: "avatar1.jpg")
        XCTAssertFalse(operator1 == operator2)
        
        operator1 = OperatorImpl(id: "id1",
                                 name: "name1",
                                 avatarURLString: "avatar1.jpg")
        operator2 = OperatorImpl(id: "id1",
                                 name: "name1",
                                 avatarURLString: nil)
        XCTAssertFalse(operator1 == operator2)
        
        operator1 = OperatorImpl(id: "id1",
                                 name: "name1",
                                 avatarURLString: "avatar1.jpg")
        operator2 = nil
        XCTAssertFalse(operator1 == operator2)
    }
    
}
