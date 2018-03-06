//
//  DeltaRequestLoopTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 31.01.18.
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
import XCTest
@testable import WebimClientLibrary

class DeltaRequestLoopTests: XCTestCase {
    
    // MARK: - Properties
    private var deltaRequestLoop: DeltaRequestLoopForTests?
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        
        deltaRequestLoop = DeltaRequestLoopForTests(deltaCallback: DeltaCallback(currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: "https://demo.webim.ru")),
                                                    completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: SessionDestroyer(),
                                                                                                                 queue: DispatchQueue.global()),
                                                    sessionParametersListener: nil,
                                                    internalErrorListener: InternalErrorListenerForTests() as InternalErrorListener,
                                                    baseURL: "https://demo.webim.ru",
                                                    title: "Page Title",
                                                    location: "mobile",
                                                    appVersion: "1.0.0",
                                                    visitorFieldsJSONString: nil,
                                                    providedAuthenticationTokenStateListener: nil,
                                                    providedAuthenticationToken: nil,
                                                    deviceID: "device_id",
                                                    deviceToken: nil,
                                                    visitorJSONString: nil,
                                                    sessionID: nil,
                                                    authorizationData: nil)
    }
    
    override func tearDown() {
        deltaRequestLoop = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testStart() {
        // MARK: Test 1
        
        // When: DeltaRequestLoop is started.
        deltaRequestLoop!.start()
        let queue = deltaRequestLoop!.queue
        
        // Then: Queue shouldn't be nil.
        XCTAssertNotNil(queue)
        
        // MARK: Test 2
        
        // When: DeltaRequestLoop is started again.
        deltaRequestLoop!.start()
        
        // Then: Queue should remain the same.
        XCTAssertEqual(deltaRequestLoop!.queue,
                       queue)
    }
    
    func testStop() {
        deltaRequestLoop!.start()
        deltaRequestLoop!.stop()
        
        XCTAssertNil(deltaRequestLoop!.queue)
    }
    
    func testChangeLocation() {
        try? deltaRequestLoop?.change(location: "location")
        
        XCTAssertNil(deltaRequestLoop?.getAuthorizationData())
        XCTAssertEqual(deltaRequestLoop!.since,
                       0)
        XCTAssertTrue(deltaRequestLoop!.initializationRunned)
    }
    
    func testRunMethod() {
        // MARK: Test 1
        
        // When: DeltaRequestLoop started without AuthorizationData.
        deltaRequestLoop?.start()
        usleep(1_000_000)
        
        // Then: Initialization should be requested, but delta should not.
        XCTAssertNil(deltaRequestLoop?.getAuthorizationData())
        XCTAssertTrue(deltaRequestLoop!.initializationRunned)
        XCTAssertFalse(deltaRequestLoop!.deltaRequestingRunned)
        
        // MARK: Test 2
        
        // When: AuthorizationData is setted.
        deltaRequestLoop?.authorizationData = AuthorizationData(pageID: "page_id",
                                                                authorizationToken: "auth_token")
        usleep(1_000_000)
        
        // Then: Delta should be requested.
        XCTAssertNotNil(deltaRequestLoop?.getAuthorizationData())
        XCTAssertTrue(deltaRequestLoop!.initializationRunned)
    }
    
}

// MARK: Mocking DeltaRequestLoop
final fileprivate class DeltaRequestLoopForTests: DeltaRequestLoop {
    
    // MARK: - Properties
    var initializationRunned = false
    var deltaRequestingRunned = false
    
    // MARK: - Methods
    
    override func requestInitialization() {
        initializationRunned = true
    }
    
    override func requestDelta() {
        deltaRequestingRunned = true
    }
    
}
