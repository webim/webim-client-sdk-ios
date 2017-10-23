//
//  MessageHolder.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 20.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

class MessageHolder {
    
    // MARK: - Properties
    private let accessChecker: AccessChecker
    private var messageTracker: MessageTrackerImpl?
    private let remoteHistoryProvider: RemoteHistoryProvider
    private let historyStorage: HistoryStorage
    private var reachedEndOfLocalHistory = false
    private var reachedEndOfRemoteHistory: Bool
    private lazy var currentChatMessages = [MessageImpl]()
    private var lastChatMessageIndex = 0
    private var messagesToSend: [MessageToSend]?
    
    
    // MARK: - Initialization
    init(withAccessChecker accessChecker: AccessChecker,
         remoteHistoryProvider: RemoteHistoryProvider,
         historyStorage: HistoryStorage,
         reachedEndOfRemoteHistory: Bool) {
        self.accessChecker = accessChecker
        self.remoteHistoryProvider = remoteHistoryProvider
        self.historyStorage = historyStorage
        self.reachedEndOfRemoteHistory = reachedEndOfRemoteHistory
        
        messagesToSend = [MessageToSend]()
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
    
    func getLastChatMessageIndex() -> Int {
        return lastChatMessageIndex
    }
    
    func getMessagesToSend() -> [MessageToSend]? {
        return messagesToSend
    }
    
    func set(messagesToSend: [MessageToSend]?) {
        self.messagesToSend = messagesToSend
    }
    
    func getLatestMessagesBy(limit: Int,
                             completion: @escaping ([Message]) throws -> ()) throws {
        if currentChatMessages.count != 0 {
            try respondTo(messages: currentChatMessages,
                          limitOfMessages: limit,
                          completion: completion)
        } else {
            try historyStorage.getLatestBy(limitOfMessages: limit,
                                           completion: completion)
        }
    }
    
    func getMessagesBy(limit: Int,
                       before message: MessageImpl,
                       completion: @escaping ([Message]) throws -> ()) throws {
        if message.getSource().isCurrentChatMessage() {
            if currentChatMessages.count == 0 {
                print("Current chat is empty. Requesting history rejected.")
            }
            
            let firstMessage = currentChatMessages[0]
            if message == firstMessage {
                if !firstMessage.hasHistoryComponent() {
                    try historyStorage.getLatestBy(limitOfMessages: limit,
                                                   completion: completion)
                } else {
                    try getMessagesFromHistoryBefore(id: firstMessage.getHistoryID()!,
                                                     limit: limit,
                                                     completion: completion)
                }
            } else {
                try getMessagesFromCurrentChatBefore(message: message,
                                                     limit: limit,
                                                     completion: completion)
            }
        } else {
            try getMessagesFromHistoryBefore(id: message.getHistoryID()!,
                                             limit: limit,
                                             completion: completion)
        }
    }
    
    func getMessageTracker() -> MessageTrackerImpl? {
        return messageTracker
    }
    
    func set(messageTracker: MessageTrackerImpl?) {
        self.messageTracker = messageTracker
    }
    
    func getHistoryStorage() -> HistoryStorage {
        return historyStorage
    }
    
    func getRemoteHistoryProvider() -> RemoteHistoryProvider {
        return remoteHistoryProvider
    }
    
    func set(reachedEndOfLocalHistory: Bool) {
        self.reachedEndOfLocalHistory = reachedEndOfLocalHistory
    }
    
    func newMessageTracker(withMessageListener messageListener: MessageListener) throws -> MessageTrackerImpl {
        if self.messageTracker != nil {
            do {
                try self.messageTracker?.destroy()
            } catch {
                throw MessageTrackerError.invalidState("Tried to create new MessageTracker object not from the thread the WebimSession was created in.")
            }
        }
        
        let messageTracker = MessageTrackerImpl(withMessageListener: messageListener,
                                                messageHolder: self)
        self.set(messageTracker: messageTracker)
        
        return messageTracker
    }
    
    func receiveHistoryUpdateWith(messages: [MessageImpl],
                                  deleted: Set<String>,
                                  completion: @escaping () -> ()) throws {
        try historyStorage.receiveHistoryUpdate(messages: messages,
                                                idsToDelete: deleted,
                                                completion: { (endOfBatch: Bool, messageDeleted: Bool, deletedMessageID: String?, messageChanged: Bool, changedMessage: MessageImpl?, messageAdded: Bool, addedMessage: MessageImpl?, idBeforeAddedMessage: HistoryID?) throws -> () in
                                                    if endOfBatch {
                                                        if self.messageTracker != nil {
                                                            try self.messageTracker?.endedHistoryBatch()
                                                        }
                                                        
                                                        completion()
                                                    }
                                                    
                                                    if messageDeleted {
                                                        // Assuming that when messageDeleted == true deletedMessageID cannot be nil.
                                                        if self.messageTracker != nil {
                                                            self.messageTracker?.deletedHistory(messageID: deletedMessageID!)
                                                        }
                                                    }
                                                    
                                                    if messageChanged {
                                                        // Assuming that when messageChanged == true changedMessage cannot be nil.
                                                        if self.messageTracker != nil {
                                                            try self.messageTracker!.changedHistory(message: changedMessage!)
                                                        }
                                                    }
                                                    
                                                    if messageAdded {
                                                        // Assuming that when messageAdded == true addedMessage cannot be nil.
                                                        if !self.tryMergeWithLastChat(message: addedMessage!) &&
                                                            (self.messageTracker != nil) {
                                                            try self.messageTracker?.addedHistory(message: addedMessage!,
                                                                                                  before: idBeforeAddedMessage)
                                                        }
                                                    }
        })
    }
    
    func set(endOfHistoryReached: Bool) {
        reachedEndOfRemoteHistory = endOfHistoryReached
        historyStorage.set(reachedHistoryEnd: endOfHistoryReached)
    }
    
    func receiving(chat: ChatItem?,
                   previousChat: ChatItem?,
                   newMessages: [MessageImpl]) throws {
        if (currentChatMessages.isEmpty) {
            try receive(newMessages: newMessages)
        } else {
            if chat == nil {
                historifyCurrentChat()
            } else if (previousChat == nil) ||
                (chat != previousChat) {
                historifyCurrentChat()
                try receive(newMessages: newMessages)
            } else {
                try mergeCurrentChatWith(newMessages: newMessages)
            }
        }
    }
    
    func receive(newMessage: MessageImpl) throws {
        if messageTracker != nil {
            try messageTracker?.addedNew(message: newMessage,
                                         of: self)
        } else {
            currentChatMessages.append(newMessage)
        }
    }
    
    func changed(message: MessageImpl) throws {
        for messageIndex in lastChatMessageIndex ..< currentChatMessages.count {
            let oldVersion = currentChatMessages[messageIndex]
            if oldVersion.getCurrentChatID() == message.getCurrentChatID() {
                currentChatMessages[messageIndex] = message
                
                if messageTracker != nil {
                    try messageTracker?.changedCurrentChatMessage(from: oldVersion,
                                                                  to: message,
                                                                  at: messageIndex,
                                                                  of: self)
                }
                
                return
            }
        }
    }
    
    func deletedMessageWith(id: String) throws {
        for messageIndex in lastChatMessageIndex ..< currentChatMessages.count {
            let message = currentChatMessages[messageIndex]
            if message.getCurrentChatID() == id {
                currentChatMessages.remove(at: messageIndex)
                
                if messageTracker != nil {
                    try messageTracker?.deletedCurrentChat(message: message,
                                                           at: messageIndex,
                                                           messageHolder: self)
                }
                
                return
            }
        }
    }
    
    func sending(message: MessageToSend) {
        messagesToSend!.append(message)
        
        if messageTracker != nil {
            messageTracker?.messageListener.added(message: message,
                                                  after: nil)
        }
    }
    
    func sendingCancelledWith(messageID: String) {
        for messageIndex in 0 ..< messagesToSend!.count {
            if messagesToSend![messageIndex].getID() == messageID {
                let message = messagesToSend![messageIndex]
                
                messagesToSend!.remove(at: messageIndex)
                
                if messageTracker != nil {
                    messageTracker?.messageListener.removed(message: message)
                }
                
                return
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func receive(newMessages: [MessageImpl]) throws {
        if messageTracker != nil {
            try messageTracker!.addedNew(messages: newMessages,
                                         of: self)
        } else {
            for message in newMessages {
                currentChatMessages.append(message)
            }
        }
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           completion: ([Message]) throws -> ()) throws {
        var messageList = [MessageImpl]()
        
        if messages.count != 0 {
            if messages.count <= limitOfMessages {
                messageList = messages
            } else {
                messageList = Array(messages[(messages.count - limitOfMessages) ..< limitOfMessages])
            }
        }
        
        try completion(messageList)
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           offset: Int,
                           completion: ([Message]) throws -> ()) throws {
        let messageList = Array(messages[max(0, (offset - limitOfMessages)) ..< offset])
        try completion(messageList)
    }
    
    private func historifyCurrentChat() {
        var newCurrentChatMessages = [MessageImpl]()
        
        for message in currentChatMessages {
            if message.hasHistoryComponent() {
                message.invertHistoryStatus()
                
                if let messageTracker = messageTracker {
                    if let id = message.getHistoryID()?.getDBid() {
                        if let historyMessage = messageTracker.idToHistoryMessageMap[id] {
                            if message != historyMessage {
                                messageTracker.messageListener.changed(message: message,
                                                                       to: historyMessage)
                            } else {
                                messageTracker.idToHistoryMessageMap[id] = message
                            }
                        }
                    }
                    
                }
            } else {
                newCurrentChatMessages.append(message)
            }
        }
        
        self.set(currentChatMessages: newCurrentChatMessages)
        
        lastChatMessageIndex = currentChatMessages.count
    }
    
    private func requestHistory(beforeID id: HistoryID,
                                limit: Int,
                                completion: @escaping ([Message]) throws -> ()) throws {
        remoteHistoryProvider.requestHistory(beforeTimeSince: id.getTimeInMicrosecond(),
                                             completion: { (messages: [MessageImpl], hasMoreMessages: Bool) in
                                                if !hasMoreMessages {
                                                    self.reachedEndOfRemoteHistory = true
                                                }
                                                
                                                if !messages.isEmpty {
                                                    self.historyStorage.receiveHistoryBefore(messages: messages,
                                                                                             hasMoreMessages: hasMoreMessages)
                                                }
                                                
                                                try self.respondTo(messages: messages,
                                                                   limitOfMessages: limit,
                                                                   completion: completion)
        })
    }
    
    private func getMessagesFromHistoryBefore(id: HistoryID,
                                              limit: Int,
                                              completion: @escaping ([Message]) throws -> ()) throws {
        if !reachedEndOfLocalHistory {
            try historyStorage.getBefore(id: id,
                                         limitOfMessages: limit,
                                         completion: { messages in
                                            if messages.isEmpty {
                                                self.reachedEndOfLocalHistory = true
                                                try self.getMessagesFromHistoryBefore(id: id,
                                                                                      limit: limit,
                                                                                      completion: completion)
                                            } else {
                                                try completion(messages)
                                            }
            })
        } else if reachedEndOfRemoteHistory {
            try completion([MessageImpl]())
        } else {
            try requestHistory(beforeID: id,
                               limit: limit,
                               completion: completion)
        }
    }
    
    private func getMessagesFromCurrentChatBefore(message: MessageImpl,
                                                  limit: Int,
                                                  completion: ([Message]) throws -> ()) throws {
        try message.getSource().assertIsCurrentChat()
        
        let messageIndex = currentChatMessages.index(of: message)!
        
        guard messageIndex >= 1 else {
            print("Message \(message.toString()) before which messages of current chat are requested can't have index less than 1.")
            
            return
        }
        
        try respondTo(messages: currentChatMessages,
                      limitOfMessages: limit,
                      offset: messageIndex,
                      completion: completion)
    }
    
    private func mergeCurrentChatWith(newMessages: [MessageImpl]) throws {
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
                            
                            if messageTracker != nil {
                                try messageTracker?.changedCurrentChatMessage(from: previousMessage,
                                                                              to: newMessage,
                                                                              at: previousMessageIndex,
                                                                              of: self)
                            }
                        }
                        
                        isMerged = true
                        
                        previousMessageIndex = previousMessageIndex + 1
                        
                        break
                    } else {
                        currentChatMessages.remove(at: previousMessageIndex)
                        
                        if messageTracker != nil {
                            try messageTracker?.deletedCurrentChat(message: previousMessage,
                                                                   at: previousMessageIndex,
                                                                   messageHolder: self)
                        }
                    }
                }
                
                if !isMerged &&
                    (previousMessageIndex >= currentChatMessages.count) {
                    areOldMessagesEnded = true
                }
            }
            
            if areOldMessagesEnded {
                try receive(newMessage: newMessage)
            }
        }
    }
    
    private func tryMergeWithLastChat(message: MessageImpl) -> Bool {
        for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
            if currentChatMessage.getID() == message.getID() {
                if currentChatMessageIndex < lastChatMessageIndex {
                    currentChatMessages.remove(at: currentChatMessageIndex)
                    lastChatMessageIndex = lastChatMessageIndex - 1
                    
                    let replacementMessage = currentChatMessage.transferToHistory(message: message)
                    if messageTracker != nil {
                        messageTracker?.idToHistoryMessageMap[(message.getHistoryID()?.getDBid())!] = replacementMessage
                        
                        if replacementMessage != currentChatMessage {
                            messageTracker?.messageListener.changed(message: currentChatMessage,
                                                                    to: replacementMessage)
                        }
                    }
                    
                } else {
                    currentChatMessage.setSecondaryHistory(historyEquivalentMessage: message)
                    
                    if messageTracker != nil {
                        messageTracker?.idToHistoryMessageMap[(message.getHistoryID()?.getDBid())!] = message
                    }
                }
                
                return true
            }
        }
        
        return false
    }
    
}
