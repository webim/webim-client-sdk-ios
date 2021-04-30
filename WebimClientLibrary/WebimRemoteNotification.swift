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
 Abstracts a remote notifications from Webim service.
 - seealso:
 `Webim.parseRemoteNotification()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol WebimRemoteNotification {
    
    /**
     - seealso:
     `NotificationType` enum.
     - returns:
     Type of this remote notification.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getType() -> NotificationType?
    
    /**
     - seealso:
     `NotificationEvent` enum.
     - returns:
     Event of this remote notification.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getEvent() -> NotificationEvent?
    
    /**
     - returns:
     Parameters of this remote notification. Each `NotificationType` has specific list of parameters.
     - seealso:
     `NotificationType`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getParameters() -> [String]
    
    /**
     - returns:
     Chat location.
     - seealso:
     `NotificationType`
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getLocation() -> String?
    
    /**
     - returns:
     Unread by visitor messages count.
     - seealso:
     `NotificationType`
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getUnreadByVisitorMessagesCount() -> Int

}

// MARK: -
/**
 - seealso:
 `WebimRemoteNotification.getType()`
 `WebimRemoteNotification.getParameters()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum NotificationType {
    
    /**
     This notification type indicated that contact information request is sent to a visitor.
     Parameters: empty.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case contactInformationRequest
    
    @available(*, unavailable, renamed: "contactInformationRequest")
    case CONTACT_INFORMATION_REQUEST
    
    /**
     This notification type indicated that an operator has connected to a dialogue.
     Parameters:
     * Operator's name.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case operatorAccepted
    
    @available(*, unavailable, renamed: "operatorAccepted")
    case OPERATOR_ACCEPTED
    
    /**
     This notification type indicated that an operator has sent a file.
     Parameters:
     * Operator's name;
     * File name.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case operatorFile
    
    @available(*, unavailable, renamed: "operatorFile")
    case OPERATOR_FILE
    
    /**
     This notification type indicated that an operator has sent a text message.
     Parameters:
     * Operator's name;
     * Message text.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case operatorMessage
    
    @available(*, unavailable, renamed: "operatorMessage")
    case OPERATOR_MESSAGE
    
    /**
     This notification type indicated that an operator has sent a widget message.
     Parameters: empty.
     - important:
     This type can be received only if server supports this functionality.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    case widget
    
    @available(*, unavailable, renamed: "widget")
    case WIDGET
}

/**
 - seealso:
 `WebimRemoteNotification.getEvent()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum NotificationEvent {
    
    /**
     Means that a notification should be added by current remote notification.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case add
    
    @available(*, unavailable, renamed: "add")
    case ADD
    
    /**
     Means that a notification should be deleted by current remote notification.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case delete
    
    @available(*, unavailable, renamed: "delete")
    case DELETE
    
}
