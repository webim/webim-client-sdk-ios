//
//  WebimSessionImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 02.08.17.
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

// MARK: - Constants
fileprivate enum UserDefaultsName: String {
    case guid = "ru.webim.WebimClientSDKiOS.guid"
    case main = "ru.webim.WebimClientSDKiOS.visitor."
}
fileprivate enum UserDefaultsMainPrefix: String {
    case authorizationToken = "auth_token"
    case dbVersion = "db_version"
    case deviceToken = "push_token"
    case historyEnded = "history_ended"
    case historyDBname = "history_db_name"
    case historyMajorVersion = "history_major_version"
    case historyRevision = "history_revision"
    case pageID = "page_id"
    case readBeforeTimestamp = "read_before_timestamp"
    case sessionID = "session_id"
    case visitor = "visitor"
    case visitorExt = "visitor_ext"
}
fileprivate enum UserDefaultsGUIDPrefix: String {
    case uuid = "guid"
}

// MARK: -
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimSessionImpl {
    
    // MARK: - Constants
    private enum DefaultSettings: String {
        case pageTitle = "iOS Client"
    }
    
    // MARK: - Properties
    private var accessChecker: AccessChecker
    private var clientStarted = false
    private var historyPoller: HistoryPoller
    private var messageStream: MessageStreamImpl
    private var sessionDestroyer: SessionDestroyer
    private var webimClient: WebimClient
    
    // MARK: - Initialization
    private init(accessChecker: AccessChecker,
                 sessionDestroyer: SessionDestroyer,
                 webimClient: WebimClient,
                 historyPoller: HistoryPoller,
                 messageStream: MessageStreamImpl) {
        self.accessChecker = accessChecker
        self.sessionDestroyer = sessionDestroyer
        self.webimClient = webimClient
        self.historyPoller = historyPoller
        self.messageStream = messageStream
    }
    
    // MARK: - Methods
    
    static func newInstanceWith(accountName: String,
                                location: String,
                                appVersion: String?,
                                visitorFields: ProvidedVisitorFields?,
                                providedAuthorizationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
                                providedAuthorizationToken: String?,
                                pageTitle: String?,
                                fatalErrorHandler: FatalErrorHandler?,
                                deviceToken: String?,
                                isLocalHistoryStoragingEnabled: Bool,
                                isVisitorDataClearingEnabled: Bool,
                                webimLogger: WebimLogger?,
                                verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel?,
                                prechat: String?) -> WebimSessionImpl {
        WebimInternalLogger.setup(webimLogger: webimLogger,
                                  verbosityLevel: verbosityLevel)
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        let userDefaultsKey = UserDefaultsName.main.rawValue + (visitorFields?.getID() ?? "anonymous")
        let userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey)
        
        if isVisitorDataClearingEnabled {
            clearVisitorDataFor(userDefaultsKey: userDefaultsKey)
        }
        
        checkSavedSessionFor(userDefaultsKey: userDefaultsKey,
                             newProvidedVisitorFields: visitorFields)
        
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: userDefaultsKey)
        
        let visitorJSON = (userDefaults?[UserDefaultsMainPrefix.visitor.rawValue] ?? nil)
        
        let visitorFieldsJSONString = visitorFields?.getJSONString()
        
        let serverURLString = InternalUtils.createServerURLStringBy(accountName: accountName)
        WebimInternalLogger.shared.log(entry: "Specified Webim server – \(serverURLString).",
            verbosityLevel: .DEBUG)
        
        let currentChatMessageMapper: MessageMapper = CurrentChatMessageMapper(withServerURLString: serverURLString)
        
        let sessionID = userDefaults?[UserDefaultsMainPrefix.sessionID.rawValue] ?? nil
        
        let pageID = userDefaults?[UserDefaultsMainPrefix.pageID.rawValue] as! String?
        let authorizationToken = userDefaults?[UserDefaultsMainPrefix.authorizationToken.rawValue] as! String?
        let authorizationData = AuthorizationData(pageID: pageID,
                                                  authorizationToken: authorizationToken)
        
        let deltaCallback = DeltaCallback(currentChatMessageMapper: currentChatMessageMapper,
                                          userDefaultsKey: userDefaultsKey)

        let webimClient = WebimClientBuilder()
            .set(baseURL: serverURLString)
            .set(location: location)
            .set(appVersion: appVersion)
            .set(visitorFieldsJSONString: visitorFieldsJSONString)
            .set(deltaCallback: deltaCallback)
            .set(sessionParametersListener: SessionParametersListenerImpl(withUserDefaultsKey: userDefaultsKey))
            .set(internalErrorListener: DestroyOnFatalErrorListener(sessionDestroyer: sessionDestroyer,
                                                                  internalErrorListener: ErrorHandlerToInternalAdapter(fatalErrorHandler: fatalErrorHandler)))
            .set(visitorJSONString: visitorJSON as! String?)
            .set(providedAuthenticationTokenStateListener: providedAuthorizationTokenStateListener,
                 providedAuthenticationToken: providedAuthorizationToken)
            .set(sessionID: sessionID as! String?)
            .set(authorizationData: authorizationData)
            .set(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                              queue: queue))
            .set(title: (pageTitle ?? DefaultSettings.pageTitle.rawValue))
            .set(deviceToken: deviceToken)
            .set(deviceID: getDeviceID())
            .set(prechat: prechat)
            .build() as WebimClient
        
        var historyStorage: HistoryStorage
        var historyMetaInformationStoragePreferences: HistoryMetaInformationStorage
        if isLocalHistoryStoragingEnabled {
            var dbName = userDefaults?[UserDefaultsMainPrefix.historyDBname.rawValue] as? String
            
            if dbName == nil {
                dbName = "webim_\(ClientSideID.generateClientSideID()).db"
                if let userDefaults = userDefaults {
                    var renewedUserDefaults = userDefaults
                    renewedUserDefaults[UserDefaultsMainPrefix.historyDBname.rawValue] = dbName
                    UserDefaults.standard.set(renewedUserDefaults,
                                              forKey: userDefaultsKey)
                } else {
                    UserDefaults.standard.setValue([UserDefaultsMainPrefix.historyDBname.rawValue: dbName],
                                                   forKey: userDefaultsKey)
                }
            }
            
            historyMetaInformationStoragePreferences = HistoryMetaInformationStoragePreferences(userDefaultsKey: userDefaultsKey)
            
            let sqlhistoryStorage = SQLiteHistoryStorage(dbName: dbName!,
                                                  serverURL: serverURLString,
                                                  webimClient: webimClient,
                                                  reachedHistoryEnd: historyMetaInformationStoragePreferences.isHistoryEnded(),
                                                  queue: queue,
                                                  readBeforeTimestamp: (userDefaults?[UserDefaultsMainPrefix.readBeforeTimestamp.rawValue] ?? Int64(-1)) as! Int64)
            historyStorage = sqlhistoryStorage
            
            let historyMajorVersion = historyStorage.getMajorVersion()
            if (userDefaults?[UserDefaultsMainPrefix.historyMajorVersion.rawValue] as? Int) != historyMajorVersion {
                if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
                    userDefaults.removeValue(forKey: UserDefaultsMainPrefix.historyRevision.rawValue)
                    userDefaults.removeValue(forKey: UserDefaultsMainPrefix.historyEnded.rawValue)
                    userDefaults.removeValue(forKey: UserDefaultsMainPrefix.historyMajorVersion.rawValue)
                    userDefaults.updateValue(historyMajorVersion, forKey: UserDefaultsMainPrefix.historyMajorVersion.rawValue)
                    sqlhistoryStorage.updateDB()
                    UserDefaults.standard.setValue(userDefaults,
                                                   forKey: userDefaultsKey)
                }
            }
        } else {
            historyStorage = MemoryHistoryStorage(readBeforeTimestamp: (userDefaults?[UserDefaultsMainPrefix.readBeforeTimestamp.rawValue] ?? Int64(-1)) as! Int64)
            historyMetaInformationStoragePreferences = MemoryHistoryMetaInformationStorage()
        }
        
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        
        let webimActions = webimClient.getActions()
        let historyMessageMapper: MessageMapper = HistoryMessageMapper(withServerURLString: serverURLString)
        let messageHolder = MessageHolder(accessChecker: accessChecker,
                                          remoteHistoryProvider: RemoteHistoryProvider(webimActions: webimActions,
                                                                                       historyMessageMapper: historyMessageMapper,
                                                                                       historyMetaInformationStorage: historyMetaInformationStoragePreferences),
                                          historyStorage: historyStorage,
                                          reachedEndOfRemoteHistory: historyMetaInformationStoragePreferences.isHistoryEnded())
        let messageStream = MessageStreamImpl(serverURLString: serverURLString,
                                              currentChatMessageFactoriesMapper: currentChatMessageMapper,
                                              sendingMessageFactory: SendingFactory(withServerURLString: serverURLString),
                                              operatorFactory: OperatorFactory(withServerURLString: serverURLString),
                                              accessChecker: accessChecker,
                                              webimActions: webimActions,
                                              messageHolder: messageHolder,
                                              messageComposingHandler: MessageComposingHandler(webimActions: webimActions,
                                                                                               queue: queue),
                                              locationSettingsHolder: LocationSettingsHolder(userDefaultsKey: userDefaultsKey))
        
        let historyPoller = HistoryPoller(withSessionDestroyer: sessionDestroyer,
                                          queue: queue,
                                          historyMessageMapper: historyMessageMapper,
                                          webimActions: webimActions,
                                          messageHolder: messageHolder,
                                          historyMetaInformationStorage: historyMetaInformationStoragePreferences)
        
        deltaCallback.set(messageStream: messageStream,
                          messageHolder: messageHolder,
                          historyPoller: historyPoller)
        
        sessionDestroyer.add() {
            webimClient.stop()
        }
        sessionDestroyer.add() {
            historyPoller.pause()
        }
        
        // Needed for message attachment secure download link generation.
        currentChatMessageMapper.set(webimClient: webimClient)
        historyMessageMapper.set(webimClient: webimClient)
        
        return WebimSessionImpl(accessChecker: accessChecker,
                                sessionDestroyer: sessionDestroyer,
                                webimClient: webimClient,
                                historyPoller: historyPoller,
                                messageStream: messageStream)
    }
    
    // MARK: Private methods
    
    private static func clearVisitorDataFor(userDefaultsKey: String) {
        deleteDBFileFor(userDefaultsKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    private static func deleteDBFileFor(userDefaultsKey: String) {
        if let dbName = UserDefaults.standard.dictionary(forKey: userDefaultsKey)?[UserDefaultsMainPrefix.historyDBname.rawValue] as? String {
            let fileManager = FileManager.default
            let documentsDirectory = try! fileManager.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: false)
            let dbURL = documentsDirectory.appendingPathComponent(dbName)
            
            do {
                try fileManager.removeItem(at: dbURL)
            } catch {
                WebimInternalLogger.shared.log(entry: "Error deleting DB file at \(dbURL) or file doesn't exist.",
                    verbosityLevel: .VERBOSE)
            }
        }
    }
    
    private static func checkSavedSessionFor(userDefaultsKey: String,
                                             newProvidedVisitorFields: ProvidedVisitorFields?) {
        let newVisitorFieldsJSONString = newProvidedVisitorFields?.getJSONString()
        let previousVisitorFieldsJSONString = UserDefaults.standard.dictionary(forKey: userDefaultsKey)?[UserDefaultsMainPrefix.visitorExt.rawValue] as? String
        
        var previousProvidedVisitorFields: ProvidedVisitorFields? = nil
        if previousVisitorFieldsJSONString != nil {
            previousProvidedVisitorFields = ProvidedVisitorFields(withJSONString: previousVisitorFieldsJSONString!)
        
            if (newProvidedVisitorFields == nil)
                || (previousProvidedVisitorFields?.getID() != newProvidedVisitorFields?.getID()) {
                clearVisitorDataFor(userDefaultsKey: userDefaultsKey)
            }
        }
        
        if newVisitorFieldsJSONString != previousVisitorFieldsJSONString {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            
            let newVisitorFieldsDictionary = [UserDefaultsMainPrefix.visitorExt.rawValue: newVisitorFieldsJSONString]
            UserDefaults.standard.set(newVisitorFieldsDictionary,
                                      forKey: userDefaultsKey)
        }
    }
    
    private static func getDeviceID() -> String {
        let userDefaults = UserDefaults.standard.dictionary(forKey: UserDefaultsName.guid.rawValue)
        var uuidString = (userDefaults?[UserDefaultsGUIDPrefix.uuid.rawValue] ?? nil)
        
        if uuidString == nil {
            uuidString = UIDevice.current.identifierForVendor!.uuidString
            if var userDefaults = UserDefaults.standard.dictionary(forKey: UserDefaultsName.guid.rawValue) {
                userDefaults[UserDefaultsGUIDPrefix.uuid.rawValue] = uuidString
                UserDefaults.standard.set(userDefaults,
                                          forKey: UserDefaultsName.guid.rawValue)
            } else {
                UserDefaults.standard.setValue([UserDefaultsGUIDPrefix.uuid.rawValue: uuidString],
                                               forKey: UserDefaultsName.guid.rawValue)
            }
        }
        
        return uuidString as! String
    }   
    
}

