//
//  MessageTrackerImpl.swift
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
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class MessageTrackerImpl: MessageTracker {
    
    // MARK: - Properties
    let messageListener: MessageListener
    private let messageHolder: MessageHolder
    var idToHistoryMessageMap = [String : MessageImpl]()
    private var allMessageSourcesEnded: Bool?
    private var cachedCompletionHandler: MessageHolderCompletionHandlerWrapper?
    private var cachedLimit: Int?
    private var destroyed: Bool?
    private var headMessage: MessageImpl?
    private var firstHistoryUpdateReceived: Bool?
    private var messagesLoading: Bool?
    
    
    // MARK: - Initialization
    init(withMessageListener messageListener: MessageListener,
         messageHolder: MessageHolder) {
        self.messageListener = messageListener
        self.messageHolder = messageHolder
    }
    
    
    // MARK: - Methods
    
    func addedNew(message: MessageImpl,
                  of messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            print("Message which is being added is not a part of current chat.")
            
            return
        }
        
        if (headMessage != nil)
            || (allMessageSourcesEnded == true) {
            addNewOrMerge(message: message,
                          of: messageHolder)
        } else {
            var currentChatMessages = messageHolder.getCurrentChatMessages()
            currentChatMessages.append(message)
            messageHolder.set(currentChatMessages: currentChatMessages)
            
            // FIXME: Do it on endOfBatch only.
            if let completionHandler = cachedCompletionHandler {
                getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                           completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func addedNew(messages: [MessageImpl],
                  of messageHolder: MessageHolder) {
        if (headMessage != nil)
            || (allMessageSourcesEnded == true) {
            for message in messages {
                addNewOrMerge(message: message,
                              of: messageHolder)
            }
        } else {
            var currentChatMessages = messageHolder.getCurrentChatMessages()
            for message in messages {
                currentChatMessages.append(message)
            }
            messageHolder.set(currentChatMessages: currentChatMessages)
            
            if let completionHandler = cachedCompletionHandler {
                getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                           completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func changedCurrentChatMessage(from previousVersion: MessageImpl,
                                   to newVersion: MessageImpl,
                                   at index: Int,
                                   of messageHolder: MessageHolder) {
        do {
            try previousVersion.getSource().assertIsCurrentChat()
        } catch {
            print("Message which is being changed is not a part of current chat.")
            
            return
        }
        do {
            try newVersion.getSource().assertIsCurrentChat()
        } catch {
            print("Replacement message for a current chat message is not a part of current chat.")
            
            return
        }
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage() {
                if previousVersion === headMessage {
                    self.headMessage = newVersion
                }
                
                messageListener.changed(message: previousVersion,
                                        to: newVersion)
            } else {
                let currentChatMessages = messageHolder.getCurrentChatMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getID() == headMessage.getID() {
                        if index >= currentChatMessageIndex {
                            if previousVersion === headMessage {
                                self.headMessage = newVersion
                            }
                            
                            messageListener.changed(message: previousVersion,
                                                    to: newVersion)
                        }
                        
                        return
                    }
                }
            }
        }
    }
    
    func deletedCurrentChat(message: MessageImpl,
                            at index: Int,
                            messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            print("Message which is being deleted is not a part of current chat.")
        }
        
        let currentChatMessages = messageHolder.getCurrentChatMessages()
        
        if let headMessage = headMessage {
            let headIndex = currentChatMessages.index(of: headMessage) ?? -1
            
            if headMessage.getSource().isHistoryMessage()
                || (index > headIndex) {
                if headIndex == (index + 1) {
                    self.headMessage = (currentChatMessages.count < headIndex) ? nil : currentChatMessages[headIndex]
                }
                
                messageListener.removed(message: message)
            }
        }
    }
    
    func set(messagesLoading: Bool) {
        self.messagesLoading = messagesLoading
    }
    
    func endedHistoryBatch() {
        if firstHistoryUpdateReceived != true {
            firstHistoryUpdateReceived = true
            
            if let completionHandler = cachedCompletionHandler {
                getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                           completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func deletedHistoryMessage(withID messageID: String) {
        guard let message = idToHistoryMessageMap[messageID] else {
            return
        }
        
        idToHistoryMessageMap[messageID] = nil
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage()
                && (message.getTimeInMicrosecond() >= headMessage.getTimeInMicrosecond()) {
                messageListener.removed(message: message)
            }
        }
    }
    
    func changedHistory(message: MessageImpl) {
        do {
            try message.getSource().assertIsHistory()
        } catch {
            print("Message which is being changed is not a part of histoty.")
        }
        
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage()
                && (message.getTimeInMicrosecond() >= headMessage.getTimeInMicrosecond()) {
                let previousMessage: MessageImpl? = idToHistoryMessageMap[message.getHistoryID()!.getDBid()]
                idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                if previousMessage != nil {
                    messageListener.changed(message: previousMessage!,
                                            to: message)
                } else {
                    print("Unknown message was changed: \(message.toString())")
                }
            }
        }
    }
    
    func addedHistory(message: MessageImpl,
                      before id: HistoryID?) {
        do {
            try message.getSource().assertIsHistory()
        } catch {
            print("Message which is being added is not a part of history.")
        }
        
        
        if headMessage != nil {
            if headMessage!.getSource().isHistoryMessage() {
                if let beforeID = id {
                    if let beforeMessage = idToHistoryMessageMap[beforeID.getDBid()] {
                        idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                        messageListener.added(message: message,
                                              after: beforeMessage)
                    }
                } else {
                    idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                    let currentChatMessages = messageHolder.getCurrentChatMessages()
                    messageListener.added(message: message,
                                          after: (currentChatMessages.isEmpty ? nil : currentChatMessages.first!))
                }
            }
        }
    }
    
    
    // MARK: MessageTracker protocol methods
    
    func getLastMessages(byLimit limitOfMessages: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            print("MessageTracker object is destroyed. Unable to perform request to get new messages.")
            
            return
        }
        guard messagesLoading != true else {
            print("Messages are already loading. Unable to perform a second request to get new messages.")
            
            return
        }
        guard limitOfMessages > 0 else {
            print("Limit of messages to perform request to get new messages must be greater that zero. Passed value – \(limitOfMessages)")
            
            return
        }
        
        messagesLoading = true
        
        messageHolder.set(currentChatMessages: [MessageImpl]())
        
        cachedCompletionHandler = MessageHolderCompletionHandlerWrapper(completionHandler: completion)
        cachedLimit = limitOfMessages
        
        messageHolder.getHistoryStorage().getLatestHistory(byLimit: limitOfMessages) { messages in
            if let cachedCompletionHandler = self.cachedCompletionHandler,
                !messages.isEmpty {
                self.firstHistoryUpdateReceived = true
                
                let completionHandlerToPass = cachedCompletionHandler.getCompletionHandler()
                self.receive(messages: messages as! [MessageImpl],
                             limit: limitOfMessages,
                             completion: completionHandlerToPass)
                
                self.cachedCompletionHandler = nil
            }
        }
    }
    
    func getNextMessages(byLimit limitOfMessages: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            print("MessageTracker object is destroyed. Unable to perform request to get new messages.")
            
            return
        }
        guard messagesLoading != true else {
            print("Messages are already loading. Unable to perform a second request to get new messages.")
            
            return
        }
        guard limitOfMessages > 0 else {
            print("Limit of messages to perform request to get new messages must be greater that zero. Passed value – \(limitOfMessages)")
            
            return
        }
        
        messagesLoading = true
        
        let currentChatMessages = messageHolder.getCurrentChatMessages()
        if (firstHistoryUpdateReceived == true)
            || (!currentChatMessages.isEmpty
                && (currentChatMessages.first != headMessage)) {
            getNextUncheckedMessagesBy(limit: limitOfMessages,
                                       completion: completion)
        } else {
            cachedCompletionHandler = MessageHolderCompletionHandlerWrapper(completionHandler: completion)
            cachedLimit = limitOfMessages
            
            messageHolder.getHistoryStorage().getLatestHistory(byLimit: limitOfMessages) { messages in
                if let cachedCompletionHandler = self.cachedCompletionHandler,
                    !messages.isEmpty {
                    self.firstHistoryUpdateReceived = true
                    
                    let completionHandlerToPass = cachedCompletionHandler.getCompletionHandler()
                    self.receive(messages: messages as! [MessageImpl],
                                 limit: limitOfMessages,
                                 completion: completionHandlerToPass)
                    
                    self.cachedCompletionHandler = nil
                }
            }
        }
    }
    
    func getAllMessages(completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            print("MessageTracker object was destroyed. Unable to perform a request to reset to a message.")
            
            return
        }
        
        messageHolder.getHistoryStorage().getFullHistory(completion: completion)
    }
    
    func resetTo(message: Message) throws {
        try messageHolder.checkAccess()
        guard destroyed != true else {
            print("MessageTracker object was destroyed. Unable to perform a request to reset to a message.")
            
            return
        }
        guard messagesLoading != true else {
            print("Messages is loading. Unable to perform a simultaneous request to reset to a message.")
            
            return
        }
        
        let unwrappedMessage = message as! MessageImpl
        if unwrappedMessage !== headMessage {
            messageHolder.set(reachedEndOfLocalHistory: false)
        }
        if unwrappedMessage.getSource().isHistoryMessage() {
            var newIDToHistoryMessageMap = [String : MessageImpl]()
            for (id, iteratedMessage) in idToHistoryMessageMap {
                if iteratedMessage.getTimeInMicrosecond() >= unwrappedMessage.getTimeInMicrosecond() {
                    newIDToHistoryMessageMap[id] = iteratedMessage
                }
            }
            idToHistoryMessageMap = newIDToHistoryMessageMap
        } else {
            idToHistoryMessageMap.removeAll()
        }
        
        headMessage = unwrappedMessage
    }
    
    func destroy() throws {
        try messageHolder.checkAccess()
        
        if destroyed != true {
            destroyed = true
            
            messageHolder.set(messagesToSend: [MessageToSend]())
            
            messageHolder.set(messageTracker: nil)
        }
    }
    
    
    // MARK: - Private methods
    
    private func addNewOrMerge(message: MessageImpl,
                               of messageHolder: MessageHolder) {
        do {
            try message.getSource().assertIsCurrentChat()
        } catch {
            print("Message which is being added is not a part of current chat.")
            
            return
        }
        
        var toCallMessageAdded = true
        
        var currentChatMessages = messageHolder.getCurrentChatMessages()
        
        if headMessage == nil {
            headMessage = message
        } else if (headMessage!.getTimeInMicrosecond()) > message.getTimeInMicrosecond() {
            toCallMessageAdded = false
            
            currentChatMessages.append(message)
        } else {
            for (historyID, historyMessage) in idToHistoryMessageMap {
                if message.getID() == historyMessage.getID() {
                    toCallMessageAdded = false
                    
                    let replacingMessage = historyMessage.transferToCurrentChat(message: message)
                    currentChatMessages.append(replacingMessage)
                    if (replacingMessage !== historyMessage) {
                        messageListener.changed(message: historyMessage,
                                                to: replacingMessage)
                    }
                    
                    idToHistoryMessageMap[historyID] = nil
                    
                    break
                }
            }
        }
        
        if toCallMessageAdded {
            currentChatMessages.append(message)
            
            if let messageToSend = getToSendMirrorOf(message: message,
                                                     of: messageHolder) {
                messageListener.changed(message: messageToSend,
                                        to: message)
            } else {
                let messagesToSend = messageHolder.getMessagesToSend()
                messageListener.added(message: message,
                                      after: messageHolder.getMessagesToSend().isEmpty ? nil : messagesToSend.first!)
            }
        }
        
        messageHolder.set(currentChatMessages: currentChatMessages)
    }
    
    private func getToSendMirrorOf(message: MessageImpl,
                                   of messageHolder: MessageHolder) -> MessageToSend? {
        let messagesToSend = messageHolder.getMessagesToSend()
        for messageToSend in messagesToSend {
            if messageToSend.getID() == message.getID() {
                return messageToSend
            }
        }
        
        return nil
    }
    
    private func getNextUncheckedMessagesBy(limit: Int,
                                            completion: @escaping ([Message]) -> ()) {
        let completionHandler = { (messages: [Message]) -> () in
            self.receive(messages: messages as! [MessageImpl],
                         limit: limit,
                         completion: completion)
        }
        
        if headMessage == nil {
            messageHolder.getLatestMessages(byLimit: limit,
                                            completion: completionHandler)
        } else {
            messageHolder.getMessagesBy(limit: limit,
                                        before: headMessage!,
                                        completion: completionHandler)
        }
    }
    
    private func receive(messages: [MessageImpl],
                         limit: Int,
                         completion: @escaping ([Message]) -> ()) {
        var result: [MessageImpl]?
        
        // FIXME: Refactor this.
        if !messages.isEmpty {
            let currentChatMessages = messageHolder.getCurrentChatMessages()
            if !currentChatMessages.isEmpty {
                if (messages.last!.getTime() >= currentChatMessages.first!.getTime()) {
                    // We received history that overlap current chat messages. Merging.
                    
                    var filteredMessages = [MessageImpl]()
                    
                    let firstMessage = messages.first!
                    
                    for message in messages {
                        var addToFilteredMessages = true
                        
                        if message.getSource().isHistoryMessage() {
                            let messageTime = message.getTime()
                            if (messageTime >= currentChatMessages.first!.getTime())
                                && (messageTime <= currentChatMessages.last!.getTime()) {
                                for currentChatMessage in currentChatMessages {
                                    if currentChatMessage.getID() == message.getID() {
                                        addToFilteredMessages = false
                                        
                                        currentChatMessage.setSecondaryHistory(historyEquivalentMessage: message)
                                        
                                        break
                                    }
                                }
                            }
                        }
                        
                        if addToFilteredMessages {
                            filteredMessages.append(message)
                        }
                    }
                    
                    if filteredMessages.isEmpty {
                        messageHolder.getMessagesBy(limit: limit,
                                                    before: firstMessage,
                                                    completion: completion)
                        
                        return
                    }
                    
                    result = filteredMessages
                } else {
                    result = messages
                }
            } else {
                result = messages
            }
            
            for message in messages {
                if message.getSource().isHistoryMessage() {
                    idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                }
            }
            
            let firstMessage = result!.first!
            
            // FIXME: Refactor this.
            if headMessage == nil {
                headMessage = firstMessage
            } else if firstMessage.getTimeInMicrosecond() < headMessage!.getTimeInMicrosecond() {
                headMessage = firstMessage
            }
        } else {
            result = messages
            
            allMessageSourcesEnded = true
        }
        
        messagesLoading = false
        
        completion(result!)
    }
    
}
