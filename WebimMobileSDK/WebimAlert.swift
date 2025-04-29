//
//  WebimAlert.swift
//  WebimClientLibrary
//
//  Created by Никита on 10.10.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
 Protocol that provides methods for implementing custom WebimClientLibrary network requests logging.
 It can be useful for debugging production releases if debug logs are not available.
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
public protocol WebimAlert: AnyObject {
    
    /**
     Method which is called after new WebimClientLibrary network request log entry came out.
     - parameter entry:
     New WebimClientLibrary network request log entry.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    func present(title: WebimAlertTitle, message: WebimAlertMessage)
    
}

// MARK: -
/**
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
public enum WebimAlertTitle {
    /**
     Account access notice.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case accountError
    /**
     Network access notice.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case networkError
    /**
     Visitor action notice.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case visitorActionError
}

// MARK: -
/**
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
public enum WebimAlertMessage {
    /**
     Account is not reachable or active.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case accountConnectionError
    /**
     File deleting is failed.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case fileDeletingError
    /**
     File sending is failed.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case fileSendingError
    /**
     Operator rating is failed.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case operatorRatingError
    /**
     Network connection is disabled.
     - author:
     Nikita Kaberov
     - copyright:
     2022 Webim
     */
    case noNetworkConnection
}
