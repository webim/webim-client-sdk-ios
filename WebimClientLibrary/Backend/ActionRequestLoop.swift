//
//  ActionRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that handles HTTP-requests sending by SDK with client requested actions (e.g. sending messages, operator rating, chat closing etc.).
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class ActionRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    private let completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor
    private let internalErrorListener: InternalErrorListener
    private var authorizationData: AuthorizationData?
    private var lastRequest: WebimRequest?
    private lazy var requestQueue = [WebimRequest]()
    
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener) {
        self.completionHandlerExecutor = completionHandlerExecutor
        self.internalErrorListener = internalErrorListener
    }
    
    
    // MARK: - Methods
    
    override func run() {
        while isRunning() {
            var currentAuthorizationData = authorizationData
            if currentAuthorizationData == nil {
                currentAuthorizationData = awaitForNewAuthorizationData(withLastAuthorizationData: nil)
            }
            
            if !isRunning() {
                return
            }
            
            self.runIteration(withAuthorizationData: currentAuthorizationData!)
        }
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: WebimRequest) {
        requestQueue.append(request)
    }
    
    // MARK: Private methods
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) -> AuthorizationData? {
        while isRunning()
            && (lastAuthorizationData == authorizationData) {
                usleep(100000)
        }
        
        return authorizationData
    }
    
    private func runIteration(withAuthorizationData authorizationData: AuthorizationData) {
        var currentRequest = lastRequest
        if currentRequest == nil {
            if !requestQueue.isEmpty {
                let nextRequest = requestQueue.removeFirst()
                lastRequest = nextRequest
                currentRequest = nextRequest
            }
        }
        
        if let currentRequest = currentRequest {
            var dataToPost = currentRequest.getPrimaryData()
            dataToPost[WebimActions.Parameter.PAGE_ID.rawValue] = authorizationData.getPageID()
            dataToPost[WebimActions.Parameter.AUTHORIZATION_TOKEN.rawValue] = authorizationData.getAuthorizationToken()
            let parametersString = dataToPost.stringFromHTTPParameters()
            
            var url: URL?
            var request: URLRequest?
            let httpMethod = currentRequest.getHTTPMethod()
            if httpMethod == .GET {
                url = URL(string: currentRequest.getBaseURLString() + "?" + parametersString)
                request = URLRequest(url: url!)
            } else {
                if let httpBody = currentRequest.getHTTPBody() {
                    // Assuming HTTP body is passed only for multipart requests.
                    url = URL(string: currentRequest.getBaseURLString() + "?" + parametersString)
                    request = URLRequest(url: url!)
                    request!.httpBody = httpBody
                } else {
                    // For URL encoded requests.
                    url = URL(string: currentRequest.getBaseURLString())
                    request = URLRequest(url: url!)
                    request!.httpBody = parametersString.data(using: .utf8)
                }
            }
            
            request!.httpMethod = httpMethod.rawValue
            
            if let contentType = currentRequest.getConentType() {
                request!.setValue(contentType,
                                  forHTTPHeaderField: "Content-Type")
            }
            
            do {
                let data = try perform(request: request!)
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                    if let error = dataJSON?["error"] as? String {
                        if error == WebimInternalError.REINIT_REQUIRED.rawValue {
                            self.authorizationData = awaitForNewAuthorizationData(withLastAuthorizationData: authorizationData)
                            
                            return
                        } else if (error == WebimInternalError.FILE_SIZE_EXCEEDED.rawValue)
                            || (error == WebimInternalError.FILE_TYPE_NOT_ALLOWED.rawValue) {
                            lastRequest = nil
                            
                            if let sendFileCompletionHandler = currentRequest.getSendFileCompletionHandler() {
                                let sendFileError: SendFileError
                                if error == WebimInternalError.FILE_SIZE_EXCEEDED.rawValue {
                                    sendFileError = .FILE_SIZE_EXCEEDED
                                } else {
                                    sendFileError = .FILE_TYPE_NOT_ALLOWED
                                }
                                
                                sendFileCompletionHandler.onFailure(messageID: currentRequest.getMessageID()!,
                                                                    error: sendFileError)
                            }
                            
                            return
                        } else if (error == WebimInternalError.NO_CHAT.rawValue)
                            || (error == WebimInternalError.OPERATOR_NOT_IN_CHAT.rawValue) {
                            lastRequest = nil
                            
                            if let rateOperatorCompletionhandler = currentRequest.getRateOperatorCompletionHandler() {
                                let rateOperatorError: RateOperatorError
                                if error == WebimInternalError.NO_CHAT.rawValue {
                                    rateOperatorError = .NO_CHAT
                                } else {
                                    rateOperatorError = .WRONG_OPERATOR_ID
                                }
                                
                                rateOperatorCompletionhandler.onFailure(error: rateOperatorError)
                            }
                            
                            return
                        } else {
                            running = false
                            
                            completionHandlerExecutor.execute(task: DispatchWorkItem {
                                self.internalErrorListener.on(error: error,
                                                              urlString: request!.url!.path)
                            })
                            
                            return
                        }
                    }
                    
                    if let completionHandler = currentRequest.getCompletionHandler() {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                            } catch {
                                print("Error executing callback.")
                            }
                            
                        })
                    }
                    
                    if let sendFileCompletionHandler = currentRequest.getSendFileCompletionHandler() {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            sendFileCompletionHandler.onSuccess(messageID: currentRequest.getMessageID()!)
                        })
                    }
                    
                    if let rateOperatorCOmpletionHandler = currentRequest.getRateOperatorCompletionHandler() {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            rateOperatorCOmpletionHandler.onSuccess()
                        })
                    }
                }
            } catch let sendFileError as SendFileError {
                if let sendFileCompletionHandler = currentRequest.getSendFileCompletionHandler() {
                    sendFileCompletionHandler.onFailure(messageID: currentRequest.getMessageID()!,
                                                        error: sendFileError)
                }
            } catch {
                print("Request failed with unknown error.")
            }
        }
        
        lastRequest = nil
    }
    
}
