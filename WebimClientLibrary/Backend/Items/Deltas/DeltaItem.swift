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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class DeltaItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum DeltaType: String {
        case chat = "CHAT"
        case chatMessage = "CHAT_MESSAGE"
        case chatOperator = "CHAT_OPERATOR"
        case chatOperatorTyping = "CHAT_OPERATOR_TYPING"
        case chatReadByVisitor = "CHAT_READ_BY_VISITOR"
        case statState = "CHAT_STATE"
        case chatUnreadByOperatorTimestamp = "CHAT_UNREAD_BY_OPERATOR_SINCE_TS"
        case departmentList = "DEPARTMENT_LIST"
        case offlineChatMessage = "OFFLINE_CHAT_MESSAGE"
        case operatorRate = "OPERATOR_RATE"
        case visitSession = "VISIT_SESSION"
        case visitSessionState = "VISIT_SESSION_STATE"
    }
    enum Event: String {
        case add = "add"
        case delete = "del"
        case update = "upd"
    }
    private enum JSONField: String {
        case data = "data"
        case event = "event"
        case objectType = "objectType"
        case id = "id"
    }
    
    // MARK: - Properties
    private var data: Any?
    private var event: Event
    private var deltaType: DeltaType?
    private var id: String
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let eventString = jsonDictionary[JSONField.event.rawValue] as? String,
            let event = Event(rawValue: eventString) else {
            return nil
        }
        self.event = event
        
        guard let id = jsonDictionary[JSONField.id.rawValue] as? String else {
            return nil
        }
        self.id = id
        
        self.data = jsonDictionary[JSONField.data.rawValue] ?? nil
        
        if let objectTypeString = jsonDictionary[JSONField.objectType.rawValue] as? String {
            deltaType = DeltaType(rawValue: objectTypeString)
        }
    }
    
    // MARK: - Methods
    
    func getDeltaType() -> DeltaType? {
        return deltaType
    }
    
    func getID() -> String {
        return id
    }
    
    func getEvent() -> Event {
        return event
    }
    
    func getData() -> Any? {
        return data
    }
    
}
