//
//  FullUpdateTests.swift
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
@testable import WebimMobileSDK
import XCTest

class FullUpdateTests: XCTestCase {

    var sut: FullUpdate!
    var nullSut: FullUpdate!

    static let defaultFullUpdateJson = """
    {
        "state" : "chat",
        "authToken" : "17778d49ecf342b5aef702479a99bb65",
        "visitorNumber" : null,
        "visitor" : {
            "fields" : {
                "name" : "Посетитель"
            },
            "channelType" : null,
            "channelId" : null,
            "id" : "877a920ede7082412656ac1cdec7ecde",
            "icon" : {
                "color" : "#5fa0ea",
                "shape" : "rhombus"
            },
            "modificationTs" : 1518790888.5528669,
            "creationTs" : 1518790888.5528669,
            "hasProvidedFields" : true,
            "channelUserName" : null,
            "tags" : [ ],
            "channelUserId" : null
        },
        "pageId" : "fc59d2b80f1742da805e1f93548b3a29",
        "onlineStatus" : "busy_online",
        "showHelloMessage" : true,
        "visitSessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
        "helloMessageDescr" : "expectedHelloMessageDescr",
        "pollingPeriod" : 2,
        "historyRevision" : 512,
        "hintsEnabled" : true,
        "chatStartAfterMessage" : true,
        "onlineOperators" : false,
        "currentTime" : 1519044952,
        "cobrowsingSession" : null,
        "normalPollingPeriod" : 10,
        "survey" : {
           "id":"123321",
           "config":{
              "id":12,
              "descriptor":{
                 "forms":[
                    {
                       "id":15123,
                       "questions":[
                          {
                             "type":"stars",
                             "text":"someText",
                             "options":[
                                "some"
                             ]
                          }
                       ]
                    }
                 ]
              },
              "version":"91"
           },
           "current_question":{
              "form_id":124,
              "question_id":89891
           }
        },
        "departments" : [
            {
                "localeToName" : {
                    "ru" : "Mobile Test 1"
                },
                "key" : "mobile_test_1",
                "online" : "offline",
                "name" : "Mobile Test 1",
                "order" : 100,
                "logo" : "/webim/images/department_logo/wmtest2_1.png"
            },
            {
                "localeToName" : {
                    "ru" : "Mobile Test 1"
                },
                "key" : "mobile_test_1",
                "online" : "offline",
                "name" : "Mobile Test 1",
                "order" : 100,
                "logo" : "/webim/images/department_logo/wmtest2_1.png"
            }
        ],
        "chat" : {
            "readByVisitor" : true,
            "category" : "Прочее",
            "subject" : null,
            "operatorTyping" : false,
            "clientSideId" : "0134e9d90e0eb95884d880860382c8ab",
            "state" : "closed_by_operator",
            "needToBeClosed" : false,
            "visitorTyping" : null,
            "messages" : [
                {
                    "avatar" : null,
                    "authorId" : null,
                    "ts" : 1519040829.056972,
                    "sessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
                    "id" : "80a332f6fced40f290a5e8ace4a6d11c_2",
                    "text" : "Text",
                    "clientSideId" : "381e483f39e041a68b965da7f767c438",
                    "kind" : "info",
                    "name" : ""
                }
            ],
            "offline" : false,
            "visitorMessageDraft" : null,
            "id" : 5123124,
            "unreadByVisitorSinceTs" : null,
            "operatorIdToRate" : { },
            "creationTs" : 1519040829.056129,
            "subcategory" : null,
            "requestedForm" : null,
            "unreadByOperatorSinceTs" : null,
            "operator" : {
                "avatar" : "/webim/images/avatar/demo_33201.png",
                "fullname" : "Administrator",
                "id" : 33201,
                "robotType" : null,
                "departmentKeys" : [
                    "telegram",
                    "test3",
                    "test2"
                ],
                "langToFullname" : { },
                "sip" : "10002715000033201"
            }
        }
    }
    """

    private let nullFullUpdateJson = "{ }"

    override func setUp() {
        super.setUp()
        sut = FullUpdate(jsonDictionary: convertToDict(FullUpdateTests.defaultFullUpdateJson))
        nullSut = FullUpdate(jsonDictionary: convertToDict(nullFullUpdateJson))
    }

    override func tearDown() {
        nullSut = nil
        sut = nil
        super.tearDown()
    }

    private func convertToDict(_ json: String) -> [String: Any?] {
        return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
    }

    // MARK: - Tests
    func testInitAuthToken() {
        let expectedAuthToken = "17778d49ecf342b5aef702479a99bb65"

        XCTAssertEqual(sut.getAuthorizationToken(), expectedAuthToken)
    }

