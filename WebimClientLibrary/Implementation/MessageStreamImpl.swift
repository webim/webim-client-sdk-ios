//
//  MessageStreamImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
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
    private var sessionOnlineStatus: SessionOnlineStatusItem = .UNKNOWN
    private var sessionOnlineStatusChangeListener: SessionOnlineStatusChangeListener?
    
    
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
    
    func getWebimActions() -> WebimActions {
        return webimActions
    }
    
    func set(invitationState: InvitationStateItem) {
        self.invitationState = invitationState
        
        isChatIsOpening = false
    }
    
    func set(sessionOnlineStatus: SessionOnlineStatusItem) {
        self.sessionOnlineStatus = sessionOnlineStatus
    }
    
    func receivingFullUpdateOf(chat: ChatItem?) {
        changingChatStateOf(chat: chat)
    }
    
    func changingChatStateOf(chat: ChatItem?) {
        let previousChat = self.chat
        self.chat = chat
        
        if self.chat !== previousChat {
            messageHolder.receiving(newChat: self.chat,
                                    previousChat: previousChat,
                                    newMessages: (self.chat == nil) ? [MessageImpl]() : currentChatMessageFactoriesMapper.mapAll(messages: self.chat!.getMessages()))
        }
        
        let newChatState = (self.chat == nil) ? .CLOSED : self.chat!.getState()
        if (chatStateListener != nil)
            && (lastChatState != newChatState) {
            chatStateListener?.changed(state: publicState(ofChatState: lastChatState),
                                       to: publicState(ofChatState: newChatState))
        }
        lastChatState = newChatState
        
        let newOperator = operatorFactory.createOperatorFrom(operatorItem: (self.chat == nil) ? nil : self.chat!.getOperator())
        if newOperator != currentOperator {
            let previousOperator = currentOperator
            currentOperator = newOperator
            
            if currentOperatorChangeListener != nil {
                currentOperatorChangeListener!.changed(operator: previousOperator!,
                                                       to: newOperator)
            }
        }
        
        let operatorTypingStatus = (chat != nil)
            && (chat?.isOperatorTyping())!
        if (operatorTypingListener != nil)
            && (lastOperatorTypingStatus != operatorTypingStatus) {
            operatorTypingListener!.onOperatorTypingStateChanged(isTyping: operatorTypingStatus)
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
    
    func onSessionOnlineStatusChanged(to newSessionOnlineStatus: SessionOnlineStatusItem) {
        let previousPublicSessionOnlineStatus = publicState(ofSessionOnlineState: sessionOnlineStatus)
        let newPublicSessionOnlineStatus = publicState(ofSessionOnlineState: newSessionOnlineStatus)
        
        if sessionOnlineStatusChangeListener != nil
            && (sessionOnlineStatus != newSessionOnlineStatus) {
            sessionOnlineStatusChangeListener!.changed(sessionOnlineStatus: previousPublicSessionOnlineStatus,
                                                       to: newPublicSessionOnlineStatus)
        }
        
        sessionOnlineStatus = newSessionOnlineStatus
    }
    
    
    // MARK: - MessageStream protocol methods
    
    func getChat() -> ChatItem? {
        return chat
    }
    
    func set(chat: ChatItem) {
        self.chat = chat
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
        let rating = (chat == nil) ? nil : chat!.getOperatorIDToRate()?[id]
        
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
    
    func set(sessionOnlineStatusChangeListener: SessionOnlineStatusChangeListener) {
        self.sessionOnlineStatusChangeListener = sessionOnlineStatusChangeListener
    }
    
    
    // MARK: - Private methods
    
    private func publicState(ofChatState chatState: ChatItem.ChatItemState) -> ChatState {
        switch chatState {
        case .QUEUE:
            return .QUEUE
        case .CHATTING:
            return .CHATTING
        case .CLOSED:
            return .NONE
        case .CLOSED_BY_VISITOR:
            return .CLOSED_BY_VISITOR
        case .CLOSED_BY_OPERATOR:
            return .CLOSED_BY_OPERATOR
        case .INVITATION:
            return .INVITATION
        default:
            return .UNKNOWN
        }
    }
    
    private func publicState(ofSessionOnlineState sessionOnlineState: SessionOnlineStatusItem) -> SessionOnlineStatus {
        switch sessionOnlineState {
        case .BUSY_OFFLINE:
            return .BUSY_OFFLINE
        case .BUSY_ONLINE:
            return .BUSY_ONLINE
        case .OFFLINE:
            return .OFFLINE
        case .ONLINE:
            return .ONLINE
        default:
            return .UNKNOWN
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
