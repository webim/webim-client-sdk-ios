//
//  MessageItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that encapsulates message data, received from a server.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class MessageItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case AUTHOR_ID = "authorId"
        case AVATAR_URL_STRING = "avatar"
        case CHAT_ID = "chatId"
        case CLIENT_SIDE_ID = "clientSideId"
        case DATA = "data"
        case DELETED = "deleted"
        case ID = "id"
        case KIND = "kind"
        case SENDER_NAME = "name"
        case TEXT = "text"
        case TIMESTAMP_IN_MICROSECOND = "ts_m"
        case TIMESTAMP_IN_SECOND = "ts"
    }
    
    // MARK: - Properties
    private var authorID: String?
    private var avatarURLString: String?
    private var chatID: String?
    private var clientSideID: String?
    private var data: [String: Any?]?
    private var deleted: Bool?
    private var id: String?
    private var kind: MessageKind?
    private var senderName: String?
    private var text: String?
    private var timestampInMicrosecond: Int64 = -1
    private var timestampInSecond: Double?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let messageKind = jsonDictionary[JSONField.KIND.rawValue] as? String {
            kind = MessageKind(rawValue: messageKind)
        }
        
        if let authorID = jsonDictionary[JSONField.AUTHOR_ID.rawValue] as? Int {
            self.authorID = String(authorID)
        }
        
        if let avatarURLString = jsonDictionary[JSONField.AVATAR_URL_STRING.rawValue] as? String {
            self.avatarURLString = avatarURLString
        }
        
        if let chatID = jsonDictionary[JSONField.CHAT_ID.rawValue] as? String {
            self.chatID = chatID
        }
        
        if let clientSideID = jsonDictionary[JSONField.CLIENT_SIDE_ID.rawValue] as? String {
            self.clientSideID = clientSideID
        }
        
        if let data = jsonDictionary[JSONField.DATA.rawValue] as? [String: Any?] {
            self.data = data
        }
        
        if let deleted = jsonDictionary[JSONField.DELETED.rawValue] as? Bool {
            self.deleted = deleted
        }
        
        if let id = jsonDictionary[JSONField.ID.rawValue] as? String {
            self.id = id
        }
        
        if let senderName = jsonDictionary[JSONField.SENDER_NAME.rawValue] as? String {
            self.senderName = senderName
        }
        
        if let text = jsonDictionary[JSONField.TEXT.rawValue] as? String {
            self.text = text
        }
        
        if let timestampInMicrosecond = jsonDictionary[JSONField.TIMESTAMP_IN_MICROSECOND.rawValue] as? Int64 {
            self.timestampInMicrosecond = timestampInMicrosecond
        }
        
        if let timestampInSecond = jsonDictionary[JSONField.TIMESTAMP_IN_SECOND.rawValue] as? Double {
            self.timestampInSecond = timestampInSecond
        }
    }
    
    // MARK: - Methods
    
    func getClientSideID() -> String? {
        if clientSideID == nil {
            clientSideID = id
        }
        
        return clientSideID
    }
    
    func getID() -> String? {
        return id
    }
    
    func getText() -> String? {
        return text
    }
    
    func getSenderID() -> String? {
        return authorID
    }
    
    func getSenderAvatarURLString() -> String? {
        return avatarURLString
    }
    
    func getData() -> [String: Any?]? {
        return data
    }
    
    func isDeleted() -> Bool {
        return (deleted == true)
    }
    
    func getKind() -> MessageKind? {
        return kind
    }
    
    func getSenderName() -> String? {
        return senderName
    }
    
    func getTimeInMicrosecond() -> Int64? {
        return ((timestampInMicrosecond != -1) ? timestampInMicrosecond : Int64(timestampInSecond! * 1_000_000))
    }
    
    // MARK: -
    enum MessageKind: String {
        
        // Raw values equal to field names received in responses from server.
        case ACTION_REQUEST = "action_request"
        case CONTACTS_REQUEST = "cont_req"
        case CONTACTS = "contacts"
        case FILE_FROM_OPERATOR = "file_operator"
        case FILE_FROM_VISITOR = "file_visitor"
        case FOR_OPERATOR = "for_operator"
        case INFO = "info"
        case OPERATOR = "operator"
        case OPERATOR_BUSY = "operator_busy"
        case VISITOR = "visitor"
        
        // MARK: - Initialization
        init(messageType: MessageType) {
            switch messageType {
            case .ACTION_REQUEST:
                self = .ACTION_REQUEST
                
                break
            case .CONTACTS_REQUEST:
                self = .CONTACTS_REQUEST
                
                break
            case .FILE_FROM_OPERATOR:
                self = .FILE_FROM_OPERATOR
                
                break
            case .FILE_FROM_VISITOR:
                self = .FILE_FROM_VISITOR
                
                break
            case .INFO:
                self = .INFO
                
                break
            case .OPERATOR:
                self = .OPERATOR
                
                break
            case .OPERATOR_BUSY:
                self = .OPERATOR_BUSY
                
                break
            case .VISITOR:
                self = .VISITOR
                
                break
            }
        }
        
    }
    
}

// MARK: - Equatable
extension MessageItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: MessageItem,
                    rhs: MessageItem) -> Bool {
        if (((lhs.id == rhs.id)
            && (lhs.clientSideID == rhs.clientSideID))
            && (lhs.timestampInSecond == rhs.timestampInSecond))
            && (lhs.text == rhs.text) {
            return true
        }
        
        return false
    }
    
}
