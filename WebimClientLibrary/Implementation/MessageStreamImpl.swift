//
//  MessageStreamImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class MessageStreamImpl: MessageStream {
    
    // MARK: - Properties
    private let accessChecker: AccessChecker
    private let currentChatMessageFactoriesMapper: MessageFactoriesMapper
    private let locationSettingsHolder: LocationSettingsHolder
    private let messageComposingHandler: MessageComposingHandler
    private let messageHolder: MessageHolder
    private let sendingMessageFactory: SendingFactory
    private let webimActions: WebimActions
    private var chat: ChatItem?
    private var chatStateListener: ChatStateListener?
    private var currentOperator: OperatorImpl?
    private var currentOperatorChangeListener: CurrentOperatorChangeListener?
    private var invitationState: InvitationStateItem = .UNKNOWN
    private var isChatIsOpening: Bool?
    private var lastChatState: ChatItem.ChatItemState = .CLOSED
    private var lastOperatorTypingStatus: Bool?
    private var locationSettingsChangeListener: LocationSettingsChangeListener?
    private var operatorFactory: OperatorFactory
    private var operatorTypingListener: OperatorTypingListener?
    
    
    // MARK: - Initialization
    init(withCurrentChatMessageFactoriesMapper currentChatMessageFactoriesMapper: MessageFactoriesMapper,
         sendingMessageFactory: SendingFactory,
         operatorFactory: OperatorFactory,
         accessChecker: AccessChecker,
         webimActions: WebimActions,
         messageHolder: MessageHolder,
         messageComposingHandler: MessageComposingHandler,
         locationSettingsHolder: LocationSettingsHolder) {
        self.currentChatMessageFactoriesMapper = currentChatMessageFactoriesMapper
        self.sendingMessageFactory = sendingMessageFactory
        self.operatorFactory = operatorFactory
        self.accessChecker = accessChecker
        self.webimActions = webimActions
        self.messageHolder = messageHolder
        self.messageComposingHandler = messageComposingHandler
        self.locationSettingsHolder = locationSettingsHolder
    }
    
    
    // MARK: - Methods
    
    func set(invitationState: InvitationStateItem) {
        self.invitationState = invitationState
        isChatIsOpening = false
    }
    
    func receivingFullUpdateOf(chat: ChatItem?) throws {
        try changingChatStateOf(chat: chat)
    }
    
    func changingChatStateOf(chat: ChatItem?) throws {
        let previousChat = self.chat
        self.chat = chat
        
        if self.chat != previousChat {
            try messageHolder.receiving(chat: self.chat,
                                        previousChat: previousChat,
                                        newMessages: (self.chat == nil) ? [MessageImpl]() : currentChatMessageFactoriesMapper.mapAll(messages: self.chat!.getMessages()))
        }
        
        let newChatState = (self.chat == nil) ? .CLOSED : self.chat?.getState()
        if (chatStateListener != nil)
            && (lastChatState != newChatState) {
            chatStateListener?.changed(state: publicState(ofChatState: lastChatState),
                                       to: publicState(ofChatState: newChatState!))
        }
        lastChatState = newChatState!
        
        let newOperator = operatorFactory.createOperatorFrom(operatorItem: (self.chat == nil) ? nil : self.chat?.getOperator())
        if newOperator != currentOperator {
            let previousOperator = currentOperator
            currentOperator = newOperator
            
            if currentOperatorChangeListener != nil {
                currentOperatorChangeListener?.changed(operator: previousOperator!,
                                                       to: newOperator!)
            }
        }
        
        let operatorTypingStatus = (chat != nil)
            && (chat?.isOperatorTyping())!
        if (operatorTypingListener != nil)
            && (lastOperatorTypingStatus != operatorTypingStatus) {
            operatorTypingListener?.onOperatorTypingStateChanged(isTyping: operatorTypingStatus)
        }
        lastOperatorTypingStatus = operatorTypingStatus
    }
    
    func saveLocationSettingsOn(fullUpdate: FullUpdate) {
        let hintsEnabled = (fullUpdate.getHintsEnabled() == true)
        
        let previousLocationSettings = locationSettingsHolder.getLocationSettings()
        let newLocationSettings = LocationSettingsImpl(withHintsEnabled: hintsEnabled)
        
        let newLocationSettingsReceived = locationSettingsHolder.receiving(locationSettings: newLocationSettings)
        
        if newLocationSettingsReceived
            && (locationSettingsChangeListener != nil) {
            locationSettingsChangeListener!.changed(locationSettings: previousLocationSettings,
                                                    to: newLocationSettings)
        }
    }
    
    
    // MARK: - MessageStream protocol methods
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func getChatState() -> ChatState {
        return publicState(ofChatState: lastChatState)
    }
    
    func getLocationSettings() -> LocationSettings {
        return locationSettingsHolder.getLocationSettings()
    }
    
    func getCurrentOperator() -> Operator? {
        return currentOperator
    }
    
    func getLastRatingOfOperatorWith(id: String) -> Int {
        let rating = (chat == nil) ? nil : chat?.getOperatorIDToRate()?[id]
        return (rating == nil) ? 0 : (rating?.getRating())!
    }
    
    
    func rateOperatorWith(id: String,
                          byRating rating: Int) throws {
        if let ratingValue = convertToInternal(rating: rating) {
            try checkAccess()
            
            webimActions.rateOperatorWith(id: id,
                                          rating: ratingValue)
        }
    }
    
    func startChat() throws {
        try checkAccess()
        
        openChatIfNecessary()
    }
    
    func closeChat() throws {
        try checkAccess()
        
        let chatIsOpen = ((lastChatState != .CLOSED_BY_VISITOR)
            && (lastChatState != .CLOSED))
            && (lastChatState != .UNKNOWN)
        if chatIsOpen {
            webimActions.closeChat()
        }
    }
    
    func setVisitorTyping(draftMessage: String?) throws {
        try checkAccess()
        
        messageComposingHandler.setComposing(draft: draftMessage)
    }
    
    func send(message: String,
              isHintQuestion: Bool? = nil) throws -> String {
        try checkAccess()
        
        openChatIfNecessary()
        
        let messageID = ClientSideID.generateClientSideID()
        webimActions.send(message: message,
                          clientSideID: messageID,
                          isHintQuestion: isHintQuestion)
        
        messageHolder.sending(message: sendingMessageFactory.createTextMessageToSendWith(id: messageID,
                                                                                         text: message))
        
        return messageID
    }
    
    func send(message: String) throws -> String {
        return try send(message: message,
                        isHintQuestion: nil)
    }
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler?) throws -> String {
        try checkAccess()
        
        openChatIfNecessary()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID))
        
        webimActions.send(file: file,
                          filename: filename,
                          mimeType: mimeType,
                          clientSideID: messageID,
                          completionHandler: completionHandler)
        
        return messageID
    }
    
    func new(messageTracker messageListener: MessageListener) throws -> MessageTracker {
        try checkAccess()
        
        return try messageHolder.newMessageTracker(withMessageListener: messageListener) as MessageTracker
    }
    
    func set(chatStateListener: ChatStateListener) {
        self.chatStateListener = chatStateListener
    }
    
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener) {
        self.currentOperatorChangeListener = currentOperatorChangeListener
    }
    
    func set(operatorTypingListener: OperatorTypingListener) {
        self.operatorTypingListener = operatorTypingListener
    }
    
    func set(locationSettingsChangeListener: LocationSettingsChangeListener) {
        self.locationSettingsChangeListener = locationSettingsChangeListener
    }
    
    
    // MARK: - Private methods
    
    private func publicState(ofChatState chatState: ChatItem.ChatItemState) -> ChatState {
        switch chatState {
        case .QUEUE:
            return ChatState.QUEUE
        case .CHATTING:
            return ChatState.CHATTING
        case .CLOSED:
            return ChatState.NONE
        case .CLOSED_BY_VISITOR:
            return ChatState.CLOSED_BY_VISITOR
        case .CLOSED_BY_OPERATOR:
            return ChatState.CLOSED_BY_OPERATOR
        case .INVITATION:
            return ChatState.INVITATION
        default:
            return ChatState.UNKNOWN
        }
    }
    
    private func checkAccess() throws {
        try accessChecker.checkAccess()
    }
    
    private func openChatIfNecessary() {
        if (lastChatState.isClosed()
            || (invitationState == .OFFLINE_MESSAGE))
            && (isChatIsOpening != true) {
            webimActions.startChat(withClientSideID: ClientSideID.generateClientSideID())
        }
    }
    
    private func convertToInternal(rating: Int) -> Int? {
        switch rating {
        case 1:
            return -2
        case 2:
            return -1
        case 3:
            return 0
        case 4:
            return 1
        case 5:
            return 2
        default:
            print("Rating must be within from 1 to 5 range. Passed value: \(rating)")
            return nil
        }
    }
    
}
