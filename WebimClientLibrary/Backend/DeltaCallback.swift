//
//  DeltaCallback.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 12.10.17.
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
 Class that handles server response when SDK requests chat updates.
 - seealso:
 `DeltaResponse`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class DeltaCallback {
    
    // MARK: - Properties
    private let currentChatMessageMapper: MessageMapper
    private var currentChat: ChatItem?
    private let readBeforeTimestampString = "read_before_timestamp"
    private weak var messageHolder: MessageHolder?
    private weak var messageStream: MessageStreamImpl?
    private weak var historyPoller: HistoryPoller?
    
    // MARK: - Initialization
    init(currentChatMessageMapper: MessageMapper) {
        self.currentChatMessageMapper = currentChatMessageMapper
    }
    
    // MARK: - Methods
    
    func set(messageStream: MessageStreamImpl,
             messageHolder: MessageHolder,
             historyPoller: HistoryPoller) {
        self.messageStream = messageStream
        self.messageHolder = messageHolder
        self.historyPoller = historyPoller
    }
    
    func process(deltaList: [DeltaItem]) {
        for delta in deltaList {
            guard let deltaType = delta.getDeltaType() else {
                continue
            }
            
            switch deltaType {
            case .chat:
                handleChatUpdateBy(delta: delta)
                
                break
            case .chatMessage:
                handleChatMessageUpdateBy(delta: delta)
                
                break
            case .chatOperator:
                handleChatOperatorUpdateBy(delta: delta)
                
                break
            case .chatOperatorTyping:
                handleChatOperatorTypingUpdateBy(delta: delta)
                
                break
            case .chatReadByVisitor:
                handleChatReadByVisitorUpdateBy(delta: delta)
                
                break
            case .chatState:
                handleChatStateUpdateBy(delta: delta)
                
                break
            case .chatUnreadByOperatorTimestamp:
                handleUnreadByOperatorTimestampUpdateBy(delta: delta)
                
                break
            case .departmentList:
                handleDepartmentListUpdateBy(delta: delta)
                
                break
            case .historyRevision:
                handleHistoryRevisionUpdateBy(delta: delta)
                
                break
            case .operatorRate:
                handleOperatorRateUpdateBy(delta: delta)
                
                break
            case .unreadByVisitor:
                handleUnreadByVisitorUpdateBy(delta: delta)
                
                break
            case .visitSessionState:
                handleVisitSessionStateUpdateBy(delta: delta)
                
                break
            case .chatMessageRead:
                handleMessageRead(delta: delta)
                break
            default:
                // Not supported delta type.
                
                break
            }
        }
    }
    
    func process(fullUpdate: FullUpdate) {
        if let visitSessionState = fullUpdate.getState() {
            messageStream?.set(visitSessionState: (VisitSessionStateItem(rawValue: visitSessionState) ?? .unknown))
        }
        
        if let departments = fullUpdate.getDepartments() {
            messageStream?.onReceiving(departmentItemList: departments)
        }
        
        currentChat = fullUpdate.getChat()
        
        messageStream?.changingChatStateOf(chat: currentChat)
        messageStream?.saveLocationSettingsOn(fullUpdate: fullUpdate)
        
        if let revision = fullUpdate.getHistoryRevision() {
            historyPoller?.set(hasHistoryRevision: true)
            historyPoller?.requestHistory(since: revision)
        }
        
        if let onlineStatusString = fullUpdate.getOnlineStatus() {
            if let onlineStatus = OnlineStatusItem(rawValue: onlineStatusString) {
                messageStream?.onOnlineStatusChanged(to: onlineStatus)
            }
        }
        
        if currentChat != nil {
            for messageItem in (currentChat?.getMessages())! {
                if let message = currentChatMessageMapper.map(message: messageItem) {
                    if (message.getType() == MessageType.FILE_FROM_VISITOR || message.getType() != MessageType.VISITOR) && message.isReadByOperator() {
                        let time = message.getTimeInMicrosecond()
                        if time > Int64(UserDefaults.standard.integer(forKey: readBeforeTimestampString)) {
                            UserDefaults.standard.set(time, forKey: readBeforeTimestampString)
                            historyPoller?.updateReadBeforeTimestamp(timestamp: time)
                        }
                    }
                }
            }
        } else {
            UserDefaults.standard.set(-1, forKey: readBeforeTimestampString)
        }
    }
    
    // MARK: Private methods
    
    private func handleChatUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let deltaData = delta.getData() as? [String : Any?] else {
                return
        }
        
        currentChat = ChatItem(jsonDictionary: deltaData)
        messageStream?.changingChatStateOf(chat: currentChat)
    }
    
    private func handleChatMessageUpdateBy(delta: DeltaItem) {
        let deltaEvent = delta.getEvent()
        let deltaID = delta.getID()
        
        if deltaEvent == .delete {
            if currentChat != nil {
                var currentChatMessages = currentChat!.getMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getID() == deltaID { // Deleted message ID is passed as delta ID.
                        currentChatMessages.remove(at: currentChatMessageIndex)
                        currentChat!.set(messages: currentChatMessages)
                        
                        break
                    }
                }
            }
            
            messageHolder?.deletedMessageWith(id: deltaID)
        } else {
            guard let deltaData = delta.getData() as? [String : Any] else {
                return
            }
            
            let messageItem = MessageItem(jsonDictionary: deltaData)
            let message = currentChatMessageMapper.map(message: messageItem)
            if deltaEvent == .add {
                var isNewMessage = false
                if currentChat != nil && !currentChat!.getMessages().contains(messageItem) {
                    currentChat?.add(message: messageItem)
                    isNewMessage = true
                }
                
                if isNewMessage && message != nil {
                    messageHolder?.receive(newMessage: message!)
                }
                
            } else if deltaEvent == .update {
                if currentChat != nil {
                    var currentChatMessages = currentChat!.getMessages()
                    for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                        if currentChatMessage.getID() == messageItem.getID() {
                            currentChatMessages[currentChatMessageIndex] = messageItem
                            
                            break
                        }
                    }
                }
                
                if message != nil {
                    messageHolder?.changed(message: message!)
                }
            }
        }
    }
    
    
    private func handleMessageRead(delta: DeltaItem) {
        let deltaEvent = delta.getEvent()
        let deltaId = delta.getID()
        
        if let isRead = delta.getData() as? Bool, deltaEvent == .update {
            if currentChat != nil {
                var currentChatMessages = currentChat!.getMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getID() == deltaId {
                        currentChatMessage.setRead(read: isRead)
                        guard let message = currentChatMessageMapper.map(message: currentChatMessage) else {
                            return
                        }
                        currentChatMessages[currentChatMessageIndex] = currentChatMessage
                        messageHolder?.changed(message: message)
                        let time = message.getTimeInMicrosecond()
                        if time > UserDefaults.standard.integer(forKey: "readBeforeTimestampString") {
                            UserDefaults.standard.set(time, forKey: "readBeforeTimestampString")
                            historyPoller?.updateReadBeforeTimestamp(timestamp: time)
                        }
                        break
                    }
                }
            }
        }
    }
    
    private func handleChatOperatorUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let deltaData = delta.getData() as? [String : Any] else {
                return
        }
        
        if let operatorItem = OperatorItem(jsonDictionary: deltaData) {
            currentChat?.set(operator: operatorItem)
            
            messageStream?.changingChatStateOf(chat: currentChat)
        }
    }
    
    private func handleChatOperatorTypingUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let operatorTyping = delta.getData() as? Bool else {
                return
        }
        
        currentChat?.set(operatorTyping: operatorTyping)
        messageStream?.changingChatStateOf(chat: currentChat)
    }
    
    private func handleChatReadByVisitorUpdateBy(delta: DeltaItem) {
        guard let readByVisitor = delta.getData() as? Bool,
            delta.getEvent() == .update else {
                return
        }
        
        currentChat?.set(readByVisitor: readByVisitor)
        
        if readByVisitor {
            currentChat?.set(unreadByVisitorTimestamp: nil)
            currentChat?.set(unreadByVisitorMessageCount: 0)
            messageStream?.set(unreadByVisitorTimestamp: nil)
            messageStream?.set(unreadByVisitorMessageCount: 0)
        }
    }
    
    private func handleChatStateUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let chatState = delta.getData() as? String else {
                return
        }
        
        currentChat?.set(state: ChatItem.ChatItemState(withType: chatState))
        
        messageStream?.changingChatStateOf(chat: currentChat)
    }
    
    private func handleUnreadByOperatorTimestampUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update else {
            return
        }
        
        var unreadByOperatorTimestamp: Double?
        if delta.getData() != nil {
            unreadByOperatorTimestamp = delta.getData() as? Double
        }
        currentChat?.set(unreadByOperatorTimestamp: unreadByOperatorTimestamp)
        messageStream?.set(unreadByOperatorTimestamp: (unreadByOperatorTimestamp != nil ? Date(timeIntervalSince1970: unreadByOperatorTimestamp!) : nil))
    }
    
    private func handleDepartmentListUpdateBy(delta: DeltaItem) {
        guard let deltaData = delta.getData() as? [Any] else {
            return
        }
        
        var departmentItems = [DepartmentItem]()
        for departmentData in deltaData {
            if let departmentDictionary = departmentData as? [String: Any] {
                if let deparmentItem = DepartmentItem(jsonDictionary: departmentDictionary) {
                    departmentItems.append(deparmentItem)
                }
            }
        }
        
        messageStream?.onReceiving(departmentItemList: departmentItems)
    }
    
    private func handleHistoryRevisionUpdateBy(delta: DeltaItem) {
        guard let deltaData = delta.getData() as? [String: Any] else {
            return
        }
        
        if let revisionItem = HistoryRevisionItem(jsonDictionary: deltaData) {
            historyPoller?.requestHistory(since: revisionItem.getRevision())
        }
    }
    
    private func handleOperatorRateUpdateBy(delta: DeltaItem) {
        guard let deltaData = delta.getData() as? [String: Any] else {
            return
        }
        
        if let rating = RatingItem(jsonDictionary: deltaData) {
            if delta.getEvent() == .update {
                currentChat?.set(rating: rating,
                                 toOperatorWithId: rating.getOperatorID())
            }
        }
    }
    
    private func handleUnreadByVisitorUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let unreadByVisitorUpdate = delta.getData() as? [String: Any],
            let unreadByVisitorMessageConut = unreadByVisitorUpdate[DeltaItem.UnreadByVisitorField.messageCount.rawValue] as? Int,
            let unreadByVisitorTimestamp = unreadByVisitorUpdate[DeltaItem.UnreadByVisitorField.timestamp.rawValue] as? Double else {
                return
        }
        currentChat?.set(unreadByVisitorMessageCount: unreadByVisitorMessageConut)
        messageStream?.set(unreadByVisitorTimestamp: Date(timeIntervalSince1970: unreadByVisitorTimestamp))
        messageStream?.set(unreadByVisitorMessageCount: unreadByVisitorMessageConut)
    }
    
    private func handleVisitSessionStateUpdateBy(delta: DeltaItem) {
        guard let sessionState = delta.getData() as? String else {
            return
        }
        
        if sessionState == VisitSessionStateItem.offlineMessage.rawValue {
            messageStream?.set(onlineStatus: .offline)
            messageStream?.getWebimActions().closeChat()
        }
        
        if delta.getEvent() == .update {
            messageStream?.set(visitSessionState: (VisitSessionStateItem(rawValue: sessionState) ?? .unknown))
        }
    }
    
}
