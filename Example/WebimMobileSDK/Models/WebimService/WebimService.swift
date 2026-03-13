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
import WebimMobileWidget

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
    
    public weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    public weak var notFatalErrorHandler: NotFatalErrorHandler?
    private var messageStream: MessageStream?
    private var messageTracker: MessageTracker?
    private var webimSession: WebimSession?
    
    // MARK: - Initialization
    
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
    }
    
    init(fatalErrorHandlerDelegate: FatalErrorHandlerDelegate,
         notFatalErrorHandler: NotFatalErrorHandler?) {
        self.fatalErrorHandlerDelegate = fatalErrorHandlerDelegate
        self.notFatalErrorHandler = notFatalErrorHandler
    }
    
    // MARK: - Methods
    
    func set(session: WebimSession) {
        self.webimSession = session
    }
    
    func set(unreadByVisitorMessageCountChangeListener listener: UnreadByVisitorMessageCountChangeListener) {
        webimSession?.getStream().set(unreadByVisitorMessageCountChangeListener: listener)
    }
    
    //For example
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
    
    func createSession(jsonString: String? = nil,
                       jsonData: Data? = nil,
                       infoListener: InfoListener? = nil) {
        
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
            .set(isLightModeEnabled: false)
            .set(infoListener: infoListener)
            .set(webimLogger: WidgetLogManager.shared,
                 verbosityLevel: .debug,
                 availableLogTypes: [.manualCall,
                                     .messageHistory,
                                     .networkRequest,
                                     .undefined])
        
        if !Settings.shared.userDataJson.isEmpty, let jsonData = Settings.shared.userDataJson.data(using: .utf8) {
            _ = sessionBuilder.set(visitorFieldsJSONData: jsonData)
        }
        
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
    
    func setMessageStream() {
        messageStream = webimSession?.getStream()
    }
    
    func getMessageStream() -> MessageStream? {
        return messageStream
    }
    
    func set(forceOnline: Bool) {
        if messageStream == nil {
            setMessageStream()
        }
        messageStream?.set(forceOnline: forceOnline)
    }
    
    func getUnreadMessagesByVisitor() -> Int {
        if messageStream == nil {
            setMessageStream()
        }
        return messageStream?.getUnreadByVisitorMessageCount() ?? 0
    }
    
    func startChat(departmentKey: String? = nil,
                   message: String? = nil) {
        do {
            if messageStream == nil {
                setMessageStream()
            }
            
            try messageStream?.startChat(departmentKey: departmentKey,
                                         firstQuestion: message)
        } catch {
            self.printError(error: error, message: "Start chat")
        }
    }
    
    func sendFile(data: Data,
                  fileName: String,
                  mimeType: String,
                  completionHandler: SendFileCompletionHandler) {
        do {
            _ = try messageStream?.send(file: data,
                                        filename: fileName,
                                        mimeType: mimeType,
                                        completionHandler: completionHandler)  // Returned message ID ignored.
        } catch {
            self.printError(error: error, message: "Send file")
        }
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
    
    func printError(error: Error,
                    message: String) {
        switch error {
        case AccessError.invalidSession:
            // Assuming to check Webim session object lifecycle or re-creating Webim session object.
            print(message + " failed because it was called when session object is invalid.")
        case AccessError.invalidThread:
            // Assuming to check concurrent calls of WebimClientLibrary methods.
            print(message + " failed because it was called from a wrong thread.")
        default:
            print(message + " failed with unknown error: \(error.localizedDescription)")
        }
    }
}
