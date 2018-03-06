//
//  WebimRemoteNotificationImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimRemoteNotificationImpl {
    
    // MARK: - Constants
    enum APNSField: String {
        case aps = "aps"
        case webim = "webim"
    }
    enum APSField: String {
        case alert = "alert"
    }
    private enum AlertField: String {
        case event = "event"
        case parameters = "loc-args"
        case type = "loc-key"
    }
    private enum InternalNotificationEvent: String {
        case add = "add"
        case delete = "del"
    }
    private enum InternalNotificationType: String {
        case contactInformationRequest = "P.CR"
        case operatorAccepted = "P.OA"
        case operatorFile = "P.OF"
        case operatorMessage = "P.OM"
        case widget = "P.WM"
    }
    
    // MARK: - Properties
    private var event: InternalNotificationEvent? = nil
    private lazy var parameters = [String]()
    private var type: InternalNotificationType
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let typeString = jsonDictionary[AlertField.type.rawValue] as? String,
            let type = InternalNotificationType(rawValue: typeString) else {
            return nil
        }
        self.type = type
        
        if let eventString = jsonDictionary[AlertField.event.rawValue] as? String,
            let event = InternalNotificationEvent(rawValue: eventString) {
            self.event = event
        }
        
        if let parameters = jsonDictionary[AlertField.parameters.rawValue] as? [String] {
            self.parameters = parameters
        }
    }
    
}

// MARK: - WebimRemoteNotification
extension WebimRemoteNotificationImpl: WebimRemoteNotification {
    
    // MARK: - Methods
    // MARK: WebimRemoteNotification protocol methods
    
    func getType() -> NotificationType {
        switch type {
        case .contactInformationRequest:
            return .CONTACT_INFORMATION_REQUEST
        case .operatorAccepted:
            return .OPERATOR_ACCEPTED
        case .operatorFile:
            return .OPERATOR_FILE
        case .operatorMessage:
            return .OPERATOR_MESSAGE
        case .widget:
            return .WIDGET
        }
    }
    
    func getEvent() -> NotificationEvent? {
        if let event = event {
            switch event {
            case .add:
                return .ADD
            case .delete:
                return .DELETE
            }
        }
        
        return nil
    }
    
    func getParameters() -> [String] {
        return parameters
    }
    
}
