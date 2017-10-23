//
//  DeltaCallback.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 12.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class DeltaCallback {
    
    // MARK: - Properties
    private let currentChatMessageMapper: MessageFactoriesMapper
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
        for delta in deltaList {
            let deltaType = delta.getObjectType()
            guard deltaType != nil else {
                continue
            }
            
            switch deltaType! {
            case DeltaItem.DeltaType.CHAT:
                try handleChatUpdateBy(delta: delta,
                                       messageStream: messageStream!)
            case DeltaItem.DeltaType.CHAT_MESSAGE:
                try handleChatMessageActionBy(delta: delta,
                                              messageStream: messageStream!,
                                              messageHolder: messageHolder!,
                                              currentChatMessageMapper: currentChatMessageMapper)
            case DeltaItem.DeltaType.CHAT_OPERATOR:
                try handleChatOperatorUpdateBy(delta: delta,
                                               messageStream: messageStream!)
            case DeltaItem.DeltaType.CHAT_OPERATOR_TYPING:
                try handleChatOperatorTypingUpdateBy(delta: delta,
                                                     messageStream: messageStream!)
            case DeltaItem.DeltaType.CHAT_READ_BY_VISITOR:
                handleChatReadByVisitorUpdateBy(delta: delta,
                                                messageStream: messageStream!)
            case DeltaItem.DeltaType.CHAT_STATE:
                try handleChatStateUpdateBy(delta: delta,
                                            messageStream: messageStream!)
            case DeltaItem.DeltaType.OPERATOR_RATE:
                handleOperatorRateUpdateBy(delta: delta,
                                           messageStream: messageStream!)
            case DeltaItem.DeltaType.VISIT_SESSION_STATE:
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
        
        try messageStream!.receivingFullUpdateOf(chat: fullUpdate.getChat())
        
        messageStream!.saveLocationSettingsOn(fullUpdate: fullUpdate)
    }
    
    // MARK: Private methods
    
    private func handleChatUpdateBy(delta: DeltaItem,
                                           messageStream: MessageStreamImpl) throws {
        if delta.getEvent() == DeltaItem.Event.UPDATE {
            if let deltaData = delta.getData() as! [String : Any?]? {
                let chatItem = ChatItem(withJSONDictionary: deltaData)
                try messageStream.changingChatStateOf(chat: chatItem)
            }
        }
    }
    
    private func handleChatMessageActionBy(delta: DeltaItem,
                                                  messageStream: MessageStreamImpl,
                                                  messageHolder: MessageHolder,
                                                  currentChatMessageMapper: MessageFactoriesMapper) throws {
        let deltaEvent = delta.getEvent()
        
        if deltaEvent == DeltaItem.Event.DELETE {
            if messageStream.getChat() != nil {
                for message in (messageStream.getChat()?.getMessages())! {
                    if message.getID() == delta.getSessionID() {
                        break
                    }
                }
            }
            
            try messageHolder.deletedMessageWith(id: delta.getSessionID()!)
        } else {
            if let deltaData = delta.getData() as! [String : Any?]? {
                let messageItem = MessageItem(withJSONDictionary: deltaData)
                let message = try currentChatMessageMapper.map(message: messageItem)
                
                if (deltaEvent == DeltaItem.Event.ADD)
                    && (message != nil) {
                    try messageHolder.receive(newMessage: message!)
                } else if (deltaEvent == DeltaItem.Event.UPDATE) &&
                    (message != nil) {
                    try messageHolder.changed(message: message!)
                }
            }
            
            
        }
    }
    
    private func handleChatOperatorUpdateBy(delta: DeltaItem,
                                                   messageStream: MessageStreamImpl) throws {
        if let deltaData = delta.getData() as! [String : Any?]? {
            let operatorItem = OperatorItem(withJSONDictionary: deltaData)
            if delta.getEvent() == DeltaItem.Event.UPDATE {
                let currentChat = messageStream.getChat()
                currentChat?.set(operator: operatorItem)
                try messageStream.changingChatStateOf(chat: currentChat)
            }
        }
        
        
    }
    
    private func handleChatOperatorTypingUpdateBy(delta: DeltaItem,
                                                         messageStream: MessageStreamImpl) throws {
        let operatorTyping = delta.getData() as! Bool
        
        if delta.getEvent() == DeltaItem.Event.UPDATE {
            let currentChat = messageStream.getChat()
            currentChat?.set(operatorTyping: operatorTyping)
            try messageStream.changingChatStateOf(chat: currentChat)
        }
    }
    
    private func handleChatReadByVisitorUpdateBy(delta: DeltaItem,
                                                        messageStream: MessageStreamImpl) {
        let readByVisitor = delta.getData() as! Bool
        
        if delta.getEvent() == DeltaItem.Event.UPDATE {
            messageStream.getChat()?.set(readByVisitor: readByVisitor)
        }
    }
    
    private func handleChatStateUpdateBy(delta: DeltaItem,
                                                messageStream: MessageStreamImpl) throws {
        let chatState = delta.getData() as! String
        
        if delta.getEvent() == DeltaItem.Event.UPDATE {
            let currentChat = messageStream.getChat()
            currentChat?.set(state: ChatItem.ChatItemState(rawValue: chatState)!)
            try messageStream.changingChatStateOf(chat: currentChat)
        }
    }
    
    private func handleOperatorRateUpdateBy(delta: DeltaItem,
                                                   messageStream: MessageStreamImpl) {
        if let deltaData = delta.getData() as! [String : Any?]? {
            if let rating = RatingItem(withJSONDictionary: deltaData) {
                if delta.getEvent() == DeltaItem.Event.UPDATE {
                    messageStream.getChat()?.set(rating: rating,
                                                 to: rating.getOperatorID()!)
                }
            }
        }
    }
    
    private func handleVisitSessionStateUpdateBy(delta: DeltaItem,
                                                        messageStream: MessageStreamImpl) {
        let sessionState = delta.getData() as! String
        
        if delta.getEvent() == DeltaItem.Event.UPDATE {
            messageStream.set(invitationState: InvitationStateItem.getTypeBy(string: sessionState))
        }
    }
    
}
