//
//  WebimTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 15.02.18.
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
import WebimClientLibrary
import XCTest

class WebimTests: XCTestCase {
    
    // MARK: - Constants
    static let REMOTE_NOTIFICATION_JSON_STRING = """
{
    "aps" : {
        "alert" : {
            "loc-key" : "P.OM",
            "loc-args" : ["Имя Оператора", "Сообщение"]
        },
        "sound" : "default",
    },
    "webim": 1
}
"""
    
    // MARK: - Properties
    let remoteNotification = try! JSONSerialization.jsonObject(with: WebimTests.REMOTE_NOTIFICATION_JSON_STRING.data(using: .utf8)!,
                                                               options: []) as! [AnyHashable : Any]
    
    // MARK: - Tests
    
    func testParseRemoteNotification() {
        let webimRemoteNotification = Webim.parse(remoteNotification: remoteNotification)!
        
        XCTAssertNil(webimRemoteNotification.getEvent())
        XCTAssertEqual(webimRemoteNotification.getParameters(), ["Имя Оператора",
                                                                  "Сообщение"])
        XCTAssertEqual(webimRemoteNotification.getType(),
                       NotificationType.OPERATOR_MESSAGE)
    }
    
    func testIsWebimRemoteNotificatin() {
        XCTAssertTrue(Webim.isWebim(remoteNotification: remoteNotification))
    }
    
}