// MARK: - WebimSession
extension WebimSessionImpl: WebimSession {
    
    func resume() throws {
        try checkAccess()
        
        if !clientStarted {
            webimClient.start()
            clientStarted = true
        }
        
        webimClient.resume()
        historyPoller.resume()
    }
    
    func pause() throws {
        if sessionDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        webimClient.pause()
        historyPoller.pause()
    }
    
    func destroy() throws {
        if sessionDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        sessionDestroyer.destroy()
    }
    
    func destroyWithClearVisitorData() throws {
        if sessionDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        sessionDestroyer.destroy()
        WebimSessionImpl.clearVisitorDataFor(userDefaultsKey: sessionDestroyer.getUserDefaulstKey())
    }
    
    func getStream() -> MessageStream {
        return messageStream
    }
    
    func change(location: String) throws {
        try checkAccess()
        
        try webimClient.getDeltaRequestLoop().change(location: location)
    }
    
    func set(deviceToken: String) throws {
        try checkAccess()
        
        webimClient.set(deviceToken: deviceToken)
    }
    
    
    // MARK: Private methods
    private func checkAccess() throws {
        try accessChecker.checkAccess()
    }
    
}

// MARK: -
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class HistoryPoller {
    
    // MARK: - Constants
    private enum TimeInterval: Int64 {
        case historyPolling = 60_000 // ms
    }
    
    // MARK: - Properties
    private let historyMessageMapper: MessageMapper
    private let historyMetaInformationStorage: HistoryMetaInformationStorage
    private let queue: DispatchQueue
    private let messageHolder: MessageHolder
    private let sessionDestroyer: SessionDestroyer
    private let webimActions: WebimActions
    private var dispatchWorkItem: DispatchWorkItem?
    private var historySinceCompletionHandler: ((_ messageList: [MessageImpl], _ deleted: Set<String>, _ hasMore: Bool, _ isInitial: Bool, _ revision: String?) -> ())?
    private var lastPollingTime = -TimeInterval.historyPolling.rawValue
    private var lastRevision: String?
    private var running: Bool?
    private var hasHistoryRevision = false
    
    // MARK: - Initialization
    init(withSessionDestroyer sessionDestroyer: SessionDestroyer,
         queue: DispatchQueue,
         historyMessageMapper: MessageMapper,
         webimActions: WebimActions,
         messageHolder: MessageHolder,
         historyMetaInformationStorage: HistoryMetaInformationStorage) {
        self.sessionDestroyer = sessionDestroyer
        self.queue = queue
        self.historyMessageMapper = historyMessageMapper
        self.webimActions = webimActions
        self.messageHolder = messageHolder
        self.historyMetaInformationStorage = historyMetaInformationStorage
    }
    
    // MARK: - Methods
    
    func pause() {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
        
        running = false
    }
    
    func resume() {
        pause()
        
        running = true
        
        historySinceCompletionHandler = createHistorySinceCompletionHandler()
        
        let uptime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
        if (uptime - lastPollingTime) > TimeInterval.historyPolling.rawValue {
            requestHistory(since: lastRevision,
                           completion: historySinceCompletionHandler!)
        } else {
            if !self.hasHistoryRevision {
                // Setting next history polling in TimeInterval.HISTORY_POLL after lastPollingTime.
            
                let dispatchTime = DispatchTime(uptimeNanoseconds: (UInt64((lastPollingTime + TimeInterval.historyPolling.rawValue) * 1_000_000) - UInt64((uptime) * 1_000_000)))
            
                dispatchWorkItem = DispatchWorkItem() { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                
                    self.requestHistory(since: self.lastRevision,
                                        completion: self.historySinceCompletionHandler!)
                }
            
                queue.asyncAfter(deadline: dispatchTime,
                                 execute: dispatchWorkItem!)
            }
        }
    }
    
    func set(hasHistoryRevision: Bool) {
        self.hasHistoryRevision = hasHistoryRevision
    }
    
    func updateReadBeforeTimestamp(timestamp: Int64, byUserDefaultsKey userDefaultsKey: String) {
        self.messageHolder.updateReadBeforeTimestamp(timestamp: timestamp)
        if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[UserDefaultsMainPrefix.readBeforeTimestamp.rawValue] = timestamp
            UserDefaults.standard.set(userDefaults, forKey: userDefaultsKey)
        }
    }
    
    func getReadBeforeTimestamp(byUserDefaultsKey userDefaultsKey: String) -> Int64 {
        let userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey)
        if let readBeforeTimestamp = userDefaults?[UserDefaultsMainPrefix.readBeforeTimestamp.rawValue] {
            return readBeforeTimestamp as! Int64
        }
        return Int64(-1)
    }
    
    // MARK: Private methods
    
    private func createHistorySinceCompletionHandler() -> (_ messageList: [MessageImpl], _ deleted: Set<String>, _ hasMore: Bool, _ isInitial: Bool, _ revision: String?) -> () {
        return { [weak self] (messageList: [MessageImpl], deleted: Set<String>, hasMore: Bool, isInitial: Bool, revision: String?) in
            guard let `self` = self,
                !self.sessionDestroyer.isDestroyed() else {
                return
            }
            
            self.lastPollingTime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
            self.lastRevision = revision
            
            if isInitial && !hasMore {
                self.messageHolder.set(endOfHistoryReached: true)
                self.historyMetaInformationStorage.set(historyEnded: true)
            }
            
            self.messageHolder.receiveHistoryUpdateWith(messages: messageList,
                                                        deleted: deleted,
                                                        completion: { [weak self] in
                                                            // Revision is saved after history is saved only.
                                                            // I.e. if history will not be saved, then revision will not be overwritten. History will be re-requested.
                                                            self?.historyMetaInformationStorage.set(revision: revision)
            })
            
            if self.running != true {
                if !isInitial
                    && hasMore {
                    self.lastPollingTime = -TimeInterval.historyPolling.rawValue
                }
                
                return
            }
            
            if !isInitial && hasMore {
                self.requestHistory(since: revision,
                                    completion: self.createHistorySinceCompletionHandler())
            } else {
                if !self.hasHistoryRevision {
                    self.dispatchWorkItem = DispatchWorkItem() { [weak self] in
                        guard let `self` = self, self.hasHistoryRevision == false else {
                            return
                        }
                        self.requestHistory(since: revision,
                                            completion: self.createHistorySinceCompletionHandler())
                    
                    
                    }
                    let interval = Int(TimeInterval.historyPolling.rawValue)
                    self.queue.asyncAfter(deadline: (.now() + .milliseconds(interval)),
                                          execute: self.dispatchWorkItem!)
                }
            }
        }
    }
    
    public func requestHistory(since: String) {
        if self.lastRevision == nil || self.lastRevision != since {
            requestHistory(since: lastRevision, completion: historySinceCompletionHandler!)
        }
    }
    
    private func requestHistory(since: String?,
                                completion: @escaping (_ messageList: [MessageImpl], _ deleted: Set<String>, _ hasMore: Bool, _ isInitial: Bool, _ revision: String?) -> ()) {
        webimActions.requestHistory(since: since) { data in
            if data != nil {
                let json = try? JSONSerialization.jsonObject(with: data!,
                                                             options: [])
                if let historySinceResponseDictionary = json as? [String: Any?] {
                    let historySinceResponse = HistorySinceResponse(jsonDictionary: historySinceResponseDictionary)
                    
                    var deletes = Set<String>()
                    var messageChanges = [MessageItem]()
                    
                    if let messages = historySinceResponse.getData()?.getMessages() {
                        for message in messages {
                            if message.isDeleted() {
                                if let id = message.getID() {
                                    deletes.insert(id)
                                }
                            } else {
                                messageChanges.append(message)
                            }
                        }
                    }
                    
                    completion(self.historyMessageMapper.mapAll(messages: messageChanges), deletes, (historySinceResponse.getData()?.isHasMore() == true), (since == nil), historySinceResponse.getData()?.getRevision())
                }
            } else {
                completion([MessageImpl](), Set<String>(), false, (since == nil), since)
            }
        }
    }
    
}

