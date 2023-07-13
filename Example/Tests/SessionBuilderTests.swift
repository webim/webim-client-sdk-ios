//
//  SessionBuilderTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 02.03.18.
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

class SessionBuilderTests: XCTestCase {
    
    // MARK: - Tests
    func testBuild() {
        let visitorFieldsJSONString = "{\"id\":\"1234567890987654321\",\"display_name\":\"Никита\",\"crc\":\"ffadeb6aa3c788200824e311b9aa44cb\"}"
        
        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(location: "location")
            .build())
        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .build())
        
        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(deviceToken: "token")
            .build())
        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(deviceToken: "token")
            .set(remoteNotificationSystem: .apns)
            .build())
        
        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(visitorFieldsJSONString: visitorFieldsJSONString)
            .set(providedAuthorizationTokenStateListener: self)
            .build())
        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(visitorFieldsJSONString: visitorFieldsJSONString)
            .build())
        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(providedAuthorizationTokenStateListener: self)
            .build())
        
        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(appVersion: "version")
            .set(visitorFieldsJSONData: visitorFieldsJSONString.data(using: .utf8)!)
            .set(pageTitle: "title")
            .set(fatalErrorHandler: self)
            .set(remoteNotificationSystem: .apns)
            .set(deviceToken: "token")
            .set(isLocalHistoryStoragingEnabled: true)
            .set(isVisitorDataClearingEnabled: false)
            .set(webimLogger: self)
            .build())

        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(multivisitorSection: "multivisitorSection")
            .set(providedAuthorizationTokenStateListener: self)
            .build())

        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(multivisitorSection: "multivisitorSection")
            .set(providedAuthorizationTokenStateListener: self)
            .build())

        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(onlineStatusRequestFrequencyInMillis: 1512)
            .set(providedAuthorizationTokenStateListener: self)
            .build())

        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(onlineStatusRequestFrequencyInMillis: 1512)
            .set(providedAuthorizationTokenStateListener: self)
            .build())
    }

    func test_Build_WithStringPrechat() {
        let prechat = "12:34\\n56:78"

        XCTAssertNoThrow(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(prechat: prechat)
            .set(providedAuthorizationTokenStateListener: self)
            .build())
    }

    func test_Build_WrongPrechat() {
        let firstPrechat = "erdtfyguhijokwadghavowhdahwbdaajwbdkjawb"
        let secondPrechat = "FFAACC"
        let thirdPrechat = "123"

        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(prechat: firstPrechat)
            .set(providedAuthorizationTokenStateListener: self)
            .build())

        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(prechat: secondPrechat)
            .set(providedAuthorizationTokenStateListener: self)
            .build())

        XCTAssertThrowsError(try Webim
            .newSessionBuilder()
            .set(accountName: "account")
            .set(location: "location")
            .set(prechat: thirdPrechat)
            .set(providedAuthorizationTokenStateListener: self)
            .build())
    }
    
}

// MARK: -
extension SessionBuilderTests: ProvidedAuthorizationTokenStateListener {
    
    // MARK: - Methods
    // MARK: ProvidedAuthorizationTokenStateListener protocol methods
    func update(providedAuthorizationToken: String) {
        // No need to do anything while testing.
    }
    
}

// MARK: -
extension SessionBuilderTests: FatalErrorHandler {
    
    // MARK: - Methods
    // MARK: FatalErrorHandler protocol methods
    func on(error: WebimError) {
        // No need to do anything when testing.
    }
    
}

// MARK: -
extension SessionBuilderTests: WebimLogger {
    
    // MARK: - Methods
    // MARK: WebimLogger protocol methods
    func log(entry: String) {
        // No need to do anything when testing.
    }
    
}
