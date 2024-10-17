//
//  ActionRequestLoopTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 30.01.18.
//  Copyright © 2018 Webim. All rights reserved.
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
@testable import WebimMobileSDK
import XCTest

class ActionRequestLoopTests: XCTestCase {
    
    // MARK: - Constants
    private static let userDefaultsKey = "userDefaultsKey"
    
    // MARK: - Properties
    private let actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(userDefaultsKey: ActionRequestLoopTests.userDefaultsKey),
                                                                                                                           queue: DispatchQueue.global()),
                                                              internalErrorListener: InternalErrorListenerForTests() as InternalErrorListener,
                                                              requestHeader: nil,
                                                              baseURL: MessageImplMockData.serverURLString.rawValue)
    
    // MARK: - Tests
    func testStart() {
        // MARK: Test 1
        
        // When: ActionRequestLoop is started.
        actionRequestLoop.start()
        
        // Then: ActionRequestLoop OperationQueue shouldn't be nil and has to have .userInitiated QoS.
        let operationQueue = actionRequestLoop.actionOperationQueue
        XCTAssertNotNil(operationQueue)
        XCTAssertEqual(operationQueue!.qualityOfService,
                       QualityOfService.userInitiated)
        
        // MARK: Test 2
        
        // When: ActionRequestLoop is tryed to start again.
        actionRequestLoop.start()
        
        // Then: ActionRequestLoop OperationQueue stays the same.
        XCTAssertEqual(operationQueue,
                       actionRequestLoop.actionOperationQueue)
    }
    
    func testStop() {
        // When: ActionRequestLoop is stopped.
        actionRequestLoop.stop()
        
        // Then: ActionRequestLoop OperationQueue should be nil.
        XCTAssertNil(actionRequestLoop.actionOperationQueue)
    }
}
