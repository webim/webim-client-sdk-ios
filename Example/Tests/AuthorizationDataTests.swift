//
//  AuthorizationDataTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 31.01.18.
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
@testable import WebimMobileSDK

class AuthorizationDataTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInitialization() {
        // MARK: Test 1
        
        // When: Page ID and authorization token are nil.
        var pageID: String? = nil
        var authorizationToken: String? = nil
        var authorizationData = AuthorizationData(pageID: pageID,
                                                  authorizationToken: authorizationToken)
        
        // Then: Authorization data should be nil.
        XCTAssertNil(authorizationData)
        
        // MARK: Test 2
        
        // When: Authorization token is nil.
        pageID = "page_id"
        authorizationToken = nil
        authorizationData = AuthorizationData(pageID: pageID,
                                              authorizationToken: authorizationToken)
        
        // Then: Authorization data should be nil.
        XCTAssertNil(authorizationData)
        
        // MARK: Test 3
        
        // When: Authorization token is nil.
        pageID = nil
        authorizationToken = "auth_token"
        authorizationData = AuthorizationData(pageID: pageID,
                                              authorizationToken: authorizationToken)
        
        // Then: Authorization data should be nil.
        XCTAssertNil(authorizationData)
        
        // MARK: Test 4
        
        // When: Page ID and authorization token aren't nil.
        pageID = "page_id"
        authorizationToken = "auth_token"
        authorizationData = AuthorizationData(pageID: pageID,
                                              authorizationToken: authorizationToken)
        
        // Then: Authorization data shouldn't be nil.
        XCTAssertNotNil(authorizationData)
        XCTAssertEqual(authorizationData!.getPageID(),
                       "page_id")
        XCTAssertEqual(authorizationData!.getAuthorizationToken(),
                       "auth_token")
    }
    
    func testEquals() {
        // MARK: Test 1
        
        // When: Page IDs and authorization tokens are the same.
        var pageID = "page_id"
        var authorizationToken = "auth_token"
        var authorizationData1 = AuthorizationData(pageID: pageID,
                                                   authorizationToken: authorizationToken)
        var authorizationData2 = AuthorizationData(pageID: pageID,
                                                   authorizationToken: authorizationToken)
        
        // Then: Thwo AuthorizationData objects must be equal.
        XCTAssertTrue(authorizationData1 == authorizationData2)
        
        // MARK: Test 2
        
        // When: Page IDs are the same but authorization tokents aren't.
        let pageID1 = "page_id1"
        let pageID2 = "page_id2"
        authorizationToken = "auth_token"
        authorizationData1 = AuthorizationData(pageID: pageID1,
                                               authorizationToken: authorizationToken)
        authorizationData2 = AuthorizationData(pageID: pageID2,
                                               authorizationToken: authorizationToken)
        
        // Then: Thwo AuthorizationData objects must be not equal.
        XCTAssertTrue(authorizationData1 != authorizationData2)
        
        // MARK: Test 3
        
        // When: Page IDs aren't the same but authorization tokents are.
        pageID = "page_id"
        let authorizationToken1 = "auth_token1"
        let authorizationToken2 = "auth_token2"
        authorizationData1 = AuthorizationData(pageID: pageID,
                                               authorizationToken: authorizationToken1)
        authorizationData2 = AuthorizationData(pageID: pageID,
                                               authorizationToken: authorizationToken2)
        
        // Then: Thwo AuthorizationData objects must be not equal.
        XCTAssertTrue(authorizationData1 != authorizationData2)
        
        // MARK: Test 4
        
        // When: One AuthorizationData object is nil.
        pageID = "page_id"
        authorizationToken = "auth_token"
        authorizationData1 = AuthorizationData(pageID: pageID,
                                               authorizationToken: authorizationToken)
        authorizationData2 = nil
        
        // Then: Thwo AuthorizationData objects must be not equal.
        XCTAssertNotNil(authorizationData1)
        XCTAssertNil(authorizationData2)
        XCTAssertTrue(authorizationData1 != authorizationData2)
    }
    
}
