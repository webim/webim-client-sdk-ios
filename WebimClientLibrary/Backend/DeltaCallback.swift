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
 - SeeAlso:
 `DeltaResponse`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class DeltaCallback {
    
    // MARK: - Properties
    private let currentChatMessageMapper: MessageFactoriesMapper
    private var currentChat: ChatItem?
    private var messageHolder: MessageHolder?
    private var messageStream: MessageStreamImpl?
    
    // MARK: - Initialization
    init(currentChatMessageMapper: MessageFactoriesMapper) {
        self.currentChatMessageMapper = currentChatMessageMapper
    }
    
    // MARK: - Methods
    
    func set(messageStream: MessageStreamImpl,
             messageHolder: MessageHolder) {
        self.messageStream = messageStream
        self.messageHolder = messageHolder
    }
    
    func process(deltaList: [DeltaItem]) {
        guard messageStream != nil,
            messageHolder != nil else {
                return
        }
        
        for delta in deltaList {
            let deltaType = delta.getDeltaType()
            guard deltaType != nil else {
                continue
            }
            
            switch deltaType! {
            case .chat:
                handleChatUpdateBy(delta: delta,
                                   messageStream: messageStream!)
                
                break
            case .chatMessage:
                handleChatMessageUpdateBy(delta: delta,
                                          messageStream: messageStream!,
                                          messageHolder: messageHolder!,
                                          currentChatMessageMapper: currentChatMessageMapper)
                
                break
            case .chatOperator:
                handleChatOperatorUpdateBy(delta: delta,
                                           messageStream: messageStream!)
                
                break
            case .chatOperatorTyping:
                handleChatOperatorTypingUpdateBy(delta: delta,
                                                 messageStream: messageStream!)
                
                break
            case .chatReadByVisitor:
                handleChatReadByVisitorUpdateBy(delta: delta,
                                                messageStream: messageStream!)
                
                break
            case .statState:
                handleChatStateUpdateBy(delta: delta,
                                        messageStream: messageStream!)
                
                break
            case .chatUnreadByOperatorTimestamp:
                handleUnreadByOperatorTimestampUpdateBy(delta: delta,
                                                        messageStream: messageStream!)
                
                break
            case .departmentList:
                handleDepartmentListUpdateBy(delta: delta,
                                             messageStream: messageStream!)
                
                break
            case .operatorRate:
                handleOperatorRateUpdateBy(delta: delta,
                                           messageStream: messageStream!)
                
                break
            case .visitSessionState:
                handleVisitSessionStateUpdateBy(delta: delta,
                                                messageStream: messageStream!)
                
                break
            default:
                // Not supported delta type.
                
                break
            }
        }
    }
    
    func process(fullUpdate: FullUpdate) {
        guard messageStream != nil else {
            return
        }
        
        if let visitSessionState = fullUpdate.getState() {
            messageStream!.set(visitSessionState: (VisitSessionStateItem(rawValue: visitSessionState) ?? .unknown))
        }
        
        if let departments = fullUpdate.getDepartments() {
            messageStream!.onReceiving(departmentItemList: departments)
        }
        
        currentChat = fullUpdate.getChat()
        
        messageStream!.changingChatStateOf(chat: currentChat)
        
        messageStream!.saveLocationSettingsOn(fullUpdate: fullUpdate)
        
        if let onlineStatusString = fullUpdate.getOnlineStatus() {
            if let onlineStatus = OnlineStatusItem(rawValue: onlineStatusString) {
                messageStream!.onOnlineStatusChanged(to: onlineStatus)
            }
        }
    }
    
    // MARK: Private methods
    
    private func handleChatUpdateBy(delta: DeltaItem,
                                    messageStream: MessageStreamImpl) {
        guard delta.getEvent() == .update,
            let deltaData = delta.getData() as? [String: Any?] else {
                return
        }
        
        currentChat = ChatItem(jsonDictionary: deltaData)
        messageStream.changingChatStateOf(chat: currentChat)
    }
    
    private func handleChatMessageUpdateBy(delta: DeltaItem,
                                           messageStream: MessageStreamImpl,
                                           messageHolder: MessageHolder,
                                           currentChatMessageMapper: MessageFactoriesMapper) {
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
            
            messageHolder.deletedMessageWith(id: deltaID)
        } else {
            guard let deltaData = delta.getData() as? [String: Any?] else {
                return
            }
            
            let messageItem = MessageItem(jsonDictionary: deltaData)
            let message = currentChatMessageMapper.map(message: messageItem)
            if deltaEvent == .add {
                currentChat?.add(message: messageItem)
                
                if message != nil {
                    messageHolder.receive(newMessage: message!)
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
                    messageHolder.changed(message: message!)
                }
            }
        }
    }
    
    private func handleChatOperatorUpdateBy(delta: DeltaItem,
                                            messageStream: MessageStreamImpl) {
        guard delta.getEvent() == .update,
            let deltaData = delta.getData() as? [String: Any?] else {
                return
        }
        
        if let operatorItem = OperatorItem(jsonDictionary: deltaData) {
            currentChat?.set(operator: operatorItem)
            
            messageStream.changingChatStateOf(chat: currentChat)
        }
    }
    
    private func handleChatOperatorTypingUpdateBy(delta: DeltaItem,
                                                  messageStream: MessageStreamImpl) {
        guard delta.getEvent() == .update,
            let operatorTyping = delta.getData() as? Bool else {
                return
        }
        
        currentChat?.set(operatorTyping: operatorTyping)
        messageStream.changingChatStateOf(chat: currentChat)
    }
    
    private func handleChatReadByVisitorUpdateBy(delta: DeltaItem,
                                                 messageStream: MessageStreamImpl) {
        guard let readByVisitor = delta.getData() as? Bool,
            delta.getEvent() == .update else {
                return
        }
        
        currentChat?.set(readByVisitor: readByVisitor)
        
        if readByVisitor {
            messageStream.set(unreadByVisitorTimestamp: nil)
        }
    }
    
    private func handleChatStateUpdateBy(delta: DeltaItem,
                                         messageStream: MessageStreamImpl) {
        guard delta.getEvent() == .update,
            let chatState = delta.getData() as? String else {
                return
        }
        
        currentChat?.set(state: ChatItem.ChatItemState(rawValue: chatState)!)
        
        messageStream.changingChatStateOf(chat: currentChat)
    }
    
    private func handleDepartmentListUpdateBy(delta: DeltaItem,
                                              messageStream: MessageStreamImpl) {
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
        
        messageStream.onReceiving(departmentItemList: departmentItems)
    }
    
    private func handleUnreadByOperatorTimestampUpdateBy(delta: DeltaItem,
                                                         messageStream: MessageStreamImpl) {
        guard delta.getEvent() == .update else {
            return
        }
        
        var unreadByOperatorTimestamp: Double?
        if delta.getData() != nil {
            unreadByOperatorTimestamp = delta.getData() as? Double
        }
        currentChat?.set(unreadByOperatorTimestamp: unreadByOperatorTimestamp)
        messageStream.set(unreadByOperatorTimestamp: (unreadByOperatorTimestamp != nil ? Date(timeIntervalSince1970: unreadByOperatorTimestamp!) : nil))
    }
    
    private func handleOperatorRateUpdateBy(delta: DeltaItem,
                                            messageStream: MessageStreamImpl) {
        guard let deltaData = delta.getData() as? [String: Any?] else {
            return
        }
        
        if let rating = RatingItem(jsonDictionary: deltaData) {
            if delta.getEvent() == .update {
                currentChat?.set(rating: rating,
                                 toOperatorWithId: rating.getOperatorID())
            }
        }
    }
    
    private func handleVisitSessionStateUpdateBy(delta: DeltaItem,
                                                 messageStream: MessageStreamImpl) {
        guard let sessionState = delta.getData() as? String else {
            return
        }
        
        if sessionState == VisitSessionStateItem.offlineMessage.rawValue {
            messageStream.set(onlineStatus: .offline)
            messageStream.getWebimActions().closeChat()
        }
        
        if delta.getEvent() == .update {
            messageStream.set(visitSessionState: (VisitSessionStateItem(rawValue: sessionState) ?? .unknown))
        }
    }
    
}