// MARK: -
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class SessionParametersListenerImpl: SessionParametersListener {
    
    // MARL: - Constants
    private enum VisitorFieldsJSONField: String {
        case id = "id"
    }
    
    // MARK: - Properties
    private let userDefaultsKey: String
    
    // MARK: - Initialization
    init(withUserDefaultsKey userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    // MARK: - Methods
    // MARK: SessionParametersListener methods
    func onSessionParametersChanged(visitorFieldsJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData) {
        if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[UserDefaultsMainPrefix.visitor.rawValue] = visitorFieldsJSONString
            userDefaults[UserDefaultsMainPrefix.sessionID.rawValue] = sessionID
            userDefaults[UserDefaultsMainPrefix.pageID.rawValue] = authorizationData.getPageID()
            userDefaults[UserDefaultsMainPrefix.authorizationToken.rawValue] = authorizationData.getAuthorizationToken()
            UserDefaults.standard.set(userDefaults,
                                      forKey: userDefaultsKey)
        } else {
            UserDefaults.standard.setValue([UserDefaultsMainPrefix.visitor.rawValue: visitorFieldsJSONString,
                                            UserDefaultsMainPrefix.sessionID.rawValue: sessionID,
                                            UserDefaultsMainPrefix.pageID.rawValue: authorizationData.getPageID(),
                                            UserDefaultsMainPrefix.authorizationToken.rawValue: authorizationData.getAuthorizationToken()],
                                           forKey: userDefaultsKey)
        }
    }
    
}

