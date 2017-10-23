//
//  ExecIfNotDestroyedHandlerExecutor.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class ExecIfNotDestroyedHandlerExecutor {
    
    // MARK: - Properties
    private let sessionDestroyer: SessionDestroyer
    private let queue: DispatchQueue
    
    // MARK: - Initialization
    init(withSessionDestroyer sessionDestroyer: SessionDestroyer,
         queue: DispatchQueue) {
        self.sessionDestroyer = sessionDestroyer
        self.queue = queue
    }
    
    // MARK: - Methods
    func execute(task: DispatchWorkItem) {
        if !sessionDestroyer.isDestroyed() {
            // FIXME: Check if it is possible to check if session is not destroyed right before executing task!
            queue.async(execute: task)
        }
    }
    
}
