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
import UIKit

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
    private let location: String
    private let webimActions: WebimActionsImpl
    private var accountConfigResponse: AccountConfigItem?
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
         location: String,
         currentChatMessageFactoriesMapper: MessageMapper,
         sendingMessageFactory: SendingFactory,
         operatorFactory: OperatorFactory,
         surveyFactory: SurveyFactory,
         accessChecker: AccessChecker,
         webimActions: WebimActionsImpl,
         messageHolder: MessageHolder,
         messageComposingHandler: MessageComposingHandler,
         locationSettingsHolder: LocationSettingsHolder) {
        self.serverURLString = serverURLString
        self.location = location
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
    
    func getWebimActions() -> WebimActionsImpl {
        return webimActions
    }
    
    func set(visitSessionState: VisitSessionStateItem) {
        let previousVisitSessionState = self.visitSessionState
        self.visitSessionState = visitSessionState
        
        isChatIsOpening = false
        
        visitSessionStateListener?.changed(state: publicState(ofVisitSessionState: previousVisitSessionState),
                                           to: publicState(ofVisitSessionState: visitSessionState))
    }
    
    func disableBotButtons() {
        for message in self.messageHolder.getCurrentChatMessages() {
            if message.disableBotButtons() {
                self.messageHolder.changed(message: message)
            }
        }
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
            WebimInternalLogger.shared.log(
                entry: "Unread message count changed from \(previousValue) to \(unreadByVisitorMessageCount) in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
        }
    }
    
    func changingChatStateOf(chat: ChatItem?) {
        guard let chat = chat else {
            self.disableBotButtons()
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
            WebimInternalLogger.shared.log(
                entry: "Received ChatItem is nil in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
            return
        }
        
        let newOperator = operatorFactory.createOperatorFrom(operatorItem: chat.getOperator())
        let newChatState = chat.getState()
        
        if newOperator != currentOperator || lastChatState != newChatState {
            self.disableBotButtons()
        }
        
        let previousChat = self.chat
        self.chat = chat
        
        messageHolder.receiving(newChat: self.chat,
                                previousChat: previousChat,
                                newMessages: currentChatMessageFactoriesMapper.mapAll(messages: chat.getMessages()))
        
        if let newChatState = newChatState {
            // Recieved chat state can be unsupported by the library.
            if lastChatState != newChatState {
                chatStateListener?.changed(state: publicState(ofChatState: lastChatState),
                                           to: publicState(ofChatState: newChatState))
                WebimInternalLogger.shared.log(
                    entry: "Chat state changed from \(lastChatState) to \(newChatState) in MessageStreamImpl - \(#function)",
                    verbosityLevel: .verbose,
                    logType: .networkRequest)
            }
            lastChatState = newChatState
        }
        
        if newOperator != currentOperator {
            let previousOperator = currentOperator
            currentOperator = newOperator
            
            currentOperatorChangeListener?.changed(operator: previousOperator,
                                                       to: newOperator)
            WebimInternalLogger.shared.log(
                entry: "Operator changed from \(previousOperator?.getName() ?? "") to \(newOperator?.getName() ?? "") in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
        }
        
        let operatorTypingStatus = chat.isOperatorTyping()
        if lastOperatorTypingStatus != operatorTypingStatus {
            operatorTypingListener?.onOperatorTypingStateChanged(isTyping: operatorTypingStatus)
            WebimInternalLogger.shared.log(
                entry: "Operator typing state changed from \(lastOperatorTypingStatus ?? false) to \(operatorTypingStatus) in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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
            WebimInternalLogger.shared.log(
                entry: "Chat is read by visitor",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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
            WebimInternalLogger.shared.log(
                entry: "Operator online status changed from \(onlineStatus) to \(newOnlineStatus) in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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
    
    func getChatId() -> Int? {
        return chat?.getId()
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
            WebimInternalLogger.shared.log(
                entry: "Rating must be within from 1 to 5 range. Passed value: \(rating)",
                verbosityLevel: .warning,
                logType: .networkRequest)
            
            return
        }
        
        try accessChecker.checkAccess()
        
        webimActions.rateOperatorWith(id: id,
                                      rating: (rating - 3), // Accepted range: (-2, -1, 0, 1, 2).
                                      visitorNote: note,
                                      completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request rate operator with rating \(rating) in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func respondSentryCall(id: String) throws {
        try accessChecker.checkAccess()
        
        webimActions.respondSentryCall(id: id)
    }
    
    func searchStreamMessagesBy(query: String, completionHandler: SearchMessagesCompletionHandler?) {
        do {
            
            try accessChecker.checkAccess()

            webimActions.searchMessagesBy(query: query) { data in
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any?]
                if let data = json?["data"] as? [String: Any?] {
                    let itemsCount =  data["count"] as? Int
                    if itemsCount == 0 {
                        completionHandler?.onSearchMessageSuccess(query: query, messages: [])
                        return
                    }
                    if let messages = data["items"] as? [[String: Any?]] {
                        
                        var searchMessagesArray = [Message]()
                        
                        for item in messages {
                            let messageItem = MessageItem(jsonDictionary: item)
                            if let message = self.currentChatMessageFactoriesMapper.map(message: messageItem) {
                                searchMessagesArray.append(message)
                            }
                        }
                        completionHandler?.onSearchMessageSuccess(query: query, messages: searchMessagesArray)

                        WebimInternalLogger.shared.log(
                            entry: "Search message success.\nFind \(searchMessagesArray.count) messages in MessageStreamImpl - \(#function)",
                            verbosityLevel: .verbose,
                            logType: .networkRequest)
                        return
                    }
                }
            }
            completionHandler?.onSearchMessageFailure(query: query)
            WebimInternalLogger.shared.log(
                entry: "Search message failure in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
        } catch {
            completionHandler?.onSearchMessageFailure(query: query)
            WebimInternalLogger.shared.log(
                entry: "Search message failure in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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
            WebimInternalLogger.shared.log(
                entry: "Request start chat in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
        }
    }
    
    func closeChat() throws {
        try accessChecker.checkAccess()
        if !lastChatState.isClosed() {
            webimActions.closeChat()
            WebimInternalLogger.shared.log(
                entry: "Request close chat in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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
        return try sendMessageInternally(messageText: message, sendMessageCompletionHandler: completionHandler)
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
        
        if mimeType == "image/heic" || mimeType == "image/heif" {
            guard let image = UIImage(data: file),
                let imageData = image.jpegData(compressionQuality: 0.5)
                else {
                    WebimInternalLogger.shared.log(
                        entry: "Error with heic/heif in MessageStreamImpl - \(#function)",
                        verbosityLevel: .verbose,
                        logType: .networkRequest)
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
        
        let messageID = ClientSideID.generateClientSideID()
        let data = MessageDataImpl(attachment: MessageAttachmentImpl(fileInfo: FileInfoImpl(urlString: nil,
                                                                                            size: Int64(file.count),
                                                                                            filename: filename,
                                                                                            contentType: mimeType,
                                                                                            guid: nil,
                                                                                            fileUrlCreator: nil),
                                                                     filesInfo: [],
                                                                     state: .upload))
        messageHolder.sending(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID, data: data))
        
        webimActions.send(file: file,
                          filename: filename,
                          mimeType: mimeType,
                          clientSideID: messageID,
                          completionHandler: SendFileCompletionHandlerWrapper(sendFileCompletionHandler: completionHandler,
                                                                              messageHolder: messageHolder,
                                                                              webimActions: webimActions,
                                                                              sendingMessageFactory: sendingMessageFactory),
                          uploadFileToServerCompletionHandler: nil)

        WebimInternalLogger.shared.log(
            entry: "Request send file - \(file) in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        
        return messageID
    }
    
    func send(uploadedFiles: [UploadedFile],
              completionHandler: SendFilesCompletionHandler?) throws -> String {
        try accessChecker.checkAccess()
        
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        if uploadedFiles.isEmpty {
            completionHandler?.onFailure(messageID: messageID, error: .fileNotFound)
            WebimInternalLogger.shared.log(
                entry: "Failure sending message with uplodaed files.\nUploaded files is empty in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
            return messageID
        }
        if uploadedFiles.count > 10 {
            completionHandler?.onFailure(messageID: messageID, error: .maxFilesCountPerMessage)
            WebimInternalLogger.shared.log(
                entry: "Failure sending message with uplodaed files.\nUploaded files number >10 in MessageStreamImpl - \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
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

        WebimInternalLogger.shared.log(
            entry: "Request send message with \(uploadedFiles.count) uplodaed files chat in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        
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
                WebimInternalLogger.shared.log(
                    entry: "Error with heic/heif in MessageStreamImpl - \(#function)",
                    verbosityLevel: .verbose,
                    logType: .networkRequest)
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
                          clientSideID: messageID, completionHandler: nil,
                          uploadFileToServerCompletionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request upload file to server \(file) - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)

        
        return messageID
    }
    
    func deleteUploadedFiles(fileGuid: String,
                             completionHandler: DeleteUploadedFileCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.deleteUploadedFile(fileGuid: fileGuid,
                                        completionHandler: completionHandler)
        WebimInternalLogger.shared.log(
            entry: "Request delete uploaded files with guid - \(fileGuid) in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func sendKeyboardRequest(button: KeyboardButton,
                             message: Message,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.sendKeyboardRequest(buttonId: button.getID(),
                                         messageId: message.getCurrentChatID() ?? "",
                                         completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request send keyboard in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func sendKeyboardRequest(buttonID: String,
                             messageCurrentChatID: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.sendKeyboardRequest(buttonId: buttonID,
                                         messageId: messageCurrentChatID,
                                         completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request send keyboard in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func sendSticker(withId stickerId: Int, completionHandler: SendStickerCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createStickerMessageToSendWith(id: messageID, stickerId: stickerId))
        webimActions.sendSticker(stickerId: stickerId, clientSideId: messageID, completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request send sticker. Sticker ID - \(stickerId) in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func autocomplete(text: String, completionHandler: AutocompleteCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        if accountConfigResponse == nil {
            webimActions.getServerSettings(forLocation: location) {
                data in
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: [])
                    if let locationSettingsResponseDictionary = json as? [String: Any?] {
                        let locationSettingsResponse = ServerSettingsResponse(jsonDictionary: locationSettingsResponseDictionary)
                        self.accountConfigResponse = locationSettingsResponse.getAccountConfig()
                        if let url = self.accountConfigResponse?.getHintsEndpoint() {
                            self.webimActions.autocomplete(forText: text, url: url, completion: completionHandler)
                        } else {
                            completionHandler?.onFailure(error: .hintApiInvalid)
                        }
                    }
                }
            }
        } else {
            if let url = accountConfigResponse?.getHintsEndpoint() {
                webimActions.autocomplete(forText: text, url: url, completion: completionHandler)
            } else {
                completionHandler?.onFailure(error: .hintApiInvalid)
            }
        }
        WebimInternalLogger.shared.log(
            entry: "Autocomplete request in MessageStreamImpl - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func getRawConfig(forLocation location: String, completionHandler: RawLocationConfigCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.getServerSettings(forLocation: location) {
            data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let locationSettingsResponseDictionary = json as? [String: Any?] {
                    let locationSettingsResponse = ServerSettingsResponse(jsonDictionary: locationSettingsResponseDictionary)
                    completionHandler?.onSuccess(rawLocationConfig: locationSettingsResponse.getLocationSettings())
                    WebimInternalLogger.shared.log(
                        entry: "Success get raw config in MessageStreamImpl- \(#function)",
                        verbosityLevel: .verbose,
                        logType: .networkRequest)
                }
            } else {
                completionHandler?.onFailure()
                WebimInternalLogger.shared.log(
                    entry: "Failure get raw config.\nEmpty data in MessageStreamImpl- \(#function)",
                    verbosityLevel: .verbose,
                    logType: .networkRequest)
            }
        }
        WebimInternalLogger.shared.log(
            entry: "Request get raw config in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }

    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?) throws {
        try accessChecker.checkAccess()
        webimActions.getServerSideSettings(completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request get server side settings in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func updateWidgetStatus(data: String) throws {
        try accessChecker.checkAccess()
        
        webimActions.updateWidgetStatusWith(data: data)

        WebimInternalLogger.shared.log(
            entry: "Request update widget status in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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

        WebimInternalLogger.shared.log(
            entry: "Request reply \(message) to \(repliedMessage.getText()) in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        
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
                              dataMessageCompletionHandler: nil, editMessageCompletionHandler: EditMessageCompletionHandlerWrapper(editMessageCompletionHandler: completionHandler,
                                                                                                                                   messageHolder: messageHolder,
                                                                                                                                   message: oldMessage), sendMessageCompletionHandler: nil)
            WebimInternalLogger.shared.log(
                entry: "Request edit message \(oldMessage) to \(text) in MessageStreamImpl- \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
            return true
        }
        WebimInternalLogger.shared.log(
            entry: "Failure edit message.\nMessage to edit is nil in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        return false
    }
    
    func react(message: Message, reaction: ReactionString, completionHandler: ReactionCompletionHandler?) throws -> Bool {
        try accessChecker.checkAccess()
        if !message.canVisitorReact() || !(message.getVisitorReaction() == nil || message.canVisitorChangeReaction()) {
            return false
        } 
        let id = message.getID()
        webimActions.sendReaction(reaction: reaction,
                                  clientSideId: id,
                                  completionHandler: completionHandler)
        WebimInternalLogger.shared.log(
            entry: "Request react to message \(message.getText()) in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        return true
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
            WebimInternalLogger.shared.log(
                entry: "Request delete message \(oldMessage) in MessageStreamImpl- \(#function)",
                verbosityLevel: .verbose,
                logType: .networkRequest)
            return true
        }
        WebimInternalLogger.shared.log(
            entry: "Failure delete message.\nMessage to delete is nil in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        return false
    }
    
    func setChatRead() throws {
        try accessChecker.checkAccess()
        
        webimActions.setChatRead()

        WebimInternalLogger.shared.log(
            entry: "Request read chat in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?) throws {
        try accessChecker.checkAccess()
       
        webimActions.sendDialogTo(emailAddress: emailAddress, completionHandler: completionHandler)
        WebimInternalLogger.shared.log(
            entry: "Request send dialog to email in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
        WebimInternalLogger.shared.log(
            entry: "Request send survey answer \(surveyAnswer) in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func closeSurvey(completionHandler: SurveyCloseCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        guard let surveyController = surveyController,
            let survey = surveyController.getSurvey() else { return }
        
        webimActions.closeSurvey(surveyID: survey.getID(),
                                 surveyCloseCompletionHandler: completionHandler)
        WebimInternalLogger.shared.log(
            entry: "Request close survey answer in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func sendGeolocation(latitude: Double, longitude: Double, completionHandler: GeolocationCompletionHandler?) throws {
        try accessChecker.checkAccess()
        
        webimActions.sendGeolocation(latitude: latitude, longitude: longitude, completionHandler: completionHandler)

        WebimInternalLogger.shared.log(
            entry: "Request send geolocation lat - \(latitude), long - \(longitude)  in MessageStreamImpl- \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
    
    func clearHistory() throws {
        try accessChecker.checkAccess()
        webimActions.clearHistory()
        messageHolder.clearHistory()
    }
    
    // MARK: Private methods
    private func sendMessageInternally(messageText: String,
                                       dataJSONString: String? = nil,
                                       isHintQuestion: Bool? = nil,
                                       dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
                                       sendMessageCompletionHandler: SendMessageCompletionHandler? = nil) throws -> String {
        try startChat()
        
        let messageID = ClientSideID.generateClientSideID()
        messageHolder.sending(message: sendingMessageFactory.createTextMessageToSendWith(id: messageID,
                                                                                         text: messageText))
        webimActions.send(message: messageText,
                          clientSideID: messageID,
                          dataJSONString: dataJSONString,
                          isHintQuestion: isHintQuestion,
                          dataMessageCompletionHandler: DataMessageCompletionHandlerWrapper(dataMessageCompletionHandler: dataMessageCompletionHandler,
                                                                                            messageHolder: messageHolder), editMessageCompletionHandler: nil,
                          sendMessageCompletionHandler: SendMessageCompletionHandlerWrapper(sendMessageCompletionHandler: sendMessageCompletionHandler, messageHolder: messageHolder))
        WebimInternalLogger.shared.log(
            entry: "Request send message - \(messageText) in MessageStream - \(#function)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        
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
        WebimInternalLogger.shared.log(
            entry: "Message success sended with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
}

fileprivate final class SendFileCompletionHandlerWrapper: SendFileCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private let webimActions: WebimActionsImpl
    private let sendingMessageFactory: SendingFactory
    private weak var sendFileCompletionHandler: SendFileCompletionHandler?
    
    // MARK: - Initialization
    init(sendFileCompletionHandler: SendFileCompletionHandler?,
         messageHolder: MessageHolder,
         webimActions: WebimActionsImpl,
         sendingMessageFactory: SendingFactory) {
        self.sendFileCompletionHandler = sendFileCompletionHandler
        self.messageHolder = messageHolder
        self.webimActions = webimActions
        self.sendingMessageFactory = sendingMessageFactory
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        webimActions.deleteSendingFile(id: messageID)
        sendFileCompletionHandler?.onSuccess(messageID: messageID)
        WebimInternalLogger.shared.log(
            entry: "File success sended with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func onFailure(messageID: String,
                   error: SendFileError) {
        WebimInternalLogger.shared.log(
            entry: "File send failure with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
        
        guard let sendingFile = webimActions.getSendingFile(id: messageID) else {
            messageHolder.sendingCancelledWith(messageID: messageID)
            sendFileCompletionHandler?.onFailure(messageID: messageID, error: error)
            return
        }
        let data = MessageDataImpl(attachment: MessageAttachmentImpl(fileInfo: FileInfoImpl(urlString: nil,
                                                                                            size: Int64(sendingFile.fileSize),
                                                                                            filename: sendingFile.fileName,
                                                                                            contentType: nil,
                                                                                            guid: nil,
                                                                                            fileUrlCreator: nil),
                                                                     filesInfo: [],
                                                                     state: .error))
    
        messageHolder.changed(message: sendingMessageFactory.createFileMessageToSendWith(id: messageID, data: data))
        webimActions.sendFileProgress(fileSize: sendingFile.fileSize,
                                      filename: sendingFile.fileName,
                                      mimeType: sendingFile.clientSideId,
                                      clientSideID: sendingFile.clientSideId,
                                      error: error,
                                      progress: nil,
                                      state: .error,
                                      completionHandler: SendFileProgressCompletionHandlerWrapper(messageHolder: messageHolder,
                                                                                                  sendFileCompletionHandler: sendFileCompletionHandler))
        webimActions.deleteSendingFile(id: messageID)
    }
}

fileprivate final class SendFileProgressCompletionHandlerWrapper: SendFileCompletionHandler {
    
    // MARK: - Properties
    private let messageHolder: MessageHolder
    private weak var sendFileCompletionHandler: SendFileCompletionHandler?
    
    // MARK: - Initialization
    init(messageHolder: MessageHolder,
         sendFileCompletionHandler: SendFileCompletionHandler?) {
        self.messageHolder = messageHolder
        self.sendFileCompletionHandler = sendFileCompletionHandler
    }
    
    // MARK: - Methods
    
    func onSuccess(messageID: String) {
        sendFileCompletionHandler?.onSuccess(messageID: messageID)
        WebimInternalLogger.shared.log(
            entry: "File success sended with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func onFailure(messageID: String,
                   error: SendFileError) {
        messageHolder.sendingCancelledWith(messageID: messageID)
        sendFileCompletionHandler?.onFailure(messageID: messageID,
                                             error: error)
        WebimInternalLogger.shared.log(
            entry: "File send failure with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
        WebimInternalLogger.shared.log(
            entry: "Message data success sended with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func onFailure(messageID: String, error: DataMessageError) {
        messageHolder.sendingCancelledWith(messageID: messageID)
        dataMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
        WebimInternalLogger.shared.log(
            entry: "Message data send failure with ID - \(messageID) in MessageStream",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
        WebimInternalLogger.shared.log(
            entry: "Success edit message with ID \(messageID)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func onFailure(messageID: String, error: EditMessageError) {
        messageHolder.changingCancelledWith(messageID: messageID, message: message)
        editMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
        WebimInternalLogger.shared.log(
            entry: "Failure edit message with ID \(messageID)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
        deleteMessageCompletionHandler?.onSuccess(messageID: messageID)
        WebimInternalLogger.shared.log(
            entry: "Success delete message with ID \(messageID)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
    func onFailure(messageID: String, error: DeleteMessageError) {
        messageHolder.changingCancelledWith(messageID: messageID, message: message)
        deleteMessageCompletionHandler?.onFailure(messageID: messageID, error: error)
        WebimInternalLogger.shared.log(
            entry: "Failure delete message with ID \(messageID)",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
    
}
