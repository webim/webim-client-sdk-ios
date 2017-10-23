//
//  WebimError.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
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
 Error types that can be throwed by MessageTracker methods.
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
