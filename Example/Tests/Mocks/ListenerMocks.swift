//
//  ListenerMocks.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 29.08.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
@testable import WebimClientLibrary

final class VisitSessionStateListenerMock: VisitSessionStateListener {

    // MARK: - Properties
    var called = false
    var state: VisitSessionState?

    // MARK: - Methods
    // MARK: VisitSessionStateListenerMock protocol methods
    func changed(state previousState: VisitSessionState,
                 to newState: VisitSessionState) {
        called = true
        state = newState
    }
}

final class OnlineStatusChangeListenerMock: OnlineStatusChangeListener {

    // MARK: - Properties
    var called = false
    var status: OnlineStatus?

    // MARK: - Methods
    // MARK: OnlineStatusChangeListenerMock protocol methods
    func changed(onlineStatus previousOnlineStatus: OnlineStatus,
                 to newOnlineStatus: OnlineStatus) {
        called = true
        status = newOnlineStatus
    }
}

final class LocationSettingsChangeListenerMock: LocationSettingsChangeListener {

    // MARK: - Properties
    var called = false
    var locationSettings: LocationSettings?

    // MARK: - Methods
    // MARK: LocationSettingsChangeListener protocol methods
    func changed(locationSettings previousLocationSettings: LocationSettings, to newLocationSettings: LocationSettings) {
        called = true
        locationSettings = newLocationSettings
    }
}

final class SurveyListenerMock: SurveyListener {

    // MARK: - Properties
    var onSurveyCancelledCalled = false
    var onSurveyCalled = false

    // MARK: - Methods
    // MARK: SurveyListener protocol methods
    func on(survey: Survey) {
        onSurveyCalled = true
    }

    func on(nextQuestion: SurveyQuestion) { }

    func onSurveyCancelled() {
        onSurveyCancelledCalled = true
    }
}

final class HelloMessageListenerMock: HelloMessageListener {
    // MARK: - Properties
    var helloMessageCalled = false
    var helloMessageText: String?

    // MARK: - Methods
    // MARK: HelloMessageListener protocol methods
    func helloMessage(message: String) {
        helloMessageCalled = true
        helloMessageText = message
    }
}

final class RateOperatorCompletionHandlerMock: RateOperatorCompletionHandler {
    // MARK: - Properties
    var completionCalled = false
    var rateSuccess = false

    // MARK: - Methods
    // MARK: RateOperatorCompletionHandler protocol methods
    func onSuccess() {
        completionCalled = true
        rateSuccess = true
    }

    func onFailure(error: RateOperatorError) {
        completionCalled = true
        rateSuccess = false
    }
}

final class SearchMessagesCompletionHandlerMock: SearchMessagesCompletionHandler {
    //MARK: Properties
    var completionCalled = false
    var completionSuccess: Bool?


    // MARK: - Methods
    // MARK: SearchMessagesCompletionHandler protocol methods
    func onSearchMessageSuccess(query: String, messages: [Message]) {
        completionCalled = true
        completionSuccess = true
    }

    func onSearchMessageFailure(query: String) {
        completionCalled = true
        completionSuccess = false
    }
}

final class SendFilesCompletionHandlerMock: SendFilesCompletionHandler {
    //MARK: Properties
    var completionCalled = false
    var completionSuccess: Bool?
    var error: SendFilesError?


    // MARK: - Methods
    // MARK: SendFilesCompletionHandler protocol methods
    func onSuccess(messageID: String) {
        completionCalled = true
        completionSuccess = true
    }

    func onFailure(messageID: String, error: SendFilesError) {
        completionCalled = true
        completionSuccess = false
        self.error = error
    }
}

final class MessageListenerMock: MessageListener {
    //MARK: Properties
    var added: Bool?
    var removed: Bool?
    var isAllMessagesRemoved: Bool?
    var changed: Bool?

    // MARK: - Methods
    // MARK: MessageListener protocol methods
    func added(message newMessage: Message, after previousMessage: Message?) {
        added = true
    }

    func removed(message: Message) {
        removed = true
    }

    func removedAllMessages() {
        isAllMessagesRemoved = true
    }

    func changed(message oldVersion: Message, to newVersion: Message) {
        changed = true
    }
}

final class ChatStateListenerMock: ChatStateListener {
    //MARK: Properties
    var chatStateChanged = false
    var newChatState: ChatState?

    // MARK: - Methods
    // MARK: ChatStateListener protocol methods
    func changed(state previousState: ChatState, to newState: ChatState) {
        newChatState = newState
        chatStateChanged = true
    }
}

final class CurrentOperatorChangeListenerMock: CurrentOperatorChangeListener {
    //MARK: Properties
    var operatorChanged = false
    var newOperator: Operator?

    // MARK: - Methods
    // MARK: CurrentOperatorChangeListener protocol methods
    func changed(operator previousOperator: Operator?, to newOperator: Operator?) {
        operatorChanged = true
        self.newOperator = newOperator
    }
}

final class OperatorTypingListenerMock: OperatorTypingListener {
    // MARK: - Properties
    var isTyping: Bool?
    var typingStateChanged = false

