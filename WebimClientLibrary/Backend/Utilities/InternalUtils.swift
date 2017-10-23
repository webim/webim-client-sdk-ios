//
//  InternalUtils.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class InternalUtils {
    
    // MARK: - Constants
    private enum JSONField: String {
        case DATA = "data"
    }
    
    
    // MARK: - Methods
    
    static func compare(number firstNumber: Int64,
                        with secondNumber: Int64) -> Int {
        return (firstNumber < secondNumber) ? -1 : ((firstNumber == secondNumber) ? 0 : 1)
    }
    
    static func createServerURLStringBy(accountName: String?) -> String? {
        if accountName == nil {
            return nil
        }
        
        if accountName?.range(of: "://") != nil {
            return accountName
        }
        
        return "https://\(accountName!).webim.ru"
    }
    
    static func getCurrentTimeInMicrosecond() -> Int64 {
        let currentDate = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second],
                                                     from: currentDate)
        
        let hour = Int64(dateComponents.hour!)
        let minute = Int64(dateComponents.minute!)
        let second = Int64(dateComponents.second!)
        
        let hourInMicrosecond = hour * 60 * 60 * 1000
        let minuteInMicrosecond = minute * 60 * 1000
        let secondInMicrosecond = second * 1000
        let currentTimeInMicrosecond = hourInMicrosecond + minuteInMicrosecond + secondInMicrosecond
        
        return currentTimeInMicrosecond
    }
    
    static func parse(remoteNotification: [AnyHashable : Any]) throws -> WebimPushNotification? {
        if let apsFields = remoteNotification[WebimPushNotificationImpl.APNsField.APS.rawValue] as? [String : Any] {
            if let alertFields = apsFields[WebimPushNotificationImpl.APSField.ALERT.rawValue] as? [String : Any] {
                return WebimPushNotificationImpl(withJSONDictionary: alertFields) as WebimPushNotification?
            } else {
                return nil
            }
        } else {
            throw Webim.PushNotificationError.UnknownNotificationFormat
        }
    }
    
    static func isWebim(remoteNotification: [AnyHashable : Any]) throws -> Bool {
        if let apsFields = remoteNotification[WebimPushNotificationImpl.APNsField.APS.rawValue] as? [String : Any] {
            if let customFields = apsFields[WebimPushNotificationImpl.APSField.CUSTOM.rawValue] as? [String : Any] {
                if let webimField = customFields[WebimPushNotificationImpl.CustomField.WEBIM.rawValue] as? Bool {
                    return webimField
                }
            }
        } else {
            throw Webim.PushNotificationError.UnknownNotificationFormat
        }
        
        return false
    }
    
}
