//
//  DeltaRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 16.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class DeltaRequestLoop: AbstractRequestLoop {
    
    // MARK: - Constants
    private enum ServerError: Error {
        case INCORRECT_SERVER_ANSWER
    }
    
    
    // MARK: - Properties
    private let appVersion: String?
    private let baseURL: String
    private let completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor
    private let deltaCallback: DeltaCallback
    private let deviceID: String
    private let internalErrorListener: InternalErrorListener
    private let location: String
    private let platform: String
    private let sessionParametersListener: SessionParametersListener?
    private let title: String
    private var authorizationData: AuthorizationData?
    private var deviceToken: String?
    private var sessionID: String?
    private var since: Int64 = 0
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    
    
    // MARK: - Initialization
    init(withDeltaCallback deltaCallback: DeltaCallback,
         completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         sessionParametersListener: SessionParametersListener?,
         internalErrorListener: InternalErrorListener,
         baseURL: String,
         platform: String,
         title: String,
         location: String,
         appVersion: String?,
         visitorFieldsJSONString: String?,
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
        self.platform = platform
        self.title = title
        self.location = location
        self.appVersion = appVersion
        self.visitorFieldsJSONString = visitorFieldsJSONString
        self.deviceID = deviceID
        self.deviceToken = deviceToken
        self.visitorJSONString = visitorJSONString
        self.sessionID = sessionID
        self.authorizationData = authorizationData
    }
    
    
    // MARK: - Methods
    
    override func run() throws {
        while isRunning() {
            try runIteration()
        }
    }
    
    func set(deviceToken: String?) {
        self.deviceToken = deviceToken
    }
    
    
    // MARK: Private methods
    private func runIteration() throws {
        if (authorizationData != nil)
            && (since != 0) {
            try requestDelta()
        } else {
            try requestInitialization()
        }
    }
    
    private func requestInitialization() throws {
        let timeSinceToPost = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        var dataToPost = [WebimActions.Parameter.DEVICE_ID.rawValue : deviceID,
                          WebimActions.Parameter.EVENT.rawValue : WebimActions.Event.INITIALIZATION.rawValue,
                          WebimActions.Parameter.LOCATION.rawValue : location,
                          WebimActions.Parameter.PLATFORM.rawValue : platform,
                          WebimActions.Parameter.RESPOND_IMMEDIATELY.rawValue : String(1), // true
                          WebimActions.Parameter.SINCE.rawValue : String(0),
                          WebimActions.Parameter.TITLE.rawValue : title,
                          WebimActions.Parameter.TIME_SINCE.rawValue : String(timeSinceToPost)] as [String : Any]
        if let appVersion = appVersion {
            dataToPost[WebimActions.Parameter.APP_VERSION.rawValue] = appVersion
        }
        if let deviceToken = deviceToken {
            dataToPost[WebimActions.Parameter.DEVICE_TOKEN.rawValue] = deviceToken
        }
        if let sessionID = sessionID {
            dataToPost[WebimActions.Parameter.SESSION_ID.rawValue] = sessionID
        }
        if let visitorJSONString = visitorJSONString {
            dataToPost[WebimActions.Parameter.VISITOR.rawValue] = visitorJSONString
        }
        if let visitorFieldsJSONString = visitorFieldsJSONString {
            dataToPost[WebimActions.Parameter.VISITOR_FIELDS.rawValue] = visitorFieldsJSONString
        }
        
        let parametersString = dataToPost.stringFromHTTPParameters()
        let url = URL(string: getDeltaServerURLString() + "?" + parametersString)
        var request = URLRequest(url: url!)
        
        request.httpMethod = AbstractRequestLoop.HTTPMethod.GET.rawValue
        
        let data = try perform(request: request)
        do {
            let dataJSON = try JSONSerialization.jsonObject(with: data) as! [String : Any]
            
            if let error = dataJSON["error"] as? String {
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
                let deltaResponse = DeltaResponse(withJSONDictionary: dataJSON)
                
                if let deltaList = deltaResponse.getDeltaList() {
                    if deltaList.count > 0 {
                        throw ServerError.INCORRECT_SERVER_ANSWER
                    }
                }
                
                guard let fullUpdate = deltaResponse.getFullUpdate() else {
                    throw ServerError.INCORRECT_SERVER_ANSWER
                }
                
                if let since = deltaResponse.getRevision() {
                    self.since = since
                }
                
                process(fullUpdate: fullUpdate)
            }
        } catch {
            print("Error de-serializing server response.")
        }
    }
    
    private func requestDelta() throws {
        let timeSinceToPost = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        var dataToPost = [WebimActions.Parameter.SINCE.rawValue : String(since),
                          WebimActions.Parameter.TIME_SINCE.rawValue : String(timeSinceToPost)] as [String : Any]
        if let authorizationData = authorizationData {
            dataToPost[WebimActions.Parameter.PAGE_ID.rawValue] = authorizationData.getPageID()
            dataToPost[WebimActions.Parameter.AUTHORIZATION_TOKEN.rawValue] = authorizationData.getAuthorizationToken()
        }
        
        let parametersString = dataToPost.stringFromHTTPParameters()
        let url = URL(string: getDeltaServerURLString() + "?" + parametersString)
        var request = URLRequest(url: url!)
        
        request.httpMethod = AbstractRequestLoop.HTTPMethod.GET.rawValue
        
        let data = try perform(request: request)
        do {
            let dataJSON = try JSONSerialization.jsonObject(with: data) as! [String : Any]
            if let error = dataJSON["error"] as? String {
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
                let deltaResponse = DeltaResponse(withJSONDictionary: dataJSON)
                
                guard let revision = deltaResponse.getRevision() else {
                    // Delta timeout.
                    return
                }
                since = revision
                
                if let fullUpdate = deltaResponse.getFullUpdate() {
                    process(fullUpdate: fullUpdate)
                } else if let deltaList = deltaResponse.getDeltaList() {
                    if deltaList.count > 0 {
                        completionHandlerExecutor.execute(task: DispatchWorkItem {
                            do {
                                try self.deltaCallback.process(deltaList: deltaList)
                            } catch {
                                print("Error processing delta list.")
                            }
                        })
                    }
                }
            }
        } catch {
            print("Error de-serializing server response.")
        }
    }
    
    private func process(fullUpdate: FullUpdate) {
        let visitorJSONString = fullUpdate.getVisitorJSONString()
        let sessionID = fullUpdate.getSessionID()
        let authorizationData = AuthorizationData(pageID: fullUpdate.getPageId()!,
                                                  authorizationToken: fullUpdate.getAuthorizationToken())
        
        let isNecessaryToUpdateVisitorFieldJSONString = (self.visitorFieldsJSONString == nil)
            || (self.visitorFieldsJSONString != visitorFieldsJSONString)
        let isNecessaryToUpdateSessionID = (self.sessionID == nil)
            || (self.sessionID != sessionID)
        let isNecessaryToUpdateAuthorizationData = (self.authorizationData == nil)
            || ((self.authorizationData?.getPageID() != fullUpdate.getPageId())
                || (self.authorizationData?.getAuthorizationToken() != fullUpdate.getAuthorizationToken()))
        
        if (isNecessaryToUpdateVisitorFieldJSONString
            || isNecessaryToUpdateSessionID)
            || isNecessaryToUpdateAuthorizationData {
            self.visitorJSONString = visitorJSONString
            self.sessionID = sessionID
            self.authorizationData = authorizationData
            
            if sessionParametersListener != nil {
                DispatchQueue.global(qos: .background).async {
                    self.sessionParametersListener?.onSessionParametersChanged(visitorFieldsJSONString: self.visitorJSONString!,
                                                                               sessionID: self.sessionID!,
                                                                               authorizationData: self.authorizationData!)
                }
            }
        }
        
        completionHandlerExecutor.execute(task: DispatchWorkItem {
            do {
                try self.deltaCallback.process(fullUpdate: fullUpdate)
            } catch {
                print("Error processing delta list.")
            }
        })
    }
    
    private func getDeltaServerURLString() -> String! {
        return baseURL + WebimActions.ServerPathSuffix.GET_DELTA.rawValue
    }
    
}