    func testInitAuthTokenNullValue() {
        XCTAssertNil(nullSut.getAuthorizationToken())
    }

    func testInitChat() {
        let chatItemJson = """
        {
            "id" : 5123124,
            "clientSideId" : "0134e9d90e0eb95884d880860382c8ab"

        }
        """
        let exceptedChatItem = ChatItem(jsonDictionary: convertToDict(chatItemJson))

        XCTAssertEqual(sut.getChat(), exceptedChatItem)
    }

    func testInitChatNullValue() {
        XCTAssertNil(nullSut.getChat())
    }

    func testInitDepartments() {
        let expectedDepartmentsCount = 2

        XCTAssertEqual(sut.getDepartments()?.count, expectedDepartmentsCount)
    }

    func testInitDepartmentsNullValue() {
        XCTAssertNil(nullSut.getDepartments())
    }

    func testInitHintsEnabled() {
        XCTAssertTrue(sut.getHintsEnabled())
    }

    func testInitHintsEnabledNullValue() {
        XCTAssertFalse(nullSut.getHintsEnabled())
    }

    func testInitHistoryRevision() {
        let expectedHistoryRevision = "512"

        XCTAssertEqual(sut.getHistoryRevision(), expectedHistoryRevision)
    }

    func testInitHistoryRevisionNullValue() {
        XCTAssertNil(nullSut.getHistoryRevision())
    }

    func testInitOnlineStatus() {
        let expectedOnlineStatus = "busy_online"

        XCTAssertEqual(sut.getOnlineStatus(), expectedOnlineStatus)
    }

    func testInitOnlineStatusNullValue() {
        XCTAssertNil(nullSut.getOnlineStatus())
    }

    func testInitPageId() {
        let expectedPageId = "fc59d2b80f1742da805e1f93548b3a29"

        XCTAssertEqual(sut.getPageID(), expectedPageId)
    }

    func testInitPageIdNullValue() {
        XCTAssertNil(nullSut.getPageID())
    }

    func testInitSessionId() {
        let expectedSessionId = "80a332f6fced40f290a5e8ace4a6d11c"

        XCTAssertEqual(sut.getSessionID(), expectedSessionId)
    }

    func testInitSessionIdNullValue() {
        XCTAssertNil(nullSut.getSessionID())
    }

    func testInitState() {
        let expectedValue = "chat"

        XCTAssertEqual(sut.getState(), expectedValue)
    }

    func testInitStateNullValue() {
        XCTAssertNil(nullSut.getState())
    }

    func testInitSurvey() {
        let expectedSurveyId = "123321"

        XCTAssertEqual(sut.getSurvey()?.getID(), expectedSurveyId)
    }

    func testInitSurveyNullValue() {
        XCTAssertNil(nullSut.getSurvey())
    }

    func testInitVisitor() {
        let expectedVisitorJsonString = "{\"fields\":{\"name\":\"Посетитель\"},\"channelType\":null,\"channelId\":null,\"id\":\"877a920ede7082412656ac1cdec7ecde\",\"channelUserId\":null,\"modificationTs\":1518790888.5528669,\"creationTs\":1518790888.5528669,\"hasProvidedFields\":true,\"channelUserName\":null,\"icon\":{\"color\":\"#5fa0ea\",\"shape\":\"rhombus\"},\"tags\":[]}"

        XCTAssertEqual(sut.getVisitorJSONString(), expectedVisitorJsonString)
    }

    func testInitVisitorNullValue() {
        XCTAssertNil(nullSut.getVisitorJSONString())
    }

    func testInitShowHelloMessage() {
        let expectedShowHelloMessage = true

        XCTAssertEqual(sut.getShowHelloMessage(), expectedShowHelloMessage)
    }

    func testInitShowHelloMessageNullValue() {
        XCTAssertNil(nullSut.getShowHelloMessage())
    }

    func testInitChatStartAfterMessage() {
        let expectedChatStartAfterMessage = true

        XCTAssertEqual(sut.getChatStartAfterMessage(), expectedChatStartAfterMessage)
    }

    func testInitChatStartAfterMessageNullValue() {
        XCTAssertNil(nullSut.getChatStartAfterMessage())
    }

    func testInitHelloMessageDescr() {
        let expectedHelloMessageDescr = "expectedHelloMessageDescr"

        XCTAssertEqual(sut.getHelloMessageDescr(), expectedHelloMessageDescr)
    }

    func testInitHelloMessageDescrNullValue() {
        XCTAssertNil(nullSut.getHelloMessageDescr())
    }
}
