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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class InternalUtils {
    static let domains = ["webim.ru", "webim2.ru", "webim.chat"]
    
    // MARK: - Methods
    
    static func changeDomainFor(url: String) -> String {
        for (index, domain) in domains.enumerated() {
            if url.contains(domain) {
                return url.replacingOccurrences(of: domains[index], with: domains[(index + 1) % domains.count])
            }
        }
        return url
    }
    
    static func createServerURLStringBy(accountName: String) -> String {
        var serverURLstring = accountName
        
        if let _ = serverURLstring.range(of: "://") {
            if (serverURLstring.last ?? Character(" ")) == "/" {
                serverURLstring.removeLast()
            }
            
            return serverURLstring
        }
        
        return "https://\(serverURLstring).\(domains[0])"
    }
    
    static func getCurrentTimeInMicrosecond() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1_000_000)
    }
    
    static func parse(remoteNotification: [AnyHashable : Any], visitorId: String?) -> WebimRemoteNotification? {
        guard let remoteNotification = remoteNotification as? [String : Any?] else {
            return nil
        }
        if visitorId != nil {
            return WebimRemoteNotificationImpl(jsonDictionary: remoteNotification) as WebimRemoteNotification?
        } else {
            let notification = WebimRemoteNotificationImpl(jsonDictionary: remoteNotification) as WebimRemoteNotification?
            let params = notification?.getParameters()
            var indexOfId: Int
            switch notification?.getType() {
            case .operatorAccepted:
                indexOfId = 1
                break
            case .operatorFile,
                 .operatorMessage:
                indexOfId = 2
                break
            default:
                indexOfId = 0
            }
                    
            if params?.count ?? 0 <= indexOfId {
                return notification
            }
            return params?[indexOfId] == visitorId ? notification : nil
        }
    }
    
    static func isWebim(remoteNotification: [AnyHashable: Any]) -> Bool {
        if let webimField = remoteNotification[WebimRemoteNotificationImpl.APNSField.webim.rawValue] as? Bool {
            return webimField
        }
        
        return false
    }
    
}
