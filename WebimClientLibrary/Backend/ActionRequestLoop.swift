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
    private lazy var queue = [WebimRequest]()
    
    
    // MARK: - Initialization
    init(withCompletionHandlerExecutor completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
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
            
            runIteration(withAuthorizationData: currentAuthorizationData!)
        }
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: WebimRequest) {
        queue.append(request)
    }
    
    // MARK: Private methods
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) -> AuthorizationData? {
        while isRunning()
            && (lastAuthorizationData === authorizationData) {
                usleep(100000)
        }
        
        return authorizationData
    }
    
    private func runIteration(withAuthorizationData authorizationData: AuthorizationData) {
        var currentRequest = lastRequest
        if currentRequest == nil {
            if !queue.isEmpty {
                let nextRequest = queue.removeFirst()
                lastRequest = nextRequest
                currentRequest = nextRequest
            }
        }
        
        if let currentRequest = currentRequest {
            var dataToPost = currentRequest.getPrimaryData()
            dataToPost[WebimActions.Parameter.PAGE_ID.rawValue] = authorizationData.getPageID()
            dataToPost[WebimActions.Parameter.AUTHORIZATION_TOKEN.rawValue] = authorizationData.getAuthorizationToken()
            
            let parametersString = dataToPost.stringFromHTTPParameters()
            let url = URL(string: currentRequest.getBaseURLString() + "?" + parametersString)
            var request = URLRequest(url: url!)
            
            if let httpBody = currentRequest.getHTTPBody() {
                request.httpMethod = AbstractRequestLoop.HTTPMethod.POST.rawValue
                
                // Assuming boundary string is always exists when POST request is being handled.
                let contentType = "multipart/form-data; boundary=" + currentRequest.getBoundaryString()!
                request.setValue(contentType,
                                 forHTTPHeaderField: "Content-Type")
                
                request.httpBody = httpBody
            } else {
                request.httpMethod = AbstractRequestLoop.HTTPMethod.GET.rawValue
            }
            
            do {
                let data = try perform(request: request)
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                    if let error = dataJSON?["error"] as? String {
                        if error == WebimInternalError.REINIT_REQUIRED.rawValue {
                            self.authorizationData = awaitForNewAuthorizationData(withLastAuthorizationData: authorizationData)
                            
                            return
                        } else {
                            running = false
                            
                            completionHandlerExecutor.execute(task: DispatchWorkItem {
                                self.internalErrorListener.on(error: error,
                                                              urlString: (request.url?.path)!)
                            })
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
                }
            } catch let error as SendFileError {
                if let sendFileCompletionHandler = currentRequest.getSendFileCompletionHandler() {
                    sendFileCompletionHandler.onFailure(messageID: currentRequest.getMessageID()!,
                                                        error: error)
                }
            } catch let error as WebimInternalError {
                running = false
                
                completionHandlerExecutor.execute(task: DispatchWorkItem {
                    self.internalErrorListener.on(error: error.rawValue,
                                                  urlString: (request.url?.path)!)
                })
            } catch _ as UnknownError {
                print("Request was interrupted.")
            } catch {
                print("Request failed with unknown error.")
            }
        }
        
        lastRequest = nil
    }
    
}
