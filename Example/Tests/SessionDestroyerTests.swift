//
//  SessionDestroyerTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 01.02.18.
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

class SessionDestroyerTests: XCTestCase {
    
    // MARK: - Constants
    private let sessionDestroyer = SessionDestroyer(userDefaultsKey: SessionDestroyerTests.userDefaultsKey)
    private static let userDefaultsKey = "userDefaultsKey"
    // MARK: - Tests
    func testDestroy() {
        // Setup.
        
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        let expectation3 = XCTestExpectation()
        
        sessionDestroyer.add {
            expectation1.fulfill()
        }
        sessionDestroyer.add {
            expectation2.fulfill()
        }
        sessionDestroyer.add {
            expectation3.fulfill()
        }
        
        // When: Session is destroyed.
        sessionDestroyer.destroy()
        
        // Then: All passed actions should be executed.
        XCTAssertTrue(sessionDestroyer.isDestroyed())
        wait(for: [expectation1],
             timeout: 1.0)
        wait(for: [expectation2],
             timeout: 1.0)
        wait(for: [expectation3],
             timeout: 1.0)
    }

    func testGetUserDefaultsKey() {
        XCTAssertEqual(sessionDestroyer.getUserDefaulstKey(),
                       SessionDestroyerTests.userDefaultsKey)
    }
 
}
