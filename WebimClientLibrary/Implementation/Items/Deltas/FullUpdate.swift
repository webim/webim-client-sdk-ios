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
 Class that encapsulates full chat data, received from a server.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
struct FullUpdate {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case AUTHORIZATION_TOKEN = "authToken"
        case CHAT = "chat"
        case HINTS_ENABLED = "hintsEnabled"
        case ONLINE_STATUS = "onlineStatus"
        case PAGE_ID = "pageId"
        case SESSION_ID = "visitSessionId"
        case STATE = "state"
        case VISITOR_JSON = "visitor"
    }
    
    
    // MARK: - Properties
    
    private var authorizationToken: String?
    private var chat: ChatItem?
    private var onlineStatus: String?
    private var pageID: String?
    private var sessionID: String?
    private var state: String?
    private var visitorJSONString: String?
    
    // MARK: LocationSettings properties
    private var hintsEnabled: Bool?
    
    
    // MARK: - Initialization
    init(jsonDictionary: [String : Any?]) {
        if let authorizationToken = jsonDictionary[JSONField.AUTHORIZATION_TOKEN.rawValue] as? String {
            self.authorizationToken = authorizationToken
        }
        
        if let chatValue = jsonDictionary[JSONField.CHAT.rawValue] as? [String : Any?] {
            chat = ChatItem(withJSONDictionary: chatValue)
        }
        
        if let pageID = jsonDictionary[JSONField.PAGE_ID.rawValue] as? String {
            self.pageID = pageID
        }
        
        if let onlineStatus = jsonDictionary[JSONField.ONLINE_STATUS.rawValue] as? String {
            self.onlineStatus = onlineStatus
        }
        
        if let sessionID = jsonDictionary[JSONField.SESSION_ID.rawValue] as? String {
            self.sessionID = sessionID
        }
        
        if let state = jsonDictionary[JSONField.STATE.rawValue] as? String {
            self.state = state
        }
        
        if let visitorJSON = jsonDictionary[JSONField.VISITOR_JSON.rawValue] {
            if let visitorJSONData = try? JSONSerialization.data(withJSONObject: visitorJSON!) {
                visitorJSONString = String(data: visitorJSONData,
                                           encoding: .utf8)
            }
            
        }
    }
    
    
    // MARK: - Methods
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func getHintsEnabled() -> Bool? {
        return hintsEnabled
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
    func getPageId() -> String? {
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
