//
//  InternalUtils.swift
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
 Various SDK utilities.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class InternalUtils {
    
    // MARK: - Constants
    private enum JSONField: String {
        case DATA = "data"
    }
    
    // MARK: - Methods
    
    static func createServerURLStringBy(accountName: String) -> String {
        var serverURLstring = accountName
        
        if serverURLstring.range(of: "://") != nil {
            if serverURLstring.last! == "/" {
                serverURLstring.removeLast()
            }
            
            return serverURLstring
        }
        
        return "https://\(serverURLstring).webim.ru"
    }
    
    static func getCurrentTimeInMicrosecond() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    static func parse(remoteNotification: [AnyHashable: Any]) -> WebimRemoteNotification? {
        if let apsFields = remoteNotification[WebimRemoteNotificationImpl.APNsField.APS.rawValue] as? [String: Any] {
            if let alertFields = apsFields[WebimRemoteNotificationImpl.APSField.ALERT.rawValue] as? [String: Any] {
                return WebimRemoteNotificationImpl(jsonDictionary: alertFields) as WebimRemoteNotification?
            } else {
                return nil
            }
        } else {
            WebimInternalLogger.shared.log(entry: "Unknown remote notification format: \(remoteNotification).",
                verbosityLevel: .DEBUG)
            
            return nil
        }
    }
    
    static func isWebim(remoteNotification: [AnyHashable: Any]) -> Bool {
        if let webimField = remoteNotification[WebimRemoteNotificationImpl.APNsField.WEBIM.rawValue] as? Bool {
            return webimField
        }
        
        return false
    }
    
}
