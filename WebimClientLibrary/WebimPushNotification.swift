//
//  WebimPushNotification.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 Abstracts a push notifications.
 - SeeAlso:
 `Webim.parsePushNotification()`
 */
public protocol WebimPushNotification {
    
    /**
     - returns:
     The type of the notification.
     */
    func getType() -> NotificationType
    
    /**
     - returns:
     The event of this notification.
     */
    func getEvent() -> NotificationEvent
    
    /**
     - returns:
     Parameters of this push notification. Each `NotificationType` has specific list of parameters.
     - SeeAlso:
     `NotificationType`
     */
    func getParameters() -> [String]

}

// MARK: -
/**
 - SeeAlso:
 `WebimPushNotification.getType()`
 `WebimPushNotification.getParameters()`
 */
public enum NotificationType {
    
    /**
     This notification type indicated that an operator has connected to a dialogue.
     Parameters:
     - Operator's name.
     */
    case OPERATOR_ACCEPTED
    
    /**
     This notification type indicated that an operator has sent a text message.
     Parameters:
     - Operator's name;
     - Message text.
     */
    case OPERATOR_MESSAGE
    
    /**
     This notification type indicated that an operator has sent a file.
     Parameters:
     - Operator's name;
     - File name.
     */
    case OPERATOR_FILE
    
}

// MARK: -
/**
 - SeeAlso:
 `WebimPushNotification.getEvent()`
 */
public enum NotificationEvent {
    
    /**
     Means that a notification should be added by current remote notification.
     */
    case ADD
    
    /**
     Means that a notification should be deleted by current remote notification.
     */
    case DELETE
    
}
