//
//  DeltaItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class DeltaItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    
    enum DeltaType: String {
        case CHAT = "CHAT"
        case CHAT_MESSAGE = "CHAT_MESSAGE"
        case CHAT_OPERATOR = "CHAT_OPERATOR"
        case CHAT_OPERATOR_TYPING = "CHAT_OPERATOR_TYPING"
        case CHAT_READ_BY_VISITOR = "CHAT_READ_BY_VISITOR"
        case CHAT_STATE = "CHAT_STATE"
        case OFFLINE_CHAT_MESSAGE = "OFFLINE_CHAT_MESSAGE"
        case OPERATOR_RATE = "OPERATOR_RATE"
        case VISIT_SESSION = "VISIT_SESSION"
        case VISIT_SESSION_STATE = "VISIT_SESSION_STATE"
    }
    
    enum Event: String {
        case ADD = "add"
        case DELETE = "del"
        case UPDATE = "upd"
    }
    
    private enum JSONField: String {
        case DATA = "data"
        case EVENT = "event"
        case OBJECT_TYPE = "objectType"
        case SESSION_ID = "id"
    }
    
    
    // MARK: - Properties
    private var data: Any?
    private var event: Event?
    private var objectType: DeltaType?
    private var sessionID: String?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let eventString = jsonDictionary[JSONField.EVENT.rawValue] as? String {
            event = Event(rawValue: eventString)
        }
        
        
        if let objectTypeString = jsonDictionary[JSONField.OBJECT_TYPE.rawValue] as? String {
            objectType = DeltaType(rawValue: objectTypeString)
        }
        
        data = jsonDictionary[JSONField.DATA.rawValue] ?? nil
        
        if let sessionID = jsonDictionary[JSONField.SESSION_ID.rawValue] as? String {
            self.sessionID = sessionID
        }
    }
    
    
    // MARK: - Methods
    
    func getObjectType() -> DeltaType? {
        return objectType
    }
    
    func getSessionID() -> String? {
        return sessionID
    }
    
    func getEvent() -> Event? {
        return event
    }
    
    func getData() -> Any? {
        return data
    }
    
}
