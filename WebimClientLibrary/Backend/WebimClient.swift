//
//  WebimClient.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 10.08.17.
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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimClientBuilder {
    
    // MARK: - Properties
    private var appVersion: String?
    private var prechat: String?
    private var authorizationData: AuthorizationData?
    private var baseURL: String?
    private var completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?
    private var deltaCallback: DeltaCallback?
    private var deviceID: String?
    private var deviceToken: String?
    private var internalErrorListener: InternalErrorListener?
    private var notFatalErrorHandler: NotFatalErrorHandler?
    private var location: String?
    private var providedAuthenticationToken: String?
    private weak var providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?
    private var sessionID: String?
    private var sessionParametersListener: SessionParametersListener?
    private var title: String?
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    
    // MARK: - Builder methods
    
    func set(appVersion: String?) -> WebimClientBuilder {
        self.appVersion = appVersion
        
        return self
    }
    
    func set(baseURL: String) -> WebimClientBuilder {
        self.baseURL = baseURL
        
        return self
    }
    
    func set(location: String) -> WebimClientBuilder {
        self.location = location
        
        return self
    }
    
    func set(deltaCallback: DeltaCallback) -> WebimClientBuilder {
        self.deltaCallback = deltaCallback
        
        return self
    }
    
    func set(sessionParametersListener: SessionParametersListener) -> WebimClientBuilder {
        self.sessionParametersListener = sessionParametersListener
        
        return self
    }
    
    func set(internalErrorListener: InternalErrorListener) -> WebimClientBuilder {
        self.internalErrorListener = internalErrorListener
        
        return self
    }
    
    func set(visitorJSONString: String?) -> WebimClientBuilder {
        self.visitorJSONString = visitorJSONString
        
        return self
    }
    
    func set(visitorFieldsJSONString: String?) -> WebimClientBuilder {
        self.visitorFieldsJSONString = visitorFieldsJSONString
        
        return self
    }
    
    func set(providedAuthenticationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
             providedAuthenticationToken: String? = nil) -> WebimClientBuilder {
        self.providedAuthenticationTokenStateListener = providedAuthenticationTokenStateListener
        self.providedAuthenticationToken = providedAuthenticationToken
        
        return self
    }
    
    func set(sessionID: String?) -> WebimClientBuilder {
        self.sessionID = sessionID
        
        return self
    }
    
    func set(authorizationData: AuthorizationData?) -> WebimClientBuilder {
        self.authorizationData = authorizationData
        
        return self
    }
    
    func set(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?) -> WebimClientBuilder {
        self.completionHandlerExecutor = completionHandlerExecutor
        
        return self
    }
    
    func set(title: String) -> WebimClientBuilder {
        self.title = title
        
        return self
    }
    
    func set(deviceToken: String?) -> WebimClientBuilder {
        self.deviceToken = deviceToken
        
        return self
    }
    
    func set(deviceID: String?) -> WebimClientBuilder {
        self.deviceID = deviceID
        
        return self
    }
    
    func set(notFatalErrorHandler: NotFatalErrorHandler?) -> WebimClientBuilder {
        self.notFatalErrorHandler = notFatalErrorHandler
        
        return self
    }
    
    func set(prechat:String?) -> WebimClientBuilder {
        self.prechat = prechat
        return self
    }
    
    func build() -> WebimClient {
        guard let completionHandlerExecutor = completionHandlerExecutor else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Completion Handler Executor is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Completion Handler Executor is nil in WebimClient.\(#function)")
        }
        guard let internalErrorListener = internalErrorListener else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Internal Error Listener is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Internal Error Listener is nil in WebimClient.\(#function)")
        }
        
        let actionRequestLoop = ActionRequestLoop(completionHandlerExecutor: completionHandlerExecutor,
                                                  internalErrorListener: internalErrorListener,
                                                  notFatalErrorHandler: notFatalErrorHandler)
        
        actionRequestLoop.set(authorizationData: authorizationData)
        
        guard let deltaCallback = deltaCallback else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Delta Callback is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Delta Callback is nil in WebimClient.\(#function)")
        }
        guard let baseURL = baseURL else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Base URL is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Base URL is nil in WebimClient.\(#function)")
        }
        guard let title = title else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Title is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Title is nil in WebimClient.\(#function)")
        }
        guard let location = location else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Location is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Location is nil in WebimClient.\(#function)")
        }
        guard let deviceID = deviceID else {
            WebimInternalLogger.shared.log(entry: "Building Webim client failure because Device ID is nil in WebimClient.\(#function)")
            fatalError("Building Webim client failure because Device ID is nil in WebimClient.\(#function)")
        }
        
        let deltaRequestLoop = DeltaRequestLoop(deltaCallback: deltaCallback,
                                                completionHandlerExecutor: completionHandlerExecutor,
                                                sessionParametersListener: SessionParametersListenerWrapper(withSessionParametersListenerToWrap: sessionParametersListener,
                                                                                                            actionRequestLoop: actionRequestLoop),
                                                internalErrorListener: internalErrorListener,
                                                baseURL: baseURL,
                                                title: title,
                                                location: location,
                                                appVersion: appVersion,
                                                visitorFieldsJSONString: visitorFieldsJSONString,
                                                providedAuthenticationTokenStateListener: providedAuthenticationTokenStateListener,
                                                providedAuthenticationToken: providedAuthenticationToken,
                                                deviceID: deviceID,
                                                deviceToken: deviceToken,
                                                visitorJSONString: visitorJSONString,
                                                sessionID: sessionID,
                                                prechat: prechat,
                                                authorizationData: authorizationData
                                                )
        
        return WebimClient(withActionRequestLoop: actionRequestLoop,
                           deltaRequestLoop: deltaRequestLoop,
                           webimActions: WebimActions(baseURL: baseURL,
                                                      actionRequestLoop: actionRequestLoop))
    }
    
}

