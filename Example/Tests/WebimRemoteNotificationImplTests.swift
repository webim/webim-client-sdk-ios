//
//  WebimRemoteNotificationImplTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 30.01.18.
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

class WebimRemoteNotificationImplTests: XCTestCase {
    
    // MARK: - Tests
    
    func testContactRequestNotification() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.CR"
                ] as [String : Any]
            ]
        ]

        // When: Receiving contact request notification.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)

        // Then: Parameters should be ruturned like this.
        XCTAssertNil(webimRemoteNotification?.getEvent())
        XCTAssertTrue(webimRemoteNotification!.getParameters().isEmpty)
        XCTAssertEqual(webimRemoteNotification?.getType(),
                       NotificationType.contactInformationRequest)
    }
    
    func testOperatorAcceptedNotification() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.OA",
                    "loc-args" : ["Operator"]
                ] as [String : Any]
            ]
        ]
        
        // When: Receiving operator accepted notification.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)
        
        // Then: Parameters should be ruturned like this.
        XCTAssertNil(webimRemoteNotification?.getEvent())
        XCTAssertTrue(webimRemoteNotification?.getParameters().count == 1)
        XCTAssertEqual(webimRemoteNotification?.getType(),
                       NotificationType.operatorAccepted)
    }
    
    func testOperatorFileNotification() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.OF",
                    "loc-args" : ["Operator", "File"],
                    "event" : "add"
                ] as [String : Any]
            ]
        ]
        
        // When: Receiving operator file adding notification.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)
        
        // Then: Parameters should be ruturned like this.
        XCTAssertEqual(webimRemoteNotification?.getEvent(), NotificationEvent.add)
        XCTAssertTrue(webimRemoteNotification?.getParameters().count == 2)
        XCTAssertEqual(webimRemoteNotification?.getType(),
                       NotificationType.operatorFile)
    }
    
    func testOperatorMessageNotification() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.OM",
                    "loc-args" : ["Operator", "Message"],
                    "event" : "del"
                ] as [String : Any]
            ]
        ]

        // When: Receiving operator message deleting notification.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)

        // Then: Parameters should be ruturned like this.
        XCTAssertEqual(webimRemoteNotification?.getEvent(), NotificationEvent.delete)
        XCTAssertTrue(webimRemoteNotification?.getParameters().count == 2)
        XCTAssertEqual(webimRemoteNotification?.getType(),
                       NotificationType.operatorMessage)
    }
    
    func testWidgetNotification() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.WM"
                ] as [String : Any]
            ]
        ]

        // When: Receiving contact request notification.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)

        // Then: Parameters should be ruturned like this.
        XCTAssertNil(webimRemoteNotification?.getEvent())
        XCTAssertTrue(webimRemoteNotification!.getParameters().isEmpty)
        XCTAssertEqual(webimRemoteNotification?.getType(),
                       NotificationType.widget)
    }
    
    func testUnsupportedAps() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "non-alert" : [
                    "loc-key" : "P.WM"
                ] as [String : Any]
            ]
        ]
        
        // When: Receiving notification of unsupported type.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)
        
        // Then: WebimRemoteNotification object should be nil.
        XCTAssertNil(webimRemoteNotification)
    }
    
    func testUnsupportedEvent() {
        // Setup.
        let notificationDictionary = [
            "aps" : [
                "alert" : [
                    "loc-key" : "P.OM",
                    "loc-args" : ["Operator", "Message"],
                    "event" : "NewEvent"
                ] as [String : Any]
            ]
        ]
        
        // When: Receiving notification of unsupported type.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)
        
        // Then: Event should be nil.
        XCTAssertNil(webimRemoteNotification?.getEvent())
    }
    
    func testEmptyAlertNotification() {
        // Setup.
        let notificationDictionary =  [
            "aps" : [
                "alert" : []
            ]
        ]
        
        // When: Receiving notification without type.
        let webimRemoteNotification = WebimRemoteNotificationImpl(jsonDictionary: notificationDictionary)
        
        // Then: WebimRemoteNotification object should be nil.
        XCTAssertNil(webimRemoteNotification)
    }
    
}
