//
//  ActionRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

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
    
    func getAuthorizationData() -> AuthorizationData? {
        return authorizationData
    }
    
    func enqueue(request: WebimRequest) {
        queue.append(request)
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
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            self.internalErrorListener.on(error: error,
                                                          urlString: (request.url?.path)!)
                        })
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
