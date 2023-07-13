//
//  WebimInternalLoggerTests.swift
//  WebimClientLibrary
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
@testable import WebimMobileSDK

class WebimInternalLoggerTests: XCTestCase {
    
    // MARK: - Properties
    let webimInternalLogger = WebimInternalLogger.shared
    var logEntry: String?
    var availableLogTypes: [SessionBuilder.WebimLogType]!
    
    // MARK: Methods
    override func setUp() {
        super.setUp()
        availableLogTypes = [.networkRequest, .manualCall, .messageHistory, .undefined]
        logEntry = nil
    }

    override class func tearDown() {
        AbstractRequestLoop.logRequestData = true
        super.tearDown()
    }
    
    // MARK: - Tests
    func testSetup() {
        // When: Low verbosity level installed and high verbosity level log message is send.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: .error,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: "Test",
                                verbosityLevel: .verbose)
        
        // Then: WebimLogger method should not be called.
        XCTAssertNil(logEntry)
    }
    
    func testLogWithSameVerbosityLevelIsPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.debug
        let logString = "Test"
        
        // When: Logger installed and log entry passed with the same verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNotNil(logEntry)
    }
    
    func testLogWithLowerVerbosityLevelIsPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.debug
        let higherVerbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "Test"
        
        // When: Logger installed and log entry passed with lower verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: higherVerbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNotNil(logEntry)
    }
    
    func testLogWithHigherVerbosityLevelIsNotPassed() {
        // Setup.
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.debug
        let lowerVerbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.info
        let logString = "Test"
        
        // When: Logger installed and log entry passed with higher verbosity level.
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: lowerVerbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel)
        
        // Then: Log entry should be passed to WebimLogger.
        XCTAssertNil(logEntry)
    }

    func testLogNetworkTypeWhenLogRequestDataDisabled() {
        //Given
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.debug
        let logString = "Test"
        AbstractRequestLoop.logRequestData = false
        //When: Logger installed and AbstractRequestLoop disable logRequestData

        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .networkRequest)

        //Then
        XCTAssertNil(logEntry)
    }

    func testEmptyAvailableLogType() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "networkRequest"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = []

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .undefined)

        //Then
        XCTAssertNil(logEntry)
    }

    func testAvailableLogTypeNetworkRequest() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "networkRequest"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.networkRequest]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .networkRequest)

        //Then
        XCTAssertTrue(logEntry?.contains(logString) == true)
    }

    func testAvailableLogTypeUndefined() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "undefined"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.undefined]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .undefined)

        //Then
        XCTAssertTrue(logEntry?.contains(logString) == true)
    }

    func testAvailableLogTypeMessageHistory() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "messageHistory"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.messageHistory]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .messageHistory)

        //Then
        XCTAssertTrue(logEntry?.contains(logString) == true)
    }

    func testAvailableLogTypeManualCall() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "manualCall"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.manualCall]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .manualCall)

        //Then
        XCTAssertTrue(logEntry?.contains(logString) == true)
    }

    func testAllAvailableLogTypes() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "messageHistory"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.networkRequest, .manualCall, .messageHistory, .undefined]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .undefined)

        //Then
        XCTAssertTrue(logEntry?.contains(logString) == true)
    }

    func testDisabledLogTypes() {
        let verbosityLevel = SessionBuilder.WebimLoggerVerbosityLevel.verbose
        let logString = "undefined"
        AbstractRequestLoop.logRequestData = true
        availableLogTypes = [.undefined]

        //When: Logger installed and AbstractRequestLoop enable logRequestData
        WebimInternalLogger.setup(webimLogger: self,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        webimInternalLogger.log(entry: logString,
                                verbosityLevel: verbosityLevel,
                                logType: .manualCall)

        //Then
        XCTAssertNil(logEntry)
    }

}

// MARK: - WebimLogger
extension WebimInternalLoggerTests: WebimLogger {
    
    func log(entry: String) {
        logEntry = entry
    }
    
}
