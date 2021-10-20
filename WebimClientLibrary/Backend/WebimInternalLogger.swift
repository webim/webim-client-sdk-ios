//
//  WebimInternalLogger.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.01.18.
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
 Class that wraps `WebimLogger` into singleton pattern and encapsulates its verbose level.
 First, one should call `setup(webimLogger:verbosityLevel:)` method with particular parameters, then it will be possible to use `WebimInternalLogger.shared`.
 - seealso:
 `WebimLogger`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
final class WebimInternalLogger {
    
    // MARK: - Properties
    static let shared = WebimInternalLogger()
    private static let setup = WebimInternalLoggerParametersHelper()
    
    // MARK: - Initialization
    private init() {
        // Needed for singleton pattern.
    }
    
    // MARK: - Methods
    
    class func setup(webimLogger: WebimLogger?,
                     verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel?) {
        WebimInternalLogger.setup.webimLogger = webimLogger
        WebimInternalLogger.setup.verbosityLevel = verbosityLevel
    }
    
    func log(entry: String,
             verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel = .error) {
        if !AbstractRequestLoop.logRequestData {
            return
        }
        let logEntry = "WEBIM LOG. " + Date().debugDescription + " " + entry
        switch verbosityLevel {
        case .verbose:
            if isVerbose() {
                WebimInternalLogger.setup.webimLogger?.log(entry: logEntry)
            }
            
            break
        case .debug:
            if isDebug() {
                WebimInternalLogger.setup.webimLogger?.log(entry: logEntry)
            }
            
            break
        case .info:
            if isInfo() {
                WebimInternalLogger.setup.webimLogger?.log(entry: logEntry)
            }
            
            break
        case .warning:
            if isWarning() {
                WebimInternalLogger.setup.webimLogger?.log(entry: logEntry)
            }
            
            break
        case .error:
            WebimInternalLogger.setup.webimLogger?.log(entry: logEntry)
            
            break
        }
    }
    
    // MARK: Private methods
    
    private func isVerbose() -> Bool {
        return (WebimInternalLogger.setup.verbosityLevel == .verbose)
    }
    
    private func isDebug() -> Bool {
        return ((WebimInternalLogger.setup.verbosityLevel == .debug)
            || (WebimInternalLogger.setup.verbosityLevel == .verbose))
    }
    
    private func isInfo() -> Bool {
        return ((WebimInternalLogger.setup.verbosityLevel == .verbose)
            || (WebimInternalLogger.setup.verbosityLevel == .debug)
            || (WebimInternalLogger.setup.verbosityLevel == .info))
    }
    
    private func isWarning() -> Bool {
        return ((WebimInternalLogger.setup.verbosityLevel == .verbose)
            || (WebimInternalLogger.setup.verbosityLevel == .debug)
            || (WebimInternalLogger.setup.verbosityLevel == .info)
            || (WebimInternalLogger.setup.verbosityLevel == .warning))
    }
    
}

/**
 Helper class for `WebimInternalLogger` singleton instance setup.
 - seealso:
 `WebimInternalLogger`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
final class WebimInternalLoggerParametersHelper {
    
    // MARK: - Properties
    var verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel?
    weak var webimLogger: WebimLogger?
    
}
