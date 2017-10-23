//
//  ChatItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class ChatItem {
    
    // MARK: - Constants
    
    // Raw values equal to field names received in responses from server.
    enum JSONField: String {
        case CATEGORY = "category"
        case CLIENT_SIDE_ID = "clientSideId"
        case CREATION_TIME_SINCE = "creationTs"
        case ID = "id"
        case MESSAGES = "messages"
        case MODIFICATION_TIME_SINCE = "modificationTs"
        case OFFLINE = "offline"
        case OPERATOR = "operator"
        case OPERATOR_ID_TO_RATE = "operatorIdToRate"
        case OPERATOR_TYPING = "operatorTyping"
        case READ_BY_VISITOR = "readByVisitor"
        case STATE = "state"
        case SUBCATEGORY = "subcategory"
        case SUBJECT = "subject"
        case UNREAD_BY_OPERATOR_TIME_SINCE = "unreadByOperatorSinceTs"
        case UNREAD_BY_VISITOR_TIME_SINCE = "unreadByVisitorSinceTs"
        case VISITOR_TYPING = "visitorTyping"
    }
    
    enum ChatItemState: String {
        
        case UNKNOWN = "unknown"
        case QUEUE = "queue"
        case CHATTING = "chatting"
        case CLOSED = "closed"
        case CLOSED_BY_VISITOR = "closed_by_visitor"
        case CLOSED_BY_OPERATOR = "closed_by_operator"
        case INVITATION = "invitation"
        
        // MARK: - Properties
        
        // Setted for getTypeBy(string:) method.
        private static let chatItemStateValues = [UNKNOWN,
                                                  QUEUE,
                                                  CHATTING,
                                                  CLOSED,
                                                  CLOSED_BY_VISITOR,
                                                  CLOSED_BY_OPERATOR,
                                                  INVITATION]
        
        
        // MARK: - Initialization
        init(withType typeValue: String) {
            self = ChatItemState(rawValue: typeValue)!
        }
        
        
        // MARK: - Methods
        
        func isClosed() -> Bool {
            return (((self == .CLOSED)
                || (self == .CLOSED_BY_VISITOR))
                || (self == .CLOSED_BY_OPERATOR))
                || (self == .UNKNOWN)
        }
        
        func isOpen() -> Bool {
            return !isClosed()
        }
        
        func getTypeBy(string: String) -> ChatItemState {
            for chatItemStateType in ChatItemState.chatItemStateValues {
                if chatItemStateType == ChatItemState(withType: string) {
                    return chatItemStateType
                }
            }
            
            return .UNKNOWN
        }
        
        func getTypeValue() -> String {
            return self.rawValue
        }
        
    }
    
    
    // MARK: - Properties
    
    fileprivate var id: String
    
    private var category: String?
    fileprivate var clientSideID: String?
    private var creationTimeSince: Double
    private lazy var messages = [MessageItem]()
    private var modificationTimeSince: Double?
    private var offline: Bool?
    private var `operator`: OperatorItem?
    private lazy var operatorIDToRate = [String : RatingItem]()
    private var operatorTyping: Bool?
    private var readByVisitor: Bool?
    private var state: String?
    private var subcategory: String?
    private var subject: String?
    private var unreadByOperatorTimeSince: Double?
    private var unreadByVisitorTimeSince: Double?
    private var visitorTyping: Bool?
    
    
    // MARK: - Initializers
    
    init(withID id: String? = nil) {
        creationTimeSince = ChatItem.createCreationTimeSince()
        
        if id == nil {
            self.id = String(Int(-creationTimeSince))
        } else {
            self.id = id!
        }
    }
    
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let creationTimeSinceValue = jsonDictionary[JSONField.CREATION_TIME_SINCE.rawValue] as? Double {
            creationTimeSince = creationTimeSinceValue
        } else {
            creationTimeSince = ChatItem.createCreationTimeSince()
        }
        
        if let idValue = jsonDictionary[JSONField.ID.rawValue] as? String {
            id = idValue
        } else {
            id = String(Int(-creationTimeSince))
        }
        
        if let messagesValue = jsonDictionary[JSONField.MESSAGES.rawValue] as? [Any] {
            for message in messagesValue {
                if let messageValue = message as? [String : Any?] {
                    let messageItem = MessageItem(withJSONDictionary: messageValue)
                    messages.append(messageItem)
                }
            }
        }

        if let operatorValue = jsonDictionary[JSONField.OPERATOR.rawValue] as? [String : Any?] {
            `operator` = OperatorItem(withJSONDictionary: operatorValue)
        }
        
        if let operatorIDToRateValue = jsonDictionary[JSONField.OPERATOR_ID_TO_RATE.rawValue] as? [String : Any?] {
            for (operatorIDValue, ratingValue) in operatorIDToRateValue {
                if let ratingItemValue = ratingValue as? [String : Any?] {
                    let rating = RatingItem(withJSONDictionary: ratingItemValue)
                    operatorIDToRate[operatorIDValue] = rating
                }
            }
        }
        
        if let category = jsonDictionary[JSONField.CATEGORY.rawValue] as? String {
            self.category = category
        }
        
        if let clientSideID = jsonDictionary[JSONField.CLIENT_SIDE_ID.rawValue] as? String {
            self.clientSideID = clientSideID
        }
        
        if let modificationTimeSince = jsonDictionary[JSONField.MODIFICATION_TIME_SINCE.rawValue] as? Double {
            self.modificationTimeSince = modificationTimeSince
        }
        
        if let offline = jsonDictionary[JSONField.OFFLINE.rawValue] as? Bool {
            self.offline = offline
        }
        
        if let operatorTyping = jsonDictionary[JSONField.OPERATOR_TYPING.rawValue] as? Bool {
            self.operatorTyping = operatorTyping
        }
        
        if let readByVisitor = jsonDictionary[JSONField.READ_BY_VISITOR.rawValue] as? Bool {
            self.readByVisitor = readByVisitor
        }
        
        if let state = jsonDictionary[JSONField.STATE.rawValue] as? String {
            self.state = state
        }
        
        if let subcategory = jsonDictionary[JSONField.SUBCATEGORY.rawValue] as? String {
            self.subcategory = subcategory
        }
        
        if let subject = jsonDictionary[JSONField.SUBJECT.rawValue] as? String {
            self.subject = subject
        }
        
        if let unreadByOperatorTimeSince = jsonDictionary[JSONField.UNREAD_BY_OPERATOR_TIME_SINCE.rawValue] as? Double {
            self.unreadByOperatorTimeSince = unreadByOperatorTimeSince
        }
        
        if let unreadByVisitorTimeSince = jsonDictionary[JSONField.UNREAD_BY_VISITOR_TIME_SINCE.rawValue] as? Double {
            self.unreadByVisitorTimeSince = unreadByVisitorTimeSince
        }
        
        if let visitorTyping = jsonDictionary[JSONField.VISITOR_TYPING.rawValue] as? Bool {
            self.visitorTyping = visitorTyping
        }
    }
    
    
    // MARK: - Methods
    
    func getID() -> String {
        return id
    }
    
    func getMessages() -> [MessageItem] {
        return messages
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
    
    func remove(message messageToRemove: MessageItem) -> Int? {
        var tempMessage: MessageItem? = nil
        if !messages.isEmpty {
            for message in messages {
                if message.getID() == messageToRemove.getID() {
                    tempMessage = message
                    break
                }
            }
        }
        
        var messagePosition: Int? = nil
        if tempMessage != nil {
            messagePosition = getPositionOf(message: tempMessage!)
            
            messages.remove(at: messagePosition!)
        }
        
        return messagePosition
    }
    
    func getPositionOf(message: MessageItem) -> Int? {
        var messagePosition: Int? = messages.index(of: message)
        
        if messagePosition == -1 {
            for messagesIndex in 0 ..< messages.count {
                if messages[messagesIndex].getID() == message.getClientSideID() {
                    messagePosition = messagesIndex
                    break
                }
            }
        }
        
        return messagePosition
    }
    
    func set(position: Int,
             ofMessage message: MessageItem) {
        if position == -1 {
            messages.append(message)
        } else {
            messages.remove(at: position)
            messages.insert(message,
                            at: position)
        }
    }
    
    func isOperatorTyping() -> Bool {
        return operatorTyping == true
    }
    
    func set(operatorTyping: Bool?) {
        self.operatorTyping = operatorTyping
    }
    
    func getSubject() -> String? {
        return subject
    }
    
    func set(subject: String?) {
        self.subject = subject
    }
    
    func getCreationTimeSince() -> Int64 {
        return Int64(creationTimeSince * 1000)
    }
    
    func getModificationTimeSince() -> Int64 {
        return Int64(modificationTimeSince! + 1000)
    }
    
    func getUnreadByVisitorTimeSince() -> Int64 {
        return Int64(unreadByVisitorTimeSince! * 1000)
    }
    
    func set(unreadByVisitorTimeSince: Double?) {
        self.unreadByVisitorTimeSince = unreadByVisitorTimeSince
    }
    
    func getNoAnswerTime() -> Int64 {
        return Int64(unreadByOperatorTimeSince! * 1000)
    }
    
    func set(lastAnswerTime: Double) {
        unreadByOperatorTimeSince = lastAnswerTime
    }
    
    func getState() -> ChatItemState {
        return ChatItemState(withType: state!)
    }
    
    func set(stateByString state: String) {
        self.state = state
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
    
    func isOffline() -> Bool? {
        return offline
    }
    
    func isReadByVisitor() -> Bool? {
        return readByVisitor
    }
    
    func set(readByVisitor: Bool?) {
        self.readByVisitor = readByVisitor
    }
    
    func isVisitorTyping() -> Bool? {
        return visitorTyping
    }
    
    func set(visitorTyping: Bool?) {
        self.visitorTyping = visitorTyping
    }
    
    func getClientSideID() -> String? {
        return clientSideID
    }
    
    func getOperatorIDToRate() -> [String : RatingItem]? {
        return operatorIDToRate
    }
    
    func set(rating: RatingItem,
             to operatorID: String) {
        operatorIDToRate[operatorID] = rating
    }
    
    
    // MARK: Private methods
    private static func createCreationTimeSince() -> Double {
        return Double(InternalUtils.getCurrentTimeInMicrosecond()) / 1000
    }
    
    
}

// MARK: - Equatable
extension ChatItem: Equatable {
    
    static func == (lhs: ChatItem,
                    rhs: ChatItem) -> Bool {
        return (lhs.id == rhs.id)
            && (lhs.clientSideID == rhs.clientSideID)
    }
    
}