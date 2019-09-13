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
    private static let WEBIM_REMOTE_NOTIFICATION_JSON_STRING = """
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
    private static let NOT_WEBIM_REMOTE_NOTIFICATION_JSON_STRING = """
{
    "aps" : {
        "alert" : {
            "loc-key" : "P.OM",
            "loc-args" : ["Имя Оператора", "Сообщение"]
        },
        "sound" : "default",
    }
}
"""
    private static let INCORRECT_REMOTE_NOTIFICATION_JSON_STRING = """
{
    "alert" : {
        "loc-key" : "P.OM",
        "loc-args" : ["Имя Оператора", "Сообщение"]
    },
    "sound" : "default",
}
"""
    private static let REMOTE_NOTIFICATION_WITH_SPECIAL_FIELDS = """
{
  "aps": {
    "alert": {
      "loc-key": "P.OM",
      "loc-args": [
        "Имя Оператора",
        "Сообщение"
      ]
    },
    "sound": "default"
  },
  "webim": 1,
  "unread_by_visitor_msg_cnt": 1,
  "location": "mobile"
}
"""
    
    // MARK: - Properties
    let webimRemoteNotification = try! JSONSerialization.jsonObject(with: WebimTests.WEBIM_REMOTE_NOTIFICATION_JSON_STRING.data(using: .utf8)!,
                                                                    options: []) as! [AnyHashable : Any]
    let notWebimRemoteNotification = try! JSONSerialization.jsonObject(with: WebimTests.NOT_WEBIM_REMOTE_NOTIFICATION_JSON_STRING.data(using: .utf8)!,
                                                                       options: []) as! [AnyHashable : Any]
    let incorrectRemoteNotification = try! JSONSerialization.jsonObject(with: WebimTests.INCORRECT_REMOTE_NOTIFICATION_JSON_STRING.data(using: .utf8)!,
                                                                        options: []) as! [AnyHashable : Any]
    let webimRemoteNotificationWithSpecialFields = try! JSONSerialization.jsonObject(with: WebimTests.REMOTE_NOTIFICATION_WITH_SPECIAL_FIELDS.data(using: .utf8)!,
                                                                                     options: []) as! [AnyHashable : Any]
    
    // MARK: - Tests
    
    func testParseRemoteNotification() {
        let webimRemoteNotification = Webim.parse(remoteNotification: self.webimRemoteNotification)!
        
        XCTAssertNil(webimRemoteNotification.getEvent())
        XCTAssertEqual(webimRemoteNotification.getParameters(), ["Имя Оператора",
                                                                  "Сообщение"])
        XCTAssertEqual(webimRemoteNotification.getType(),
                       NotificationType.OPERATOR_MESSAGE)
        
        XCTAssertNil(Webim.parse(remoteNotification: self.incorrectRemoteNotification))
    }
    
    func testIsWebimRemoteNotification() {
        XCTAssertTrue(Webim.isWebim(remoteNotification: webimRemoteNotification))
        XCTAssertFalse(Webim.isWebim(remoteNotification: notWebimRemoteNotification))
    }
    
    func testRemoteNotificationWithSpecialFields() {
        let webimRemoteNotification = Webim.parse(remoteNotification: self.webimRemoteNotificationWithSpecialFields)
        XCTAssertEqual(webimRemoteNotification?.getUnreadByVisitorMessagesCount(), 1)
        XCTAssertEqual(webimRemoteNotification?.getLocation(), "mobile")
    }
    
}