// MARK: -
/**
 Class that responsible on destroying session on service fatal error occured.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final private class DestroyOnFatalErrorListener: InternalErrorListener {
    
    // MARK: - Properties
    private let internalErrorListener: InternalErrorListener?
    private var sessionDestroyer: SessionDestroyer
    
    // MARK: - Initialization
    init(sessionDestroyer: SessionDestroyer,
         internalErrorListener: InternalErrorListener?) {
        self.sessionDestroyer = sessionDestroyer
        self.internalErrorListener = internalErrorListener
    }
    
    // MARK: - Methods
    // MARK: InternalErrorListener protocol methods
    func on(error: String) {
        if !sessionDestroyer.isDestroyed() {
            sessionDestroyer.destroy()
            
            internalErrorListener?.on(error: error)
        }
    }
    
}

// MARK: -
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final private class ErrorHandlerToInternalAdapter: InternalErrorListener {
    
    // MARK: - Parameters
    private weak var fatalErrorHandler: FatalErrorHandler?
    
    // MARK: - Initialization
    init(fatalErrorHandler: FatalErrorHandler?) {
        self.fatalErrorHandler = fatalErrorHandler
    }
    
    // MARK: - Methods
    
    // MARK: InternalErrorListener protocol methods
    func on(error: String) {
        let webimError = WebimErrorImpl(errorType: toPublicErrorType(string: error),
                                        errorString: error)
        fatalErrorHandler?.on(error: webimError)
    }
    
    // MARK: Private methods
    private func toPublicErrorType(string: String) -> FatalErrorType {
        switch string {
        case WebimInternalError.accountBlocked.rawValue:
            return .ACCOUNT_BLOCKED
        case WebimInternalError.visitorBanned.rawValue:
            return .VISITOR_BANNED
        case WebimInternalError.wrongProvidedVisitorFieldsHashValue.rawValue:
            return .WRONG_PROVIDED_VISITOR_HASH
        case WebimInternalError.providedVisitorFieldsExpired.rawValue:
            return .PROVIDED_VISITOR_FIELDS_EXPIRED
        default:
            return .UNKNOWN
        }
    }
    
}

// MARK: -
/**
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final private class HistoryMetaInformationStoragePreferences: HistoryMetaInformationStorage {
    
    // MARK: - Properties
    var userDefaultsKey: String
    
    // MARK: - Initialization
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    // MARK: - Methods
    // MARK: HistoryMetaInformationStorage protocol methods
    
    func isHistoryEnded() -> Bool {
        if let historyEnded = UserDefaults.standard.dictionary(forKey: userDefaultsKey)?[UserDefaultsMainPrefix.historyEnded.rawValue] as? Bool {
            return historyEnded
        }
        
        return false
    }
    
    func set(historyEnded: Bool) {
        if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[UserDefaultsMainPrefix.historyEnded.rawValue] = historyEnded
            UserDefaults.standard.set(userDefaults,
                                      forKey: userDefaultsKey)
        } else {
            UserDefaults.standard.setValue([UserDefaultsMainPrefix.historyEnded.rawValue: historyEnded],
                                           forKey: userDefaultsKey)
        }
    }
    
    func set(revision: String?) {
        if let revision = revision {
            if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
                userDefaults[UserDefaultsMainPrefix.historyRevision.rawValue] = revision
                UserDefaults.standard.set(userDefaults,
                                          forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.setValue([UserDefaultsMainPrefix.historyRevision.rawValue: revision],
                                               forKey: userDefaultsKey)
            }
        }
    }
    
}
