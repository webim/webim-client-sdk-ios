//
//  WebimService.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 20.11.17.
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
import WebimMobileSDK

final class WebimService {
    
    // MARK: - Constants
    public enum ChatSettings: Int {
        case messagesPerRequest = 25
    }
    private enum VisitorFields: String {
        case id = "id"
        case name = "display_name"
        case crc = "crc"
    }
    private enum VisitorFieldsValue: String {
        // Hardcoded. See more at https://webim.ru/help/identification/
        case id = "1234567890987654321"
        case name = "Никита"
        case crc = "ffadeb6aa3c788200824e311b9aa44cb"
    }
    
    // MARK: - Private Properties
    private weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    private weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    private weak var notFatalErrorHandler: NotFatalErrorHandler?
    private var messageStream: MessageStream?
    private var messageTracker: MessageTracker?
    private var webimSession: WebimSession?
    
    // MARK: - Initialization
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate,
         departmentListHandlerDelegate: DepartmentListHandlerDelegate) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
        self.departmentListHandlerDelegate = departmentListHandlerDelegate
    }
    
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate,
         departmentListHandlerDelegate: DepartmentListHandlerDelegate,
         notFatalErrorHandler: NotFatalErrorHandler?) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
        self.departmentListHandlerDelegate = departmentListHandlerDelegate
        self.notFatalErrorHandler = notFatalErrorHandler
    }
    
    // MARK: - Methods
    func sessionState() -> ChatState {
        return webimSession?.getStream().getChatState() ?? .unknown
    }
    
    func createTestUserData() -> String {
        // !!!secretString MUST NOT be used in real application!!!
        let secretString = "64f7099e123231123123123121"
        var properties = [String: String]()

        properties["id"] = "test_id"
        properties["display_name"] = "test_name"
        
        var keys = Array(properties.keys)
        keys.sort()
        var stringToSign = ""
        for key in keys {
            stringToSign += properties[key]!
        }
        
        let crc = stringToSign.hmacSHA256(withKey: secretString)
        properties["crc"] = crc
        
        let jsonData = try! JSONSerialization.data(withJSONObject: properties, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!

        return jsonString
    }

    func createSession(jsonString: String? = nil, jsonData: Data? = nil) {
        
        let deviceToken: String? = WMKeychainWrapper.standard.string(forKey: WMKeychainWrapper.deviceTokenKey)
        let dictionary = WMKeychainWrapper.standard.dictionary(forKey: "settings_demo")
        let accountName = dictionary?["account_name"] as? String ?? Settings.shared.accountName
        let location = dictionary?["location"] as? String ?? Settings.shared.location
        let pageTitle = dictionary?["page_title"] as? String ?? Settings.shared.pageTitle
        
        let sessionBuilder = Webim.newSessionBuilder()
            .set(accountName: accountName)
            .set(location: location)
            .set(pageTitle: pageTitle)
            .set(fatalErrorHandler: self)
            .set(remoteNotificationSystem: ((deviceToken != nil) ? .apns : .none))
            .set(deviceToken: deviceToken)
            .set(isVisitorDataClearingEnabled: false)

        if let jsonString = jsonString {
            _ = sessionBuilder.set(visitorFieldsJSONString: jsonString)
        }
        
        if let jsonData = jsonData {
            _ = sessionBuilder.set(visitorFieldsJSONData: jsonData)
        }
        
        if let notFatalErrorHandler = notFatalErrorHandler {
            _ = sessionBuilder.set(notFatalErrorHandler: notFatalErrorHandler)
        }
        
        sessionBuilder.build(
            onSuccess: { [weak self] webimSession in
                guard let self = self else {
                    print("Webim session object creating failed because of WebimService is nil.")
                    return
                }
                self.webimSession = webimSession
            },
            onError: { error in
                switch error {
                case .nilAccountName:
                    print("Webim session object creating failed because of passing nil account name.")
                    
                case .nilLocation:
                    print("Webim session object creating failed because of passing nil location name.")
                    
                case .invalidRemoteNotificationConfiguration:
                    print("Webim session object creating failed because of invalid remote notifications configuration.")
                    
                case .invalidAuthentificatorParameters:
                    print("Webim session object creating failed because of invalid visitor authentication system configuration.")
                    
                case .invalidHex:
                    print("Webim can't parsed prechat fields")
                    
                case .unknown:
                    print("Webim session object creating failed with unknown error")
                }
            }
        )
    }
    
    func resumeSession() {
        do {
            try webimSession?.resume()
        } catch {
            self.printError(error: error, message: "Webim session starting/resuming")
        }
       
        startChat()
    }
    
    func stopSession() {
        do {
            try messageTracker?.destroy()
            try webimSession?.destroy()
            webimSession = nil
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Ignored because if session is already destroyed, we don't care (it's the same thing that we try to achieve).
                
                break
            case .invalidThread:
                // Assuming to check concurrent calls of WebimClientLibrary methods.
                print("Webim session or message tracker destroing failed because it was called from a wrong thread.")
                
            }
        } catch {
            print("Webim session or message tracker destroing failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func set(session: WebimSession) {
        self.webimSession = session
    }
    
    func set(unreadByVisitorMessageCountChangeListener listener: UnreadByVisitorMessageCountChangeListener) {
        webimSession?.getStream().set(unreadByVisitorMessageCountChangeListener: listener)
    }
    
    func setMessageStream() {
        messageStream = webimSession?.getStream()
    }
    
    func getMessageStream() -> MessageStream? {
        return messageStream
    }
    
    func setVisitorTyping(draft: String?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.setVisitorTyping(draftMessage: draft)
        } catch {
            self.printError(error: error, message: "Visitor status sending")
        }
    }
    
    func send(
        message: String,
        completion: (() -> Void)? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            if shouldShowDepartmentSelection(),
                let departments = messageStream?.getDepartmentList() {
                departmentListHandlerDelegate?.showDepartmentsList(
                    departments,
                    action: { [weak self] departmentKey in
                        self?.startChat(
                            departmentKey: departmentKey,
                            message: message
                        )
                        completion?()
                    }
                )
            } else {
                _ = try messageStream?.send(message: message) // Returned message ID ignored.
                completion?()
            }
        } catch {
            self.printError(error: error, message: "Message sending")
        }
    }
    
    func searchMessagesBy(query: String, completionHandler: SearchMessagesCompletionHandler?) {
        
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.searchStreamMessagesBy(query: query, completionHandler: completionHandler)
            
        } catch {
            self.printError(error: error, message: "Search")
        }
    }

    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            try messageStream?.getServerSideSettings(completionHandler: completionHandler)

        } catch {
            self.printError(error: error, message: "Getting Server side settings")
        }
    }
    
    func send(surveyAnswer: String, completionHandler: SendSurveyAnswerCompletionHandler?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.send(
                surveyAnswer: surveyAnswer,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Send survey answer")
        }
    }
    
    func send(
        file data: Data,
        fileName: String,
        mimeType: String,
        completionHandler: SendFileCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(
                        departmentKey: departmentKey,
                        message: nil
                    )
                    self?.sendFile(
                        data: data,
                        fileName: fileName,
                        mimeType: mimeType,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            sendFile(
                data: data,
                fileName: fileName,
                mimeType: mimeType,
                completionHandler: completionHandler
            )
        }
    }
    
    func reply(
        message: String,
        repliedMessage: Message,
        completion: (() -> Void)? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            if shouldShowDepartmentSelection(),
                let departments = messageStream?.getDepartmentList() {
                departmentListHandlerDelegate?.showDepartmentsList(
                    departments,
                    action: { [weak self] departmentKey in
                        self?.startChat(
                            departmentKey: departmentKey
                        )
                        self?.replyMessage(
                            message: message,
                            repliedMessage: repliedMessage
                        )
                    }
                )
            } else {
                replyMessage(
                    message: message,
                    repliedMessage: repliedMessage
                )
            }
        }
    }
    
    func edit(
        message: Message,
        text: String,
        completionHandler: EditMessageCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(
                        departmentKey: departmentKey,
                        message: nil
                    )
                    self?.editMessage(
                        message: message,
                        text: text,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            editMessage(
                message: message,
                text: text,
                completionHandler: completionHandler
            )
        }
    }
    
    func delete(
        message: Message,
        completionHandler: DeleteMessageCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.deleteMessage(
                        message: message,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            deleteMessage(
                message: message,
                completionHandler: completionHandler
            )
        }
    }
    
    func react(
        reaction: ReactionString,
        message: Message,
        completionHandler: ReactionCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
           let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.setReaction(
                        message: message,
                        reaction: reaction,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            self.setReaction(
                message: message,
                reaction: reaction,
                completionHandler: completionHandler
            )
        }
    }
    
    func isChatExist() -> Bool {
        guard let chatState = messageStream?.getChatState() else {
            return false
        }
        
        return ((chatState == .chatting)
            || (chatState == .closedByOperator))
    }
    
    func closeChat() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.closeChat()
        } catch {
            self.printError(error: error, message: "Close chat")
        }
    }
    
    func clearHistory() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.clearHistory()
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
                
            case .invalidThread:
                // Assuming to check concurrent calls of WebimClientLibrary methods.
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func rateOperator(
        withID operatorID: String,
        byRating rating: Int,
        completionHandler: RateOperatorCompletionHandler?
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.rateOperatorWith(
                id: operatorID,
                byRating: rating,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Rate operator")
        }
    }
    
    func setHelloMessageListener(with helloMessageListener: HelloMessageListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(helloMessageListener: helloMessageListener)
    }
    
    func setMessageTracker(withMessageListener messageListener: MessageListener) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageTracker = messageStream?.newMessageTracker(
                messageListener: messageListener
            )
        } catch {
            self.printError(error: error, message: "Set message tracker")
        }
    }
    
    func getLastMessages(completion: @escaping (_ result: [Message]) -> Void) {
        do {
            try messageTracker?.getLastMessages(
                byLimit: ChatSettings.messagesPerRequest.rawValue,
                completion: completion
            )
        } catch {
            self.printError(error: error, message: "Get last messages")
        }
    }
    
    func getNextMessages(completion: @escaping (_ result: [Message]) -> Void) {
        do {
            try messageTracker?.getNextMessages(
                byLimit: ChatSettings.messagesPerRequest.rawValue,
                completion: completion
            )
        } catch {
            self.printError(error: error, message: "Get next messages")
        }
    }
    
    func setChatRead() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.setChatRead()
        } catch {
            print("Read chat failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func getUnreadMessagesByVisitor() -> Int {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getUnreadByVisitorMessageCount() ?? 0
    }
    
    func set(operatorTypingListener: OperatorTypingListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(operatorTypingListener: operatorTypingListener)
    }
    
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(currentOperatorChangeListener: currentOperatorChangeListener)
    }
    
    func getCurrentOperator() -> Operator? {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getCurrentOperator()
    }
    
    func getLastRatingOfOperatorWith(id: String) -> Int {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getLastRatingOfOperatorWith(id: id) ?? 0
    }
    
    func set(surveyListener: SurveyListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(surveyListener: surveyListener)
    }
    
    func set(chatStateListener: ChatStateListener) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(chatStateListener: chatStateListener)
    }
    
    func sendKeyboardRequest(
        button: KeyboardButton,
        message: Message,
        completionHandler: SendKeyboardRequestCompletionHandler
    ) {
        if messageStream == nil {
            setMessageStream()
        }
        
        if shouldShowDepartmentSelection(),
            let departments = messageStream?.getDepartmentList() {
            departmentListHandlerDelegate?.showDepartmentsList(
                departments,
                action: { [weak self] departmentKey in
                    self?.startChat(departmentKey: departmentKey)
                    
                    self?.sendKeyboard(
                        button: button,
                        message: message,
                        completionHandler: completionHandler
                    )
                }
            )
        } else {
            sendKeyboard(
                button: button,
                message: message,
                completionHandler: completionHandler
            )
        }
    }

    
    func startChat(
        departmentKey: String? = nil,
        message: String? = nil
    ) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.startChat(
                departmentKey: departmentKey,
                firstQuestion: message
            )
        } catch {
            self.printError(error: error, message: "Start chat")
        }
    }
    // MARK: Private methods
    
    private func replyMessage(
        message: String,
        repliedMessage: Message
    ) {
        do {
            _ = try messageStream?.reply(
                message: message,
                repliedMessage: repliedMessage
            )
        } catch {
            self.printError(error: error, message: "Reply message")
        }
    }
    
    private func setReaction(
        message: Message,
        reaction: ReactionString,
        completionHandler: ReactionCompletionHandler?
    ) {
        do {
            _ = try messageStream?.react(
                message: message,
                reaction: reaction,
                completionHandler: completionHandler
            )
        } catch let error as AccessError {
            switch error {
            case .invalidSession:
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
                print("Message editing failed because it was called when session object is invalid.")
            case .invalidThread:
                // Assuming to check concurrent calls of WebimClientLibrary methods.
                print("Message editing failed because it was called from a wrong thread.")
            }
        } catch {
            print("Message status editing failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    func sendFile(
        data: Data,
        fileName: String,
        mimeType: String,
        completionHandler: SendFileCompletionHandler
    ) {
        do {
            _ = try messageStream?.send(
                file: data,
                filename: fileName,
                mimeType: mimeType,
                completionHandler: completionHandler
            )  // Returned message ID ignored.
        } catch {
            self.printError(error: error, message: "Send file")
        }
    }
    
    private func editMessage(
        message: Message,
        text: String,
        completionHandler: EditMessageCompletionHandler
    ) {
        do {
            _ = try messageStream?.edit(
                message: message,
                text: text,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Edit message")
        }
    }
    
    private func deleteMessage(
        message: Message,
        completionHandler: DeleteMessageCompletionHandler
    ) {
        do {
            _ = try messageStream?.delete(
                message: message,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Delete message")
        }
    }
    
    private func sendKeyboard(
        button: KeyboardButton,
        message: Message,
        completionHandler: SendKeyboardRequestCompletionHandler
    ) {
        do {
            _ = try messageStream?.sendKeyboardRequest(
                button: button,
                message: message,
                completionHandler: completionHandler
            )
        } catch {
            self.printError(error: error, message: "Sending keyboard request")
        }
    }
    
    func shouldShowDepartmentSelection() -> Bool {
        return messageStream?.getVisitSessionState() == .departmentSelection || messageStream?.getVisitSessionState() == .idleAfterChat
    }

    func departmentList() -> [Department]? {
        return messageStream?.getDepartmentList()
    }
    
    func printError(error: Error, message: String) {
        switch error {
        case AccessError.invalidSession:
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            print(message + " failed because it was called when session object is invalid.")
        case AccessError.invalidThread:
            // Assuming to check concurrent calls of WebimClientLibrary methods.
            print(message + " failed because it was called from a wrong thread.")
        default :
            print(message + " failed with unknown error: \(error.localizedDescription)")
        }
    }
    
}

// MARK: - WEBIM: FatalErrorHandler
extension WebimService: FatalErrorHandler {
    
    // MARK: - Methods
    func on(error: WebimError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .accountBlocked:
            // Assuming to contact with Webim support.
            print("Account with used account name is blocked by Webim service.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "AccountBlocked".localized)
            
        case .providedVisitorFieldsExpired:
            // Assuming to re-authorize it and re-create session object.
            print("Provided visitor fields expired. See \"expires\" key of this fields.")
            
        case .unknown:
            print("An unknown error occured: \(error.getErrorString()).")
            
        case .visitorBanned:
            print("Visitor with provided visitor fields is banned by an operator.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Your visitor account is in the black list.".localized)
            
        case .wrongProvidedVisitorHash:
            // Assuming to check visitor field generating.
            print("Wrong CRC passed with visitor fields.")
            
        }
    }
    
}

// MARK: - WEBIM: NotFatalErrorHandler
extension WebimService: NotFatalErrorHandler {
    
    func on(error: WebimNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
    
}

// MARK: -
protocol FatalErrorHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    func showErrorDialog(withMessage message: String)
    
}

// MARK: -
protocol DepartmentListHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    func showDepartmentsList(
        _ departaments: [Department],
        action: @escaping (String) -> Void
    )
}

extension DepartmentListHandlerDelegate {
    func showDepartmentsList(_ departmentList: [Department], action: @escaping (String) -> Void) {}
}
