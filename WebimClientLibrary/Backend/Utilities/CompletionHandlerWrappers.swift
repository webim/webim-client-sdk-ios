//
//  CompletionHandlerWrappers.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 20.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 Class used for handling storing cached completion handler in `MessageTrackerImpl` class.
 - SeeAlso:
 `MessageTrackerImpl.cachedCompletionHandler`
 */
struct MessageHolderCompletionHandlerWrapper {
    
    // MARK: - Properties
    private var messageHolderCompletionHandler: ([Message]) -> ()
    
    // MARK: - Initialization
    init(completionHandler: @escaping ([Message]) -> ()) {
        messageHolderCompletionHandler = completionHandler
    }
    
    // MARK: - Methods
    func getCompletionHandler() -> ([Message]) -> () {
        return messageHolderCompletionHandler
    }
    
}
