//
//  AccessChecker.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
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
 Class that checks if session methods are called in appropriate conditions.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class AccessChecker {
    
    // MARK: - Properties
    let thread: Thread
    let sessionDestroyer: SessionDestroyer
    let queue: DispatchQueue
    // MARK: - Initialization
    init(thread: Thread,
         sessionDestroyer: SessionDestroyer) {
        self.thread = thread
        self.sessionDestroyer = sessionDestroyer
        self.queue = DispatchQueue.current
    }
    
    // MARK: - Methods
    func checkAccess() throws {
        guard thread == Thread.current else {
            throw AccessError.invalidThread
        }
        
        guard self.queue == DispatchQueue.current else {
            throw AccessError.invalidSession
        }
        
        guard !sessionDestroyer.isDestroyed() else {
            throw AccessError.invalidSession
        }
    }
    
}

extension DispatchQueue {

    private struct QueueReference { weak var queue: DispatchQueue? }

    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()

    private static func _registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }

    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
                                        .main,
                                        .global(qos: .background),
                                        .global(qos: .default),
                                        .global(qos: .unspecified),
                                        .global(qos: .userInitiated),
                                        .global(qos: .userInteractive),
                                        .global(qos: .utility)
                                    ]
        _registerDetection(of: queues, key: key)
    }
}

// MARK: public functionality

extension DispatchQueue {
    static func registerDetection(of queue: DispatchQueue) {
        _registerDetection(of: [queue], key: key)
    }

    static var currentQueueLabel: String? {
        current?.label
    }
    static var current: DispatchQueue! {
        getSpecific(key: key)?.queue
    }
}
