//
//  MessageHolder.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 20.10.17.
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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MessageHolder {
    
    // MARK: - Properties
    private let accessChecker: AccessChecker
    private let historyStorage: HistoryStorage
    private let remoteHistoryProvider: RemoteHistoryProvider
    private lazy var currentChatMessages = [MessageImpl]()
    private var lastChatMessageIndex = 0
    private lazy var messagesToSend = [MessageToSend]()
    private var messageTracker: MessageTrackerImpl?
    private var currentChatMessagesWereReceived = false
    private var reachedEndOfLocalHistory = false
    private var reachedEndOfRemoteHistory: Bool
    
    // MARK: - Initialization
    init(accessChecker: AccessChecker,
         remoteHistoryProvider: RemoteHistoryProvider,
         historyStorage: HistoryStorage,
         reachedEndOfRemoteHistory: Bool) {
        self.accessChecker = accessChecker
        self.remoteHistoryProvider = remoteHistoryProvider
        self.historyStorage = historyStorage
        self.reachedEndOfRemoteHistory = reachedEndOfRemoteHistory
    }
    
    // MARK: - Methods
    
    func checkAccess() throws {
        try accessChecker.checkAccess()
    }
    
    func getCurrentChatMessages() -> [MessageImpl] {
        return currentChatMessages
    }
    
    func set(currentChatMessages: [MessageImpl]) {
        self.currentChatMessages = currentChatMessages
    }
    
    func getMessagesToSend() -> [MessageToSend] {
        return messagesToSend
    }
    
    func removeFromMessagesToSendAt(index: Int) {
        messagesToSend.remove(at: index)
    }
    
    func set(messagesToSend: [MessageToSend]) {
        self.messagesToSend = messagesToSend
    }
    
    func getCurrentChatMessagesWereReceived() -> Bool {
        return currentChatMessagesWereReceived
    }
    
    func set(currentChatMessagesWereReceived: Bool) {
        self.currentChatMessagesWereReceived = currentChatMessagesWereReceived
    }
    
    func getLatestMessages(byLimit limitOfMessages: Int,
                           completion: @escaping ([Message]) -> ()) {
        if !currentChatMessages.isEmpty {
            respondTo(messages: currentChatMessages,
                      limitOfMessages: limitOfMessages,
                      completion: completion)
        } else {
            historyStorage.getLatestHistory(byLimit: limitOfMessages,
                                            completion: completion)
        }
    }
    
    func getMessagesBy(limit: Int,
                       before message: MessageImpl,
                       completion: @escaping ([Message]) -> ()) {
        if message.getSource().isCurrentChatMessage() {
            if currentChatMessages.isEmpty {
                WebimInternalLogger.shared.log(entry: "Current chat is empty. Requesting history rejected.",
                                               verbosityLevel: .verbose)
                
                completion([Message]())
                
                return
            }
            
            guard let firstMessage = currentChatMessages.first else {
                WebimInternalLogger.shared.log(entry: "Current chat has not first message in MessageHolder.\(#function)")
                return
            }
            if message == firstMessage {
                if !firstMessage.hasHistoryComponent() {
                    currentChatMessagesWereReceived = true
                    historyStorage.getLatestHistory(byLimit: limit,
                                                    completion: completion)
                } else {
                    guard let historyID = firstMessage.getHistoryID() else {
                        WebimInternalLogger.shared.log(entry: "First mesage of current chat has not hitory ID in MessageHolder.\(#function)")
                        return
                    }
                    getMessagesFromHistoryBefore(id: historyID,
                                                 limit: limit,
                                                 completion: completion)
                }
            } else {
                getMessagesFromCurrentChatBefore(message: message,
                                                 limit: limit,
                                                 completion: completion)
            }
        } else {
            guard let historyID = message.getHistoryID() else {
                WebimInternalLogger.shared.log(entry: "Mesage of current chat has not hitory ID in MessageHolder.\(#function)")
                return
            }
            getMessagesFromHistoryBefore(id: historyID,
                                         limit: limit,
                                         completion: completion)
        }
    }
    
    func set(messageTracker: MessageTrackerImpl?) {
        self.messageTracker = messageTracker
    }
    
    func getHistoryStorage() -> HistoryStorage {
        return historyStorage
    }
    
    func set(reachedEndOfLocalHistory: Bool) {
        self.reachedEndOfLocalHistory = reachedEndOfLocalHistory
    }
    
    func getReachedEndOfRemoteHistory() -> Bool {
        return reachedEndOfRemoteHistory
    }
    
    func newMessageTracker(withMessageListener messageListener: MessageListener) throws -> MessageTrackerImpl {
        try messageTracker?.destroy()
        
        let messageTracker = MessageTrackerImpl(messageListener: messageListener,
                                                messageHolder: self)
        
        set(messageTracker: messageTracker)
        
        return messageTracker
    }
    
    func receiveHistoryUpdateWith(messages: [MessageImpl],
                                  deleted: Set<String>,
                                  completion: @escaping () -> ()) {
        historyStorage.receiveHistoryUpdate(withMessages: messages,
                                            idsToDelete: deleted) { [weak self] (endOfBatch: Bool, messageDeleted: Bool, deletedMessageID: String?, messageChanged: Bool, changedMessage: MessageImpl?, messageAdded: Bool, addedMessage: MessageImpl?, idBeforeAddedMessage: HistoryID?) -> () in
                                                if endOfBatch {
                                                    self?.messageTracker?.endedHistoryBatch()
                                                    self?.reachedEndOfRemoteHistory = true
                                                    
                                                    completion()
                                                }
                                                
                                                if messageDeleted {
                                                    guard let deletedMessageID = deletedMessageID else {
                                                        WebimInternalLogger.shared.log(entry: "Deleted Message ID is nil in MessageHolder.\(#function)")
                                                        return
                                                    }
                                                    self?.messageTracker?.deletedHistoryMessage(withID: deletedMessageID)
                                                }
                                                
                                                if messageChanged {
                                                    guard let changedMessage = changedMessage else {
                                                        WebimInternalLogger.shared.log(entry: "Changed Message is nil in MessageHolder.\(#function)")
                                                        return
                                                    }
                                                    self?.messageTracker?.changedHistory(message: changedMessage)
                                                }
                                                
                                                if messageAdded {
                                                    guard let addedMessage = addedMessage else {
                                                        WebimInternalLogger.shared.log(entry: "Added Message is nil in MessageHolder.\(#function)")
                                                        return
                                                    }
                                                    if (self?.tryMergeWithLastChat(message: addedMessage) != true) {
                                                        self?.messageTracker?.addedHistory(message: addedMessage,
                                                                                           before: idBeforeAddedMessage)
                                                    }
                                                }
        }
    }
    
    func receiving(newChat: ChatItem?,
                   previousChat: ChatItem?,
                   newMessages: [MessageImpl]) {
        if currentChatMessages.isEmpty {
            receive(newMessages: newMessages)
        } else {
            if newChat == nil {
                historifyCurrentChat()
            } else if (previousChat == nil) ||
                (newChat != previousChat) {
                historifyCurrentChat()
                
                receive(newMessages: newMessages)
            } else {
                mergeCurrentChatWith(newMessages: newMessages)
            }
        }
    }
    
    func receive(newMessage: MessageImpl) {
        if let messageTracker = messageTracker {
            messageTracker.addedNew(message: newMessage,
                                    of: self)
        } else {
            currentChatMessages.append(newMessage)
        }
    }
    
    func changed(message: MessageImpl) {
        for messageIndex in lastChatMessageIndex ..< currentChatMessages.count {
            let previousVersion = currentChatMessages[messageIndex]
            if previousVersion.getCurrentChatID() == message.getCurrentChatID() {
                currentChatMessages[messageIndex] = message
                
                messageTracker?.changedCurrentChatMessage(from: previousVersion,
                                                          to: message,
                                                          at: messageIndex,
                                                          of: self)
            
                return
            }
        }
    }
    
    func deletedMessageWith(id: String) {
        for messageIndex in lastChatMessageIndex ..< currentChatMessages.count {
            let message = currentChatMessages[messageIndex]
            if message.getCurrentChatID() == id {
                currentChatMessages.remove(at: messageIndex)
                
                messageTracker?.deletedCurrentChat(message: message,
                                                   at: messageIndex,
                                                   messageHolder: self)
                
                return
            }
        }
    }
    
    func sending(message: MessageToSend) {
        messagesToSend.append(message)
        
        messageTracker?.messageListener?.added(message: message,
                                               after: nil)
    }
    
    func sendingCancelledWith(messageID: String) {
        for messageIndex in 0 ..< messagesToSend.count {
            if messagesToSend[messageIndex].getID() == messageID {
                let message = messagesToSend[messageIndex]
                
                messagesToSend.remove(at: messageIndex)
                
                messageTracker?.messageListener?.removed(message: message)
                
                return
            }
        }
    }
    
    func changing(messageID: String, message: String?) -> String? {
        if messageTracker == nil {
            return nil
        }
        var optionamMessageImpl: MessageImpl? = nil
        
        for curr in currentChatMessages {
            if curr.getID() == messageID {
                optionamMessageImpl = curr
                break
            }
        }
        
        guard let messageImpl = optionamMessageImpl else {
            WebimInternalLogger.shared.log(entry: "Current Message is nil in MessageHolder.\(#function)")
            return String()
        }
        
        let newMessage = MessageImpl(serverURLString: messageImpl.getServerUrlString(),
                                     id: messageID,
                                     keyboard: messageImpl.getKeyboard(),
                                     keyboardRequest: messageImpl.getKeyboardRequest(),
                                     operatorID: messageImpl.getOperatorID(),
                                     quote: messageImpl.getQuote(),
                                     senderAvatarURLString: messageImpl.getSenderAvatarURLString(),
                                     senderName: messageImpl.getSenderName(),
                                     sendStatus: .sending,
                                     sticker: messageImpl.getSticker(),
                                     type: messageImpl.getType(),
                                     rawData: messageImpl.getRawData(),
                                     data: messageImpl.getData(),
                                     text: message ?? messageImpl.getText(),
                                     timeInMicrosecond: messageImpl.getTimeInMicrosecond(),
                                     historyMessage: messageImpl.getSource().isHistoryMessage(),
                                     internalID: messageImpl.getCurrentChatID(),
                                     rawText: messageImpl.getRawText(),
                                     read: messageImpl.isReadByOperator(),
                                     messageCanBeEdited: messageImpl.canBeEdited(),
                                     messageCanBeReplied: messageImpl.canBeReplied(),
                                     messageIsEdited: messageImpl.isEdited())
        messageTracker?.messageListener?.changed(message: messageImpl, to: newMessage)
        return messageImpl.getText()
    }
    
    func changingCancelledWith(messageID: String, message: String) {
        if messageTracker == nil {
            return
        }
        var optionamMessageImpl: MessageImpl? = nil
        
        for curr in currentChatMessages {
            if curr.getID() == messageID {
                optionamMessageImpl = curr
                break
            }
        }
        
        guard let messageImpl = optionamMessageImpl else {
            WebimInternalLogger.shared.log(entry: "Current Message is nil in MessageHolder.\(#function)")
            return
        }
        
        let newMessage = MessageImpl(serverURLString: messageImpl.getServerUrlString(),
                                     id: messageID,
                                     keyboard: messageImpl.getKeyboard(),
                                     keyboardRequest: messageImpl.getKeyboardRequest(),
                                     operatorID: messageImpl.getOperatorID(),
                                     quote: messageImpl.getQuote(),
                                     senderAvatarURLString: messageImpl.getSenderAvatarURLString(),
                                     senderName: messageImpl.getSenderName(),
                                     sendStatus: .sent,
                                     sticker: messageImpl.getSticker(),
                                     type: messageImpl.getType(),
                                     rawData: messageImpl.getRawData(),
                                     data: messageImpl.getData(),
                                     text: message,
                                     timeInMicrosecond: messageImpl.getTimeInMicrosecond(),
                                     historyMessage: messageImpl.getSource().isHistoryMessage(),
                                     internalID: messageImpl.getCurrentChatID(),
                                     rawText: messageImpl.getRawText(),
                                     read: messageImpl.isReadByOperator(),
                                     messageCanBeEdited: messageImpl.canBeEdited(),
                                     messageCanBeReplied: messageImpl.canBeReplied(),
                                     messageIsEdited: messageImpl.isEdited())
        messageTracker?.messageListener?.changed(message: messageImpl, to: newMessage)
    }
    
    // MARK: For testing purposes.
    
    func getLastChatMessageIndex() -> Int {
        return lastChatMessageIndex
    }
    
    func getRemoteHistoryProvider() -> RemoteHistoryProvider {
        return remoteHistoryProvider
    }
    
    func set(endOfHistoryReached: Bool) {
        reachedEndOfRemoteHistory = endOfHistoryReached
        historyStorage.set(reachedHistoryEnd: endOfHistoryReached)
    }
    
    // MARK: Private methods
    
    private func receive(newMessages: [MessageImpl]) {
        if let messageTracker = messageTracker {
            messageTracker.addedNew(messages: newMessages,
                                    of: self)
        } else {
            for message in newMessages {
                currentChatMessages.append(message)
            }
        }
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           completion: ([Message]) -> ()) {
        completion(messages.isEmpty
            ? [MessageImpl]()
            : (messages.count <= limitOfMessages) ? messages : Array(messages[(messages.count - limitOfMessages) ..< messages.count]))
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           offset: Int,
                           completion: ([Message]) -> ()) {
        let messageList = Array(messages[max(0, (offset - limitOfMessages)) ..< offset])
        completion(messageList)
    }
    
    private func historifyCurrentChat() {
        var newCurrentChatMessages = [MessageImpl]()
        
        for currentChatMessage in currentChatMessages {
            if currentChatMessage.hasHistoryComponent() {
                currentChatMessage.invertHistoryStatus()
                
                if let id = currentChatMessage.getHistoryID()?.getDBid() {
                    if let historyMessage = messageTracker?.idToHistoryMessageMap[id] {
                        historyMessage.setMessageCanBeEdited(messageCanBeEdited: false)
                        if currentChatMessage != historyMessage {
                            messageTracker?.messageListener?.changed(message: currentChatMessage,
                                                                     to: historyMessage)
                        } else {
                            messageTracker?.idToHistoryMessageMap[id] = currentChatMessage
                        }
                    }
                }
            } else {
                newCurrentChatMessages.append(currentChatMessage)
                if currentChatMessage.canBeEdited() {
                    currentChatMessage.setMessageCanBeEdited(messageCanBeEdited: false)
                    messageTracker?.messageListener?.changed(message: currentChatMessage, to: currentChatMessage)
                }
            }
        }
        
        self.set(currentChatMessages: newCurrentChatMessages)
        
        lastChatMessageIndex = currentChatMessages.count
    }
    
    private func requestHistory(beforeID id: HistoryID,
                                limit: Int,
                                completion: @escaping ([Message]) -> ()) {
        remoteHistoryProvider.requestHistory(beforeTimestamp: id.getTimeInMicrosecond(),
                                             completion: { [weak self] (messages: [MessageImpl], hasMoreMessages: Bool) in
                                                if messages.isEmpty {
                                                    self?.reachedEndOfRemoteHistory = true
                                                } else {
                                                    self?.reachedEndOfLocalHistory = false
                                                    self?.historyStorage.receiveHistoryBefore(messages: messages,
                                                                                              hasMoreMessages: hasMoreMessages)
                                                }
                                                
                                                self?.respondTo(messages: messages,
                                                                limitOfMessages: limit,
                                                                completion: completion)
        })
    }
    
    private func getMessagesFromHistoryBefore(id: HistoryID,
                                              limit: Int,
                                              completion: @escaping ([Message]) -> ()) {
        if reachedEndOfLocalHistory != true {
            historyStorage.getHistoryBefore(id: id,
                                            limitOfMessages: limit,
                                            completion: { [weak self] messages in
                                                if !messages.isEmpty {
                                                    completion(messages)
                                                } else {
                                                    self?.reachedEndOfLocalHistory = true
                                                    self?.getMessagesFromHistoryBefore(id: id,
                                                                                       limit: limit,
                                                                                       completion: completion)
                                                }
            })
        } else if reachedEndOfRemoteHistory == true {
            completion([MessageImpl]())
        } else {
            requestHistory(beforeID: id,
                           limit: limit,
                           completion: completion)
        }
    }
    
    private func getMessagesFromCurrentChatBefore(message: MessageImpl,
                                                  limit: Int,
                                                  completion: ([Message]) -> ()) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            WebimInternalLogger.shared.log(entry: "Message before which messages are requested is not a part of current chat: \(message.toString()).",
                verbosityLevel: .debug)
            
            return
        }
        
        guard let messageIndex = currentChatMessages.firstIndex(of: message),
            messageIndex >= 1 else {
                WebimInternalLogger.shared.log(entry: "Message \(message.toString()) before which messages of current chat are requested can't have index less than 1. Current index: \(String(describing: currentChatMessages.firstIndex(of: message))).",
                verbosityLevel: .debug)
            
            return
        }
        
        respondTo(messages: currentChatMessages,
                  limitOfMessages: limit,
                  offset: messageIndex,
                  completion: completion)
    }
    
    private func mergeCurrentChatWith(newMessages: [MessageImpl]) {
        var previousMessageIndex = lastChatMessageIndex
        var areOldMessagesEnded = false
        
        for messageIndex in 0 ..< newMessages.count {
            let newMessage = newMessages[messageIndex]
            
            if !areOldMessagesEnded {
                var isMerged = false
                
                while previousMessageIndex < currentChatMessages.count {
                    let previousMessage = currentChatMessages[previousMessageIndex]
                    if previousMessage.getID() == newMessage.getID() {
                        if previousMessage != newMessage {
                            currentChatMessages[previousMessageIndex] = newMessage
                            
                            messageTracker?.changedCurrentChatMessage(from: previousMessage,
                                                                      to: newMessage,
                                                                      at: previousMessageIndex,
                                                                      of: self)
                        }
                        
                        isMerged = true
                        
                        previousMessageIndex = previousMessageIndex + 1
                        
                        break
                    } else {
                        currentChatMessages.remove(at: previousMessageIndex)
                        
                        messageTracker?.deletedCurrentChat(message: previousMessage,
                                                           at: previousMessageIndex,
                                                           messageHolder: self)
                    }
                } // End of "while previousMessageIndex < currentChatMessages.count".
                
                if !isMerged &&
                    (previousMessageIndex >= currentChatMessages.count) {
                    areOldMessagesEnded = true
                }
            } // End of "if !areOldMessagesEnded".
            
            if areOldMessagesEnded {
                receive(newMessage: newMessage)
            }
        }
    }
    
    private func tryMergeWithLastChat(message: MessageImpl) -> Bool {
        for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
            guard currentChatMessage.getID() == message.getID(),
                let messageHistoryID = message.getHistoryID() else {
                continue
            }
            
            if currentChatMessageIndex < lastChatMessageIndex {
                let replacementMessage = currentChatMessage.transferToHistory(message: message)
                messageTracker?.idToHistoryMessageMap[messageHistoryID.getDBid()] = replacementMessage
                
                if replacementMessage != currentChatMessage {
                    messageTracker?.messageListener?.changed(message: currentChatMessage,
                                                             to: replacementMessage)
                }
                
                currentChatMessages.remove(at: currentChatMessageIndex)
                lastChatMessageIndex -= 1
            } else {
                currentChatMessage.setSecondaryHistory(historyEquivalentMessage: message)
                
                messageTracker?.idToHistoryMessageMap[messageHistoryID.getDBid()] = message
            }
            
            return true
        }
        
        return false
    }
    
    func updateReadBeforeTimestamp(timestamp: Int64) {
        historyStorage.updateReadBeforeTimestamp(timestamp: timestamp)
    }
    
    func historyMessagesEmpty() -> Bool {
        var isHistoryMessagesEmpty = true
        if let messageTracker = messageTracker,
           !messageTracker.idToHistoryMessageMap.isEmpty {
            isHistoryMessagesEmpty = false
        }
        return isHistoryMessagesEmpty
    }
}
