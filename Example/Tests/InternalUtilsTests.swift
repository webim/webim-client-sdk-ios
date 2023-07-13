//
//  InternalUtilsTests.swift
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
@testable import WebimMobileSDK

class InternalUtilsTests: XCTestCase {

    //MARK: Tests
    func test_CreateServerURLString_AccountNameHasOnlyName() {
        let accountName = "demo"
        let expectedURLString = "https://demo.webim.ru"

        XCTAssertEqual(InternalUtils.createServerURLStringBy(accountName: accountName), expectedURLString)
    }

    func test_CreateServerURLString_AccountNameHasFullURL() {
        let accountName = "https://demo.webim.ru"
        let expectedURLString = "https://demo.webim.ru"

        XCTAssertEqual(InternalUtils.createServerURLStringBy(accountName: accountName), expectedURLString)
    }

    func test_CreateServerURLString_AccountNameHasFullURLWithSlash() {
        let accountName = "https://demo.webim.ru/"
        let expectedURLString = "https://demo.webim.ru"

        let sut = InternalUtils.createServerURLStringBy(accountName: accountName)

        XCTAssertEqual(sut, expectedURLString)
    }

    func test_GetCurrentTimeInMicrosecond() {
        let expectedTime = Int64(Date().timeIntervalSince1970 * 1_000_000)

        XCTAssertEqual(InternalUtils.getCurrentTimeInMicrosecond(), expectedTime, accuracy: 10)
    }

    func test_ParseRemoteNotification_EmptyValue() {
        let emptyRemoteNotificationValue: [AnyHashable: Any] = [:]

        let sut = InternalUtils.parse(remoteNotification: emptyRemoteNotificationValue, visitorId: "someValue")

        XCTAssertNil(sut)
    }

    func test_ParseRemoteNotification_WrongValue() {
        let wrongRemoteNotificationValue: [AnyHashable: Any] = [1: 1212,
                                                                5.5123: "someValue",
                                                                "someKey": 123]

        let sut = InternalUtils.parse(remoteNotification: wrongRemoteNotificationValue, visitorId: "someValue")

        XCTAssertNil(sut)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_ContactInformationRequestType() {
        let remoteNotificationContactInfoType = produceNotificationDictionary(type: "P.CR")
        let expectedType = NotificationType.contactInformationRequest

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationContactInfoType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_OperatorAcceptedType() {
        let remoteNotificationOperatorAcceptedType = produceNotificationDictionary(type: "P.OA")
        let expecetedType = NotificationType.operatorAccepted

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationOperatorAcceptedType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expecetedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_OperatorFileType() {
        let remoteNotificationOperatorFileType = produceNotificationDictionary(type: "P.OF")
        let expectedType = NotificationType.operatorFile

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationOperatorFileType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_OperatorMessageType() {
        let remoteNotificationOperatorMessageType = produceNotificationDictionary(type: "P.OM")
        let expectedType = NotificationType.operatorMessage

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationOperatorMessageType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_WidgetType() {
        let remoteNotificationWidgetType = produceNotificationDictionary(type: "P.WM")
        let expectedType = NotificationType.widget

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationWidgetType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_RateOperatorType() {
        let remoteNotificationRateOperatorType = produceNotificationDictionary(type: "P.RO")
        let expectedType = NotificationType.rateOperator

        let sut = InternalUtils.parse(remoteNotification: remoteNotificationRateOperatorType, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil_ParamsNotEmpty() {
        let remoteNotification = produceNotificationDictionary(type: "P.RO",
                                                               params: ["some",
                                                                        "some",
                                                                        "some",
                                                                        "some",
                                                                        "some"])

        let sut = InternalUtils.parse(remoteNotification: remoteNotification, visitorId: nil)

        XCTAssertNil(sut)
    }

    func test_ParseRemoteNotification_ParamsNotEmpty() {
        let visitorId = "visitorId"
        let remoteNotification = produceNotificationDictionary(type: "P.OA",
                                                               params: ["some",
                                                                        visitorId,
                                                                        "some",
                                                                        "some",
                                                                        "some"])
        let expectedType = NotificationType.operatorAccepted

        let sut = InternalUtils.parse(remoteNotification: remoteNotification, visitorId: visitorId)

        XCTAssertEqual(sut?.getType(), expectedType)
    }

    func test_ParseRemoteNotification_VisitorIdIsNil__ParamsIsNull() {
        let remoteNotification: [AnyHashable: Any] = [
            "aps": [
                "alert" : [
                    "loc-key": "P.OA"
                ]
            ],
            "unread_by_visitor_msg_cnt": 1,
            "location": "null"
        ]
        let expectedType = NotificationType.operatorAccepted

        let sut = InternalUtils.parse(remoteNotification: remoteNotification, visitorId: nil)

        XCTAssertEqual(sut?.getType(), expectedType)
    }


    private func produceNotificationDictionary(type: String,
                                               params: [String] = [],
                                               location: String? = nil,
                                               unreadByVisitorMsgCnt: Int = 0,
                                               aps: [String: Any] = ["alert" : [String: Any]()]) -> [AnyHashable : Any] {



        let remoteNotification: [AnyHashable: Any] = [
            "aps": [
                "alert" : [
                    "loc-key": "\(type)",
                    "loc-args": params
                ]
            ],
            "unread_by_visitor_msg_cnt": unreadByVisitorMsgCnt,
            "location": location ?? "null"
        ]
        return remoteNotification
    }

    func test_IsWebim_EmptyNotification() {
        let remoteNotification = [AnyHashable: Any]()

        let sut = InternalUtils.isWebim(remoteNotification: remoteNotification)

        XCTAssertFalse(sut)
    }

    func test_IsWebim_NotificationWebimTrue() {
        let remoteNotification: [AnyHashable: Any] = ["webim": true]

        let sut = InternalUtils.isWebim(remoteNotification: remoteNotification)

        XCTAssertTrue(sut)
    }

    func test_IsWebim_NotificationWebimFalse() {
        let remoteNotification: [AnyHashable: Any] = ["webim": false]

        let sut = InternalUtils.isWebim(remoteNotification: remoteNotification)

        XCTAssertFalse(sut)
    }
}
