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
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol Department {
    
    /**
     Department key is used to start chat with some department.
     - SeeAlso:
     `startChat(departmentKey:)` method of `MessageStream` protocol.
     - returns:
     Department key value that uniquely identifies this department.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getKey() -> String
    
    /**
     - returns:
     Department public name.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getName() -> String
    
    /**
     - SeeAlso:
     `DepartmentOnlineStatus`.
     - returns:
     Department online status.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getDepartmentOnlineStatus() -> DepartmentOnlineStatus
    
    /**
     - returns:
     Order number. Higher numbers match higher priority.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getOrder() -> Int
    
    /**
     - returns:
     Dictionary of department localized names (if exists). Key is custom locale descriptor, value is matching name.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getLocalizedNames() -> [String: String]?
    
    /**
     - returns:
     Department logo URL (if exists).
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getLogoURL() -> URL?
    
}

/**
 Possible department online statuses.
 - SeeAlso:
 `getDepartmentOnlineStatus()` of `Department` protocol.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum DepartmentOnlineStatus {
    
    /**
     Offline state with chats' count limit exceeded.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case BUSY_OFFLINE
    
    /**
     Online state with chats' count limit exceeded.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case BUSY_ONLINE
    
    /**
     Visitor is able to send offline messages.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OFFLINE
    
    /**
     Visitor is able to send both online and offline messages.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case ONLINE
    
    /**
     Any status that is not supported by this version of the library.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case UNKNOWN
    
}
