//
//  FullUpdate.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class FullUpdate {
    
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
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
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
    
    func getPageId() -> String? {
        return pageID
    }
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
    func getSessionID() -> String? {
        return sessionID
    }
    
    func getVisitorJSONString() -> String? {
        return visitorJSONString
    }
    
    func set(visitorJSONString: String?) {
        self.visitorJSONString = visitorJSONString
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
    func getState() -> String? {
        return state
    }
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func hasChat() -> Bool {
        return chat != nil
    }
    
    func getHintsEnabled() -> Bool? {
        return hintsEnabled
    }
    
}
