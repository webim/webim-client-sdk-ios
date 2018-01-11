//
//  DeltaRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 16.08.17.
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
 Class that handles HTTP-requests sending by SDK with internal requested actions (initialization and chat updates).
 - SeeAlso:
 `DeltaCallback`
 `DeltaResponse`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class DeltaRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    private static var providedAuthTokenErrorCount = 0
    private let appVersion: String?
    private let baseURL: String
    private let completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor
    private let deltaCallback: DeltaCallback
    private let deviceID: String
    private let internalErrorListener: InternalErrorListener
    private let sessionParametersListener: SessionParametersListener?
    private let title: String
    private var authorizationData: AuthorizationData?
    private var deviceToken: String?
    private var location: String
    private var providedAuthenticationToken: String?
    private var providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?
    private var queue: DispatchQueue?
    private var sessionID: String?
    private var since: Int64 = 0
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    
    
    // MARK: - Initialization
    init(deltaCallback: DeltaCallback,
         completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         sessionParametersListener: SessionParametersListener?,
         internalErrorListener: InternalErrorListener,
         baseURL: String,
         title: String,
         location: String,
         appVersion: String?,
         visitorFieldsJSONString: String?,
         providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
         providedAuthenticationToken: String?,
         deviceID: String,
         deviceToken: String?,
         visitorJSONString: String?,
         sessionID: String?,
         authorizationData: AuthorizationData?) {
        self.deltaCallback = deltaCallback
        self.completionHandlerExecutor = completionHandlerExecutor
        self.sessionParametersListener = sessionParametersListener
        self.internalErrorListener = internalErrorListener
        self.baseURL = baseURL
        self.title = title
        self.location = location
        self.appVersion = appVersion
        self.visitorFieldsJSONString = visitorFieldsJSONString
        self.deviceID = deviceID
        self.deviceToken = deviceToken
        self.visitorJSONString = visitorJSONString
        self.sessionID = sessionID
        self.authorizationData = authorizationData
        self.providedAuthenticationTokenStateListener = providedAuthenticationTokenStateListener
        self.providedAuthenticationToken = providedAuthenticationToken
    }
    
    
    // MARK: - Methods
    
    override func start() {
        guard queue == nil else {
            print("Can't start delta loop because it is already started.")
            
            return
        }
        
        queue = DispatchQueue(label: "ru.webim.DeltaDispatchQueue")
        queue?.async {
            self.run()
        }
    }
    
    override func stop() {
        super.stop()
        
        queue = nil
    }
    
    func set(deviceToken: String) {
        self.deviceToken = deviceToken
    }
    
    func change(location: String) throws {
        self.location = location
        
        authorizationData = nil
        since = 0
        
        requestInitialization()
    }
    
    func getAuthorizationData() -> AuthorizationData? {
        return authorizationData
    }
    
    // MARK: Private methods
    
    private func run() {
        while isRunning() {
            if authorizationData != nil {
                requestDelta()
            } else {
                requestInitialization()
            }
        }
    }
    
    private func requestInitialization() {
        let url = URL(string: getDeltaServerURLString() + "?" + getInitializationParameterString())
        var request = URLRequest(url: url!)
        request.httpMethod = AbstractRequestLoop.HTTPMethod.GET.rawValue
        
        do {
            let data = try perform(request: request)
            if let dataJSON = try? JSONSerialization.jsonObject(with: data) as! [String: Any] {
                if let error = dataJSON[AbstractRequestLoop.ResponseField.ERROR.rawValue] as? String {
                    if error == WebimInternalError.REINIT_REQUIRED.rawValue {
                        authorizationData = nil
                        since = 0
                    } else if error == WebimInternalError.PROVIDED_AUTHORIZATION_TOKEN_NOT_FOUND.rawValue {
                        DeltaRequestLoop.providedAuthTokenErrorCount += 1
                        
                        if DeltaRequestLoop.providedAuthTokenErrorCount < 5 {
                            sleepBetweenInitializationAttempts()
                        } else {
                            providedAuthenticationTokenStateListener?.update(providedAuthorizationToken: providedAuthenticationToken!)
                            
                            DeltaRequestLoop.providedAuthTokenErrorCount = 0
                            
                            sleepBetweenInitializationAttempts()
                        }
                    } else {
                        running = false
                        
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            self.internalErrorListener.on(error: error,
                                                          urlString: (request.url?.path)!)
                        })
                    }
                } else {
                    DeltaRequestLoop.providedAuthTokenErrorCount = 0
                    
                    let deltaResponse = DeltaResponse(jsonDictionary: dataJSON)
                    
                    if let deltaList = deltaResponse.getDeltaList() {
                        if deltaList.count > 0 {
                            handleIncorrectServerAnswer()
                            
                            return
                        }
                    }
                    
                    guard let fullUpdate = deltaResponse.getFullUpdate() else {
                        handleIncorrectServerAnswer()
                        
                        return
                    }
                    
                    if let since = deltaResponse.getRevision() {
                        self.since = since
                    }
                    
                    process(fullUpdate: fullUpdate)
                }
            } else {
                print("Error de-serializing server response.")
            }
        } catch let unknownError as UnknownError {
            handleRequestLoop(error: unknownError)
        } catch {
            print("Request failed with unknown error.")
        }
    }
    
    private func requestDelta() {
        let url = URL(string: getDeltaServerURLString() + "?" + getDeltaParameterString())
        var request = URLRequest(url: url!)
        request.httpMethod = AbstractRequestLoop.HTTPMethod.GET.rawValue
        
        do {
            let data = try perform(request: request)
            if let dataJSON = try? JSONSerialization.jsonObject(with: data) as! [String: Any] {
                if let error = dataJSON[AbstractRequestLoop.ResponseField.ERROR.rawValue] as? String {
                    if error == WebimInternalError.REINIT_REQUIRED.rawValue {
                        authorizationData = nil
                        since = 0
                    } else {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            self.internalErrorListener.on(error: error,
                                                          urlString: (request.url?.path)!)
                        })
                    }
                } else {
                    let deltaResponse = DeltaResponse(jsonDictionary: dataJSON)
                    
                    guard let revision = deltaResponse.getRevision() else {
                        // Delta timeout.
                        return
                    }
                    since = revision
                    
                    if let fullUpdate = deltaResponse.getFullUpdate() {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            self.process(fullUpdate: fullUpdate)
                        })
                    } else if let deltaList = deltaResponse.getDeltaList() {
                        if deltaList.count > 0 {
                            completionHandlerExecutor.execute(task: DispatchWorkItem {
                                self.deltaCallback.process(deltaList: deltaList)
                            })
                        }
                    }
                }
            } else {
                print("Error de-serializing server response.")
            }
        } catch let unknownError as UnknownError {
            handleRequestLoop(error: unknownError)
        } catch {
            print("Request failed with unknown error.")
        }
    }
    
    private func getDeltaServerURLString() -> String! {
        return baseURL + WebimActions.ServerPathSuffix.GET_DELTA.rawValue
    }
    
    private func getInitializationParameterString() -> String {
        let currentTimestamp = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        var parameterDictionary = [WebimActions.Parameter.DEVICE_ID.rawValue: deviceID,
                                   WebimActions.Parameter.EVENT.rawValue: WebimActions.Event.INITIALIZATION.rawValue,
                                   WebimActions.Parameter.LOCATION.rawValue: location,
                                   WebimActions.Parameter.PLATFORM.rawValue: WebimActions.Platform.IOS.rawValue,
                                   WebimActions.Parameter.RESPOND_IMMEDIATELY.rawValue: String(1), // true
            WebimActions.Parameter.SINCE.rawValue: String(0),
            WebimActions.Parameter.TITLE.rawValue: title,
            WebimActions.Parameter.TIMESTAMP.rawValue: String(currentTimestamp)] as [String: Any]
        if let appVersion = appVersion {
            parameterDictionary[WebimActions.Parameter.APP_VERSION.rawValue] = appVersion
        }
        if let deviceToken = deviceToken {
            parameterDictionary[WebimActions.Parameter.DEVICE_TOKEN.rawValue] = deviceToken
        }
        if let sessionID = sessionID {
            parameterDictionary[WebimActions.Parameter.SESSION_ID.rawValue] = sessionID
        }
        if let visitorJSONString = visitorJSONString {
            parameterDictionary[WebimActions.Parameter.VISITOR.rawValue] = visitorJSONString
        }
        if let visitorFieldsJSONString = visitorFieldsJSONString {
            parameterDictionary[WebimActions.Parameter.VISITOR_FIELDS.rawValue] = visitorFieldsJSONString
        }
        if let providedAuthenticationToken = providedAuthenticationToken {
            parameterDictionary[WebimActions.Parameter.PROVIDED_AUTHENTICATION_TOKEN.rawValue] = providedAuthenticationToken
        }
        
        return parameterDictionary.stringFromHTTPParameters()
    }
    
    private func getDeltaParameterString() -> String {
        let currentTimestamp = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        var parameterDictionary = [WebimActions.Parameter.SINCE.rawValue: String(since),
                                   WebimActions.Parameter.TIMESTAMP.rawValue: String(currentTimestamp)] as [String: Any]
        if let authorizationData = authorizationData {
            parameterDictionary[WebimActions.Parameter.PAGE_ID.rawValue] = authorizationData.getPageID()
            parameterDictionary[WebimActions.Parameter.AUTHORIZATION_TOKEN.rawValue] = authorizationData.getAuthorizationToken()
        }
        
        return parameterDictionary.stringFromHTTPParameters()
    }
    
    private func sleepBetweenInitializationAttempts() {
        authorizationData = nil
        since = 0
        
        usleep(1000 * 1000)  // 1 s.
    }
    
    private func handleIncorrectServerAnswer() {
        print("Incorrect server answer while requesting initialization.")
        
        usleep(1000 * 1000)  // 1 s.
    }
    
    private func process(fullUpdate: FullUpdate) {
        let visitorJSONString = fullUpdate.getVisitorJSONString()
        let sessionID = fullUpdate.getSessionID()
        let authorizationData = AuthorizationData(pageID: fullUpdate.getPageID(),
                                                  authorizationToken: fullUpdate.getAuthorizationToken())
        
        let isNecessaryToUpdateVisitorFieldJSONString = (self.visitorFieldsJSONString == nil)
            || (self.visitorFieldsJSONString != visitorFieldsJSONString)
        let isNecessaryToUpdateSessionID = (self.sessionID == nil)
            || (self.sessionID != sessionID)
        let isNecessaryToUpdateAuthorizationData = (self.authorizationData == nil)
            || ((self.authorizationData?.getPageID() != fullUpdate.getPageID())
                || (self.authorizationData?.getAuthorizationToken() != fullUpdate.getAuthorizationToken()))
        
        if (isNecessaryToUpdateVisitorFieldJSONString
            || isNecessaryToUpdateSessionID)
            || isNecessaryToUpdateAuthorizationData {
            self.visitorJSONString = visitorJSONString
            self.sessionID = sessionID
            self.authorizationData = authorizationData
            
            if sessionParametersListener != nil {
                DispatchQueue.global(qos: .background).async {
                    self.sessionParametersListener!.onSessionParametersChanged(visitorFieldsJSONString: self.visitorJSONString!,
                                                                               sessionID: self.sessionID!,
                                                                               authorizationData: self.authorizationData!)
                }
            }
        }
        
        completionHandlerExecutor.execute(task: DispatchWorkItem {
            self.deltaCallback.process(fullUpdate: fullUpdate)
        })
    }
    
}
