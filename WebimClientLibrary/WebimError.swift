//
//  WebimError.swift
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
 Abstracts Webim service possible error responses.
 - SeeAlso:
 `FatalErrorHandler` protocol.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol WebimError {
    
    /**
     - returns:
     Parsed type of the error.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getErrorType() -> FatalErrorType
    
    /**
     - returns:
     String representation of an error. Mostly useful if the error type is unknown.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getErrorString() -> String
    
}

// MARK: -
/**
 Webim service error types.
 - important:
 Mind that most of this errors causes session to destroy.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum FatalErrorType {
    
    /**
     Indicates that the account in Webim service has been disabled (e.g. for non-payment). The error is unrelated to the user’s actions.
     Recommended response is to show the user an error message with a recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case ACCOUNT_BLOCKED
    
    /**
     Indicates an expired authorization of a visitor.
     The recommended response is to re-authorize it and to re-create session object.
     - important:
     Notice that the session will be destroyed if this error occured.
     - SeeAlso:
     `Webim.SessionBuilder.set(visitorFieldsJSONstring:)`
     `Webim.SessionBuilder.set(visitorFieldsJSONdata:)`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case PROVIDED_VISITOR_FIELDS_EXPIRED
    
    /**
     Indicates the occurrence of an unknown error.
     Recommended response is to send an automatic bug report and show to a user an error message with the recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     - SeeAlso:
     `WebimError.getErrorString()`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case UNKNOWN
    
    /**
     Indicates that a visitor was banned by an operator and can't send messages to a chat anymore.
     Occurs when a user tries to open the chat or write a message after that.
     Recommended response is to show the user an error message with the recommendation to try using the chat later or explain to the user that it was blocked for some reason.
     - important:
     Notice that the session will be destroyed if this error occured.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case VISITOR_BANNED
    
    /**
     Indicates a problem of your application authorization mechanism and is unrelated to the user’s actions.
     Occurs when trying to authorize a visitor with a non-valid signature.
     Recommended response is to send an automatic bug report and show the user an error message with the recommendation to try using the chat later.
     - important:
     Notice that the session will be destroyed if this error occured.
     - SeeAlso:
     `Webim.SessionBuilder.set(visitorFieldsJSONstring:)`
     `Webim.SessionBuilder.set(visitorFieldsJSONdata:)`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case WRONG_PROVIDED_VISITOR_HASH
    
}
