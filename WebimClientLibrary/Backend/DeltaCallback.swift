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
    init(withCurrentChatMessageMapper currentChatMessageMapper: MessageFactoriesMapper) {
        self.currentChatMessageMapper = currentChatMessageMapper
    }
    
    // MARK: - Methods
    
    func set(messageStream: MessageStreamImpl,
             messageHolder: MessageHolder) {
        self.messageStream = messageStream
        self.messageHolder = messageHolder
    }
    
    func process(deltaList: [DeltaItem]) throws {
        guard messageStream != nil,
            messageHolder != nil else {
            print("Unable to process received delta list, because Message Stream object doesn't exist.")
            
            return
        }
        
        for delta in deltaList {
            let deltaType = delta.getObjectType()
            guard deltaType != nil else {
                continue
            }
            
            switch deltaType! {
            case .CHAT:
                try handleChatUpdateBy(delta: delta,
                                       messageStream: messageStream!)
            case .CHAT_MESSAGE:
                try handleChatMessageUpdateBy(delta: delta,
                                              messageStream: messageStream!,
                                              messageHolder: messageHolder!,
                                              currentChatMessageMapper: currentChatMessageMapper)
            case .CHAT_OPERATOR:
                try handleChatOperatorUpdateBy(delta: delta,
                                               messageStream: messageStream!)
            case .CHAT_OPERATOR_TYPING:
                try handleChatOperatorTypingUpdateBy(delta: delta,
                                                     messageStream: messageStream!)
            case .CHAT_READ_BY_VISITOR:
                handleChatReadByVisitorUpdateBy(delta: delta,
                                                messageStream: messageStream!)
            case .CHAT_STATE:
                try handleChatStateUpdateBy(delta: delta,
                                            messageStream: messageStream!)
            case .OPERATOR_RATE:
                handleOperatorRateUpdateBy(delta: delta,
                                           messageStream: messageStream!)
            case .VISIT_SESSION_STATE:
                handleVisitSessionStateUpdateBy(delta: delta,
                                                messageStream: messageStream!)
            default:
                break
            }
        }
    }
    
    func process(fullUpdate: FullUpdate) throws {
        if let invitationState = fullUpdate.getState() {
            messageStream!.set(invitationState: InvitationStateItem.getTypeBy(string: invitationState))
        }
        
        currentChat = fullUpdate.getChat()
        
        try messageStream!.receivingFullUpdateOf(chat: currentChat)
        
        messageStream!.saveLocationSettingsOn(fullUpdate: fullUpdate)
    }
    
    // MARK: Private methods
    
    private func handleChatUpdateBy(delta: DeltaItem,
                                    messageStream: MessageStreamImpl) throws {
        if delta.getEvent() == .UPDATE {
            if let deltaData = delta.getData() as? [String : Any?] {
                currentChat = ChatItem(withJSONDictionary: deltaData)
                try messageStream.changingChatStateOf(chat: currentChat)
            }
        }
    }
    
    private func handleChatMessageUpdateBy(delta: DeltaItem,
                                           messageStream: MessageStreamImpl,
                                           messageHolder: MessageHolder,
                                           currentChatMessageMapper: MessageFactoriesMapper) throws {
        let deltaEvent = delta.getEvent()
        let sessionID = delta.getSessionID()
        
        if deltaEvent == .DELETE {
            if currentChat != nil {
                var currentChatMessages = currentChat!.getMessages()
                for (currentChatMessageIndex, currentChatMessage) in currentChatMessages.enumerated() {
                    if currentChatMessage.getID() == sessionID {
                        currentChatMessages.remove(at: currentChatMessageIndex)
                        currentChat!.set(messages: currentChatMessages)
                        
                        break
                    }
                }
            }
            
            messageHolder.deletedMessageWith(id: sessionID)
        } else {
            if let deltaData = delta.getData() as? [String : Any?] {
                let messageItem = MessageItem(withJSONDictionary: deltaData)
                let message = currentChatMessageMapper.map(message: messageItem)
                if deltaEvent == .ADD {
                    if currentChat != nil {
                        currentChat?.add(message: messageItem)
                    }
                    
                    if message != nil {
                        try messageHolder.receive(newMessage: message!)
                    }
                } else if deltaEvent == .UPDATE {
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
    }
    
    private func handleChatOperatorUpdateBy(delta: DeltaItem,
                                            messageStream: MessageStreamImpl) throws {
        if let deltaData = delta.getData() as? [String : Any?] {
            let operatorItem = OperatorItem(withJSONDictionary: deltaData)
            if delta.getEvent() == .UPDATE {
                if currentChat != nil {
                    currentChat!.set(operator: operatorItem)
                }
                
                try messageStream.changingChatStateOf(chat: currentChat)
            }
        }
    }
    
    private func handleChatOperatorTypingUpdateBy(delta: DeltaItem,
                                                  messageStream: MessageStreamImpl) throws {
        if let operatorTyping = delta.getData() as? Bool {
            if delta.getEvent() == .UPDATE {
                if currentChat != nil {
                    currentChat!.set(operatorTyping: operatorTyping)
                }
                
                try messageStream.changingChatStateOf(chat: currentChat)
            }
        }
    }
    
    private func handleChatReadByVisitorUpdateBy(delta: DeltaItem,
                                                 messageStream: MessageStreamImpl) {
        if let readByVisitor = delta.getData() as? Bool {
            if delta.getEvent() == .UPDATE {
                if currentChat != nil {
                    currentChat!.set(readByVisitor: readByVisitor)
                }
            }
        }
    }
    
    private func handleChatStateUpdateBy(delta: DeltaItem,
                                         messageStream: MessageStreamImpl) throws {
        if let chatState = delta.getData() as? String {
            if delta.getEvent() == .UPDATE {
                if currentChat != nil {
                    currentChat!.set(state: ChatItem.ChatItemState(rawValue: chatState)!)
                }
                
                try messageStream.changingChatStateOf(chat: currentChat)
            }
        }
    }
    
    private func handleOperatorRateUpdateBy(delta: DeltaItem,
                                            messageStream: MessageStreamImpl) {
        if let deltaData = delta.getData() as? [String : Any?] {
            if let rating = RatingItem(withJSONDictionary: deltaData) {
                if delta.getEvent() == .UPDATE {
                    if currentChat != nil {
                        currentChat!.set(rating: rating,
                                         toOperatorWithId: rating.getOperatorID()!)
                    }
                }
            }
        }
    }
    
    private func handleVisitSessionStateUpdateBy(delta: DeltaItem,
                                                 messageStream: MessageStreamImpl) {
        if let sessionState = delta.getData() as? String {
            if delta.getEvent() == .UPDATE {
                messageStream.set(invitationState: InvitationStateItem.getTypeBy(string: sessionState))
            }
        }
    }
    
}
