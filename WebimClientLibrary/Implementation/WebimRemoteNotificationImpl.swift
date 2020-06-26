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
        case unreadByVisitorMessagesCount = "unread_by_visitor_msg_cnt"
        case location = "location"
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
    private var type: InternalNotificationType?
    private var location: String?
    private var unreadByVisitorMessagesCount = 0
    
    // MARK: - Initialization
    /*init?(jsonDictionary: [String: Any?]) {
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
    }*/
    
    init?(jsonDictionary: [String: Any?]) {
        guard let apsFields = jsonDictionary[APNSField.aps.rawValue] as? [String: Any],
            let alertFields = apsFields[APSField.alert.rawValue] as? [String: Any] else {
                return nil
        }
        
        if let typeString = alertFields[AlertField.type.rawValue] as? String,
            let type = InternalNotificationType(rawValue: typeString) {
                self.type = type
        }
                
        if let eventString = alertFields[AlertField.event.rawValue] as? String,
            let event = InternalNotificationEvent(rawValue: eventString) {
                self.event = event
        }
        
        if let parameters = alertFields[AlertField.parameters.rawValue] as? [String] {
            self.parameters = parameters
        }
        
        if let location = jsonDictionary[APNSField.location.rawValue] as? String {
            self.location = location
        }
        
        if let unreadByVisitorMessagesCount = jsonDictionary[APNSField.unreadByVisitorMessagesCount.rawValue] as? Int {
            self.unreadByVisitorMessagesCount = unreadByVisitorMessagesCount
        }
        
    }
    
}

// MARK: - WebimRemoteNotification
extension WebimRemoteNotificationImpl: WebimRemoteNotification {
    
    // MARK: - Methods
    // MARK: WebimRemoteNotification protocol methods
    
    func getType() -> NotificationType? {
        guard let type = self.type else {
            return nil
        }
        switch type {
        case .contactInformationRequest:
            return .contactInformationRequest
        case .operatorAccepted:
            return .operatorAccepted
        case .operatorFile:
            return .operatorFile
        case .operatorMessage:
            return .operatorMessage
        case .widget:
            return .widget
        }
    }
    
    func getEvent() -> NotificationEvent? {
        if let event = event {
            switch event {
            case .add:
                return .add
            case .delete:
                return .delete
            }
        }
        return nil
    }
    
    func getParameters() -> [String] {
        return parameters
    }
    
    func getLocation() -> String? {
        return location
    }
    
    func getUnreadByVisitorMessagesCount() -> Int {
        return unreadByVisitorMessagesCount
    }
    
}
