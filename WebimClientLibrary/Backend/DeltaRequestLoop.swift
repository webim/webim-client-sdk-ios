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
 - seealso:
 `DeltaCallback`
 `DeltaResponse`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class DeltaRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    private static var providedAuthenticationTokenErrorCount = 0
    private let appVersion: String?
    private let baseURL: String
    private let deltaCallback: DeltaCallback
    private let deviceID: String
    private let sessionParametersListener: SessionParametersListener?
    private let title: String
    var authorizationData: AuthorizationData?
    var queue: DispatchQueue?
    var since: Int64 = 0
    private var deviceToken: String?
    private var location: String
    private var providedAuthenticationToken: String?
    private weak var providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?
    private var sessionID: String?
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    private var prechat: String?
    
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
         prechat:String?,
         authorizationData: AuthorizationData?) {
        self.deltaCallback = deltaCallback
        self.sessionParametersListener = sessionParametersListener
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
        self.prechat = prechat
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    // MARK: - Methods
    
    override func start() {
        guard queue == nil else {
            return
        }
        
        queue = DispatchQueue(label: "ru.webim.DeltaDispatchQueue")
        guard let queue = queue else {
            WebimInternalLogger.shared.log(entry: "DispatchQueue initialisation failure in DeltaRequestLoop.\(#function)")
            return
        }
        queue.async {
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
    
    func run() {
        while isRunning() {
            if authorizationData != nil && since != 0 {
                requestDelta()
            } else {
                requestInitialization()
            }
        }
    }
    
    func requestInitialization() {
        let url = URL(string: getDeltaServerURLString() + "?" + getInitializationParameterString())
        var request = URLRequest(url: url!)
        request.setValue("3.34.4", forHTTPHeaderField: WebimActions.Parameter.webimSDKVersion.rawValue)
        request.httpMethod = AbstractRequestLoop.HTTPMethods.get.rawValue
        
        do {
            let data = try perform(request: request)
            if let dataJSON = try? (JSONSerialization.jsonObject(with: data) as? [String: Any]) {
                if let error = dataJSON[AbstractRequestLoop.ResponseFields.error.rawValue] as? String {
                    handleInitialization(error: error)
                } else {
                    DeltaRequestLoop.providedAuthenticationTokenErrorCount = 0
                    
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
                WebimInternalLogger.shared.log(entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                    verbosityLevel: .warning)
            }
        } catch let unknownError as UnknownError {
            handleRequestLoop(error: unknownError)
        } catch {
            WebimInternalLogger.shared.log(entry: "Request failed with unknown error: \(error.localizedDescription)",
                verbosityLevel: .warning)
        }
    }
    
    func requestDelta() {
        guard let url = URL(string: getDeltaServerURLString() + "?" + getDeltaParameterString()) else {
            WebimInternalLogger.shared.log(entry: "Initialize URL failure in  DeltaRequestLoop.\(#function)")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = AbstractRequestLoop.HTTPMethods.get.rawValue
        
        do {
            let data = try perform(request: request)
            if let dataJSON = try? (JSONSerialization.jsonObject(with: data) as? [String: Any]) {
                if let error = dataJSON[AbstractRequestLoop.ResponseFields.error.rawValue] as? String {
                    handleDeltaRequest(error: error)
                } else {
                    let deltaResponse = DeltaResponse(jsonDictionary: dataJSON)
                    
                    guard let revision = deltaResponse.getRevision() else {
                        // Delta timeout.
                        return
                    }
                    since = revision
                    
                    if let fullUpdate = deltaResponse.getFullUpdate() {
                        completionHandlerExecutor?.execute(task: DispatchWorkItem {
                            self.process(fullUpdate: fullUpdate)
                        })
                    } else if let deltaList = deltaResponse.getDeltaList() {
                        if deltaList.count > 0 {
                            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                                self.deltaCallback.process(deltaList: deltaList)
                            })
                        }
                    }
                }
            } else {
                WebimInternalLogger.shared.log(entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                    verbosityLevel: .warning)
            }
        } catch let unknownError as UnknownError {
            handleRequestLoop(error: unknownError)
        } catch {
            WebimInternalLogger.shared.log(entry: "Request failed with unknown error: \(error.localizedDescription).",
                verbosityLevel: .warning)
        }
    }
    
    // MARK: Private methods
    
    private func getDeltaServerURLString() -> String {
        return (baseURL + WebimActions.ServerPathSuffix.getDelta.rawValue)
    }
    
    private func getInitializationParameterString() -> String {
        var parameterDictionary = [WebimActions.Parameter.deviceID.rawValue: deviceID,
                                   WebimActions.Parameter.event.rawValue: WebimActions.Event.initialization.rawValue,
                                   WebimActions.Parameter.location.rawValue: location,
                                   WebimActions.Parameter.platform.rawValue: WebimActions.Platform.ios.rawValue,
                                   WebimActions.Parameter.respondImmediately.rawValue: true,
                                   WebimActions.Parameter.since.rawValue: 0,
                                   WebimActions.Parameter.title.rawValue: title] as [String: Any]
        if let appVersion = appVersion {
            parameterDictionary[WebimActions.Parameter.applicationVersion.rawValue] = appVersion
        }
        if let deviceToken = deviceToken {
            parameterDictionary[WebimActions.Parameter.deviceToken.rawValue] = deviceToken
        }
        if let sessionID = sessionID {
            parameterDictionary[WebimActions.Parameter.visitSessionID.rawValue] = sessionID
        }
        if let visitorJSONString = visitorJSONString {
            parameterDictionary[WebimActions.Parameter.visitor.rawValue] = visitorJSONString
        }
        if let visitorFieldsJSONString = visitorFieldsJSONString {
            parameterDictionary[WebimActions.Parameter.visitorExt.rawValue] = visitorFieldsJSONString
        }
        if let providedAuthenticationToken = providedAuthenticationToken {
            parameterDictionary[WebimActions.Parameter.providedAuthenticationToken.rawValue] = providedAuthenticationToken
        }
        if let prechat = prechat {
            parameterDictionary[WebimActions.Parameter.prechat.rawValue] = prechat
        }
        
        return parameterDictionary.stringFromHTTPParameters()
    }
    
    private func getDeltaParameterString() -> String {
        let currentTimestamp = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        var parameterDictionary = [WebimActions.Parameter.since.rawValue: String(since),
                                   WebimActions.Parameter.timestamp.rawValue: currentTimestamp] as [String: Any]
        if let authorizationData = authorizationData {
            parameterDictionary[WebimActions.Parameter.pageID.rawValue] = authorizationData.getPageID()
            parameterDictionary[WebimActions.Parameter.authorizationToken.rawValue] = authorizationData.getAuthorizationToken()
        }
        
        return parameterDictionary.stringFromHTTPParameters()
    }
    
    private func sleepBetweenInitializationAttempts() {
        authorizationData = nil
        since = 0
        
        usleep(1_000_000)  // 1s
    }
    
    private func handleIncorrectServerAnswer() {
        WebimInternalLogger.shared.log(entry: "Incorrect server answer while requesting initialization.",
                                       verbosityLevel: .debug)
        
        usleep(1_000_000)  // 1s
    }
    
    private func handleInitialization(error: String) {
        switch error {
        case WebimInternalError.reinitializationRequired.rawValue:
            handleReinitializationRequiredError()
            
            break
        case WebimInternalError.providedAuthenticationTokenNotFound.rawValue:
            handleProvidedAuthenticationTokenNotFoundError()
            
            break
        default:
            running = false
            
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                self.internalErrorListener?.on(error: error)
            })
            
            break
        }
    }
    
    private func handleDeltaRequest(error: String) {
        if error == WebimInternalError.reinitializationRequired.rawValue {
            handleReinitializationRequiredError()
        } else {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                self.internalErrorListener?.on(error: error)
            })
        }
    }
    
    private func handleReinitializationRequiredError() {
        authorizationData = nil
        since = 0
    }
    
    private func handleProvidedAuthenticationTokenNotFoundError() {
        DeltaRequestLoop.providedAuthenticationTokenErrorCount += 1
        
        if DeltaRequestLoop.providedAuthenticationTokenErrorCount < 5 {
            sleepBetweenInitializationAttempts()
        } else {
            guard let token = providedAuthenticationToken else {
                WebimInternalLogger.shared.log(entry: "Provided Authentication Token is nil in  DeltaRequestLoop.\(#function)")
                return
            }
            providedAuthenticationTokenStateListener?.update(providedAuthorizationToken: token)
            
            DeltaRequestLoop.providedAuthenticationTokenErrorCount = 0
            
            sleepBetweenInitializationAttempts()
        }
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
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let `self` = self,
                    let visitorJSONString = self.visitorJSONString,
                    let sessionID = self.sessionID,
                    let authorizationData = self.authorizationData else {
                        WebimInternalLogger.shared.log(entry: "Changing parameters failure while unwrpping in DeltaRequestLoop.\(#function)")
                        return
                }
                
                
                self.sessionParametersListener?.onSessionParametersChanged(visitorFieldsJSONString: visitorJSONString,
                                                                           sessionID: sessionID,
                                                                           authorizationData: authorizationData)
            }
        }
        
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            self.deltaCallback.process(fullUpdate: fullUpdate)
        })
    }
    
}
