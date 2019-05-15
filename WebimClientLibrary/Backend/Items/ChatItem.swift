//
//  ChatItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
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
 Class that encapsulates chat data.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class ChatItem {
    
    // MARK: - Constants
    
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case category = "category"
        case clientSideID = "clientSideId"
        case creationTimestamp = "creationTs"
        case id = "id"
        case messages = "messages"
        case modificationTimestamp = "modificationTs"
        case offline = "offline"
        case `operator` = "operator"
        case operatorIDToRate = "operatorIdToRate"
        case operatorTyping = "operatorTyping"
        case readByVisitor = "readByVisitor"
        case state = "state"
        case subcategory = "subcategory"
        case subject = "subject"
        case unreadByOperatorTimestamp = "unreadByOperatorSinceTs"
        case unreadByVisitorMessageCount = "unreadByVisitorMsgCnt"
        case unreadByVisitorTimestamp = "unreadByVisitorSinceTs"
        case visitorTyping = "visitorTyping"
    }
    
    // MARK: - Properties
    private var category: String?
    private var clientSideID: String?
    private var creationTimestamp: Double
    private var id: String
    private lazy var messages = [MessageItem]()
    private var modificationTimestamp: Double?
    private var offline: Bool?
    private var `operator`: OperatorItem?
    private lazy var operatorIDToRate = [String: RatingItem]()
    private var operatorTyping: Bool?
    private var readByVisitor: Bool?
    private var state: String?
    private var subcategory: String?
    private var subject: String?
    private var unreadByOperatorTimestamp: Double?
    private var unreadByVisitorMessageCount: Int
    private var unreadByVisitorTimestamp: Double?
    private var visitorTyping: Bool?
    
    // MARK: - Initialization
    
    init(jsonDictionary: [String: Any?]) {
        if let creationTimestampValue = jsonDictionary[JSONField.creationTimestamp.rawValue] as? Double {
            creationTimestamp = creationTimestampValue
        } else {
            creationTimestamp = ChatItem.createCreationTimestamp()
        }
        
        if let idValue = jsonDictionary[JSONField.id.rawValue] as? String {
            id = idValue
        } else {
            id = String(Int(-creationTimestamp))
        }
        
        if let unreadByVisitorMessageCount = jsonDictionary[JSONField.unreadByVisitorMessageCount.rawValue] as? Int {
            self.unreadByVisitorMessageCount = unreadByVisitorMessageCount
        } else {
            self.unreadByVisitorMessageCount = 0
        }
        
        if let messagesValue = jsonDictionary[JSONField.messages.rawValue] as? [Any] {
            for message in messagesValue {
                if let messageValue = message as? [String: Any?] {
                    let messageItem = MessageItem(jsonDictionary: messageValue)
                    messages.append(messageItem)
                }
            }
        }

        if let operatorValue = jsonDictionary[JSONField.`operator`.rawValue] as? [String: Any?] {
            `operator` = OperatorItem(jsonDictionary: operatorValue)
        }
        
        if let operatorIDToRateValue = jsonDictionary[JSONField.operatorIDToRate.rawValue] as? [String: Any?] {
            for (operatorIDValue, ratingValue) in operatorIDToRateValue {
                if let ratingItemValue = ratingValue as? [String: Any?] {
                    let rating = RatingItem(jsonDictionary: ratingItemValue)
                    operatorIDToRate[operatorIDValue] = rating
                }
            }
        }
        
        if let category = jsonDictionary[JSONField.category.rawValue] as? String {
            self.category = category
        }
        
        if let clientSideID = jsonDictionary[JSONField.clientSideID.rawValue] as? String {
            self.clientSideID = clientSideID
        }
        
        if let modificationTimestamp = jsonDictionary[JSONField.modificationTimestamp.rawValue] as? Double {
            self.modificationTimestamp = modificationTimestamp
        }
        
        if let offline = jsonDictionary[JSONField.offline.rawValue] as? Bool {
            self.offline = offline
        }
        
        if let operatorTyping = jsonDictionary[JSONField.operatorTyping.rawValue] as? Bool {
            self.operatorTyping = operatorTyping
        }
        
        if let readByVisitor = jsonDictionary[JSONField.readByVisitor.rawValue] as? Bool {
            self.readByVisitor = readByVisitor
        }
        
        if let state = jsonDictionary[JSONField.state.rawValue] as? String {
            self.state = state
        }
        
        if let subcategory = jsonDictionary[JSONField.subcategory.rawValue] as? String {
            self.subcategory = subcategory
        }
        
        if let subject = jsonDictionary[JSONField.subject.rawValue] as? String {
            self.subject = subject
        }
        
        if let unreadByOperatorTimestamp = jsonDictionary[JSONField.unreadByOperatorTimestamp.rawValue] as? Double {
            self.unreadByOperatorTimestamp = unreadByOperatorTimestamp
        }
        
        if let unreadByVisitorTimestamp = jsonDictionary[JSONField.unreadByVisitorTimestamp.rawValue] as? Double {
            self.unreadByVisitorTimestamp = unreadByVisitorTimestamp
        }
        
        if let visitorTyping = jsonDictionary[JSONField.visitorTyping.rawValue] as? Bool {
            self.visitorTyping = visitorTyping
        }
    }
    
    // For testing purpoeses.
    init(id: String? = nil) {
        creationTimestamp = ChatItem.createCreationTimestamp()

        if id == nil {
            self.id = String(Int(-creationTimestamp))
        } else {
            self.id = id! 
        }
        
        unreadByVisitorMessageCount = 0
    }
    
    // MARK: - Methods
    
    func getMessages() -> [MessageItem] {
        return messages
    }
    
    func set(messages: [MessageItem]) {
        self.messages = messages
    }
    
    func add(message: MessageItem,
             atPosition position: Int? = nil) {
        if position == nil {
            messages.append(message)
        } else {
            messages.insert(message,
                            at: position!)
        }
    }
    
    func isOperatorTyping() -> Bool {
        return (operatorTyping == true)
    }
    
    func set(operatorTyping: Bool?) {
        self.operatorTyping = operatorTyping
    }
    
    func getState() -> ChatItemState? {
        return ChatItemState(withType: state!)
    }
    
    func set(state: ChatItemState) {
        self.state = state.rawValue
    }
    
    func getOperator() -> OperatorItem? {
        return `operator`
    }
    
    func set(operator: OperatorItem) {
        self.`operator` = `operator`
    }
    
    func getReadByVisitor() -> Bool? {
        return readByVisitor
    }
    
    func set(readByVisitor: Bool?) {
        self.readByVisitor = readByVisitor
    }
    
    func getOperatorIDToRate() -> [String: RatingItem]? {
        return operatorIDToRate
    }
    
    func set(rating: RatingItem,
             toOperatorWithId operatorID: String) {
        operatorIDToRate[operatorID] = rating
    }
    
    func getUnreadByVisitorMessageCount() -> Int {
        return unreadByVisitorMessageCount
    }
    
    func set(unreadByVisitorMessageCount: Int) {
        self.unreadByVisitorMessageCount = unreadByVisitorMessageCount
    }
    
    func getUnreadByVisitorTimestamp() -> Double? {
        return unreadByVisitorTimestamp
    }
    
    func getUnreadByOperatorTimestamp() -> Double? {
        return unreadByOperatorTimestamp
    }
    
    func set(unreadByOperatorTimestamp: Double?) {
        self.unreadByOperatorTimestamp = unreadByOperatorTimestamp
    }
    
    func set(unreadByVisitorTimestamp: Double?) {
        self.unreadByVisitorTimestamp = unreadByVisitorTimestamp
    }
    
    
    // MARK: Private methods
    private static func createCreationTimestamp() -> Double {
        return Double(InternalUtils.getCurrentTimeInMicrosecond())
    }
    
    // MARK: -
    enum ChatItemState: String {
        case chatting = "chatting"
        case chattingWithRobot = "chatting_with_robot"
        case closed = "closed"
        case closedByOperator = "closed_by_operator"
        case closedByVisitor = "closed_by_visitor"
        case invitation = "invitation"
        case queue = "queue"
        case unknown = "unknown"
        
        // MARK: - Initialization
        init(withType typeValue: String) {
            self = ChatItemState(rawValue: typeValue) ?? .unknown
        }
        
        
        // MARK: - Methods
        func isClosed() -> Bool {
            return (((self == .closed)
                || (self == .closedByVisitor))
                || (self == .closedByOperator))
                || (self == .unknown)
        }
        
    }
    
}

// MARK: - Equatable
extension ChatItem: Equatable {
    
    // MARK: - Methods
    // Used inside MessageHolderImpl.receiving(newChat:previousChat:newMessages:) only.
    static func == (lhs: ChatItem,
                    rhs: ChatItem) -> Bool {
        return (lhs.id == rhs.id)
            && (lhs.clientSideID == rhs.clientSideID)
    }
    
}
