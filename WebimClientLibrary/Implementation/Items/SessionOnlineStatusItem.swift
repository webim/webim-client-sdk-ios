//
//  SessionOnlineStatusItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 Raw values equal to field names received in responses from server.
 
 `BUSY_OFFLINE` - user can't send messages at all;
 `BUSY_ONLINE` - user send offline messages, but server can return an error;
 `OFFLINE` - user can send offline messages;
 `ONLINE` - user can send online and offline messages;
 `UNKNOWN` - session has not received data from server.
 */
enum SessionOnlineStatusItem: String {
    
    case BUSY_OFFLINE = "busy_offline"
    case BUSY_ONLINE = "busy_online"
    case OFFLINE = "offline"
    case ONLINE = "online"
    case UNKNOWN = "unknown"
    
    // Setted for getTypeBy(string:) method.
    private static let sessionOnlineStatusValues = [BUSY_OFFLINE,
                                                    BUSY_ONLINE,
                                                    OFFLINE,
                                                    ONLINE,
                                                    UNKNOWN]
    
    
    // MARK: - Initialization
    init(withType typeValue: String) {
        self = SessionOnlineStatusItem(rawValue: typeValue)!
    }
    
    
    // MARK: - Methods
    
    func getTypeBy(string: String) -> SessionOnlineStatusItem {
        for sessionOnlineStatusItemType in SessionOnlineStatusItem.sessionOnlineStatusValues {
            if sessionOnlineStatusItemType == SessionOnlineStatusItem(withType: string) {
                return sessionOnlineStatusItemType
            }
        }
        
        return .UNKNOWN
    }
    
    func getTypeValue() -> String {
        return self.rawValue
    }
    
}
