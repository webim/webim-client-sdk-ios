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
import UIKit

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
    let completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?
    let internalErrorListener: InternalErrorListener?
    
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?,
         internalErrorListener: InternalErrorListener?) {
        self.completionHandlerExecutor = completionHandlerExecutor
        self.internalErrorListener = internalErrorListener
    }
    
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
        var requestWithUserAgent = request
        requestWithUserAgent.setValue("iOS: Webim-Client 3.39.3; (\(UIDevice.current.model); \(UIDevice.current.systemVersion)); Bundle ID and version: \(Bundle.main.bundleIdentifier ?? "none") \(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "none")", forHTTPHeaderField: "User-Agent")
        
        var errorCounter = 0
        var connectionErrorCounter = 0
        var lastHTTPCode = -1
        
        while isRunning() {
            let startTime = Date()
            var httpCode = 0
            
            let semaphore = DispatchSemaphore(value: 0)
            var receivedData: Data? = nil
            
            log(request: requestWithUserAgent)
            
            let dataTask = URLSession.shared.dataTask(with: requestWithUserAgent) { [weak self] data, response, error in
                guard let `self` = `self` else {
                    return
                }
                
                if let response = response,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    httpCode = statusCode
                }
                
                let webimLoggerEntry = self.configureLogMessage(
                    type: "response",
                    url: requestWithUserAgent.url,
                    parameters: requestWithUserAgent.httpBody,
                    code: httpCode,
                    data: data,
                    error: error
                )
                
                if let error = error {
                    semaphore.signal()
                    
                    WebimInternalLogger.shared.log(
                        entry: webimLoggerEntry,
                        logType: .networkRequest)
                    WebimInternalAlert.shared.present(title: .networkError, message: .noNetworkConnection)
                    
                    if let error = error as NSError?,
                        !(error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet) {
                        return
                    }
                }
                
                if let data = data {
                    receivedData = data
                    
                    WebimInternalLogger.shared.log(
                        entry: webimLoggerEntry,
                        verbosityLevel: .debug,
                        logType: .networkRequest)
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
                if let handler = self.completionHandlerExecutor {
                    handler.execute(task: DispatchWorkItem {
                        self.internalErrorListener?.onNotFatal(error: .noNetworkConnection)
                        self.internalErrorListener?.connectionStateChanged(connected: false)
                    })
                    usleep(useconds_t(1_000_000 * (connectionErrorCounter / 5)))
                    if connectionErrorCounter < 24 {
                        connectionErrorCounter += 1
                    }
                } else {
                    throw UnknownError.serverError
                }
                continue
            }
            
            if let receivedData = receivedData,
               (httpCode == 200 || httpCode == 400 || httpCode == 403 || httpCode == 413 || httpCode == 415) {
                self.internalErrorListener?.connectionStateChanged(connected: true)
                return receivedData
            }
            
            if httpCode == lastHTTPCode {
                let webimLoggerEntry = self.configureLogMessage(
                    type: "Request failed",
                    url: requestWithUserAgent.url,
                    parameters: requestWithUserAgent.httpBody,
                    code: httpCode
                )
                WebimInternalLogger.shared.log(
                    entry: webimLoggerEntry,
                    verbosityLevel: .warning,
                    logType: .networkRequest)
            }
            
            errorCounter += 1
            
            lastHTTPCode = httpCode
            
            // If request wasn't successful and error isn't fatal, wait some time and try again.
            if (errorCounter > 4) {
                // If there was more that five tries stop trying.
                self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                    self.internalErrorListener?.onNotFatal(error: .serverIsNotAvailable)
                })
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
            WebimInternalLogger.shared.log(
                entry: "Request interrupted (it's OK if WebimSession object was destroyed).",
                verbosityLevel: .debug,
                logType: .networkRequest)
            
            break
        case .serverError:
            WebimInternalLogger.shared.log(
                entry: "Request failed with server error.",
                logType: .networkRequest)
            
            break
        }
    }

    func decodeToServerSideSettings(data: Data) throws -> WebimServerSideSettings  {
        let readyData = prepareServerSideData(rawData: data)
        let webimServerSideSettings = try JSONDecoder().decode(WebimServerSideSettings.self, from: readyData)
        return webimServerSideSettings
    }

    func prepareServerSideData(rawData: Data) -> Data {
        guard var rawDataString = String(data: rawData, encoding: .utf8),
              rawDataString.count >= 31 else {
            return Data()
        }

        rawDataString.removeFirst(29)
        rawDataString.removeLast(2)

        guard let newData = rawDataString.data(using: .utf8, allowLossyConversion: false) else {
            return Data()
        }
        return newData
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
        let webimLoggerEntry = configureLogMessage(type: "request",
                                                   method: request.httpMethod,
                                                   url: request.url,
                                                   parameters: request.httpBody)
        
        WebimInternalLogger.shared.log(
            entry: webimLoggerEntry,
            verbosityLevel: .info,
            logType: .networkRequest)
    }
    
    static var logRequestData = true
    
    private func configureLogMessage(type: String,
                                     method: String? = nil,
                                     url: URL? = nil,
                                     parameters: Data? = nil,
                                     code: Int? = nil,
                                     data: Data? = nil,
                                     error: Error? = nil) -> String {
        if !AbstractRequestLoop.logRequestData {
            return ""
        }
        var logMessage = "Webim \(type):"
        
        if let method = method {
            logMessage += ("\nHTTP method - \(method)")
        }
        
        if let url = url {
            logMessage += "\nURL – \(url.absoluteString)"
        }
        
        if let parameters = parameters {
            if let parametersString = String(data: parameters,
                                             encoding: .utf8) {
                logMessage += "\nParameters – \(parametersString)"
            }
        }
        
        if let code = code {
            logMessage += "\nHTTP code – \(code)"
        }
        
        if let data = data {
            logMessage += self.encode(responseData: data)
        }
        
        if let error = error {
            logMessage += "\nError – \(error.localizedDescription)"
        }
        
        return logMessage
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
