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
 Class that responsible for handling full set of events inside message stream.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MessageStreamImpl {
    
    // MARK: - Properties
    private let accessChecker: AccessChecker
    private let currentChatMessageFactoriesMapper: MessageMapper
    private let locationSettingsHolder: LocationSettingsHolder
    private let messageComposingHandler: MessageComposingHandler
    private let messageHolder: MessageHolder
    private let sendingMessageFactory: SendingFactory
    private let serverURLString: String
    private let webimActions: WebimActions
    private var chat: ChatItem?
    private weak var chatStateListener: ChatStateListener?
    private var currentOperator: OperatorImpl?
    private var departmentList: [Department]?
    private weak var departmentListChangeListener: DepartmentListChangeListener?
    private weak var currentOperatorChangeListener: CurrentOperatorChangeListener?
    private var isChatIsOpening = false
    private var lastChatState: ChatItem.ChatItemState = .unknown
    private var lastOperatorTypingStatus: Bool?
    private weak var locationSettingsChangeListener: LocationSettingsChangeListener?
    private var operatorFactory: OperatorFactory
    private weak var operatorTypingListener: OperatorTypingListener?
    private var onlineStatus: OnlineStatusItem = .unknown
    private weak var onlineStatusChangeListener: OnlineStatusChangeListener?
    private var surveyFactory: SurveyFactory
    private var unreadByOperatorTimestamp: Date?
    private weak var unreadByOperatorTimestampChangeListener: UnreadByOperatorTimestampChangeListener?
    private var unreadByVisitorMessageCount: Int
    private weak var unreadByVisitorMessageCountChangeListener: UnreadByVisitorMessageCountChangeListener?
    private var unreadByVisitorTimestamp: Date?
    private weak var unreadByVisitorTimestampChangeListener: UnreadByVisitorTimestampChangeListener?
    private var visitSessionState: VisitSessionStateItem = .unknown
    private weak var visitSessionStateListener: VisitSessionStateListener?
    private var surveyController: SurveyController?
    private var helloMessage: String?
    private weak var helloMessageListener: HelloMessageListener?
    
    // MARK: - Initialization
    init(serverURLString: String,
         currentChatMessageFactoriesMapper: MessageMapper,
         sendingMessageFactory: SendingFactory,
         operatorFactory: OperatorFactory,
         surveyFactory: SurveyFactory,
         accessChecker: AccessChecker,
         webimActions: WebimActions,
         messageHolder: MessageHolder,
         messageComposingHandler: MessageComposingHandler,
         locationSettingsHolder: LocationSettingsHolder) {
        self.serverURLString = serverURLString
        self.currentChatMessageFactoriesMapper = currentChatMessageFactoriesMapper
        self.sendingMessageFactory = sendingMessageFactory
        self.operatorFactory = operatorFactory
        self.surveyFactory = surveyFactory
        self.accessChecker = accessChecker
        self.webimActions = webimActions
        self.messageHolder = messageHolder
        self.messageComposingHandler = messageComposingHandler
        self.locationSettingsHolder = locationSettingsHolder
        self.unreadByVisitorMessageCount = -1
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
    
    func set(unreadByOperatorTimestamp: Date?) {
        let previousValue = self.unreadByOperatorTimestamp
        
        self.unreadByOperatorTimestamp = unreadByOperatorTimestamp
        
        if previousValue != unreadByOperatorTimestamp {
            unreadByOperatorTimestampChangeListener?.changedUnreadByOperatorTimestampTo(newValue: self.unreadByOperatorTimestamp)
        }
    }
    
    func set(unreadByVisitorTimestamp: Date?) {
        let previousValue = self.unreadByVisitorTimestamp
        
        self.unreadByVisitorTimestamp = unreadByVisitorTimestamp
        
        if previousValue != unreadByVisitorTimestamp {
            unreadByVisitorTimestampChangeListener?.changedUnreadByVisitorTimestampTo(newValue: self.unreadByVisitorTimestamp)
        }
    }
    
    func set(unreadByVisitorMessageCount: Int) {
        let previousValue = self.unreadByVisitorMessageCount
        
        self.unreadByVisitorMessageCount = unreadByVisitorMessageCount
        
        if previousValue != unreadByVisitorMessageCount {
            unreadByVisitorMessageCountChangeListener?.changedUnreadByVisitorMessageCountTo(newValue: self.unreadByVisitorMessageCount)
        }
    }
    
    func changingChatStateOf(chat: ChatItem?) {
        guard let chat = chat else {
            messageHolder.receiving(newChat: self.chat,
                                    previousChat: nil,
                                    newMessages: [MessageImpl]())
            chatStateListener?.changed(state: publicState(ofChatState: lastChatState),
                                       to: publicState(ofChatState: ChatItem.ChatItemState.closed))
            lastChatState = ChatItem.ChatItemState.closed
            let newOperator = operatorFactory.createOperatorFrom(operatorItem: nil)
            let previousOperator = currentOperator
            currentOperatorChangeListener?.changed(operator: previousOperator,
                                                   to: newOperator)
            currentOperator = newOperator
            operatorTypingListener?.onOperatorTypingStateChanged(isTyping: false)
            return
        }
        let previousChat = self.chat
        self.chat = chat
        
        messageHolder.receiving(newChat: self.chat,
                                previousChat: previousChat,
                                newMessages: currentChatMessageFactoriesMapper.mapAll(messages: chat.getMessages()))
        
        let newChatState = chat.getState()
        if let newChatState = newChatState {
            // Recieved chat state can be unsupported by the library.
            if lastChatState != newChatState {
                chatStateListener?.changed(state: publicState(ofChatState: lastChatState),
                                           to: publicState(ofChatState: newChatState))
            }
            lastChatState = newChatState
        }
        
        let newOperator = operatorFactory.createOperatorFrom(operatorItem: self.chat?.getOperator())
        if newOperator != currentOperator {
            let previousOperator = currentOperator
            currentOperator = newOperator
            
            currentOperatorChangeListener?.changed(operator: previousOperator,
                                                       to: newOperator)
        }
        
        let operatorTypingStatus = chat.isOperatorTyping()
        if lastOperatorTypingStatus != operatorTypingStatus {
            operatorTypingListener?.onOperatorTypingStateChanged(isTyping: operatorTypingStatus)
        }
        lastOperatorTypingStatus = operatorTypingStatus
        
        if let unreadByOperatorTimestamp = chat.getUnreadByOperatorTimestamp() {
            set(unreadByOperatorTimestamp: Date(timeIntervalSince1970: unreadByOperatorTimestamp))
        }
        
        let unreadByVisitorMessageCount = chat.getUnreadByVisitorMessageCount()
        set(unreadByVisitorMessageCount: unreadByVisitorMessageCount)
        
        if let unreadByVisitorTimestamp = chat.getUnreadByVisitorTimestamp() {
            set(unreadByVisitorTimestamp: Date(timeIntervalSince1970: unreadByVisitorTimestamp))
        }
        if chat.getReadByVisitor() == true {
            set(unreadByVisitorTimestamp: nil)
        }
    }
    
    func saveLocationSettingsOn(fullUpdate: FullUpdate) {
        let hintsEnabled = (fullUpdate.getHintsEnabled() == true)
        
        let previousLocationSettings = locationSettingsHolder.getLocationSettings()
        let newLocationSettings = LocationSettingsImpl(hintsEnabled: hintsEnabled)
        
        let newLocationSettingsReceived = locationSettingsHolder.receiving(locationSettings: newLocationSettings)
        
        if newLocationSettingsReceived {
            locationSettingsChangeListener?.changed(locationSettings: previousLocationSettings,
                                                    to: newLocationSettings)
        }
    }
    
    func onOnlineStatusChanged(to newOnlineStatus: OnlineStatusItem) {
        let previousPublicOnlineStatus = publicState(ofOnlineStatus: onlineStatus)
        let newPublicOnlineStatus = publicState(ofOnlineStatus: newOnlineStatus)
        
        if onlineStatus != newOnlineStatus {
            onlineStatusChangeListener?.changed(onlineStatus: previousPublicOnlineStatus,
                                                to: newPublicOnlineStatus)
        }
        
        onlineStatus = newOnlineStatus
    }
    
    func onReceiving(departmentItemList: [DepartmentItem]) {
        var departmentList = [Department]()
        let departmentFactory = DepartmentFactory(serverURLString: serverURLString)
        for departmentItem in departmentItemList {
            let department = departmentFactory.convert(departmentItem: departmentItem)
            departmentList.append(department)
        }
        self.departmentList = departmentList
        
        departmentListChangeListener?.received(departmentList: departmentList)
    }
    
    func onReceived(surveyItem: SurveyItem) {
        if let surveyController = surveyController,
            let survey = surveyFactory.createSurveyFrom(surveyItem: surveyItem) {
            surveyController.set(survey: survey)
            surveyController.nextQuestion()
        }
    }

    func onSurveyCancelled() {
        if let surveyController = surveyController {
            surveyController.cancelSurvey()
        }
    }
    
    func handleHelloMessage(showHelloMessage: Bool?,
                            chatStartAfterMessage: Bool?,
                            currentChatEmpty: Bool?,
                            helloMessageDescr: String?) {
        guard helloMessageListener != nil,
              let showHelloMessage = showHelloMessage,
              let chatStartAfterMessage = chatStartAfterMessage,
              let currentChatEmpty = currentChatEmpty,
              let helloMessageDescr = helloMessageDescr else {
            return
        }
        
        if showHelloMessage && chatStartAfterMessage && currentChatEmpty && messageHolder.historyMessagesEmpty() {
            helloMessageListener?.helloMessage(message: helloMessageDescr)
        }
    }
    
    // MARK: Private methods
    
    private func publicState(ofChatState chatState: ChatItem.ChatItemState) -> ChatState {
        switch chatState {
        case .queue:
            return .queue
        case .chatting:
            return .chatting
        case .chattingWithRobot:
            return .chattingWithRobot
        case .closed:
            return .closed
        case .closedByVisitor:
            return .closedByVisitor
        case .closedByOperator:
            return .closedByOperator
        case .invitation:
            return .invitation
        default:
            return .unknown
        }
    }
    
    private func publicState(ofOnlineStatus onlineStatus: OnlineStatusItem) -> OnlineStatus {
        switch onlineStatus {
        case .busyOffline:
            return .busyOffline
        case .busyOnline:
            return .busyOnline
        case .offline:
            return .offline
        case .online:
            return .online
        default:
            return .unknown
        }
    }
    
    private func publicState(ofVisitSessionState visitSessionState: VisitSessionStateItem) -> VisitSessionState {
        switch visitSessionState {
        case .chat:
            return .chat
        case .departmentSelection:
            return .departmentSelection
        case .idle:
            return .idle
        case .idleAfterChat:
            return .idleAfterChat
        case .offlineMessage:
            return .offlineMessage
        default:
            return .unknown
        }
    }
    
}

// MARK: - MessageStream
extension MessageStreamImpl: MessageStream {
    
    // MARK: - Methods
    
    func getVisitSessionState() -> VisitSessionState {
        return publicState(ofVisitSessionState: visitSessionState)
    }
    
    func getChatState() -> ChatState {
        return publicState(ofChatState: lastChatState)
    }
    
    func getUnreadByOperatorTimestamp() -> Date? {
        return unreadByOperatorTimestamp
    }
    
    func getUnreadByVisitorMessageCount() -> Int {
        return (unreadByVisitorMessageCount > 0) ? unreadByVisitorMessageCount : 0
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
        // rating in [-2, 2]
        let rating = chat?.getOperatorIDToRate()?[id]
        
        // rating in [1, 5]
        return (rating?.getRating() ?? -3) + 3
    }
    
    func rateOperatorWith(id: String?, byRating rating: Int, completionHandler: RateOperatorCompletionHandler?) throws {
        try rateOperatorWith(id: id, note: nil, byRating: rating, completionHandler: completionHandler)
    }
    
    func rateOperatorWith(id: String?,
                          note: String?,
                          byRating rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) throws {
        guard rating >= 1,
            rating <= 5 else {
            WebimInternalLogger.shared.log(entry: "Rating must be within from 1 to 5 range. Passed value: \(rating)",
                verbosityLevel: .warning)
            
            return
        }
        
        try accessChecker.checkAccess()
        
        webimActions.rateOperatorWith(id: id,
                                      rating: (rating - 3), // Accepted range: (-2, -1, 0, 1, 2).
                                      visitorNote: note,
                                      completionHandler: completionHandler)
    }
    
    func respondSentryCall(id: String) throws {
        try accessChecker.checkAccess()
        
        webimActions.respondSentryCall(id: id)
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
    
    func startChat(customFields:String?) throws {
        try startChat(departmentKey: nil, firstQuestion: nil, customFields: customFields)
    }
    
    func startChat(firstQuestion:String?, customFields: String?) throws {
        try startChat(departmentKey: nil, firstQuestion: firstQuestion, customFields: customFields)
    }
    
    func startChat(departmentKey: String?, customFields: String?) throws {
        try startChat(departmentKey: departmentKey, firstQuestion: nil, customFields: customFields)
    }
    
    func startChat(departmentKey: String?, firstQuestion: String?) throws {
        try startChat(departmentKey: departmentKey, firstQuestion: firstQuestion, customFields: nil)
    }
    
    func startChat(departmentKey: String?,
                   firstQuestion: String?,
                   customFields: String?) throws {
        try accessChecker.checkAccess()
        
        if (lastChatState.isClosed()
            || (visitSessionState == .offlineMessage))
            && !isChatIsOpening {
            webimActions.startChat(withClientSideID: ClientSideID.generateClientSideID(),
                                   firstQuestion: firstQuestion,
                                   departmentKey: departmentKey,
                                   customFields: customFields)
        }
    }
    
    func closeChat() throws {
        try accessChecker.checkAccess()
        if !lastChatState.isClosed() {
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
    
    func send(message: String, completionHandler: SendMessageCompletionHandler?) throws -> String {
        return try sendMessageInternally(messageText: message, sendMessageComplitionHandler: completionHandler)
    }
    
    func send(message: String,
              data: [String: Any]?,
              completionHandler: DataMessageCompletionHandler?) throws -> String {
        if let data = data,
            let jsonData = try? JSONSerialization.data(withJSONObject: data as Any,
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
        try accessChecker.checkAccess()
        
        var file = file,
            filename = filename,
            mimeType = mimeType
        
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID))
        
        if mimeType == "image/heic" || mimeType == "image/heif" {
            guard let image = UIImage(data: file),
                let imageData = image.jpegData(compressionQuality: 0.5)
                else {
                print("Error with heic/heif"); return String()
            }
            
            mimeType = "image/jpeg"
            file = imageData
            
            var nameComponents = filename.components(separatedBy: ".")
            if nameComponents.count > 1 {
                nameComponents.removeLast()
                filename = nameComponents.joined(separator: ".")
            }
            filename += ".jpeg"
        }
        
        webimActions.send(file: file,
                          filename: filename,
                          mimeType: mimeType,
                          clientSideID: messageID,
                          completionHandler: SendFileCompletionHandlerWrapper(sendFileCompletionHandler: completionHandler,
                                                                              messageHolder: messageHolder))
        
        return messageID
    }
    
    func send(uploadedFiles: [UploadedFile],
              completionHandler: SendFilesCompletionHandler?) throws -> String {
        try accessChecker.checkAccess()
        
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        if uploadedFiles.isEmpty {
            completionHandler?.onFailure(messageID: messageID, error: .fileNotFound)
            return messageID
        }
        if uploadedFiles.count > 10 {
            completionHandler?.onFailure(messageID: messageID, error: .maxFilesCountPerMessage)
            return messageID
        }
        var message = "[\(uploadedFiles[0].description)"
        for uploadFile in uploadedFiles.dropFirst() {
            message += ", \(uploadFile.description)"
        }
        message += "]"
        messageHolder.sending(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID))
        
        webimActions.sendFiles(message: message,
                               clientSideID: messageID,
                               isHintQuestion: false,
                               sendFilesCompletionHandler: completionHandler)
        
        return messageID
    }
    
    func uploadFilesToServer(file: Data,
                             filename: String,
                             mimeType: String,
                             completionHandler: UploadFileToServerCompletionHandler?) throws -> String {
        try accessChecker.checkAccess()
        
        var file = file
        var filename = filename
        var mimeType = mimeType
        
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        
        if mimeType == "image/heic" || mimeType == "image/heif" {
            guard let image = UIImage(data: file),
                let imageData = image.jpegData(compressionQuality: 0.5)
                else {
                print("Error with heic/heif"); return String()
            }
            
            mimeType = "image/jpeg"
            file = imageData
            
            var nameComponents = filename.components(separatedBy: ".")
            if nameComponents.count > 1 {
                nameComponents.removeLast()
                filename = nameComponents.joined(separator: ".")
            }
            filename += ".jpeg"
        }
        
        webimActions.send(file: file,
                          filename: filename,
                          mimeType: mimeType,
                          clientSideID: messageID,
                          uploadFileToServerCompletionHandler: completionHandler)
        
        return messageID
    }
    
    func deleteUploadedFiles(fileGuid: String,
                             completionHandler: DeleteUploadedFileCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.deleteUploadedFile(fileGuid: fileGuid,
                                        completionHandler: completionHandler)
    }
    
    func sendKeyboardRequest(button: KeyboardButton,
                             message: Message,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.sendKeyboardRequest(buttonId: button.getID(),
                                         messageId: message.getCurrentChatID() ?? "",
                                         completionHandler: completionHandler)
    }
    
    func sendKeyboardRequest(buttonID: String,
                             messageCurrentChatID: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.sendKeyboardRequest(buttonId: buttonID,
                                         messageId: messageCurrentChatID,
                                         completionHandler: completionHandler)
    }
    
    func sendSticker(withId stickerId: Int, completionHandler: SendStickerCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createStickerMessageToSendWith(id: messageID, stickerId: stickerId))
        webimActions.sendSticker(stickerId: stickerId, clientSideId: messageID, completionHandler: completionHandler)
    }
    
    
    func updateWidgetStatus(data: String) throws {
        try accessChecker.checkAccess()
        
        webimActions.updateWidgetStatusWith(data: data)
    }
    
    func reply(message: String, repliedMessage: Message) throws -> String? {
        try startChat()
        
        guard repliedMessage.canBeReplied() else {
            return nil
        }
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createTextMessageToSendWithQuoteWith(id: messageID,
                                                                                                  text: message,
                                                                                                  repliedMessage: repliedMessage))
        webimActions.replay(message: message,
                            clientSideID: messageID,
                            quotedMessageID: repliedMessage.getCurrentChatID() ?? repliedMessage.getID())
        
        return messageID
    }
    
    func edit(message: Message, text: String, completionHandler: EditMessageCompletionHandler?) throws -> Bool {
        try accessChecker.checkAccess()
        
        if !message.canBeEdited() {
            return false
        }
        let id = message.getID()
        let oldMessage = messageHolder.changing(messageID: id, message: text)
        if let oldMessage = oldMessage {
            webimActions.send(message: text,
                              clientSideID: id,
                              dataJSONString: nil,
                              isHintQuestion: false,
                              editMessageCompletionHandler: EditMessageCompletionHandlerWrapper(editMessageCompletionHandler: completionHandler,
                                                                                                messageHolder: messageHolder,
                                                                                                message: oldMessage))
            return true
        }
        return false
    }
    
    func delete(message: Message, completionHandler: DeleteMessageCompletionHandler?) throws -> Bool {
        try accessChecker.checkAccess()
        
        if !message.canBeEdited() {
            return false
        }
        let id = message.getID()
        let oldMessage = messageHolder.changing(messageID: id, message: nil)
        
        if let oldMessage = oldMessage {
            webimActions.delete(clientSideID: id,
                                completionHandler: DeleteMessageCompletionHandlerWrapper(deleteMessageCompletionHandler: completionHandler,
                                                                                         messageHolder: messageHolder,
                                                                                         message: oldMessage))
            return true
        }
        return false
    }
    
    func setChatRead() throws {
        try accessChecker.checkAccess()
        
        webimActions.setChatRead()
    }
    
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?) throws {
        try accessChecker.checkAccess()
        if !lastChatState.isClosed() {
            webimActions.sendDialogTo(emailAddress: emailAddress, completionHandler: completionHandler)
        } else {
            completionHandler?.onFailure(error: .noChat)
        }
    }
    
    func set(prechatFields: String) throws {
        try accessChecker.checkAccess()
        
        webimActions.set(prechatFields: prechatFields)
    }
    
    func newMessageTracker(messageListener: MessageListener) throws -> MessageTracker {
        try accessChecker.checkAccess()
        
        return try messageHolder.newMessageTracker(withMessageListener: messageListener) as MessageTracker
    }
    
    func send(surveyAnswer: String, completionHandler: SendSurveyAnswerCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        guard let surveyController = surveyController,
            let survey = surveyController.getSurvey() else { return }

        let formID = surveyController.getCurrentFormID()
        let questionID = surveyController.getCurrentQuestionPointer()
        let surveyID = survey.getID()
        webimActions.sendQuestionAnswer(surveyID: surveyID,
                                        formID: formID,
                                        questionID: questionID,
                                        surveyAnswer: surveyAnswer,
                                        sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper(surveyController: surveyController,
                                                                                                                    sendSurveyAnswerCompletionHandler: completionHandler))
    }
    
    func closeSurvey(completionHandler: SurveyCloseCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        guard let surveyController = surveyController,
            let survey = surveyController.getSurvey() else { return }
        
        webimActions.closeSurvey(surveyID: survey.getID(),
                                 surveyCloseCompletionHandler: completionHandler)
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
    
    func set(unreadByOperatorTimestampChangeListener: UnreadByOperatorTimestampChangeListener) {
        self.unreadByOperatorTimestampChangeListener = unreadByOperatorTimestampChangeListener
    }
    
    func set(unreadByVisitorMessageCountChangeListener: UnreadByVisitorMessageCountChangeListener) {
        self.unreadByVisitorMessageCountChangeListener = unreadByVisitorMessageCountChangeListener
    }
    
    func set(unreadByVisitorTimestampChangeListener: UnreadByVisitorTimestampChangeListener) {
        self.unreadByVisitorTimestampChangeListener = unreadByVisitorTimestampChangeListener
    }
    
    func set(surveyListener: SurveyListener) {
        self.surveyController = SurveyController(surveyListener: surveyListener)
    }
    
    func set(helloMessageListener: HelloMessageListener) {
        self.helloMessageListener = helloMessageListener
    }
    
    // MARK: Private methods
    private func sendMessageInternally(messageText: String,
                                       dataJSONString: String? = nil,
                                       isHintQuestion: Bool? = nil,
                                       dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
                                       sendMessageComplitionHandler: SendMessageCompletionHandler? = nil) throws -> String {
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createTextMessageToSendWith(id: messageID,
                                                                                         text: messageText))
        webimActions.send(message: messageText,
                          clientSideID: messageID,
                          dataJSONString: dataJSONString,
                          isHintQuestion: isHintQuestion,
                          dataMessageCompletionHandler: DataMessageCompletionHandlerWrapper(dataMessageCompletionHandler: dataMessageCompletionHandler,
                                                                                            messageHolder: messageHolder),
                          sendMessageCompletionHandler: SendMessageCompletionHandlerWrapper(sendMessageCompletionHandler: sendMessageComplitionHandler, messageHolder: messageHolder))
        
        return messageID
    }
    
}