// MARK: -
// Need to update deviceToken in DeltaRequestLoop on update in WebimActions.
/**
 Class that is responsible for history storage when it is set to memory mode.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimClient {
    
    // MARK: - Properties
    private let actionRequestLoop: ActionRequestLoop
    private let deltaRequestLoop: DeltaRequestLoop
    private let webimActions: WebimActions
    
    // MARK: - Initialization
    init(withActionRequestLoop actionRequestLoop: ActionRequestLoop,
         deltaRequestLoop: DeltaRequestLoop,
         webimActions: WebimActions) {
        self.actionRequestLoop = actionRequestLoop
        self.deltaRequestLoop = deltaRequestLoop
        self.webimActions = webimActions
    }
    
    // MARK: - Methods
    
    func start() {
        deltaRequestLoop.start()
        actionRequestLoop.start()
    }
    
    func pause() {
        deltaRequestLoop.pause()
        actionRequestLoop.pause()
    }
    
    func resume() {
        deltaRequestLoop.resume()
        actionRequestLoop.resume()
    }
    
    func stop() {
        deltaRequestLoop.stop()
        actionRequestLoop.stop()
    }
    
    func set(deviceToken: String) {
        deltaRequestLoop.set(deviceToken: deviceToken)
        webimActions.update(deviceToken: deviceToken)
    }
    
    func getDeltaRequestLoop() -> DeltaRequestLoop {
        return deltaRequestLoop
    }
    
    func getActions() -> WebimActions {
        return webimActions
    }
    
}

// MARK: -
// Need to update AuthorizationData in ActionRequestLoop on update in DeltaRequestLoop.
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final private class SessionParametersListenerWrapper: SessionParametersListener {
    
    // MARK: - Properties
    private let wrappedSessionParametersListener: SessionParametersListener?
    private let actionRequestLoop: ActionRequestLoop
    
    // MARK: - Initializers
    init(withSessionParametersListenerToWrap wrappingSessionParametersListener: SessionParametersListener?,
         actionRequestLoop: ActionRequestLoop) {
        wrappedSessionParametersListener = wrappingSessionParametersListener
        self.actionRequestLoop = actionRequestLoop
    }
    
    // MARK: - SessionParametersListener protocol methods
    func onSessionParametersChanged(visitorFieldsJSONString visitorJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData) {
        actionRequestLoop.set(authorizationData: authorizationData)
        
        wrappedSessionParametersListener?.onSessionParametersChanged(visitorFieldsJSONString: visitorJSONString,
                                                                     sessionID: sessionID,
                                                                     authorizationData: authorizationData)
    }
    
}
