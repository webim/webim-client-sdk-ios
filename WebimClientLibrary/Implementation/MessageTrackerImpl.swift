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

final class MessageTrackerImpl: MessageTracker {
    
    // MARK: - Properties
    let messageListener: MessageListener
    private let messageHolder: MessageHolder!
    var idToHistoryMessageMap = [String : MessageImpl]()
    private var allMessageSourcesEnded: Bool?
    private var cachedCompletionHandler: MessageHolderCompletionHandlerWrapper?
    private var cachedLimit: Int?
    private var destroyed: Bool?
    private var firstHistoryUpdateReceived: Bool?
    private var headMessage: MessageImpl?
    private var messagesLoading: Bool?
    
    
    // MARK: - Initialization
    init(withMessageListener messageListener: MessageListener,
         messageHolder: MessageHolder) {
        self.messageListener = messageListener
        self.messageHolder = messageHolder
    }
    
    
    // MARK: - Methods
    
    func addedNew(message: MessageImpl,
                  of messageHolder: MessageHolder) throws {
        try message.getSource().assertIsCurrentChat()
        
        if (headMessage != nil)
            || (allMessageSourcesEnded == true) {
            try addNewOrMerge(message: message,
                              of: messageHolder)
        } else {
            var currentChatMessages = messageHolder.getCurrentChatMessages()
            currentChatMessages.append(message)
            messageHolder.set(currentChatMessages: currentChatMessages)
            
            // FIXME: Do it on endOfBatch only
            if let completionHandler = cachedCompletionHandler {
                try getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                               completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func addedNew(messages: [MessageImpl],
                  of messageHolder: MessageHolder) throws {
        if (headMessage != nil)
            || (allMessageSourcesEnded == true) {
            for message in messages {
                try addNewOrMerge(message: message,
                                  of: messageHolder)
            }
        } else {
            var currentChatMessages = messageHolder.getCurrentChatMessages()
            for message in messages {
                currentChatMessages.append(message)
            }
            messageHolder.set(currentChatMessages: currentChatMessages)
            
            if let completionHandler = cachedCompletionHandler {
                try getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                               completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func changedCurrentChatMessage(from previousVersion: MessageImpl,
                                   to newVersion: MessageImpl,
                                   at index: Int,
                                   of messageHolder: MessageHolder) throws {
        try previousVersion.getSource().assertIsCurrentChat()
        try newVersion.getSource().assertIsCurrentChat()
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage() {
                if previousVersion == headMessage {
                    self.headMessage = newVersion
                }
                
                messageListener.changed(message: previousVersion,
                                        to: newVersion)
            } else {
                let currentChatMessages = messageHolder.getCurrentChatMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getID() == headMessage.getID() {
                        if index >= currentChatMessageIndex {
                            if previousVersion == headMessage {
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
                            messageHolder: MessageHolder) throws {
        try message.getSource().assertIsCurrentChat()
        
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
    
    func getHeadMessage() -> MessageImpl? {
        return headMessage
    }
    
    func set(headMessage: MessageImpl?) {
        self.headMessage = headMessage
    }
    
    func set(allMessageSourcesEnded: Bool) {
        self.allMessageSourcesEnded = allMessageSourcesEnded
    }
    
    func set(messagesLoading: Bool) {
        self.messagesLoading = messagesLoading
    }
    
    func endedHistoryBatch() throws {
        if firstHistoryUpdateReceived != true {
            firstHistoryUpdateReceived = true
            
            if let completionHandler = cachedCompletionHandler {
                try getNextUncheckedMessagesBy(limit: ((cachedLimit != nil) ? cachedLimit! : 0),
                                               completion: completionHandler.getCompletionHandler())
                
                cachedCompletionHandler = nil
            }
        }
    }
    
    func deletedHistory(messageID: String) {
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
    
    func changedHistory(message: MessageImpl) throws {
        try message.getSource().assertIsHistory()
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage()
                && (message.getTimeInMicrosecond() >= headMessage.getTimeInMicrosecond()) {
                let previousMessage: MessageImpl? = idToHistoryMessageMap[message.getHistoryID()!.getDBid()] ?? nil
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
                      before id: HistoryID?) throws {
        try message.getSource().assertIsHistory()
        
        if let headMessage = headMessage {
            if headMessage.getSource().isHistoryMessage() {
                if let beforeID = id {
                    if let beforeMessage = idToHistoryMessageMap[beforeID.getDBid()] {
                        idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                        messageListener.added(message: message,
                                              after: beforeMessage)
                    }
                } else {
                    idToHistoryMessageMap[message.getHistoryID()!.getDBid()] = message
                    let currentChatMessages = messageHolder.getCurrentChatMessages()
                    messageListener.added(message: message, after: (currentChatMessages.isEmpty ? nil : currentChatMessages.first!))
                }
            }
        }
    }
    
    
    // MARK: MessageTracker protocol methods
    
    func getNextMessages(byLimit limit: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        try messageHolder.checkAccess()
        
        guard destroyed != true else {
            throw MessageTrackerError.destroyedObject("MessageTracker object is destroyed. Unable to perform request to get new messages.")
        }
        guard messagesLoading != true else {
            throw MessageTrackerError.repeatedRequest("Messages are already loading. Unable to perform a second request to get new messages.")
        }
        guard limit > 0 else {
            throw MessageTrackerError.invalidArgument("Limit of messages to perform request to get new messages must be greater that zero. Passed value – \(limit)")
        }
        
        messagesLoading = true
        
        if (firstHistoryUpdateReceived == true)
            || ((messageHolder.getCurrentChatMessages().count != 0)
                && (messageHolder.getCurrentChatMessages()[0] != headMessage)) {
            try getNextUncheckedMessagesBy(limit: limit,
                                           completion: completion)
        } else {
            cachedCompletionHandler = MessageHolderCompletionHandlerWrapper(completionHandler: completion)
            cachedLimit = limit
            
            try messageHolder.getHistoryStorage().getLatestBy(limitOfMessages: limit) { messages in
                if let cachedCompletionHandler = self.cachedCompletionHandler {
                    if !messages.isEmpty {
                        let completionHandlerToPass = cachedCompletionHandler.getCompletionHandler()
                        
                        self.firstHistoryUpdateReceived = true
                        
                        try self.receive(messages: messages as! [MessageImpl],
                                         limit: limit,
                                         completion: completionHandlerToPass)
                        
                        self.cachedCompletionHandler = nil
                    }
                }
            }
        }
    }
    
    func resetTo(message: Message) throws {
        try messageHolder.checkAccess()
        
        guard destroyed != true else {
            throw MessageTrackerError.destroyedObject("MessageTracker object was destroyed. Unable to perform a request to reset to a message.")
        }
        guard messagesLoading != true else {
            throw MessageTrackerError.repeatedRequest("Messages is loading. Unable to perform a simultaneous request to reset to a message.")
        }
        
        let unwrappedMessage = message as! MessageImpl
        if unwrappedMessage != headMessage {
            messageHolder.set(reachedEndOfLocalHistory: false)
        }
        if unwrappedMessage.getSource().isHistoryMessage() {
            for (id, iteratedMessage) in idToHistoryMessageMap {
                if iteratedMessage.getTimeInMicrosecond() < unwrappedMessage.getTimeInMicrosecond() {
                    idToHistoryMessageMap[id] = nil
                }
            }
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
                               of messageHolder: MessageHolder) throws {
        try message.getSource().assertIsCurrentChat()
        
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
                    if (replacingMessage != historyMessage) {
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
                                            completion: @escaping ([Message]) -> ()) throws {
        let completionHandler = { (messages: [Message]) throws -> () in
            try self.receive(messages: messages as! [MessageImpl],
                             limit: limit,
                             completion: completion)
        }
        
        if headMessage == nil {
            try messageHolder.getLatestMessagesBy(limit: limit,
                                                  completion: completionHandler)
        } else {
            try messageHolder.getMessagesBy(limit: limit,
                                            before: headMessage!,
                                            completion: completionHandler)
        }
    }
    
    private func receive(messages: [MessageImpl],
                         limit: Int,
                         completion: @escaping ([Message]) -> ()) throws {
        var result = [MessageImpl]()
        
        if !messages.isEmpty {
            let currentChatMessages = messageHolder.getCurrentChatMessages()
            
            if !currentChatMessages.isEmpty {
                if messages.last!.getTime() >= currentChatMessages.first!.getTime() {
                    // We received history that overlap current chat messages. Merging.
                    
                    var filteredMessages = [MessageImpl]()
                    
                    let firstMessage = messages.first!
                    
                    for message in messages {
                        var addToFilteredMessages = true
                        
                        if message.getSource().isHistoryMessage() {
                            if (message.getTime() >= (currentChatMessages.first!.getTime()))
                                && (message.getTime() <= (currentChatMessages.last!.getTime())) {
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
                        try messageHolder.getMessagesBy(limit: limit,
                                                        before: firstMessage,
                                                        completion: completion)
                        return
                    }
                    
                    result = filteredMessages
                }
            } else {
                result = messages
            }
            
            for message in messages {
                if message.getSource().isHistoryMessage() {
                    idToHistoryMessageMap[(message.getHistoryID()!.getDBid())] = message
                }
            }
            
            let firstMessage = result.first!
            
            if (headMessage == nil)
                || (firstMessage.getTimeInMicrosecond() < headMessage!.getTimeInMicrosecond()) {
                headMessage = firstMessage
            }
        } else {
            result = messages
            
            allMessageSourcesEnded = true
        }
        
        messagesLoading = false
        
        completion(result as [Message])
    }
    
}
