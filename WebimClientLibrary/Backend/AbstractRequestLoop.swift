//
//  AbstractRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
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
 Class that handles HTTP-request sending by SDK.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class AbstractRequestLoop {
    
    // MARK: - Constants
    enum HTTPMethods: String {
        case get = "GET"
        case post = "POST"
    }
    enum ResponseFields: String {
        case data = "data"
        case error = "error"
    }
    enum DataFields: String {
        case error = "error"
    }
    enum UnknownError: Error {
        case interrupted
        case serverError
    }
    
    // MARK: - Properties
    private let pauseCondition = NSCondition()
    private let pauseLock = NSRecursiveLock()
    var paused = true
    var running = true
    private var currentDataTask: URLSessionDataTask?
    
    // MARK: - Methods
    
    func start() {
        preconditionFailure("This method must be overridden!")
    }
    
    func pause() {
        pauseLock.lock()
        paused = true
        pauseLock.unlock()
    }
    
    func resume() {
        pauseLock.lock()
        paused = false
        pauseCondition.broadcast()
        pauseLock.unlock()
    }
    
    func stop() {
        running = false
        resume()
            
        if let currentDataTask = currentDataTask {
            currentDataTask.cancel()
        }
    }
    
    func isRunning() -> Bool {
        return running
    }
    
    func perform(request: URLRequest) throws -> Data {
        var errorCounter = 0
        var lastHTTPCode = -1
        
        while isRunning() {
            let startTime = Date()
            var httpCode = 0
            
            let semaphore = DispatchSemaphore(value: 0)
            var receivedData: Data? = nil
            
            log(request: request)
            
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let `self` = `self` else {
                    return
                }
                
                if let response = response {
                    httpCode = (response as! HTTPURLResponse).statusCode
                }
                
                if error != nil {
                    semaphore.signal()
                    
                    // Error log.
                    var webimLoggerEntry = "Webim response:\n"
                        + "URL – " + request.url!.absoluteString
                    if let httpBody = request.httpBody {
                        if let dataString = String(data: httpBody,
                                                   encoding: .utf8) {
                            webimLoggerEntry += ("\nParameters – " + dataString)
                        }
                    }
                    webimLoggerEntry += "\nHTTP code – " + String(httpCode)
                    webimLoggerEntry += "\nError – " + error!.localizedDescription
                    WebimInternalLogger.shared.log(entry: webimLoggerEntry)
                    
                    if let error = error as NSError?, !(error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet) {
                        return
                    }
                }
                
                if let data = data {
                    receivedData = data
                    
                    var webimLoggerEntry = "Webim response:\n"
                        + "URL – " + request.url!.absoluteString
                    if let httpBody = request.httpBody {
                        if let dataString = String(data: httpBody,
                                                   encoding: .utf8) {
                            webimLoggerEntry += ("\nParameters – " + dataString)
                        }
                    }
                    webimLoggerEntry += "\nHTTP code – " + String(httpCode)
                    webimLoggerEntry += self.encode(responseData: data)
                    WebimInternalLogger.shared.log(entry: webimLoggerEntry, verbosityLevel: .DEBUG)
                }
                
                semaphore.signal()
            }
            currentDataTask = dataTask
            dataTask.resume()
           
            _ = semaphore.wait(timeout: .distantFuture)
            currentDataTask = nil
            blockUntilPaused()
            
            if !isRunning() {
                break
            }
            
            if httpCode == 0 {
                continue
            }
            
            if let receivedData = receivedData,
                httpCode == 200 {
                return receivedData
            }
            
            if httpCode == 413 { // Request Entity Too Large
                throw SendFileError.FILE_SIZE_EXCEEDED
            }
            if httpCode == 415 { // Unsupported Media Type
                throw SendFileError.FILE_TYPE_NOT_ALLOWED
            }
            
            if httpCode == lastHTTPCode {
                var parametersString: String?
                if let httpBody = request.httpBody {
                    parametersString = String(data: httpBody,
                                              encoding: .utf8)
                }
                WebimInternalLogger.shared.log(entry: "Request \(request.url!.absoluteString)"
                    + "\(parametersString ?? "") "
                    + "failed with HTTP code: \(httpCode).",
                    verbosityLevel: .WARNING)
            }
            
            errorCounter += 1
            
            lastHTTPCode = httpCode
            
            // If request wasn't successful and error isn't fatal, wait some time and try again.
            if (errorCounter >= 5) {
                // If there was more that five tries stop trying.
                throw UnknownError.serverError
            }
            let sleepTime = Double(errorCounter) as TimeInterval
            let timeElapsed = Date().timeIntervalSince(startTime)
            if Double(timeElapsed) < Double(sleepTime) {
                let remainingTime = Double(sleepTime) - Double(timeElapsed)
                usleep(useconds_t(remainingTime * 1_000_000.0))
            }
        }
        
        throw UnknownError.interrupted
    }
    
    func handleRequestLoop(error: UnknownError) {
        switch error {
        case .interrupted:
            WebimInternalLogger.shared.log(entry: "Request interrupted (it's OK if WebimSession object was destroyed).",
                                           verbosityLevel: .DEBUG)
            
            break
        case .serverError:
            WebimInternalLogger.shared.log(entry: "Request failed with server error.")
            
            break
        }
    }
    
    // MARK: Private methods
    
    private func blockUntilPaused() {
        pauseCondition.lock()
        while paused {
            pauseCondition.wait()
        }
        pauseCondition.unlock()
    }
    
    private func log(request: URLRequest) {
        var webimLoggerEntry = "Webim request:\n"
        webimLoggerEntry += ("HTTP method - " + request.httpMethod! + "\n")
        webimLoggerEntry += ("URL – " + request.url!.absoluteString)
        if let httpBody = request.httpBody {
            if let dataString = String(data: httpBody,
                                       encoding: .utf8) {
                webimLoggerEntry += ("\nParameters – " + dataString)
            }
        }
        
        WebimInternalLogger.shared.log(entry: webimLoggerEntry,
                                       verbosityLevel: .INFO)
    }
    
    private func encode(responseData: Data) -> String {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: responseData,
                                                                options: .mutableContainers)
            let prettyPrintedJSONResponse = try JSONSerialization.data(withJSONObject: jsonResponse,
                                                                       options: .prettyPrinted)
            
            if let dataResponseString = String(data: prettyPrintedJSONResponse,
                                               encoding: .utf8) {
                return "\nJSON:\n" + dataResponseString
            }
        } catch {
            if let dataResponseString = String(data: responseData,
                                               encoding: .utf8) {
                return "\nData:\n" + dataResponseString
            }
        }
        
        return ""
    }
    
}
