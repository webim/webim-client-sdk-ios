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
 Class that handles HTTP-requests sended by WebimClientLibrary with visitor requested actions (e.g. sending messages, operator rating, chat closing etc.).
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
    private var operationQueue: OperationQueue?
    
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener) {
        self.completionHandlerExecutor = completionHandlerExecutor
        self.internalErrorListener = internalErrorListener
    }
    
    
    // MARK: - Methods
    
    override func start() {
        guard operationQueue == nil else {
            return
        }
        
        operationQueue = OperationQueue()
        operationQueue?.qualityOfService = .userInitiated
    }
    
    override func stop() {
        super.stop()
        
        operationQueue?.cancelAllOperations()
        operationQueue = nil
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: WebimRequest) {
        operationQueue?.addOperation {
            if self.authorizationData == nil {
                self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: nil)
            }
            let usedAuthorizationData = self.authorizationData!
            
            if !self.isRunning() {
                return
            }
            
            var parameterDictionary = request.getPrimaryData()
            parameterDictionary[WebimActions.Parameter.PAGE_ID.rawValue] = usedAuthorizationData.getPageID()
            parameterDictionary[WebimActions.Parameter.AUTHORIZATION_TOKEN.rawValue] = usedAuthorizationData.getAuthorizationToken()
            let parametersString = parameterDictionary.stringFromHTTPParameters()
            
            var url: URL?
            var urlRequest: URLRequest?
            let httpMethod = request.getHTTPMethod()
            if httpMethod == .GET {
                url = URL(string: (request.getBaseURLString() + "?" + parametersString))
                urlRequest = URLRequest(url: url!)
            } else { // POST
                if let httpBody = request.getHTTPBody() {
                    // Assuming that ready HTTP body is passed only for multipart requests.
                    url = URL(string: (request.getBaseURLString() + "?" + parametersString))
                    urlRequest = URLRequest(url: url!)
                    urlRequest!.httpBody = httpBody
                } else {
                    // For URL encoded requests.
                    url = URL(string: request.getBaseURLString())
                    urlRequest = URLRequest(url: url!)
                    urlRequest!.httpBody = parametersString.data(using: .utf8)
                }
                
                // Assuming that content type field is always exists when it is POST request, and does not when request is of GET type.
                urlRequest!.setValue(request.getContentType(),
                                     forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest!.httpMethod = httpMethod.rawValue
            
            do {
                let data = try self.perform(request: urlRequest!)
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = dataJSON?[AbstractRequestLoop.ResponseField.ERROR.rawValue] as? String {
                        switch error {
                        case WebimInternalError.REINIT_REQUIRED.rawValue:
                            self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: usedAuthorizationData)
                            self.enqueue(request: request)
                            
                            break
                        case WebimInternalError.FILE_SIZE_EXCEEDED.rawValue,
                             WebimInternalError.FILE_TYPE_NOT_ALLOWED.rawValue:
                            self.handleSendFile(error: error,
                                                ofRequest: request)
                            
                            break
                        case WebimInternalError.WRONG_ARGUMENT_VALUE.rawValue:
                            self.handleWrongArgumentValueError(ofRequest: request)
                            
                            break
                        case WebimInternalError.NO_CHAT.rawValue,
                             WebimInternalError.OPERATOR_NOT_IN_CHAT.rawValue:
                            self.handleRateOperator(error: error,
                                                    ofRequest: request)
                            
                            break
                        default:
                            self.running = false
                            
                            self.completionHandlerExecutor.execute(task: DispatchWorkItem {
                                self.internalErrorListener.on(error: error,
                                                              urlString: urlRequest!.url!.path)
                            })
                            
                            break
                        }
                        
                        return
                    }
                    
                    // Some internal errors can be received inside "error" field inside "data" field.
                    if let dataDictionary = dataJSON?[AbstractRequestLoop.ResponseField.DATA.rawValue] as? [String: Any],
                        let errorString = dataDictionary[AbstractRequestLoop.DataField.ERROR.rawValue] as? String {
                        self.handleDataMessage(error: errorString,
                                               ofRequest: request)
                    }
                    
                    if let completionHandler = request.getCompletionHandler() {
                        self.completionHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                            } catch {
                                WebimInternalLogger.shared.log(entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                                    verbosityLevel: .WARNING)
                            }
                            
                        })
                    }
                    
                    self.handleClientCompletionHandlerOf(request: request)
                } else {
                    WebimInternalLogger.shared.log(entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data")",
                        verbosityLevel: .WARNING)
                }
            } catch let sendFileError as SendFileError {
                // SendFileErrors are generated from HTTP code.
                if let sendFileCompletionHandler = request.getSendFileCompletionHandler() {
                    sendFileCompletionHandler.onFailure(messageID: request.getMessageID()!,
                                                        error: sendFileError)
                }
            } catch let unknownError as UnknownError {
                self.handleRequestLoop(error: unknownError)
            } catch {
                WebimInternalLogger.shared.log(entry: "Request failed with unknown error: \(request.getBaseURLString()).",
                    verbosityLevel: .WARNING)
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) -> AuthorizationData {
        while isRunning()
            && (lastAuthorizationData == authorizationData) {
                usleep(100 * 1000) // 0.1 s.
        }
        
        return authorizationData!
    }
    
    private func handleDataMessage(error errorString: String,
                                   ofRequest webimRequest: WebimRequest) {
        if let dataMessageCompletionHandler = webimRequest.getDataMessageCompletionHandler() {
            completionHandlerExecutor.execute(task: DispatchWorkItem {
                dataMessageCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
                                                       error: ActionRequestLoop.convertToPublic(dataMessageErrorString: errorString))
            })
        }
    }
    
    private func handleRateOperator(error errorString: String,
                                    ofRequest webimRequest: WebimRequest) {
        if let rateOperatorCompletionhandler = webimRequest.getRateOperatorCompletionHandler() {
            completionHandlerExecutor.execute(task: DispatchWorkItem {
                let rateOperatorError: RateOperatorError
                if errorString == WebimInternalError.NO_CHAT.rawValue {
                    rateOperatorError = .NO_CHAT
                } else {
                    rateOperatorError = .WRONG_OPERATOR_ID
                }
                
                rateOperatorCompletionhandler.onFailure(error: rateOperatorError)
            })
        }
    }
    
    private func handleSendFile(error errorString: String,
                                ofRequest webimRequest: WebimRequest) {
        if let sendFileCompletionHandler = webimRequest.getSendFileCompletionHandler() {
            completionHandlerExecutor.execute(task: DispatchWorkItem {
                let sendFileError: SendFileError
                if errorString == WebimInternalError.FILE_SIZE_EXCEEDED.rawValue {
                    sendFileError = .FILE_SIZE_EXCEEDED
                } else {
                    sendFileError = .FILE_TYPE_NOT_ALLOWED
                }
                
                sendFileCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
                                                    error: sendFileError)
            })
        }
    }
    
    private func handleWrongArgumentValueError(ofRequest webimRequest: WebimRequest) {
        WebimInternalLogger.shared.log(entry: "Request \(webimRequest.getBaseURLString()) with parameters \(webimRequest.getPrimaryData().stringFromHTTPParameters()) failed with error \(WebimInternalError.WRONG_ARGUMENT_VALUE.rawValue)",
            verbosityLevel: .WARNING)
    }
    
    private func handleClientCompletionHandlerOf(request: WebimRequest) {
        completionHandlerExecutor.execute(task: DispatchWorkItem {
            request.getDataMessageCompletionHandler()?.onSussess(messageID: request.getMessageID()!)
            request.getSendFileCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
            request.getRateOperatorCompletionHandler()?.onSuccess()
        })
    }
    
    private static func convertToPublic(dataMessageErrorString: String) -> DataMessageError {
        switch dataMessageErrorString {
        case WebimInternalError.QUOTED_MESSAGE_CANNOT_BE_REPLIED.rawValue:
            return .QUOTED_MESSAGE_CANNOT_BE_REPLIED
        case WebimInternalError.QUOTED_MESSAGE_CORRUPTED_ID.rawValue:
            return .QUOTED_MESSAGE_WRONG_ID
        case WebimInternalError.QUOTED_MESSAGE_FROM_ANOTHER_VISITOR.rawValue:
            return .QUOTED_MESSAGE_FROM_ANOTHER_VISITOR
        case WebimInternalError.QUOTED_MESSAGE_MULTIPLE_IDS.rawValue:
            return .QUOTED_MESSAGE_MULTIPLE_IDS
        case WebimInternalError.QUOTED_MESSAGE_NOT_FOUND.rawValue:
            return .QUOTED_MESSAGE_WRONG_ID
        case WebimInternalError.QUOTED_MESSAGE_REQUIRED_ARGUMENTS_MISSING.rawValue:
            return .QUOTED_MESSAGE_REQUIRED_ARGUMENTS_MISSING
        default:
            return .UNKNOWN
        }
    }
    
}
