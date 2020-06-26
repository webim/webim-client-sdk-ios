//
//  FullUpdate.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
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

/**
 Class that encapsulates full data update, received from a server.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
struct FullUpdate {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case authorizationToken = "authToken"
        case chat = "chat"
        case departments = "departments"
        case hintsEnabled = "hintsEnabled"
        case historyRevision = "historyRevision"
        case onlineStatus = "onlineStatus"
        case pageID = "pageId"
        case sessionID = "visitSessionId"
        case state = "state"
        case visitor = "visitor"
    }
    
    // MARK: - Properties
    private var authorizationToken: String?
    private var chat: ChatItem?
    private var departments: [DepartmentItem]?
    private var hintsEnabled: Bool
    private var historyRevision: Int?
    private var onlineStatus: String?
    private var pageID: String?
    private var sessionID: String?
    private var state: String?
    private var visitorJSONString: String?

    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let authorizationToken = jsonDictionary[JSONField.authorizationToken.rawValue] as? String {
            self.authorizationToken = authorizationToken
        }
        
        if let chatValue = jsonDictionary[JSONField.chat.rawValue] as? [String: Any?] {
            chat = ChatItem(jsonDictionary: chatValue)
        }
        
        if let pageID = jsonDictionary[JSONField.pageID.rawValue] as? String {
            self.pageID = pageID
        }
        
        if let onlineStatus = jsonDictionary[JSONField.onlineStatus.rawValue] as? String {
            self.onlineStatus = onlineStatus
        }
        
        if let sessionID = jsonDictionary[JSONField.sessionID.rawValue] as? String {
            self.sessionID = sessionID
        }
        
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            self.state = state
        }
        
        if let visitorJSON = jsonDictionary[JSONField.visitor.rawValue] {
            if let visitorJSONData = try? JSONSerialization.data(withJSONObject: visitorJSON as Any) {
                visitorJSONString = String(data: visitorJSONData,
                                           encoding: .utf8)
            }
        }
        
        if let departmantsData = jsonDictionary[JSONField.departments.rawValue] as? [Any] {
            var departmentItems = [DepartmentItem]()
            for departmentData in departmantsData {
                if let departmentDictionary = departmentData as? [String: Any] {
                    if let deparmentItem = DepartmentItem(jsonDictionary: departmentDictionary) {
                        departmentItems.append(deparmentItem)
                    }
                }
            }
            self.departments = departmentItems
        }
        
        hintsEnabled = (jsonDictionary[JSONField.hintsEnabled.rawValue] as? Bool) ?? false
        
        if let historyRevision = jsonDictionary[JSONField.historyRevision.rawValue] as? Int {
            self.historyRevision = historyRevision
        }
    }
    
    // MARK: - Methods
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
    func getDepartments() -> [DepartmentItem]? {
        return departments
    }
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func getHintsEnabled() -> Bool {
        return hintsEnabled
    }
    
    func getHistoryRevision() -> String? {
        guard let historyRevision = historyRevision else {
            return nil
        }
        return String(historyRevision)
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
    func getPageID() -> String? {
        return pageID
    }
    
    func getSessionID() -> String? {
        return sessionID
    }
    
    func getState() -> String? {
        return state
    }
    
    func getVisitorJSONString() -> String? {
        return visitorJSONString
    }
    
}
