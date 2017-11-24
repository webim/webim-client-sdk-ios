//
//  WebimService.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 20.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
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
import WebimClientLibrary

/**
 A set of methods that handles WebimClientLibrary functionality.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class WebimService {
    
    // MARK: - Constants
    private enum ChatSettings: Int {
        case MESSAGES_PER_REQUEST = 5
    }
    private enum SessionDefaults: String {
        case ACCOUNT_NAME = "demo"
        case LOCATION = "mobile"
        case PAGE_TITLE = "iOS demo app"
    }
    private enum VisitorField: String {
        case ID = "id"
        case NAME = "display_name"
        case CRC = "crc"
    }
    private enum VisitorFieldValue: String {
        // Hardcoded. See more at https://webim.ru/help/identification/
        case ID = "1234567890987654321"
        case NAME = "Никита"
        case CRC = "ffadeb6aa3c788200824e311b9aa44cb"
    }
    
    
    // MARK: - Properties
    var messageStream: MessageStream?
    var messageTracker: MessageTracker?
    var webimSession: WebimSession?
    
    
    // MARK: - Methods
    
    // MARK: Webim session methods.
    
    /**
     Tries to create session of Webim service.
     - SeeAlso:
     `Webim` and `SessionBuilder` classes of WebimClientLibrary.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func createSession() {
        // Hardcoded values that work with "demo" account only!
        let visitorFieldsJSONString = "{\"\(VisitorField.ID.rawValue)\":\"\(VisitorFieldValue.ID.rawValue)\",\"\(VisitorField.NAME.rawValue)\":\"\(VisitorFieldValue.NAME.rawValue)\",\"\(VisitorField.CRC.rawValue)\":\"\(VisitorFieldValue.CRC.rawValue)\"}"
        
        let deviceToken: String? = UserDefaults.standard.object(forKey: AppDelegate.UserDefaultsKey.DEVICE_TOKEN.rawValue) as? String
        
        do {
            webimSession = try Webim.newSessionBuilder()
                .set(accountName: SessionDefaults.ACCOUNT_NAME.rawValue)
                .set(location: SessionDefaults.LOCATION.rawValue)
                .set(pageTitle: SessionDefaults.PAGE_TITLE.rawValue)
                .set(visitorFieldsJSONString: visitorFieldsJSONString)
                .set(fatalErrorHandler: self)
                .set(remoteNotificationSystem: (deviceToken != nil) ? .APNS : .NONE)
                .set(deviceToken: deviceToken)
                .build()
        } catch let error as SessionBuilder.SessionBuilderError {
            // Assuming to check parameters values in Webim session builder methods.
            switch error {
            case .NIL_ACCOUNT_NAME:
                print("Webim session object creating failed because of passing nil account name.")
            case .NIL_LOCATION:
                print("Webim session object creating failed because of passing nil location name.")
            case .INVALID_REMOTE_NOTIFICATION_CONFIGURATION:
                print("Webim session object creating failed because of invalid remote notifications configuration.")
            }
        } catch {
            print("Webim session object creating failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to start session of Webim service.
     - important:
     It is necessary to call `createSession()` before calling this one.
     - SeeAlso:
     `resume()` method of `WebimSession` protocol of WebimClientLibrary.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func startSession() {
        do {
            try webimSession?.resume()
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    // MARK: MessageStream methods.
    
    /**
     Sets `MessageStream` object appropriate to Webim session.
     - important:
     It is necessary to call `createSession()` method before calling this one.
     - SeeAlso:
     `getStream()` method of `WebimSession` protocol of WebimClientLibrary.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func setMessageStream() {
        messageStream = webimSession?.getStream()
    }
    
    /**
     Tries to send draft message to Webim service.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `setVisitorTyping(draftMessage:)` method of `MessageStream` protocol of WebimClientLibrary.
     - parameter draft:
     Message draft. Empty string or nil means that visitor stopped typing.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func setVisitorTyping(draft: String?) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.setVisitorTyping(draftMessage: draft)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Visitor status sending failed because it was called when session object is invalid.")
                // Assuming to check Webim session object lifecycle.
            case .INVALID_THREAD:
                print("Visitor status sending failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Visitor typing status sending failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to send message to Webim service.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `send(message:)` method of `MessageStream` protocol of WebimClientLibrary.
     - parameter message:
     Message to be sent.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func send(message: String) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            // Function returns an unique message ID. In this app it is not used.
            _ = try messageStream?.send(message: message)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Message sending failed because it was called when session object is invalid.")
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Message sending failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Message status sending failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to send file to Webim service.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `send(file:,filename:,mimeType:,completionHandler:)` method of `MessageStream` protocol of WebimClientLibrary.
     - parameter data:
     Data of file to be sent.
     - parameter fileName:
     File name.
     - parameter mimeType:
     File MIME-type.
     - parameter completionHandler:
     `SendFileCompletionHandler` object.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func send(file data: Data,
              fileName: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            // Function returns an unique message ID. In this app it is not used.
            let _ = try messageStream?.send(file: data,
                                            filename: fileName,
                                            mimeType: mimeType,
                                            completionHandler: completionHandler)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Message sending failed because it was called when session object is invalid.")
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Message sending failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Message status sending failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to close current chat.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `closeChat()` method of `MessageStream` protocol of WebimClientLibrary.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func closeChat() {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.closeChat()
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to rate current operator.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `rateOperatorWith(id:,byRating:)` method of `MessageStream` protocol of WebimClientLibrary.
     - parameter operatorID:
     ID of the operator to rate.
     - parameter rating:
     Rating in whole numbers from 1 to 5.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func rateOperator(withID operatorID: String,
                      byRating rating: Int) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.rateOperatorWith(id: operatorID,
                                                byRating: rating)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
                // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    // MARK: MessageTracker methods
    
    /**
     Sets `MessageTracker` object.
     - important:
     Assuming session is created and started.
     - SeeAlso:
     `new(messageTracker:)` method of `MessageStream` protocol of WebimClientLibrary.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func setMessageTracker(withMessageListener messageListener: MessageListener) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageTracker = messageStream?.new(messageTracker: messageListener)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to get last messages of message history.
     - important:
     Assuming session is created and started.
     - important:
     It is necessary to call `setMessageTracker(withMessageListener messageListener:` method before calling this one.
     - SeeAlso:
     `getLastMessages(byLimit:,completion:)` method of `MessageTracker` protocol of WebimClientLibrary.
     `Message` protocol of WebimClientLibrary.
     - parameter completion:
     Completion that will be called on the resulting array of messages if method call succeeded.
     - parameter result:
     Resulting array of messages if method call succeeded.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getLastMessages(completion: @escaping (_ result: [Message]) -> ()) {
        do {
            try messageTracker?.getLastMessages(byLimit: ChatSettings.MESSAGES_PER_REQUEST.rawValue,
                                                completion: completion)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
    /**
     Tries to get next messages above in the message history.
     - important:
     Assuming session is created and started.
     It is necessary to call `setMessageTracker(withMessageListener messageListener:` method before calling this one.
     - SeeAlso:
     `getNextMessages(byLimit:,completion:)` method of `MessageTracker` protocol of WebimClientLibrary.
     `Message` protocol of WebimClientLibrary.
     - parameter completion:
     Completion that will be called on the resulting array of messages if method call succeeded.
     - parameter result:
     Resulting array of messages if method call succeeded.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getNextMessages(completion: @escaping (_ result: [Message]) -> ()) {
        do {
            try messageTracker?.getNextMessages(byLimit: ChatSettings.MESSAGES_PER_REQUEST.rawValue,
                                               completion: completion)
        } catch let error as AccessError {
            switch error {
            case .INVALID_SESSION:
                print("Webim session starting/resuming failed because it was called when session object is invalid.")
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            case .INVALID_THREAD:
                print("Webim session starting/resuming failed because it was called from a wrong thread.")
                // Assuming to check concurrent calls of WebimClientLibrary methods.
            }
        } catch {
            print("Webim session starting/resuming failed with unknown error: \(error.localizedDescription)")
        }
    }
    
}

// MARK: - WEBIM: FatalErrorHandler
extension WebimService: FatalErrorHandler {
    
    func on(error: WebimError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .ACCOUNT_BLOCKED:
            print("Account with used account name is blocked by Webim service.")
            // Assuming to contact with Webim support.
        case .PROVIDED_VISITOR_EXPIRED:
            print("Provided visitor fields expired.")
            // Assuming to re-authorize it and re-create session object.
        case .UNKNOWN:
            print("An unknown error occured.")
        case .VISITOR_BANNED:
            print("Visitor with provided visitor fields is banned by an operator.")
        case .WRONG_PROVIDED_VISITOR_HASH:
            print("Provided visitor fields are wrong.")
            // Assuming to check visitor field generating.
        }
    }
    
}
