//
//  Department.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 12.12.17.
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
 Single department entity. Provides methods to get department information.
 Department objects can be received through `DepartmentListChangeListener` protocol methods and `getDepartmentList()` method of `MessageStream` protocol.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol Department {
    
    /**
     Department key is used to start chat with some department.
     - seealso:
     `startChat(departmentKey:)` method of `MessageStream` protocol.
     - returns:
     Department key value that uniquely identifies this department.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getKey() -> String
    
    /**
     - returns:
     Department public name.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getName() -> String
    
    /**
     - seealso:
     `DepartmentOnlineStatus`.
     - returns:
     Department online status.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getDepartmentOnlineStatus() -> DepartmentOnlineStatus
    
    /**
     - returns:
     Order number. Higher numbers match higher priority.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getOrder() -> Int
    
    /**
     - returns:
     Dictionary of department localized names (if exists). Key is custom locale descriptor, value is matching name.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getLocalizedNames() -> [String: String]?
    
    /**
     - returns:
     Department logo URL (if exists).
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getLogoURL() -> URL?
    
}

/**
 Possible department online statuses.
 - seealso:
 `getDepartmentOnlineStatus()` of `Department` protocol.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum DepartmentOnlineStatus {
    
    /**
     Offline state with chats' count limit exceeded.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case busyOffline
    
    @available(*, unavailable, renamed: "busyOffline")
    case BUSY_OFFLINE
    
    /**
     Online state with chats' count limit exceeded.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case busyOnline
    
    @available(*, unavailable, renamed: "busyOnline")
    case BUSY_ONLINE
    
    /**
     Visitor is able to send offline messages.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case offline
    
    @available(*, unavailable, renamed: "offline")
    case OFFLINE
    
    /**
     Visitor is able to send both online and offline messages.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case online
    
    @available(*, unavailable, renamed: "online")
    case ONLINE
    
    /**
     Any status that is not supported by this version of the library.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}
