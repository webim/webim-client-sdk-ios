//
//  WebimRemoteNotification.swift
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
 Abstracts a remote notifications.
 - SeeAlso:
 `Webim.parseRemoteNotification()`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol WebimRemoteNotification {
    
    /**
     - returns:
     The type of this remote notification.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getType() -> NotificationType
    
    /**
     - returns:
     The event of this remote notification.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getEvent() -> NotificationEvent
    
    /**
     - returns:
     Parameters of this remote notification. Each `NotificationType` has specific list of parameters.
     - SeeAlso:
     `NotificationType`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getParameters() -> [String]

}


// MARK: -
/**
 - SeeAlso:
 `WebimRemoteNotification.getType()`
 `WebimRemoteNotification.getParameters()`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum NotificationType {
    
    /**
     This notification type indicated that an operator has connected to a dialogue.
     Parameters:
     * Operator's name.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OPERATOR_ACCEPTED
    
    /**
     This notification type indicated that an operator has sent a file.
     Parameters:
     * Operator's name;
     * File name.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OPERATOR_FILE
    
    /**
     This notification type indicated that an operator has sent a text message.
     Parameters:
     * Operator's name;
     * Message text.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OPERATOR_MESSAGE
}

// MARK: -
/**
 - SeeAlso:
 `WebimRemoteNotification.getEvent()`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum NotificationEvent {
    
    /**
     Means that a notification should be added by current remote notification.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case ADD
    
    /**
     Means that a notification should be deleted by current remote notification.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case DELETE
    
}