    // MARK: - Methods
    // MARK: OperatorTypingListener protocol methods
    func onOperatorTypingStateChanged(isTyping: Bool) {
        self.isTyping = isTyping
        typingStateChanged = true
    }
}

final class DepartmentListChangeListenerMock: DepartmentListChangeListener {
    // MARK: - Properties
    var received = false
    var departmentList = [Department]()

    // MARK: - Methods
    // MARK: DepartmentListChangeListener protocol methods
    func received(departmentList: [Department]) {
        received = true
        self.departmentList = departmentList
    }
}

final class UnreadByOperatorTimestampChangeListenerMock: UnreadByOperatorTimestampChangeListener {
    //MARK: Properties
    var timestampChanged = false
    var newValue: TimeInterval?

    // MARK: - Methods
    // MARK: UnreadByOperatorTimestampChangeListener protocol methods
    func changedUnreadByOperatorTimestampTo(newValue: Date?) {
        timestampChanged = true
        self.newValue = newValue?.timeIntervalSince1970
    }
}

final class UnreadByVisitorMessageCountChangeListenerMock: UnreadByVisitorMessageCountChangeListener {
    //MARK: Properties
    var unreadValueChanged = false
    var newValue: Int?

    // MARK: - Methods
    // MARK: UnreadByVisitorMessageCountChangeListener protocol methods
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        unreadValueChanged = true
        self.newValue = newValue
    }
}

final class UnreadByVisitorTimestampChangeListenerMock: UnreadByVisitorTimestampChangeListener {
    //MARK: Properties
    var timestampChanged = false
    var newValue: TimeInterval?

    // MARK: - Methods
    // MARK: UnreadByVisitorTimestampChangeListener protocol methods
    func changedUnreadByVisitorTimestampTo(newValue: Date?) {
        timestampChanged = true
        self.newValue = newValue?.timeIntervalSince1970
    }
}

final class NotFatalErrorHandlerMock: NotFatalErrorHandler {
    //MARK: Properties
    var connectionStateChanged = false
    var connected: Bool?
    var hasError = false
    var error: WebimNotFatalError?

    // MARK: - Methods
    // MARK: NotFatalErrorHandler protocol methods
    func on(error: WebimNotFatalError) {
        hasError = true
        self.error = error
    }

    func connectionStateChanged(connected: Bool) {
        connectionStateChanged = true
        self.connected = connected

    }
}

final class DataMessageCompletionHandlerMock: DataMessageCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: DataMessageError) {
        //Nothing to do
    }
}

final class SendFileCompletionHandlerMock: SendFileCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: SendFileError) {
        //Nothing to do
    }


}

final class DeleteMessageCompletionHandlerMock: DeleteMessageCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: DeleteMessageError) {
        //Nothing to do
    }


}

final class EditMessageCompletionHandlerMock: EditMessageCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: EditMessageError) {
        //Nothing to do
    }


}

final class SendKeyboardRequestCompletionHandlerMock: SendKeyboardRequestCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: KeyboardResponseError) {
        //Nothing to do
    }


}

final class SendDialogToEmailAddressCompletionHandlerMock: SendDialogToEmailAddressCompletionHandler {
    func onSuccess() {
        //Nothing to do
    }

    func onFailure(error: SendDialogToEmailAddressError) {
        //Nothing to do
    }


}

final class SendStickerCompletionHandlerMock: SendStickerCompletionHandler {
    func onSuccess() {
        //Nothing to do
    }

    func onFailure(error: SendStickerError) {
        //Nothing to do
    }


}

final class SendMessageCompletionHandlerMock: SendMessageCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }
}

final class SurveyCloseCompletionHandlerMock: SurveyCloseCompletionHandler {
    func onSuccess() {
        //Nothing to do
    }

    func onFailure(error: SurveyCloseError) {
        //Nothing to do
    }


}

final class DeleteUploadedFileCompletionHandlerMock: DeleteUploadedFileCompletionHandler {
    func onSuccess() {
        //Nothing to do
    }

    func onFailure(error: DeleteUploadedFileError) {
        //Nothing to do
    }


}

final class UploadFileToServerCompletionHandlerMock: UploadFileToServerCompletionHandler {
    func onSuccess(id: String, uploadedFile: UploadedFile) {
        //Nothing to do
    }

    func onFailure(messageID: String, error: SendFileError) {
        //Nothing to do
    }


}

final class ReactionCompletionHandlerMock: ReactionCompletionHandler {
    func onSuccess(messageID: String) {
        //Nothing to do
    }

    func onFailure(error: ReactionError) {
        //Nothing to do
    }


}

final class GeolocationCompletionHandlerMock: GeolocationCompletionHandler {
    func onSuccess() {
        //Nothing to do
    }

    func onFailure(error: GeolocationError) {
        //Nothing to do
    }
}

final class ServerSideSettingsCompletionHandlerMock: ServerSideSettingsCompletionHandler {
    func onSuccess(webimServerSideSettings: WebimServerSideSettings) {
        //Nothing to do
    }

    func onFailure() {
        //Nothing to do
    }
}

