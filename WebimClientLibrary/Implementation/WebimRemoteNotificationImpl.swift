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
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class WebimRemoteNotificationImpl: WebimRemoteNotification {
    
    // MARK: - Constants
    
    enum APNsField: String {
        case APS = "aps"
        case WEBIM = "webim"
    }
    
    enum APSField: String {
        case ALERT = "alert"
    }
    
    private enum AlertField: String {
        case EVENT = "event"
        case PARAMETERS = "loc-args"
        case TYPE = "loc-key"
    }
    
    private enum InternalNotificationEvent: String {
        case ADD = "add"
        case DELETE = "del"
    }
    
    private enum InternalNotificationType: String {
        case CONTACT_INFORMATION_REQUEST = "P.CR"
        case OPERATOR_ACCEPTED = "P.OA"
        case OPERATOR_FILE = "P.OF"
        case OPERATOR_MESSAGE = "P.OM"
        case WIDGET = "P.WM"
    }
    
    // MARK: - Properties
    private var event: InternalNotificationEvent? = nil
    private lazy var parameters = [String]()
    private var type: InternalNotificationType
    
    
    // MARK: - Initialization
    init?(jsonDictionary: [String: Any?]) {
        guard let type = jsonDictionary[AlertField.TYPE.rawValue] as? String else {
            return nil
        }
        switch type {
        case InternalNotificationType.CONTACT_INFORMATION_REQUEST.rawValue:
            self.type = .CONTACT_INFORMATION_REQUEST
            
            break
        case InternalNotificationType.OPERATOR_ACCEPTED.rawValue:
            self.type = .OPERATOR_ACCEPTED
            
            break
        case InternalNotificationType.OPERATOR_FILE.rawValue:
            self.type = .OPERATOR_FILE
            
            break
        case InternalNotificationType.OPERATOR_MESSAGE.rawValue:
            self.type = .OPERATOR_MESSAGE
            
            break
        case InternalNotificationType.WIDGET.rawValue:
            self.type = .WIDGET
            
            break
        default:
            // Not supported notification type.
            return nil
        }
        
        if let event = jsonDictionary[AlertField.EVENT.rawValue] as? String {
            switch event {
            case InternalNotificationEvent.ADD.rawValue:
                self.event = .ADD
                
                break
            case InternalNotificationEvent.DELETE.rawValue:
                self.event = .DELETE
                
                break
            default:
                // Not supported notification event.
                break
            }
        }
        
        if let parameters = jsonDictionary[AlertField.PARAMETERS.rawValue] as? [String] {
            self.parameters = parameters
        }
    }
    
    
    // MARK: - Methods
    // MARK: WebimRemoteNotification protocol methods
    
    func getType() -> NotificationType {
        switch type {
        case .CONTACT_INFORMATION_REQUEST:
            return .CONTACT_INFORMATION_REQUEST
        case .OPERATOR_ACCEPTED:
            return .OPERATOR_ACCEPTED
        case .OPERATOR_FILE:
            return .OPERATOR_FILE
        case .OPERATOR_MESSAGE:
            return .OPERATOR_MESSAGE
        case .WIDGET:
            return .WIDGET
        }
    }
    
    func getEvent() -> NotificationEvent? {
        if let event = event {
            switch event {
            case .ADD:
                return .ADD
            case .DELETE:
                return .DELETE
            }
        }
        
        return nil
    }
    
    func getParameters() -> [String] {
        return parameters
    }
    
}
