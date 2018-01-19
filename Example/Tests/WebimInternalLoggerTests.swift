//
//  WebimInternalLoggerTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.01.18.
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

class WebimInternalLoggerTests: XCTestCase {
    
    // MARK: - Properties
    let webimInternalLogger = WebimInternalLogger.shared
    var logEntry: String?
    
    // MARK: Methods
    override func setUp() {
        super.setUp()
        
        logEntry = nil
    }
    
    // MARK: - Tests
    func testSetup() {
        // When: Low verbosity level installed and high verbosity level log message is send.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: .ERROR)
        webimInternalLogger.log(entry: "Test",
                                verbosityLevel: .VERBOSE)
        
        // Then: WebimLogger method should not be called.
        XCTAssertNil(logEntry)
    }
    
    func testLogWithSameVerbosityLevelIsPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.DEBUG
        let logString = "Test"
        
        // When: Logger installed and log entry passed with the same verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNotNil(logEntry)
    }
    
    func testLogWithLowerVerbosityLevelIsPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.DEBUG
        let higherVerbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.VERBOSE
        let logString = "Test"
        
        // When: Logger installed and log entry passed with lower verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: higherVerbosityLevel)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNotNil(logEntry)
    }
    
    func testLogWithHigherVerbosityLevelIsNotPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.DEBUG
        let lowerVerbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.INFO
        let logString = "Test"
        
        // When: Logger installed and log entry passed with higher verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: lowerVerbosityLevel)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNil(logEntry)
    }
    
}

// MARK: - WebimLogger
extension WebimInternalLoggerTests: WebimLogger {
    
    func log(entry: String) {
        logEntry = entry
    }
    
}
