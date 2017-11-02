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
 - SeeAlso:
 `FatalErrorHandler`
 */
public protocol WebimError {
    
    /**
     - returns:
     Parsed type of the error.
     */
    func getErrorType() -> FatalErrorType
    
    /**
     - returns:
     String representation of an error. Mostly useful if the error type is unknown.
     */
    func getErrorString() -> String
    
}


/**
 Error types that can be throwed by MessageStream methods.
 - SeeAlso:
 `WebimSession` and `MessageStream` methods.
 */
public enum AccessError: Error {
    case invalidThread(String)
    case invalidSession(String)
}

/**
 Error types that can be thrown by MessageTracker methods.
 - SeeAlso:
 `MessageTracker.getNextMessages(byLimit limit:completion:)`
 `MessageTracker.resetTo(message:)`
 `MessageTracker.destroy()`
 */
public enum MessageTrackerError: Error {
    case invalidState(String)
    case destroyedObject(String)
    case repeatedRequest(String)
    case invalidArgument(String)
}
