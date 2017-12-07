//
//  DeltaItem.swift
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
 Class that encapsulates chat update data, received from a server.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
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
    private var data: Any
    private var event: Event
    private var objectType: DeltaType?
    private var sessionID: String
    
    
    // MARK: - Initialization
    init?(jsonDictionary: [String : Any?]) {
        // FIXME: Refactor this.
        if let eventString = jsonDictionary[JSONField.EVENT.rawValue] as? String {
            guard let event = Event(rawValue: eventString) else {
                return nil
            }
            
            self.event = event
        } else {
            return nil
        }
        
        if let data = jsonDictionary[JSONField.DATA.rawValue],
            data != nil {
            self.data = data!
        } else {
            return nil
        }
        
        if let sessionID = jsonDictionary[JSONField.SESSION_ID.rawValue] as? String {
            self.sessionID = sessionID
        } else {
            return nil
        }
        
        if let objectTypeString = jsonDictionary[JSONField.OBJECT_TYPE.rawValue] as? String {
            objectType = DeltaType(rawValue: objectTypeString)
        }
    }
    
    
    // MARK: - Methods
    
    func getObjectType() -> DeltaType? {
        return objectType
    }
    
    func getSessionID() -> String {
        return sessionID
    }
    
    func getEvent() -> Event {
        return event
    }
    
    func getData() -> Any {
        return data
    }
    
}
