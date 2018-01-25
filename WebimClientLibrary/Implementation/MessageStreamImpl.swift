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
final class MessageStreamImpl {
    
    // MARK: - Properties
    private let accessChecker: AccessChecker
    private let currentChatMessageFactoriesMapper: MessageFactoriesMapper
    private let locationSettingsHolder: LocationSettingsHolder
    private let messageComposingHandler: MessageComposingHandler
    private let messageHolder: MessageHolder
    private let sendingMessageFactory: SendingFactory
    private let serverURLString: String
    private let webimActions: WebimActions
    private var chat: ChatItem?
    private var chatStateListener: ChatStateListener?
    private var currentOperator: OperatorImpl?
    private var departmentList: [Department]?
    private var departmentListChangeListener: DepartmentListChangeListener?
    private var currentOperatorChangeListener: CurrentOperatorChangeListener?
    private var isChatIsOpening = false
    private var lastChatState: ChatItem.ChatItemState = .CLOSED
    private var lastOperatorTypingStatus: Bool?
    private var locationSettingsChangeListener: LocationSettingsChangeListener?
    private var operatorFactory: OperatorFactory
    private var operatorTypingListener: OperatorTypingListener?
    private var onlineStatus: OnlineStatusItem = .UNKNOWN
    private var onlineStatusChangeListener: OnlineStatusChangeListener?
    private var unreadByOperatorTimestamp: Date?
    private var unreadByVisitorTimestamp: Date?
    private var visitSessionState: VisitSessionStateItem = .UNKNOWN
    private var visitSessionStateListener: VisitSessionStateListener?
    
    
    // MARK: - Initialization
    init(serverURLString: String,
         currentChatMessageFactoriesMapper: MessageFactoriesMapper,
         sendingMessageFactory: SendingFactory,
         operatorFactory: OperatorFactory,
         accessChecker: AccessChecker,
         webimActions: WebimActions,
         messageHolder: MessageHolder,
         messageComposingHandler: MessageComposingHandler,
         locationSettingsHolder: LocationSettingsHolder) {
        self.serverURLString = serverURLString
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
    
    func set(visitSessionState: VisitSessionStateItem) {
        let previousVisitSessionState = self.visitSessionState
        self.visitSessionState = visitSessionState
        
        isChatIsOpening = false
        
        visitSessionStateListener?.changed(state: publicState(ofVisitSessionState: previousVisitSessionState),
                                           to: publicState(ofVisitSessionState: visitSessionState))
    }
    
    func set(onlineStatus: OnlineStatusItem) {
        self.onlineStatus = onlineStatus
    }
    
    func set(unreadByVisitorTimestamp: Date) {
        self.unreadByVisitorTimestamp = unreadByVisitorTimestamp
    }
    
    func changingChatStateOf(chat: ChatItem?) {
        let previousChat = self.chat
        self.chat = chat
        
        if self.chat != previousChat {
            messageHolder.receiving(newChat: self.chat,
                                    previousChat: previousChat,
                                    newMessages: (self.chat == nil) ? [MessageImpl]() : currentChatMessageFactoriesMapper.mapAll(messages: self.chat!.getMessages()))
        }
        
        let newChatState = (self.chat == nil) ? .CLOSED : self.chat!.getState()
        if (chatStateListener != nil)
            && (lastChatState != newChatState) {
            chatStateListener!.changed(state: publicState(ofChatState: lastChatState),
                                       to: publicState(ofChatState: newChatState))
        }
        lastChatState = newChatState
        
        let newOperator = operatorFactory.createOperatorFrom(operatorItem: (self.chat != nil) ? self.chat!.getOperator() : nil)
        if newOperator != currentOperator {
            let previousOperator = currentOperator
            currentOperator = newOperator
            
            currentOperatorChangeListener?.changed(operator: previousOperator!,
                                                       to: newOperator)
        }
        
        let operatorTypingStatus = (chat != nil)
            && (chat?.isOperatorTyping())!
        if (operatorTypingListener != nil)
            && (lastOperatorTypingStatus != operatorTypingStatus) {
            operatorTypingListener!.onOperatorTypingStateChanged(isTyping: operatorTypingStatus)
        }
        lastOperatorTypingStatus = operatorTypingStatus
        
        if let unreadByOperatorTimestamp = chat?.getUnreadByOperatorTimestamp() {
            self.unreadByOperatorTimestamp = Date(timeIntervalSince1970: unreadByOperatorTimestamp)
        }
        
        if let unreadByVisitorTimestamp = chat?.getUnreadByVisitorTimestamp() {
            self.unreadByVisitorTimestamp = Date(timeIntervalSince1970: unreadByVisitorTimestamp)
        }
        if chat?.getReadByVisitor() == true {
            // Set unread messages by visitor timestamp to current date after receiving information that chat is read by visitor.
            unreadByVisitorTimestamp = Date()
        }
    }
    
    func saveLocationSettingsOn(fullUpdate: FullUpdate) {
        let hintsEnabled = (fullUpdate.getHintsEnabled() == true)
        
        let previousLocationSettings = locationSettingsHolder.getLocationSettings()
        let newLocationSettings = LocationSettingsImpl(hintsEnabled: hintsEnabled)
        
        let newLocationSettingsReceived = locationSettingsHolder.receiving(locationSettings: newLocationSettings)
        
        if newLocationSettingsReceived
            && (locationSettingsChangeListener != nil) {
            locationSettingsChangeListener!.changed(locationSettings: previousLocationSettings,
                                                    to: newLocationSettings)
        }
    }
    
    func onOnlineStatusChanged(to newOnlineStatus: OnlineStatusItem) {
        let previousPublicOnlineStatus = publicState(ofOnlineStatus: onlineStatus)
        let newPublicOnlineStatus = publicState(ofOnlineStatus: newOnlineStatus)
        
        if onlineStatusChangeListener != nil
            && (onlineStatus != newOnlineStatus) {
            onlineStatusChangeListener!.changed(onlineStatus: previousPublicOnlineStatus,
                                                to: newPublicOnlineStatus)
        }
        
        onlineStatus = newOnlineStatus
    }
    
    func onReceiving(departmentItemList: [DepartmentItem]) {
        var departmentList = [Department]()
        for departmentItem in departmentItemList {
            var fullLogoURL: URL? = nil
            if let logoURLString = departmentItem.getLogoURLString() {
                fullLogoURL = URL(string: serverURLString + logoURLString)
            }
            
            let department = DepartmentImpl(key: departmentItem.getKey(),
                                            name: departmentItem.getName(),
                                            departmentOnlineStatus: publicState(ofDepartmentOnlineStatus: departmentItem.getOnlineStatus()),
                                            order: departmentItem.getOrder(),
                                            localizedNames: departmentItem.getLocalizedNames(),
                                            logo: fullLogoURL)
            departmentList.append(department)
        }
        self.departmentList = departmentList
        
        departmentListChangeListener?.received(departmentList: departmentList)
    }
    
    // MARK: Private methods
    
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
    
    private func publicState(ofOnlineStatus onlineStatus: OnlineStatusItem) -> OnlineStatus {
        switch onlineStatus {
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
    
    private func publicState(ofVisitSessionState visitSessionState: VisitSessionStateItem) -> VisitSessionState {
        switch visitSessionState {
        case .CHAT:
            return .CHAT
        case .DEPARTMENT_SELECTION:
            return .DEPARTMENT_SELECTION
        case .IDLE:
            return .IDLE
        case .IDLE_AFTER_CHAT:
            return .IDLE_AFTER_CHAT
        case .OFFLINE_MESSAGE:
            return .OFFLINE_MESSAGE
        default:
            return .UNKNOWN
        }
    }
    
    private func publicState(ofDepartmentOnlineStatus departmentOnlineStatus: DepartmentItem.InternalDepartmentOnlineStatus) -> DepartmentOnlineStatus {
        switch departmentOnlineStatus {
        case .BUSY_OFFLINE:
            return .BUSY_OFFLINE
        case .BUSY_ONLINE:
            return .BUSY_ONLINE
        case .OFFLINE:
            return .OFFLINE
        case .ONLINE:
            return .ONLINE
        case .UNKNOWN:
            return .UNKNOWN
        }
    }
    
}

// MARK: - MessageStream
extension MessageStreamImpl: MessageStream {
    
    func getVisitSessionState() -> VisitSessionState {
        return publicState(ofVisitSessionState: visitSessionState)
    }
    
    func getChatState() -> ChatState {
        return publicState(ofChatState: lastChatState)
    }
    
    func getUnreadByOperatorTimestamp() -> Date? {
        return unreadByOperatorTimestamp
    }
    
    func getUnreadByVisitorTimestamp() -> Date? {
        return unreadByVisitorTimestamp
    }
    
    func getDepartmentList() -> [Department]? {
        return departmentList
    }
    
    func getLocationSettings() -> LocationSettings {
        return locationSettingsHolder.getLocationSettings()
    }
    
    func getCurrentOperator() -> Operator? {
        return currentOperator
    }
    
    func getLastRatingOfOperatorWith(id: String) -> Int {
        let rating = ((chat != nil) ? chat!.getOperatorIDToRate()?[id] : nil)
        
        return ((rating == nil) ? 0 : rating!.getRating())
    }
    
    
    func rateOperatorWith(id: String?,
                          byRating rating: Int,
                          comletionHandler: RateOperatorCompletionHandler?) throws {
        if let ratingValue = convertToInternal(rating: rating) {
            try accessChecker.checkAccess()
            
            webimActions.rateOperatorWith(id: id,
                                          rating: ratingValue,
                                          completionHandler: comletionHandler)
        }
    }
    
    func startChat() throws {
        try startChat(departmentKey: nil,
                      firstQuestion: nil)
    }
    
    func startChat(firstQuestion: String?) throws {
        try startChat(departmentKey: nil,
                      firstQuestion: firstQuestion)
    }
    
    func startChat(departmentKey: String?) throws {
        try startChat(departmentKey: departmentKey,
                      firstQuestion: nil)
    }
    
    func startChat(departmentKey: String?,
                   firstQuestion: String?) throws {
        try accessChecker.checkAccess()
        
        if (lastChatState.isClosed()
            || (visitSessionState == .OFFLINE_MESSAGE))
            && !isChatIsOpening {
            webimActions.startChat(withClientSideID: ClientSideID.generateClientSideID(),
                                   firstQuestion: firstQuestion,
                                   departmentKey: departmentKey)
        }
    }
    
    func closeChat() throws {
        try accessChecker.checkAccess()
        
        let chatIsOpen = ((lastChatState != .CLOSED_BY_VISITOR)
            && (lastChatState != .CLOSED))
            && (lastChatState != .UNKNOWN)
        if chatIsOpen {
            webimActions.closeChat()
        }
    }
    
    func setVisitorTyping(draftMessage: String?) throws {
        try accessChecker.checkAccess()
        
        messageComposingHandler.setComposing(draft: draftMessage)
    }
    
    func send(message: String) throws -> String {
        return try sendMessageInternally(messageText: message)
    }
    
    func send(message: String,
              data: [String: Any]?,
              completionHandler: DataMessageCompletionHandler?) throws -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data as Any,
                                                      options: []) {
            let jsonString = String(data: jsonData,
                                    encoding: .utf8)
            
            return try sendMessageInternally(messageText: message,
                                             dataJSONString: jsonString,
                                             dataMessageCompletionHandler: completionHandler)
        } else {
            return try sendMessageInternally(messageText: message)
        }
    }
    
    func send(message: String,
              isHintQuestion: Bool?) throws -> String {
        return try sendMessageInternally(messageText: message,
                                         isHintQuestion: isHintQuestion)
    }
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler?) throws -> String {
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID))
        
        webimActions.send(file: file,
                          filename: filename,
                          mimeType: mimeType,
                          clientSideID: messageID,
                          completionHandler: completionHandler)
        
        return messageID
    }
    
    func newMessageTracker(messageListener: MessageListener) throws -> MessageTracker {
        try accessChecker.checkAccess()
        
        return try messageHolder.newMessageTracker(withMessageListener: messageListener) as MessageTracker
    }
    
    func set(visitSessionStateListener: VisitSessionStateListener) {
        self.visitSessionStateListener = visitSessionStateListener
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
    
    func set(departmentListChangeListener: DepartmentListChangeListener) {
        self.departmentListChangeListener = departmentListChangeListener
    }
    
    func set(locationSettingsChangeListener: LocationSettingsChangeListener) {
        self.locationSettingsChangeListener = locationSettingsChangeListener
    }
    
    func set(onlineStatusChangeListener: OnlineStatusChangeListener) {
        self.onlineStatusChangeListener = onlineStatusChangeListener
    }
    
    // MARK: Private methods
    
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
            WebimInternalLogger.shared.log(entry: "Rating must be within from 1 to 5 range. Passed value: \(rating)",
                verbosityLevel: .WARNING)
            
            return nil
        }
    }
    
    private func sendMessageInternally(messageText: String,
                                       dataJSONString: String? = nil,
                                       isHintQuestion: Bool? = nil,
                                       dataMessageCompletionHandler: DataMessageCompletionHandler? = nil) throws -> String {
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        webimActions.send(message: messageText,
                          clientSideID: messageID,
                          dataJSONString: dataJSONString,
                          isHintQuestion: isHintQuestion,
                          dataMessageCompletionHandler: dataMessageCompletionHandler)
        messageHolder.sending(message: sendingMessageFactory.createTextMessageToSendWith(id: messageID,
                                                                                         text: messageText))
        
        return messageID
    }
    
}
