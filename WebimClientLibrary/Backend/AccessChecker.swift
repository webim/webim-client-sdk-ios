//
//  AccessChecker.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

class AccessChecker {
    
    // MARK: - Properties
    let thread: Thread
    let sessionDestroyer: SessionDestroyer
    
    // MARK: - Initialization
    init(with thread: Thread,
         sessionDestroyer: SessionDestroyer) {
        self.thread = thread
        self.sessionDestroyer = sessionDestroyer
    }
    
    // MARK: - Methods
    func checkAccess() throws {
        guard thread == Thread.current else {
            throw AccessError.invalidThread("All Webim actions must be invoked from one thread, the one the session was created in./nCurrent thread: \(Thread.current), session thread: \(thread)")
        }
        
        guard !sessionDestroyer.isDestroyed() else {
            throw AccessError.invalidSession("The session you are tried to use has been destroyed.")
        }
    }
    
}