// MARK: -
fileprivate final class SendMessageCompletionHandlerWrapper: SendMessageCompletionHandler {

// MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var sendMessageCompletionHandler: SendMessageCompletionHandler?

// MARK: - Initialization
    init(sendMessageCompletionHandler: SendMessageCompletionHandler?,
         messageHolder: MessageHolder) {
        self.sendMessageCompletionHandler = sendMessageCompletionHandler
        self.messageHolder = messageHolder
}

// MARK: - Methods

    func onSuccess(messageID: String) {
        sendMessageCompletionHandler?.onSuccess(messageID: messageID)
    }
}

fileprivate final class SendFileCompletionHandlerWrapper: SendFileCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var sendFileCompletionHandler: SendFileCompletionHandler?
    
    // MARK: - Initialization
    init(sendFileCompletionHandler: SendFileCompletionHandler?,
         messageHolder: MessageHolder) {
        self.sendFileCompletionHandler = sendFileCompletionHandler
        self.messageHolder = messageHolder
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        sendFileCompletionHandler?.onSuccess(messageID: messageID)
    }
    
    func onFailure(messageID: String,
                   error: SendFileError) {
        messageHolder.sendingCancelledWith(messageID: messageID)
        sendFileCompletionHandler?.onFailure(messageID: messageID,
                                             error: error)
    }
    
}

