//
//  MessageStream.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 07.08.17.
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
 - seealso:
 `WebimSession.getStream()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol MessageStream: class {
    
    /**
     - seealso:
     `VisitSessionState` type.
     - returns:
     Current session state.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getVisitSessionState() -> VisitSessionState
    
    /**
     - returns:
     Current chat state.
     - seealso:
     `ChatState` type.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getChatState() -> ChatState
    
    /**
     - returns:
     Timestamp after which all chat messages are unread by operator (at the moment of last server update recieved).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getUnreadByOperatorTimestamp() -> Date?
    
    /**
     - returns:
     Timestamp after which all chat messages are unread by visitor (at the moment of last server update recieved) or `nil` if there's no unread by visitor messages.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getUnreadByVisitorTimestamp() -> Date?
    
    /**
     - returns:
     Count of unread by visitor messages (at the moment of last server update recieved).
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func getUnreadByVisitorMessageCount() -> Int

    /**
     - seealso:
     `Department` protocol.
     `DepartmentListChangeListener` protocol.
     - returns:
     List of departments or `nil` if there're any or department list is not received yet.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getDepartmentList() -> [Department]?
    
    /**
     - returns:
     Current LocationSettings of the MessageStream.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getLocationSettings() -> LocationSettings
    
    /**
     - returns:
     Operator of the current chat.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getCurrentOperator() -> Operator?
    
    /**
     - parameter id:
     ID of the operator.
     - returns:
     Previous rating of the operator or 0 if it was not rated before.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getLastRatingOfOperatorWith(id: String) -> Int
    
    /**
     Rates an operator.
     To get an ID of the current operator call `getCurrentOperator()`.
     - important:
     Requires existing chat.
     - seealso:
     `RateOperatorCompletionHandler` protocol.
     - parameter id:
     ID of the operator to be rated. If passed `nil` current chat operator will be rated.
     - parameter rate:
     A number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
     - parameter comletionHandler:
     `RateOperatorCompletionHandler` object.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func rateOperatorWith(id: String?,
                          byRating rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) throws
    
    /**
     Respond sentry call
     - important:
     Id of redirect to sentry message
     - parameter id:
     ID of the operator to be rated. If passed `nil` current chat operator will be rated.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func respondSentryCall(id: String) throws
    
    /**
     Changes `ChatState` to `ChatState.QUEUE`.
     Can cause `VisitSessionState.DEPARTMENT_SELECTION` session state. It means that chat must be started by `startChat(departmentKey:)` method.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func startChat() throws
    
    /**
     Starts chat and sends first message simultaneously.
     Changes `ChatState` to `ChatState.QUEUE`.
     - parameter firstQuestion:
     First message to send.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func startChat(firstQuestion: String?) throws
    
    /**
     Starts chat with particular department.
     Changes `ChatState` to `ChatState.QUEUE`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func startChat(departmentKey: String?) throws

    
    /**
     Starts chat with custom fields.
     Changes `ChatState` to `ChatState.QUEUE`.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
    */
    func startChat(customFields:String?) throws
    
    /**
     Starts chat with particular department and sends first message simultaneously.
     Changes `ChatState` to `ChatState.QUEUE`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter firstQuestion:
     First message to send.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev
     - copyright:
     2017 Webim
     */
    func startChat(departmentKey: String?,
                   firstQuestion: String?) throws
    
    /**
     Starts chat with custom fields and sends first message simultaneously.
     Changes `ChatState` to `ChatState.QUEUE`.
     - parameter firstQuestion:
     First message to send.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func startChat(firstQuestion:String?,
                   customFields: String?) throws
    
    /**
     Starts chat with particular department and custom fields.
     Changes `ChatState` to `ChatState.QUEUE`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func startChat(departmentKey: String?,
                   customFields: String?) throws
    
    /**
     Starts chat with particular department and custom fields and sends first message simultaneously.
     Changes `ChatState` to `ChatState.QUEUE`.
     - seealso:
     `Department` protocol.
     - parameter departmentKey:
     Department key (see `getKey()` of `Department` protocol). Calling this method without this parameter passed is the same as `startChat()` method is called.
     - parameter firstQuestion:
     First message to send.
     - parameter customFields:
     Custom fields in JSON format.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func startChat(departmentKey: String?,
                   firstQuestion: String?,
                   customFields: String?) throws
    
    
    /**
     Changes `ChatState` to `ChatState.CLOSED_BY_VISITOR`.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func closeChat() throws
    
    /**
     This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter.
     - parameter draftMessage:
     Current message content.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func setVisitorTyping(draftMessage: String?) throws
    
    /**
     Sends prechat fields to server.
     - parameter prechatFields:
     Custom fields.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func set(prechatFields: String) throws
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` (see newMessageTracker(messageListener:)). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - returns:
     ID of the message.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func send(message: String) throws -> String
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - parameter data:
     Optional. Custom message parameters dictionary. Note that this functionality does not work as is – server version must support it.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func send(message: String,
              data: [String: Any]?,
              completionHandler: DataMessageCompletionHandler?) throws -> String
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.added(message:after:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     Text of the message.
     - parameter isHintQuestion:
     Optional. Shows to server if a visitor chose a hint (true) or wrote his own text (false).
     - returns:
     ID of the message.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func send(message: String,
              isHintQuestion: Bool?) throws -> String
    
    /**
     Sends a file message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method), `MessageListener.added(message:after:)` with a message `MessageSendStatus.SENDING` in the status is also called.
     - seealso:
     Method could fail. See `SendFileError`.
     - parameter file:
     File data to send
     - parameter filename:
     File name with file extension.
     - parameter mimeType:
     MIME type of the file to send.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func send(file: Data,
              filename: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler?) throws -> String
    
    /**
     Send keyboard request with button.
     - parameter button:
     Selected button.
     - parameter message:
     Message with keyboard.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func sendKeyboardRequest(button: KeyboardButton,
                             message:Message,
                             completionHandler: SendKeyboardRequestCompletionHandler?) throws
    
    /**
     Update widget status. The change is displayed by the operator.
     - parameter data:
     JSON string with new widget status.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func updateWidgetStatus(data: String) throws
    
    /**
     Edits a text message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.changed(oldVersion:newVersion:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - important:
     Maximum length of message is 32000 characters. Longer messages will be clipped.
     - parameter message:
     ID of the message to edit.
     - parameter text:
     Text of the message.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     True if the message can be edited.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func edit(message: Message,
              text: String,
              completionHandler: EditMessageCompletionHandler?) throws -> Bool
    
    /**
     Deletes a message.
     When calling this method, if there is an active `MessageTracker` object (see `newMessageTracker(messageListener:)` method). `MessageListener.removed(message:)`) with a message `MessageSendStatus.SENT` in the status is also called.
     - parameter message:
     The message to delete.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     True if the message can be deleted.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func delete(message: Message,
                completionHandler: DeleteMessageCompletionHandler?) throws -> Bool
    
    /**
     Set chat has been read by visitor.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Aleksej Lapenok
     - copyright:
     2018 Webim
     */
    func setChatRead() throws
    
    /**
     `MessageTracker` (via `MessageTracker.getNextMessages(byLimit:completion:)`) allows to request the messages which are above in the history. Each next call `MessageTracker.getNextMessages(byLimit:completion:)` returns earlier messages in relation to the already requested ones.
     Changes of user-visible messages (e.g. ever requested from `MessageTracker`) are transmitted to `MessageListener`. That is why `MessageListener` is needed when creating `MessageTracker`.
     - important:
     For each `MessageStream` at every single moment can exist the only one active `MessageTracker`. When creating a new one at the previous there will be automatically called `MessageTracker.destroy()`.
     - parameter messageListener:
     A listener of message changes in the tracking range.
     - returns:
     A new `MessageTracker` for this stream.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the WebimSession was created in.
     `AccessError.INVALID_SESSION` if WebimSession was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func newMessageTracker(messageListener: MessageListener) throws -> MessageTracker
    
    /**
     Sets `VisitSessionStateListener` object.
     - seealso:
     `VisitSessionStateListener` protocol.
     `VisitSessionState` type.
     - parameter visitSessionStateListener:
     `VisitSessionStateListener` object.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(visitSessionStateListener: VisitSessionStateListener)
    
    /**
     Sets the `ChatState` change listener.
     - parameter chatStateListener:
     The `ChatState` change listener.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(chatStateListener: ChatStateListener)
    
    /**
     Sets the current `Operator` change listener.
     - parameter currentOperatorChangeListener:
     Current `Operator` change listener.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener)
    
    /**
     Sets `DepartmentListChangeListener` object.
     - seealso:
     `DepartmentListChangeListener` protocol.
     `Department` protocol.
     - parameter departmentListChangeListener:
     `DepartmentListChangeListener` object.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(departmentListChangeListener: DepartmentListChangeListener)
    
    /**
     Sets the listener of the MessageStream LocationSettings changes.
     - parameter locationSettingsChangeListener:
     The listener of MessageStream LocationSettings changes.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(locationSettingsChangeListener: LocationSettingsChangeListener)
    
    /**
     Sets the listener of the "operator typing" status changes.
     - parameter operatorTypingListener:
     The listener of the "operator typing" status changes.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(operatorTypingListener: OperatorTypingListener)
    
    /**
     Sets the listener of session status changes.
     - parameter onlineStatusChangeListener:
     `OnlineStatusChangeListener` object.
     - seealso:
     `OnlineStatusChangeListener`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func set(onlineStatusChangeListener: OnlineStatusChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method.
     - parameter unreadByOperatorTimestampChangeListener:
     `UnreadByOperatorTimestampChangeListener` object.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func set(unreadByOperatorTimestampChangeListener: UnreadByOperatorTimestampChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
     - parameter unreadByVisitorMessageCountChangeListener:
     `UnreadByVisitorMessageCountChangeListener` object.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func set(unreadByVisitorMessageCountChangeListener: UnreadByVisitorMessageCountChangeListener)
    
    /**
     Sets listener for parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
     - parameter unreadByVisitorTimestampChangeListener:
     `UnreadByVisitorTimestampChangeListener` object.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func set(unreadByVisitorTimestampChangeListener: UnreadByVisitorTimestampChangeListener)
    
}

/**
 Interface that provides methods for handling MessageStream LocationSettings which are received from server.
 - seealso:
 `LocationSettingsChangeListener`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol LocationSettings {
    
    /**
     This method shows to an app if it should show hint questions to visitor.
     - returns:
     True if an app should show hint questions to visitor, false otherwise.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func areHintsEnabled() -> Bool
    
}

// MARK: -
/**
 - seealso:
 `MessageStream.send(message:data:completionHandler:)`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
public protocol DataMessageCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `DataMessageError`.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func onFailure(messageID: String,
                   error: DataMessageError)
    
}

/**
 - seealso:
 `MessageStream.edit(message:messageID:completionHandler:)`.
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
public protocol EditMessageCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `EditMessageError`.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func onFailure(messageID: String,
                   error: EditMessageError)
}

/**
 - seealso:
 `MessageStream.delete(messageID:completionHandler:)`.
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
public protocol DeleteMessageCompletionHandler: class {
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `DeleteMessageError`.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func onFailure(messageID: String,
                   error: DeleteMessageError)
}

/**
 - seealso:
 `MessageStream.send(file:filename:mimeType:completionHandler:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol SendFileCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `SendFileError`.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func onFailure(messageID: String,
                   error: SendFileError)
    
}

/**
 - seealso:
 `MessageStream.sendKeyboardRequest(button:message:completionHandler:)`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol SendKeyboardRequestCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - seealso:
     `KeyboardResponseError`.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func onFailure(messageID: String,
                   error: KeyboardResponseError)
    
}

/**
 - seealso:
 `MessageStream.rateOperatorWith(id:byRating:completionHandler:)`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol RateOperatorCompletionHandler: class {
    
    /**
     Executed when operation is done successfully.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func onSuccess()
    
    /**
     Executed when operation is failed.
     - parameter error:
     Error.
     - seealso:
     `RateOperatorError`.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func onFailure(error: RateOperatorError)
    
}

/**
 Provides methods to track changes of `VisitSessionState` status.
 - seealso:
 `VisitSessionState` protocol.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol VisitSessionStateListener: class {
    
    /**
     Called when `VisitSessionState` status is changed.
     - parameter previousState:
     Previous value of `VisitSessionState` status.
     - parameter newState:
     New value of `VisitSessionState` status.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func changed(state previousState: VisitSessionState,
                 to newState: VisitSessionState)
    
}

/**
 Delegate protocol that provides methods to handle changes of chat state.
 - seealso:
 `MessageStream.set(chatStateListener:)`
 `MessageStream.getChatState()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol ChatStateListener: class {
    
    /**
     Called during `ChatState` transition.
     - parameter previousState:
     Previous state.
     - parameter newState:
     New state.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func changed(state previousState: ChatState,
                 to newState: ChatState)
    
}

/**
 - seealso:
 `MessageStream.set(currentOperatorChangeListener:)`
 `MessageStream.getCurrentOperator()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol CurrentOperatorChangeListener: class {
    
    /**
     Called when `Operator` of the current chat changed.
     - parameter previousOperator:
     Previous operator.
     - parameter newOperator:
     New operator or nil if doesn't exist.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func changed(operator previousOperator: Operator?,
                 to newOperator: Operator?)
    
}

/**
 Provides methods to track changes in departments list.
 - seealso:
 `Department` protocol.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol DepartmentListChangeListener: class {
    
    /**
     Called when department list is received.
     - seealso:
     `Department` protocol.
     - parameter departmentList:
     Current department list.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func received(departmentList: [Department])
    
}

/**
 Interface that provides methods for handling changes in LocationSettings.
 - seealso:
 `LocationSettings`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol LocationSettingsChangeListener: class {
    
    /**
     Method called by an app when new LocationSettings object is received.
     - parameter previousLocationSettings:
     Previous LocationSettings state.
     - parameter newLocationSettings:
     New LocationSettings state.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func changed(locationSettings previousLocationSettings: LocationSettings,
                 to newLocationSettings: LocationSettings)
    
}

/**
 - seealso:
 `MessageStream.set(operatorTypingListener:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol OperatorTypingListener: class {
    
    /**
     Called when operator typing state changed.
     - parameter isTyping:
     True if operator is typing, false otherwise.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func onOperatorTypingStateChanged(isTyping: Bool)
    
}

/**
 Interface that provides methods for handling changes of session status.
 - seealso:
 `MessageStream.set(onlineStatusChangeListener:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol OnlineStatusChangeListener: class {
    
    /**
     Called when new session status is received.
     - parameter previousOnlineStatus:
     Previous value.
     - parameter newOnlineStatus:
     New value.
     - seealso:
     `OnlineStatus`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func changed(onlineStatus previousOnlineStatus: OnlineStatus,
                 to newOnlineStatus: OnlineStatus)
    
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method.
 - seealso:
 `MessageStream.set(unreadByOperatorTimestampChangeListener:)`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
public protocol UnreadByOperatorTimestampChangeListener: class {
    
    /**
     Method to be called when parameter that is to be returned by `MessageStream.getUnreadByOperatorTimestamp()` method is changed.
     - parameter newValue:
     New unread by operator timestamp value.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func changedUnreadByOperatorTimestampTo(newValue: Date?)
    
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
 - seealso:
 `MessageStream.set(unreadByVisitorMessageCountChangeListener:)`.
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
public protocol UnreadByVisitorMessageCountChangeListener: class {
    
    /**
     Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorMessageCount()` method.
     - parameter newValue:
     New unread by visitor message count value.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func changedUnreadByVisitorMessageCountTo(newValue: Int)
    
}

/**
 Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
 - seealso:
 `MessageStream.set(unreadByVisitorTimestampChangeListener:)`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
public protocol UnreadByVisitorTimestampChangeListener: class {
    
    /**
     Interface that provides methods for handling changes of parameter that is to be returned by `MessageStream.getUnreadByVisitorTimestamp()` method.
     - parameter newValue:
     New unread by visitor timestamp value.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func changedUnreadByVisitorTimestampTo(newValue: Date?)
    
}

// MARK: -

/**
 A chat is seen in different ways by an operator depending on ChatState.
 The initial state is `NONE`.
 Then if a visitor sends a message (`MessageStream.send(message:isHintQuestion:)`), the chat changes it's state to `QUEUE`. The chat can be turned into this state by calling `MessageStream.startChat()`.
 After that, if an operator takes the chat to process, the state changes to `CHATTING`. The chat is being in this state until the visitor or the operator closes it.
 When closing a chat by the visitor `MessageStream.closeChat()`, it turns into the state `CLOSED_BY_VISITOR`, by the operator - `CLOSED_BY_OPERATOR`.
 When both the visitor and the operator close the chat, it's state changes to the initial – `NONE`. A chat can also automatically turn into the initial state during long-term absence of activity in it.
 Furthermore, the first message can be sent not only by a visitor but also by an operator. In this case the state will change from the initial to `INVITATION`, and then, after the first message of the visitor, it changes to `CHATTING`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum ChatState {
    
    /**
     Means that an operator has taken a chat for processing.
     From this state a chat can be turned into:
     * `CLOSED_BY_OPERATOR`, if an operator closes the chat;
     * `CLOSED_BY_VISITOR`, if a visitor closes the chat (`MessageStream.closeChat()`);
     * `NONE`, automatically during long-term absence of activity.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case CHATTING
    
    /**
     Means that chat is picked up by a bot.
     From this state a chat can be turned into:
     * `CHATTING`, if an operator intercepted the chat;
     * `CLOSED_BY_VISITOR`, if a visitor closes the chat (`MessageStream.closeChat()`);
     * `NONE`, automatically during long-term absence of activity.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case CHATTING_WITH_ROBOT
    
    /**
     Means that an operator has closed the chat.
     From this state a chat can be turned into:
     * `NONE`, if the chat is also closed by a visitor (`MessageStream.closeChat()`), or automatically during long-term absence of activity;
     * `QUEUE`, if a visitor sends a new message (`MessageStream.send(message:isHintQuestion:)`).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case CLOSED_BY_OPERATOR
    
    /**
     Means that a visitor has closed the chat.
     From this state a chat can be turned into:
     * `NONE`, if the chat is also closed by an operator or automatically during long-term absence of activity;
     * `QUEUE`, if a visitor sends a new message (`MessageStream.send(message:isHintQuestion:)`).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case CLOSED_BY_VISITOR
    
    /**
     Means that a chat has been started by an operator and at this moment is waiting for a visitor's response.
     From this state a chat can be turned into:
     * `CHATTING`, if a visitor sends a message (`MessageStream.send(message:isHintQuestion:)`);
     * `NONE`, if an operator or a visitor closes the chat (`MessageStream.closeChat()`).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case INVITATION
    
    /**
     Means the absence of a chat as such, e.g. a chat has not been started by a visitor nor by an operator.
     From this state a chat can be turned into:
     * `QUEUE`, if the chat is started by a visitor (by the first message or by calling `MessageStream.startChat()`;
     * `INVITATION`, if the chat is started by an operator.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case NONE
    
    /**
     Means that a chat has been started by a visitor and at this moment is being in the queue for processing by an operator.
     From this state a chat can be turned into:
     * `CHATTING`, if an operator takes the chat for processing;
     * `NONE`, if a visitor closes the chat (by calling (`MessageStream.closeChat()`) before it is taken for processing;
     * `CLOSED_BY_OPERATOR`, if an operator closes the chat without taking it for processing.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case QUEUE
    
    /**
     The state is undefined.
     This state is set as the initial when creating a new session, until the first response of the server containing the actual state is got. This state is also used as a fallback if WebimClientLibrary can not identify the server state (e.g. if the server has been updated to a version that contains new states).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case UNKNOWN
    
}

/**
 Online state possible cases.
 - seealso:
 `OnlineStatusChangeListener`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum OnlineStatus {
    
    /**
     Offline state with chats' count limit exceeded.
     Means that visitor is not able to send messages at all.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case BUSY_OFFLINE
    
    /**
     Online state with chats' count limit exceeded.
     Visitor is able send offline messages, but the server can reject it.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case BUSY_ONLINE
    
    /**
     Visitor is able to send offline messages.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case OFFLINE
    
    /**
     Visitor is able to send both online and offline messages.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case ONLINE
    
    /**
     First status is not recieved yet or status is not supported by this version of the library.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case UNKNOWN
    
}

/**
 Session possible states.
 - seealso:
 `getVisitSessionState()` method of `MessageStream` protocol.
 `VisitSessionStateListener` protocol.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum VisitSessionState {
    
    /**
     Chat in progress.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case CHAT
    
    /**
     Chat must be started with department selected (there was a try to start chat without department selected).
     - seealso:
     `startChat(departmentKey:)` of `MessageStream` protocol.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case DEPARTMENT_SELECTION
    
    /**
     Session is active but no chat is occuring (chat was not started yet).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case IDLE
    
    /**
     Session is active but no chat is occuring (chat was closed recently).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case IDLE_AFTER_CHAT
    
    /**
     Offline state.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case OFFLINE_MESSAGE
    
    /**
     First status is not received yet or status is not supported by this version of the library.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case UNKNOWN
    
}

/**
 - seealso:
 `DataMessageCompletionHandler.onFailure(messageID:error:)`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
public enum DataMessageError: Error {
    
    /**
     Received error is not supported by current WebimClientLibrary version.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case UNKNOWN
    
    // MARK: Quoted message errors
    // Note that quoted message mechanism is not a standard feature – it must be implemented by a server. For more information please contact with Webim support service.
    
    /**
     To be raised when quoted message ID belongs to a message without `canBeReplied` flag set to `true` (this flag is to be set on the server-side).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case QUOTED_MESSAGE_CANNOT_BE_REPLIED
    
    /**
     To be raised when quoted message ID belongs to another visitor's chat.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case QUOTED_MESSAGE_FROM_ANOTHER_VISITOR
    
    /**
     To be raised when quoted message ID belongs to multiple messages (server DB error).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case QUOTED_MESSAGE_MULTIPLE_IDS
    
    /**
     To be raised when one or more required arguments of quoting mechanism are missing.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case QUOTED_MESSAGE_REQUIRED_ARGUMENTS_MISSING
    
    /**
     To be raised when wrong quoted message ID is sent.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case QUOTED_MESSAGE_WRONG_ID
    
}

/**
 - seealso:
 `EditMessageCompletionHandler.onFailure(messageID:error:)`
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
public enum EditMessageError: Error {
    /**
     Received error is not supported by current WebimClientLibrary version.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case UNKNOWN
    /**
     Editing messages by visitor is turned off on the server.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case NOT_ALLOWED
    /**
     Editing message is empty.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case MESSAGE_EMPTY
    /**
     Visitor can edit only his messages.
     The specified id belongs to someone else's message.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case MESSAGE_NOT_OWNED
    /**
     The server may deny a request if the message size exceeds a limit.
     The maximum size of a message is configured on the server.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case MAX_LENGTH_EXCEEDED
    /**
     Visitor can edit only text messages.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case WRONG_MESSAGE_KIND
}

/**
 - seealso:
 `DeleteMessageCompletionHandler.onFailure(messageID:error:)`
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
public enum DeleteMessageError: Error {
    /**
     Received error is not supported by current WebimClientLibrary version.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case UNKNOWN
    /**
     Deleting messages by visitor is turned off on the server.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case NOT_ALLOWED
    /**
     Visitor can delete only his messages.
     The specified id belongs to someone else's message.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case MESSAGE_NOT_OWNED
    /**
     Message with the specified id is not found in history.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case MESSAGE_NOT_FOUND
}

/**
 - seealso:
 `SendFileCompletionHandler.onFailure(messageID:error:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum SendFileError: Error {
    
    /**
     The server may deny a request if the file size exceeds a limit.
     The maximum size of a file is configured on the server.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case FILE_SIZE_EXCEEDED
    
    /**
     The server may deny a request if the file type is not allowed.
     The list of allowed file types is configured on the server.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case FILE_TYPE_NOT_ALLOWED
    
    /**
     Sending files in body is not supported. Use multipart form only.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case UPLOADED_FILE_NOT_FOUND
    /**
     Received error is not supported by current WebimClientLibrary version.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    case UNKNOWN
    
}

/**
 - seealso:
 `KeyboardResponseCompletionHandler.onFailure(error:)`.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum KeyboardResponseError: Error {
    
    /**
     Received error is not supported by current WebimClientLibrary version.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case UNKNOWN
    
    /**
     Arised when trying to response if no chat is exists.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case NO_CHAT
    
    /**
     Arised when trying to response without button id.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case BUTTON_ID_NOT_SET
    
    /**
     Arised when trying to response without request message id.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case REQUEST_MESSAGE_ID_NOT_SET
    
    /**
     Arised when trying to response with wrong data.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case CAN_NOT_CREATE_RESPONSE
    
}

/**
 - seealso:
 `RateOperatorCompletionHandler.onFailure(error:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum RateOperatorError: Error {
    
    /**
     Arised when trying to send operator rating request if no chat is exists.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case NO_CHAT
    
    /**
     Arised when trying to send operator rating request if passed operator ID doesn't belong to existing chat operator (or, in the same place, chat doesn't have an operator at all).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case WRONG_OPERATOR_ID
    
}
