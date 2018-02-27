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
@testable import WebimClientLibrary
import XCTest

class FullUpdateTests: XCTestCase {
    
    // MARK: - Constants
    private static let FULL_UPDATE_JSON_STRING = """
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
    "onlineStatus" : "offline",
    "visitSessionId" : "80a332f6fced40f290a5e8ace4a6d11c",
    "pollingPeriod" : 2,
    "onlineOperators" : false,
    "currentTime" : 1519044952,
    "cobrowsingSession" : null,
    "normalPollingPeriod" : 10,
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
        "id" : 2547,
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
    
    // MARK: - Properties
    private let fullUpdateDictionary = try! JSONSerialization.jsonObject(with: FullUpdateTests.FULL_UPDATE_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testInit() {
        let fullUpdateItem = FullUpdate(jsonDictionary: fullUpdateDictionary)
        
        XCTAssertEqual(fullUpdateItem.getAuthorizationToken(),
                       "17778d49ecf342b5aef702479a99bb65")
        
        let chatItemString = """
{
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
    "id" : 2547,
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
"""
        let chatItemDictonary = try! JSONSerialization.jsonObject(with: chatItemString.data(using: .utf8)!,
                                                                  options: []) as! [String : Any?]
        XCTAssertEqual(fullUpdateItem.getChat(),
                       ChatItem(jsonDictionary: chatItemDictonary))
        
        XCTAssertNil(fullUpdateItem.getDepartments())
        
        XCTAssertFalse(fullUpdateItem.getHintsEnabled())
        
        XCTAssertEqual(fullUpdateItem.getOnlineStatus(),
                       "offline")
        
        XCTAssertEqual(fullUpdateItem.getPageID(),
                       "fc59d2b80f1742da805e1f93548b3a29")
        
        XCTAssertEqual(fullUpdateItem.getSessionID(),
                       "80a332f6fced40f290a5e8ace4a6d11c")
        
        XCTAssertEqual(fullUpdateItem.getState(),
                       "chat")
        
        XCTAssertNotNil(fullUpdateItem.getVisitorJSONString())
    }
    
}