fileprivate final class DataMessageCompletionHandlerWrapper: DataMessageCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var dataMessageCompletionHandler: DataMessageCompletionHandler?
    
    // MARK: - Initialization
    init(dataMessageCompletionHandler: DataMessageCompletionHandler?,
         messageHolder: MessageHolder) {
        self.dataMessageCompletionHandler = dataMessageCompletionHandler
        self.messageHolder = messageHolder
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        dataMessageCompletionHandler?.onSuccess(messageID : messageID)
    }
    
    func onFailure(messageID: String, error: DataMessageError) {
        messageHolder.sendingCancelledWith(messageID: messageID)
        dataMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
    }
    
}

fileprivate final class EditMessageCompletionHandlerWrapper: EditMessageCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var editMessageCompletionHandler: EditMessageCompletionHandler?
    private let message: String
    
    // MARK: - Initialization
    init(editMessageCompletionHandler: EditMessageCompletionHandler?,
         messageHolder: MessageHolder,
         message: String) {
        self.editMessageCompletionHandler = editMessageCompletionHandler
        self.messageHolder = messageHolder
        self.message = message
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        editMessageCompletionHandler?.onSuccess(messageID : messageID)
    }
    
    func onFailure(messageID: String, error: EditMessageError) {
        messageHolder.changingCancelledWith(messageID: messageID, message: message)
        editMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
    }
    
}

fileprivate final class DeleteMessageCompletionHandlerWrapper: DeleteMessageCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var deleteMessageCompletionHandler: DeleteMessageCompletionHandler?
    private let message: String
    
    // MARK: - Initialization
    init(deleteMessageCompletionHandler: DeleteMessageCompletionHandler?,
         messageHolder: MessageHolder,
         message: String) {
        self.deleteMessageCompletionHandler = deleteMessageCompletionHandler
        self.messageHolder = messageHolder
        self.message = message
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        deleteMessageCompletionHandler?.onSuccess(messageID : messageID)
    }
    
    func onFailure(messageID: String, error: DeleteMessageError) {
        messageHolder.changingCancelledWith(messageID: messageID, message: message)
        deleteMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
    }
    
}
