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
    private let historyMessageMapper: MessageMapper
    private var currentChat: ChatItem?
    private let userDefaultsKey: String
    private weak var messageHolder: MessageHolder?
    private weak var messageStream: MessageStreamImpl?
    private weak var historyPoller: HistoryPoller?
    
    // MARK: - Initialization
    init(currentChatMessageMapper: MessageMapper,
         historyMessageMapper: MessageMapper,
         userDefaultsKey: String) {
        self.currentChatMessageMapper = currentChatMessageMapper
        self.historyMessageMapper = historyMessageMapper
        self.userDefaultsKey = userDefaultsKey
    }
    
    // MARK: - Methods
    
    func set(messageStream: MessageStreamImpl,
             messageHolder: MessageHolder,
             historyPoller: HistoryPoller) {
        self.messageStream = messageStream
        self.messageHolder = messageHolder
        self.historyPoller = historyPoller
    }
    
    func set(accountConfig: AccountConfigItem?) {
        self.currentChatMessageMapper.set(accountConfig: accountConfig)
        self.historyMessageMapper.set(accountConfig: accountConfig)
    }
    
    func process(deltaList: [DeltaItem]) {
        for delta in deltaList {
            guard let deltaType = delta.getDeltaType() else {
                continue
            }
            
            switch deltaType {
            case .chat:
                handleChatUpdateBy(delta: delta)
                
            case .chatMessage:
                handleChatMessageUpdateBy(delta: delta)
                
            case .chatOperator:
                handleChatOperatorUpdateBy(delta: delta)
                
            case .chatOperatorTyping:
                handleChatOperatorTypingUpdateBy(delta: delta)
                
            case .chatReadByVisitor:
                handleChatReadByVisitorUpdateBy(delta: delta)
                
            case .chatState:
                handleChatStateUpdateBy(delta: delta)
                
            case .chatUnreadByOperatorTimestamp:
                handleUnreadByOperatorTimestampUpdateBy(delta: delta)
                
            case .departmentList:
                handleDepartmentListUpdateBy(delta: delta)
                
            case .historyRevision:
                handleHistoryRevisionUpdateBy(delta: delta)
                
            case .operatorRate:
                handleOperatorRateUpdateBy(delta: delta)
                
            case .survey:
                handleSurveyBy(delta: delta)
                
            case .unreadByVisitor:
                handleUnreadByVisitorUpdateBy(delta: delta)
                
            case .visitSessionState:
                handleVisitSessionStateUpdateBy(delta: delta)
                
            case .chatMessageRead:
                handleMessageRead(delta: delta)
                
            case .chatId:
                handleChatId(delta: delta)
                
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
        
        if let survey = fullUpdate.getSurvey() {
            messageStream?.onReceived(surveyItem: survey)
        }
        
        currentChat = fullUpdate.getChat()
        for message in currentChat?.getMessages() ?? [] {
            WebimInternalLogger.shared.log(entry: "Delta chat: \'\(message.getText() ?? "")\'", verbosityLevel: .debug, logType: .messageHistory)
        }
        
        var isCurrentChatEmpty = true
        if let currentChat = currentChat,
           !currentChat.getMessages().isEmpty {
            isCurrentChatEmpty = false
        }
        
        messageStream?.changingChatStateOf(chat: currentChat)
        messageStream?.saveLocationSettingsOn(fullUpdate: fullUpdate)
        messageStream?.handleHelloMessage(showHelloMessage: fullUpdate.getShowHelloMessage(),
                                          chatStartAfterMessage: fullUpdate.getChatStartAfterMessage(),
                                          currentChatEmpty: isCurrentChatEmpty,
                                          helloMessageDescr: fullUpdate.getHelloMessageDescr())
        
        if let revision = fullUpdate.getHistoryRevision() {
            historyPoller?.set(hasHistoryRevision: true)
            historyPoller?.requestHistory(since: revision)
        }
        
        if let onlineStatusString = fullUpdate.getOnlineStatus() {
            if let onlineStatus = OnlineStatusItem(rawValue: onlineStatusString) {
                messageStream?.onOnlineStatusChanged(to: onlineStatus)
            }
        }
        
        if let currentChat = currentChat {
            for messageItem in (currentChat.getMessages()) {
                if let message = currentChatMessageMapper.map(message: messageItem) {
                    if (message.getType() == MessageType.fileFromVisitor || message.getType() != MessageType.visitorMessage) && message.isReadByOperator() {
                        let time = message.getTimeInMicrosecond()
                        if time > historyPoller?.getReadBeforeTimestamp(byWMKeychainWrapperKey: userDefaultsKey) ?? -1 {
                            historyPoller?.updateReadBeforeTimestamp(timestamp: time, byWMKeychainWrapperKey: userDefaultsKey)
                        }
                    }
                }
            }
        } else {
            historyPoller?.updateReadBeforeTimestamp(timestamp: -1, byWMKeychainWrapperKey: userDefaultsKey)
        }
    }
    
    // MARK: Private methods
    
    private func handleChatUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let deltaData = delta.getData() as? [String : Any?] else {
            messageStream?.changingChatStateOf(chat: nil)
            currentChat?.set(messages: [MessageItem]())
            return
        }
        
        currentChat = ChatItem(jsonDictionary: deltaData)
        
        switch currentChat?.getState() {
        case .closed,
             .unknown,
             .none:
            handleClosedChat()
            break
        default:
            break
        }
        for message in currentChat?.getMessages() ?? [] {
            if let messageItem = historyMessageMapper.map(message: message) {
                historyPoller?.insertMessageInDB(message: messageItem)
            }
            WebimInternalLogger.shared.log(entry: "Delta chat: \'\(message.getText() ?? "")\'", verbosityLevel: .debug, logType: .messageHistory)
        }
        messageStream?.changingChatStateOf(chat: currentChat)
    }
    
    private func handleChatMessageUpdateBy(delta: DeltaItem) {
        let deltaEvent = delta.getEvent()
        let deltaID = delta.getID()
        
        if deltaEvent == .delete {
            var historyMessage: MessageImpl? = nil
            if let currentChat = currentChat {
                var currentChatMessages = currentChat.getMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getServerSideID() == deltaID { // Deleted message ID is passed as delta ID.
                        currentChatMessages.remove(at: currentChatMessageIndex)
                        currentChat.set(messages: currentChatMessages)
                        historyMessage = historyMessageMapper.map(message: currentChatMessage)
                        
                        break
                    }
                }
            }
            
            messageHolder?.deletedMessageWith(id: deltaID)
            if let historyMessage = historyMessage {
                historyPoller?.deleteMessageFromDB(message: historyMessage.getServerSideID() ?? historyMessage.getID())
            }
        } else {
            guard let deltaData = delta.getData() as? [String : Any] else {
                return
            }
            
            let messageItem = MessageItem(jsonDictionary: deltaData)
            let message = currentChatMessageMapper.map(message: messageItem)
            let historyMessage = historyMessageMapper.map(message: messageItem)
            WebimInternalLogger.shared.log(entry: "Delta message: \'\(message?.getText() ?? "")\'", verbosityLevel: .debug, logType: .messageHistory)
            if deltaEvent == .add {
                var isNewMessage = false
                if let currentChat = currentChat,
                    !currentChat.getMessages().contains(messageItem) {
                    currentChat.add(message: messageItem)
                    isNewMessage = true
                }
                
                if isNewMessage,
                    let message = message {
                    messageHolder?.receive(newMessage: message)
                    if let historyMessage = historyMessage {
                        historyPoller?.insertMessageInDB(message: historyMessage)
                    }
                }
                
                
            } else if deltaEvent == .update {
                if let currentChat = currentChat {
                    var currentChatMessages = currentChat.getMessages()
                    for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                        if currentChatMessage.getServerSideID() == messageItem.getServerSideID() {
                            currentChatMessages[currentChatMessageIndex] = messageItem
                            currentChat.set(messages: currentChatMessages)
                            
                            break
                        }
                    }
                }
                
                if let message = message {
                    messageHolder?.changed(message: message)
                    if let historyMessage = historyMessage {
                        historyPoller?.insertMessageInDB(message: historyMessage)
                    }
                }
            }
        }
    }
    
    
    private func handleMessageRead(delta: DeltaItem) {
        let deltaEvent = delta.getEvent()
        let deltaId = delta.getID()
        
        if let isRead = delta.getData() as? Bool, deltaEvent == .update {
            if let currentChat = currentChat {
                var currentChatMessages = currentChat.getMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getServerSideID() == deltaId {
                        currentChatMessage.setRead(read: isRead)
                        guard let message = currentChatMessageMapper.map(message: currentChatMessage) else {
                            return
                        }
                        currentChatMessages[currentChatMessageIndex] = currentChatMessage
                        currentChat.set(messages: currentChatMessages)
                        messageHolder?.changed(message: message)
                        let time = message.getTimeInMicrosecond()
                        if time > historyPoller?.getReadBeforeTimestamp(byWMKeychainWrapperKey: userDefaultsKey) ?? -1 {
                            historyPoller?.updateReadBeforeTimestamp(timestamp: time, byWMKeychainWrapperKey: userDefaultsKey)
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
                currentChat?.set(operator: nil)
                messageStream?.changingChatStateOf(chat: currentChat)
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
        
        switch currentChat?.getState() {
        case .closed,
             .unknown,
             .none:
            handleClosedChat()
            break
        default:
            break
        }
        
        messageStream?.changingChatStateOf(chat: currentChat)
    }
    
    private func handleUnreadByOperatorTimestampUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update else {
            return
        }
        
        var unreadByOperatorTimestamp: Double?
        if let deltaData = delta.getData() as? Double {
            unreadByOperatorTimestamp = deltaData
        }
        currentChat?.set(unreadByOperatorTimestamp: unreadByOperatorTimestamp)
        if let timestamp = unreadByOperatorTimestamp {
            messageStream?.set(unreadByOperatorTimestamp: Date(timeIntervalSince1970:timestamp))
        } else {
            messageStream?.set(unreadByOperatorTimestamp: nil)
        }
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
        
        let revisionItem = HistoryRevisionItem(jsonDictionary: deltaData)
        historyPoller?.requestHistory(since: revisionItem.getRevision())
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
    
    private func handleSurveyBy(delta: DeltaItem) {
        if let deltaData = delta.getData() as? [String: Any] {
            messageStream?.onReceived(surveyItem: SurveyItem(jsonDictionary: deltaData))
        } else {
            messageStream?.onSurveyCancelled()
        }
    }
    
    private func handleUnreadByVisitorUpdateBy(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let unreadByVisitorUpdate = delta.getData() as? [String: Any],
            let unreadByVisitorMessageCount = unreadByVisitorUpdate[DeltaItem.UnreadByVisitorField.messageCount.rawValue] as? Int else {
                return
        }
        currentChat?.set(unreadByVisitorMessageCount: unreadByVisitorMessageCount)
        messageStream?.set(unreadByVisitorMessageCount: unreadByVisitorMessageCount)
        
        if let unreadByVisitorTimestamp = unreadByVisitorUpdate[DeltaItem.UnreadByVisitorField.timestamp.rawValue] as? Double {
            messageStream?.set(unreadByVisitorTimestamp: Date(timeIntervalSince1970: unreadByVisitorTimestamp))
        }
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
    
    private func handleClosedChat() {
        currentChat?.set(operator: nil)
        currentChat?.set(operatorTyping: false)
    }
    
    private func handleChatId(delta: DeltaItem) {
        guard delta.getEvent() == .update,
            let id = delta.getData() as? Int else {
                return
        }
        
        currentChat?.set(id: id)
    }
}
