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

final class MessageItem {
    
    // MARK: - Constants
    
    // Raw values equal to field names received in responses from server.
    
    enum MessageKind: String {
        
        case ACTION_REQUEST = "action_request"
        case CONTACT_REQUEST = "cont_req"
        case CONTACTS = "contacts"
        case FILE_FROM_OPERATOR = "file_operator"
        case FILE_FROM_VISITOR = "file_visitor"
        case FOR_OPERATOR = "for_operator"
        case INFO = "info"
        case OPERATOR = "operator"
        case OPERATOR_BUSY = "operator_busy"
        case VISITOR = "visitor"
        
        // MARK: - Methods
        
        func isTextMessage() -> Bool {
            return (self == .VISITOR)
                || (self == .OPERATOR)
        }
        
        func isFileMessage() -> Bool {
            return (self == .FILE_FROM_OPERATOR)
                || (self == .FILE_FROM_VISITOR)
        }
        
    }
    
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
        case TIME_SINCE_IN_MICROSECOND = "ts_m"
        case TIME_SINCE_IN_SECOND = "ts"
    }
    
    
    // MARK: - Properties

    private var authorID: String?
    private var avatarURLString: String?
    private var chatID: String?
    private var data: [String : Any?]?
    private var deleted: Bool?
    private var kind: MessageKind?
    private var senderName: String?
    private var timeSinceInMicrosecond: Int64 = -1
    fileprivate var clientSideID: String?
    fileprivate var id: String?
    fileprivate var text: String?
    fileprivate var timeSinceInSecond: Double?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
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
        
        if let data = jsonDictionary[JSONField.DATA.rawValue] as? [String : Any?] {
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
        
        if let timeSinceInMicrosecond = jsonDictionary[JSONField.TIME_SINCE_IN_MICROSECOND.rawValue] as? Int64 {
            self.timeSinceInMicrosecond = timeSinceInMicrosecond
        }
        
        if let timeSinceInSecond = jsonDictionary[JSONField.TIME_SINCE_IN_SECOND.rawValue] as? Double {
            self.timeSinceInSecond = timeSinceInSecond
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
    
    func set(text: String?) {
        self.text = text
    }
    
    func getSenderId() -> String? {
        return authorID
    }
    
    func getSenderAvatarURLString() -> String? {
        return avatarURLString
    }
    
    func getChatID() -> String? {
        return chatID
    }
    
    func set(chatID: String?) {
        self.chatID = chatID
    }
    
    func getData() -> [String : Any?]? {
        return data
    }
    
    func isDeleted() -> Bool {
        return deleted == true
    }
    
    func getKind() -> MessageKind? {
        return kind
    }
    
    func getSenderName() -> String? {
        return senderName
    }
    
    func getTimeInMicrosecond() -> Int64? {
        return (timeSinceInMicrosecond != -1) ? timeSinceInMicrosecond : Int64(timeSinceInSecond! * 1000000)
    }
    
    func getTimeInMillisecond() -> Int64? {
        if let timeInMicrosecond = getTimeInMicrosecond() {
            return timeInMicrosecond * 1000
        } else {
            return nil
        }
    }
    
}

// MARK: - Equatable
extension MessageItem: Equatable {
    
    static func == (lhs: MessageItem,
                    rhs: MessageItem) -> Bool {
        if (((lhs.id == rhs.id)
            && (lhs.clientSideID == rhs.clientSideID))
            && (lhs.timeSinceInSecond == rhs.timeSinceInSecond))
            && (lhs.text == rhs.text) {
            return true
        }
        
        return false
    }
    
}
