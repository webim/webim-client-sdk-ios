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
fileprivate enum WMKeychainWrapperName: String {
    case guid = "ru.webim.WebimClientSDKiOS.guid"
    case main = "ru.webim.WebimClientSDKiOS.visitor."
}
fileprivate enum WMKeychainWrapperMainPrefix: String {
    case authorizationToken = "auth_token"
    case deviceToken = "push_token"
    case historyEnded = "history_ended"
    case historyDBname = "history_db_name"
    case historyMajorVersion = "history_major_version"
    case historyRevision = "history_revision"
    case pageID = "page_id"
    case previousAccount = "previous_account"
    case readBeforeTimestamp = "read_before_timestamp"
    case sessionID = "session_id"
    case visitor = "visitor"
    case visitorExt = "visitor_ext"
}
fileprivate enum WMKeychainWrapperGUIDPrefix: String {
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
    private var locationStatusPoller: LocationStatusPoller?
    private var messageStream: MessageStreamImpl
    private var sessionDestroyer: SessionDestroyer
    private var webimClient: WebimClient
    private var sessionID: String?
    
    // MARK: - Initialization
    private init(accessChecker: AccessChecker,
                 sessionDestroyer: SessionDestroyer,
                 webimClient: WebimClient,
                 historyPoller: HistoryPoller,
                 locationStatusPoller: LocationStatusPoller?,
                 messageStream: MessageStreamImpl,
                 sessionID: String? = nil) {
        self.accessChecker = accessChecker
        self.sessionDestroyer = sessionDestroyer
        self.webimClient = webimClient
        self.historyPoller = historyPoller
        self.locationStatusPoller = locationStatusPoller
        self.messageStream = messageStream
        self.sessionID = sessionID
    }
    
    // MARK: - Methods
    
    static func newInstanceWith(accountName: String,
                                location: String,
                                mobileChatInstance: String? = "default",
                                appVersion: String?,
                                visitorFields: ProvidedVisitorFields?,
                                providedAuthorizationTokenStateListener: ProvidedAuthorizationTokenStateListener?,
                                providedAuthorizationToken: String?,
                                pageTitle: String?,
                                fatalErrorHandler: FatalErrorHandler?,
                                notFatalErrorHandler: NotFatalErrorHandler?,
                                deviceToken: String?,
                                remoteNotificationSystem: Webim.RemoteNotificationSystem?,
                                isLocalHistoryStoragingEnabled: Bool,
                                isVisitorDataClearingEnabled: Bool,
                                webimLogger: WebimLogger?,
                                verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel?,
                                availableLogTypes: [SessionBuilder.WebimLogType],
                                webimAlert: WebimAlert?,
                                prechat: String?,
                                multivisitorSection: String,
                                onlineStatusRequestFrequencyInMillis: Int64?,
                                requestHeader: [String: String]?) -> WebimSessionImpl {
        
        let visitorName = visitorFields?.getID() ?? "anonymous"
        let mobileChatInstance = mobileChatInstance ?? "default"
        let userDefaultsKey = WMKeychainWrapperName.main.rawValue + visitorName + "." + mobileChatInstance
        
        if let session = WMSessionController.shared.session(
            visitorName: visitorName,
            accountName: accountName,
            location: location,
            mobileChatInstance: mobileChatInstance) {
            do {
                try session.checkAccess()
            } catch {
                WMSessionController.shared.remove(session: session)
                return newInstanceWith(
                    accountName: accountName,
                    location: location,
                    mobileChatInstance: mobileChatInstance,
                    appVersion: appVersion,
                    visitorFields: visitorFields,
                    providedAuthorizationTokenStateListener: providedAuthorizationTokenStateListener,
                    providedAuthorizationToken: providedAuthorizationToken,
                    pageTitle: pageTitle,
                    fatalErrorHandler: fatalErrorHandler,
                    notFatalErrorHandler: notFatalErrorHandler,
                    deviceToken: deviceToken,
                    remoteNotificationSystem: remoteNotificationSystem,
                    isLocalHistoryStoragingEnabled: isLocalHistoryStoragingEnabled,
                    isVisitorDataClearingEnabled: isVisitorDataClearingEnabled,
                    webimLogger: webimLogger,
                    verbosityLevel: verbosityLevel,
                    availableLogTypes: availableLogTypes,
                    webimAlert: webimAlert,
                    prechat: prechat,
                    multivisitorSection: multivisitorSection,
                    onlineStatusRequestFrequencyInMillis: onlineStatusRequestFrequencyInMillis,
                    requestHeader: requestHeader
                )
            }
            return session
        }
        
        WebimInternalLogger.setup(webimLogger: webimLogger,
                                  verbosityLevel: verbosityLevel,
                                  availableLogTypes: availableLogTypes)
        WebimInternalAlert.setup(webimAlert: webimAlert)
        let webimSdkQueue = DispatchQueue.current!
        
        var userDefaults: [String: Any]? = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)
        
        let previousAccount = WMKeychainWrapper.standard.string(forKey: WMKeychainWrapperMainPrefix.previousAccount.rawValue)

        if (previousAccount != nil && previousAccount != accountName) ||  isVisitorDataClearingEnabled {
            clearVisitorDataFor(userDefaultsKey: userDefaultsKey)
        }
        
        WMKeychainWrapper.standard.setString(accountName, forKey: WMKeychainWrapperMainPrefix.previousAccount.rawValue)
        
        checkSavedSessionFor(userDefaultsKey: userDefaultsKey,
                             newProvidedVisitorFields: visitorFields)
        
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: userDefaultsKey)
        
        guard let visitorJSON = userDefaults?[WMKeychainWrapperMainPrefix.visitor.rawValue] as? String? else {
            WebimInternalLogger.shared.log(
                entry: "Wrong visitorJSON type in WebimSessionImpl -\(#function)")
            fatalError("Wrong visitorJSON type in WebimSessionImpl.\(#function)")
        }
        
        let visitorFieldsJSONString = visitorFields?.getJSONString()
        
        let serverURLString = InternalUtils.createServerURLStringBy(accountName: accountName)
        WebimInternalLogger.shared.log(
            entry: "Specified Webim server – \(serverURLString).",
            verbosityLevel: .debug)
        
        let currentChatMessageMapper: MessageMapper = CurrentChatMessageMapper(withServerURLString: serverURLString)
        let historyMessageMapper: MessageMapper = HistoryMessageMapper(withServerURLString: serverURLString)
        
        guard let sessionID = userDefaults?[WMKeychainWrapperMainPrefix.sessionID.rawValue] as? String? else {
            WebimInternalLogger.shared.log(
                entry: "Wrong sessionID type in WebimSessionImpl.\(#function)")
            fatalError("Wrong sessionID type in WebimSessionImpl.\(#function)")
        }
        
        guard let pageID = userDefaults?[WMKeychainWrapperMainPrefix.pageID.rawValue] as? String? else {
            WebimInternalLogger.shared.log(
                entry: "Wrong pageID type in WebimSessionImpl.\(#function)")
            fatalError("Wrong pageID type in WebimSessionImpl.\(#function)")
        }
        
        guard let authorizationToken = userDefaults?[WMKeychainWrapperMainPrefix.authorizationToken.rawValue] as? String? else {
            WebimInternalLogger.shared.log(
                entry: "Wrong authorizationToken type in WebimSessionImpl.\(#function)")
            fatalError("Wrong authorizationToken type in WebimSessionImpl.\(#function)")
        }
        
        let authorizationData = AuthorizationData(pageID: pageID,
                                                  authorizationToken: authorizationToken)
        
        let deltaCallback = DeltaCallback(currentChatMessageMapper: currentChatMessageMapper,
                                          historyMessageMapper: historyMessageMapper,
                                          userDefaultsKey: userDefaultsKey)

        let webimClient = WebimClientBuilder()
            .set(baseURL: serverURLString)
            .set(location: location)
            .set(appVersion: appVersion)
            .set(visitorFieldsJSONString: visitorFieldsJSONString)
            .set(deltaCallback: deltaCallback)
            .set(sessionParametersListener: SessionParametersListenerImpl(withWMKeychainWrapperKey: userDefaultsKey))
            .set(internalErrorListener: DestroyOnFatalErrorListener(sessionDestroyer: sessionDestroyer,
                                                                    internalErrorListener: ErrorHandlerToInternalAdapter(fatalErrorHandler: fatalErrorHandler), notFatalErrorHandler: notFatalErrorHandler))
            .set(visitorJSONString: visitorJSON)
            .set(providedAuthenticationTokenStateListener: providedAuthorizationTokenStateListener,
                 providedAuthenticationToken: providedAuthorizationToken)
            .set(requestHeader: requestHeader)
            .set(sessionID: sessionID)
            .set(authorizationData: authorizationData)
            .set(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                              queue: webimSdkQueue))
            .set(title: (pageTitle ?? DefaultSettings.pageTitle.rawValue))
            .set(deviceToken: deviceToken)
            .set(remoteNotificationSystem: remoteNotificationSystem)
            .set(deviceID: getDeviceID(withSuffix: multivisitorSection))
            .set(prechat: prechat)
            .build() as WebimClient
        
        var historyStorage: HistoryStorage
        var historyMetaInformationStoragePreferences: HistoryMetaInformationStorage
        let fileUrlCreator = FileUrlCreator(webimClient: webimClient, serverURL: serverURLString)
        if isLocalHistoryStoragingEnabled {
            let savedDBName = userDefaults?[WMKeychainWrapperMainPrefix.historyDBname.rawValue] as? String
            if savedDBName == nil || !(savedDBName?.hasPrefix(WMKeychainWrapper.actualDBPrefix()) ?? false) {
                let dbName = WMKeychainWrapper.actualDBPrefix() + "\(ClientSideID.generateClientSideID()).db"
                if userDefaults == nil {
                    userDefaults = [WMKeychainWrapperMainPrefix.historyDBname.rawValue: dbName]
                } else {
                    userDefaults?[WMKeychainWrapperMainPrefix.historyDBname.rawValue] = dbName
                }
                WMKeychainWrapper.standard.setDictionary(userDefaults,
                                          forKey: userDefaultsKey)
            }
            
            guard let dbName = userDefaults?[WMKeychainWrapperMainPrefix.historyDBname.rawValue] as? String else {
                WebimInternalLogger.shared.log(
                    entry: "Can not find or write DB Name to WMKeychainWrapper in WebimSessionImpl.\(#function)")
                fatalError("Can not find or write DB Name to WMKeychainWrapper in WebimSessionImpl.\(#function)")
            }
            
            historyMetaInformationStoragePreferences = HistoryMetaInformationStoragePreferences(userDefaultsKey: userDefaultsKey)
            
            guard let readBeforeTimestamp = userDefaults?[WMKeychainWrapperMainPrefix.readBeforeTimestamp.rawValue] as? Int64? else {
                WebimInternalLogger.shared.log(
                    entry: "Wrong readBeforeTimestamp type in WebimSessionImpl.\(#function)")
                fatalError("Wrong readBeforeTimestamp type in WebimSessionImpl.\(#function)")
            }
            let sqlhistoryStorage = SQLiteHistoryStorage(dbName: dbName,
                                                         serverURL: serverURLString,
                                                         fileUrlCreator: fileUrlCreator,
                                                         reachedHistoryEnd: historyMetaInformationStoragePreferences.isHistoryEnded(),
                                                         queue: webimSdkQueue,
                                                         readBeforeTimestamp: readBeforeTimestamp ?? Int64(-1))
            historyStorage = sqlhistoryStorage
            
            let historyMajorVersion = historyStorage.getMajorVersion()
            if (userDefaults?[WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue] as? Int) != historyMajorVersion {
                if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
                    if let version = userDefaults[WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue] as? Int,
                        version < 5 {
                        transferDBFiles(for: userDefaultsKey)
                    }
                    
                    userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyRevision.rawValue)
                    userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyEnded.rawValue)
                    userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue)
                    userDefaults.updateValue(historyMajorVersion, forKey: WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue)
                    sqlhistoryStorage.updateDB()
                    WMKeychainWrapper.standard.setDictionary(userDefaults, forKey: userDefaultsKey)
                }
            }
        } else {
            guard let readBeforeTimestamp = userDefaults?[WMKeychainWrapperMainPrefix.readBeforeTimestamp.rawValue] as? Int64? else {
                WebimInternalLogger.shared.log(
                    entry: "Wrong readBeforeTimestamp type in WebimSessionImpl.\(#function)")
                fatalError("Wrong readBeforeTimestamp type in WebimSessionImpl.\(#function)")
            }
            historyStorage = MemoryHistoryStorage(readBeforeTimestamp: readBeforeTimestamp ?? Int64(-1))
            historyMetaInformationStoragePreferences = MemoryHistoryMetaInformationStorage()
        }
        
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        
        let webimActions = webimClient.getActions()
        let messageHolder = MessageHolder(accessChecker: accessChecker,
                                          remoteHistoryProvider: RemoteHistoryProvider(webimActions: webimActions,
                                                                                       historyMessageMapper: historyMessageMapper,
                                                                                       historyMetaInformationStorage: historyMetaInformationStoragePreferences),
                                          historyStorage: historyStorage,
                                          reachedEndOfRemoteHistory: historyMetaInformationStoragePreferences.isHistoryEnded())
        let messageStream = MessageStreamImpl(serverURLString: serverURLString,
                                              location: location,
                                              currentChatMessageFactoriesMapper: currentChatMessageMapper,
                                              sendingMessageFactory: SendingFactory(withServerURLString: serverURLString),
                                              operatorFactory: OperatorFactory(withServerURLString: serverURLString),
                                              surveyFactory: SurveyFactory(),
                                              accessChecker: accessChecker,
                                              webimActions: webimActions,
                                              messageHolder: messageHolder,
                                              messageComposingHandler: MessageComposingHandler(webimActions: webimActions,
                                                                                               queue: webimSdkQueue),
                                              locationSettingsHolder: LocationSettingsHolder(userDefaultsKey: userDefaultsKey))
        messageHolder.set(messageStream: messageStream)
        
        let historyPoller = HistoryPoller(withSessionDestroyer: sessionDestroyer,
                                          queue: webimSdkQueue,
                                          historyMessageMapper: historyMessageMapper,
                                          webimActions: webimActions,
                                          messageHolder: messageHolder,
                                          historyMetaInformationStorage: historyMetaInformationStoragePreferences)
        
        var locationStatusPoller: LocationStatusPoller?
        if let onlineStatusRequestFrequencyInMillis = onlineStatusRequestFrequencyInMillis {
            locationStatusPoller = LocationStatusPoller(withSessionDestroyer: sessionDestroyer,
                                                        queue: webimSdkQueue,
                                                        webimActions: webimActions,
                                                        messageStream: messageStream,
                                                        location: location,
                                                        onlineStatusRequestFrequencyInMillis: onlineStatusRequestFrequencyInMillis)
        }
        
        deltaCallback.set(messageStream: messageStream,
                          messageHolder: messageHolder,
                          historyPoller: historyPoller)
        
        sessionDestroyer.add() {
            webimClient.stop()
        }
        sessionDestroyer.add() {
            historyPoller.pause()
        }
        
        sessionDestroyer.add() {
            locationStatusPoller?.pause()
        }
        
        // Needed for message attachment secure download link generation.
        currentChatMessageMapper.set(fileUrlCreator: fileUrlCreator)
        historyMessageMapper.set(fileUrlCreator: fileUrlCreator)

        WebimInternalLogger.shared.log(
            entry: "WebimSession success created in WebimSessionImpl - \(#function)",
            verbosityLevel: .verbose)
        
        let session = WebimSessionImpl(accessChecker: accessChecker,
                                       sessionDestroyer: sessionDestroyer,
                                       webimClient: webimClient,
                                       historyPoller: historyPoller,
                                       locationStatusPoller: locationStatusPoller,
                                       messageStream: messageStream,
                                       sessionID: sessionID)
        
        WMSessionController.shared.add(session: session)
        
        return session
    }
    
    func getSessionID() -> String? {
        return sessionID
    }
    
    // MARK: Private methods
    
    private static func clearVisitorDataFor(userDefaultsKey: String) {
        deleteDBFileFor(userDefaultsKey: userDefaultsKey)
        if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyRevision.rawValue)
            userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyEnded.rawValue)
            WMKeychainWrapper.standard.setDictionary(userDefaults,
                                      forKey: userDefaultsKey)
        }
        _ = WMKeychainWrapper.removeObject(key: userDefaultsKey)
        WebimInternalLogger.shared.log(
            entry: "Clear visitor data in WebimSessionImpl - \(#function)",
            verbosityLevel: .verbose)
    }
    
    private static func deleteDBFileFor(userDefaultsKey: String) {
        if let dbName = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)?[WMKeychainWrapperMainPrefix.historyDBname.rawValue] as? String {
            let fileManager = FileManager.default
            let optionalLibraryDirectory = try? fileManager.url(
                for: .libraryDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            guard let libraryDirectory = optionalLibraryDirectory else {
                WebimInternalLogger.shared.log(
                    entry: "Error getting access to Library directory.")
                return
            }
            
            let dbURL = libraryDirectory.appendingPathComponent(dbName)
            
            do {
                try fileManager.removeItem(at: dbURL)
            } catch {
                WebimInternalLogger.shared.log(
                    entry: "Error deleting DB file at \(dbURL) or file doesn't exist.")
            }
        } else {
            WebimInternalLogger.shared.log(
                entry: "Failure delete DB File. DB name is nil")
        }
    }
    
    private static func transferDBFiles(for userDefaultsKey: String) {

        guard let dbName = WMKeychainWrapper.standard.dictionary(
            forKey: userDefaultsKey)?[WMKeychainWrapperMainPrefix.historyDBname.rawValue] as? String else {
            WebimInternalLogger.shared.log(
                entry: "Transfer DB files failure. DB name is nil.")
            return
        }

        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else {
                WebimInternalLogger.shared.log(
                    entry: "Transfer DB files failure.\nError getting access to Documents directory.")
            return
        }

        guard let libraryDirectory = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask).first else {
                WebimInternalLogger.shared.log(
                    entry: "Transfer DB files failure.\nError getting access to Library directory.")
                return
            }
        
        do {
            let dbFileURL = documentsDirectory.appendingPathComponent(dbName)
            let destanationURL = libraryDirectory.appendingPathComponent(dbName)
            let fileData = try Data(contentsOf: dbFileURL)
            try fileData.write(to: destanationURL)
        } catch {
            WebimInternalLogger.shared.log(
                entry: "Error reading DB file \(documentsDirectory.path): \(error.localizedDescription)")
            print("Error reading DB file \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
    
    private static func checkSavedSessionFor(userDefaultsKey: String,
                                             newProvidedVisitorFields: ProvidedVisitorFields?) {
        let newVisitorFieldsJSONString = newProvidedVisitorFields?.getJSONString()
        let previousVisitorFieldsJSONString = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)?[WMKeychainWrapperMainPrefix.visitorExt.rawValue] as? String
        
        var previousProvidedVisitorFields: ProvidedVisitorFields? = nil
        if let fields = previousVisitorFieldsJSONString {
            previousProvidedVisitorFields = ProvidedVisitorFields(withJSONString: fields)
        
            if (newProvidedVisitorFields == nil)
                || (previousProvidedVisitorFields?.getID() != newProvidedVisitorFields?.getID()) {
                clearVisitorDataFor(userDefaultsKey: userDefaultsKey)
            }
        }
        
        if newVisitorFieldsJSONString != previousVisitorFieldsJSONString {
            _ = WMKeychainWrapper.removeObject(key: userDefaultsKey)
            
            let newVisitorFieldsDictionary = [WMKeychainWrapperMainPrefix.visitorExt.rawValue: newVisitorFieldsJSONString]
            WMKeychainWrapper.standard.setDictionary(newVisitorFieldsDictionary as [String: Any],
                                      forKey: userDefaultsKey)
        }
    }
    
    private static func getDeviceID(withSuffix suffix: String) -> String? {
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapperName.guid.rawValue)
        let name = WMKeychainWrapperGUIDPrefix.uuid.rawValue + (suffix.isEmpty ? suffix : "-" + suffix)
        var uuidString: String? = userDefaults?[name] as? String
        
        if uuidString == String() || uuidString == nil {
            guard let currentIdentifierForVendor = UIDevice.current.identifierForVendor else {
                WebimInternalLogger.shared.log(
                    entry: "Incorrect DeviceID in WebimSessionImpl.\(#function)")
                return nil
            }
            uuidString = currentIdentifierForVendor.uuidString + (suffix.isEmpty ? suffix : "-" + suffix)
            if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapperName.guid.rawValue) {
                userDefaults[name] = uuidString
                WMKeychainWrapper.standard.setDictionary(userDefaults,
                                          forKey: WMKeychainWrapperName.guid.rawValue)
            } else {
                WMKeychainWrapper.standard.setDictionary([name: uuidString as Any], forKey: WMKeychainWrapperName.guid.rawValue)
            }
        }
        guard let deviceID = uuidString else {
            WebimInternalLogger.shared.log(
                entry: "DeviceID is nil in WebimSessionImpl.\(#function)")
            return nil
        }
        return deviceID
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
        locationStatusPoller?.resume()
        WebimInternalLogger.shared.log(
            entry: "Resume session in WebimSessionImpl - \(#function)",
            verbosityLevel: .verbose)
    }
    
    func pause() throws {
        if sessionDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        webimClient.pause()
        historyPoller.pause()
        locationStatusPoller?.pause()
        WebimInternalLogger.shared.log(
            entry: "Pause session in WebimSessionImpl - \(#function)",
            verbosityLevel: .verbose)
    }
    
    func destroy() throws {
        if sessionDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        sessionDestroyer.destroy()
        WebimInternalLogger.shared.log(
            entry: "Destroy session in WebimSessionImpl - \(#function)",
            verbosityLevel: .verbose)
    }
    
    func destroyWithClearVisitorData() throws {
        if sessionDestroyer.isDestroyed() {
            WebimInternalLogger.shared.log(
                entry: "Session already destroyed in WebimSessionImpl - \(#function)",
                verbosityLevel: .verbose)
            return
        }
        
        try checkAccess()
        
        webimClient.set(deviceToken: "none")
        sleep(2)
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
    
    func setRequestHeader(key: String, value: String) throws {
        try checkAccess()
        
        webimClient.setRequestHeader(key: key, value: value)
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
        self.lastRevision = historyMetaInformationStorage.getRevision()
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
        guard let historySinceCompletionHandler = historySinceCompletionHandler else {
            WebimInternalLogger.shared.log(
                entry: "Creating History Since Completion Handler failure in WebimSessionImpl - \(#function)")
            return
        }
        
        let uptime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
        if (uptime - lastPollingTime) > TimeInterval.historyPolling.rawValue {
            requestHistory(since: lastRevision,
                           completion: historySinceCompletionHandler)
        } else {
            if !self.hasHistoryRevision {
                // Setting next history polling in TimeInterval.HISTORY_POLL after lastPollingTime.
            
                let dispatchTime = DispatchTime(uptimeNanoseconds: (UInt64((lastPollingTime + TimeInterval.historyPolling.rawValue) * 1_000_000) - UInt64((uptime) * 1_000_000)))
            
                dispatchWorkItem = DispatchWorkItem() { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                
                    self.requestHistory(since: self.lastRevision,
                                        completion: historySinceCompletionHandler)
                }
                
                guard let dispatchWorkItem = dispatchWorkItem else {
                    WebimInternalLogger.shared.log(
                        entry: "Creating Dispatch Work Item failure in WebimSessionImpl.\(#function)")
                    return
                }
            
                queue.asyncAfter(deadline: dispatchTime,
                                 execute: dispatchWorkItem)
            }
        }
    }
    
    func set(hasHistoryRevision: Bool) {
        self.hasHistoryRevision = hasHistoryRevision
    }
    
    func updateReadBeforeTimestamp(timestamp: Int64, byWMKeychainWrapperKey userDefaultsKey: String) {
        self.messageHolder.updateReadBeforeTimestamp(timestamp: timestamp)
        if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[WMKeychainWrapperMainPrefix.readBeforeTimestamp.rawValue] = timestamp
            WMKeychainWrapper.standard.setDictionary(userDefaults, forKey: userDefaultsKey)
        }
    }
    
    func getReadBeforeTimestamp(byWMKeychainWrapperKey userDefaultsKey: String) -> Int64 {
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)
        guard let readBeforeTimestamp = userDefaults?[WMKeychainWrapperMainPrefix.readBeforeTimestamp.rawValue] as? Int64 else {
            WebimInternalLogger.shared.log(
                entry: "Wrong readBeforeTimestamp type in WebimSessionImpl.\(#function)")
            return Int64(-1)
        }
        return readBeforeTimestamp
    }

    public func requestHistory(since: String) {
        if self.lastRevision == nil || self.lastRevision != since {
            guard let historySinceCompletionHandler = historySinceCompletionHandler else {
                WebimInternalLogger.shared.log(
                    entry: "History Since Completion Handler is nil in WebimSessionImpl.\(#function)",
                    logType: .networkRequest)
                return
            }
            requestHistory(since: lastRevision, completion: historySinceCompletionHandler)
        }
    }

    public func insertMessageInDB(message: MessageImpl) {
        guard !sessionDestroyer.isDestroyed() else {
            WebimInternalLogger.shared.log(
                entry: "Current session is destroyed in WebimSessionImpl - \(#function)")
            return
        }
        var messages = [MessageImpl]()
        messages.append(message)
        messageHolder.receiveHistoryUpdateWith(messages: messages, deleted: Set<String>()) {
            [weak self] in
            self?.historyMetaInformationStorage.set(revision: self?.lastRevision)
        }
        WebimInternalLogger.shared.log(
            entry: "Insert message \(message.getText()) in DB",
            verbosityLevel: .verbose)
    }

    public func deleteMessageFromDB(message: String) {
        guard !sessionDestroyer.isDestroyed() else {
            WebimInternalLogger.shared.log(
                entry: "Current session is destroyed")
            return
        }
        var deleted = Set<String>()
        deleted.insert(message)
        messageHolder.receiveHistoryUpdateWith(messages: [MessageImpl](), deleted: deleted) {
            [weak self] in
            self?.historyMetaInformationStorage.set(revision: self?.lastRevision)
        }
        WebimInternalLogger.shared.log(
            entry: "Delete message \(message) in DB",
            verbosityLevel: .verbose)
    }
    
    // MARK: Private methods
    
    private func createHistorySinceCompletionHandler() -> (_ messageList: [MessageImpl], _ deleted: Set<String>, _ hasMore: Bool, _ isInitial: Bool, _ revision: String?) -> () {
        return { [weak self] (messageList: [MessageImpl], deleted: Set<String>, hasMore: Bool, isInitial: Bool, revision: String?) in
            guard let `self` = self,
                !self.sessionDestroyer.isDestroyed() else {
                    WebimInternalLogger.shared.log(
                        entry: "Session destroyed in WebimSessionImpl - \(#function)")
                return
            }
            
            self.lastPollingTime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
            if revision != nil {
                self.lastRevision = revision
            }
            
            if isInitial && !hasMore {
                self.messageHolder.set(endOfHistoryReached: true)
                self.historyMetaInformationStorage.set(historyEnded: true)
            }
            
            self.messageHolder.receiveHistoryUpdateWith(messages: messageList,
                                                        deleted: deleted,
                                                        completion: { [weak self] in
                                                            // Revision is saved after history is saved only.
                                                            // I.e. if history will not be saved, then revision will not be overwritten. History will be re-requested.
                                                            self?.historyMetaInformationStorage.set(revision: self?.lastRevision)
            })
            
            if self.running != true {
                if !isInitial
                    && hasMore {
                    self.lastPollingTime = -TimeInterval.historyPolling.rawValue
                }
                
                return
            }
            
            if !isInitial && hasMore {
                self.requestHistory(since: self.lastRevision,
                                    completion: self.createHistorySinceCompletionHandler())
            } else {
                if !self.hasHistoryRevision {
                    self.dispatchWorkItem = DispatchWorkItem() { [weak self] in
                        guard let `self` = self, self.hasHistoryRevision == false else {
                            return
                        }
                        self.requestHistory(since: self.lastRevision,
                                            completion: self.createHistorySinceCompletionHandler())
                    
                    
                    }
                    guard let dispatchWorkItem = self.dispatchWorkItem else {
                        WebimInternalLogger.shared.log(
                            entry: "Creating Dispatch Work Item failure in WebimSessionImpl.\(#function)")
                        return
                    }
                    
                    let interval = Int(TimeInterval.historyPolling.rawValue)
                    self.queue.asyncAfter(deadline: (.now() + .milliseconds(interval)),
                                          execute: dispatchWorkItem)
                }
            }
        }
    }
    
    private func requestHistory(since: String?,
                                completion: @escaping (_ messageList: [MessageImpl], _ deleted: Set<String>, _ hasMore: Bool, _ isInitial: Bool, _ revision: String?) -> ()) {
        webimActions.requestHistory(since: since) { data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let historySinceResponseDictionary = json as? [String: Any?] {
                    let historySinceResponse = HistorySinceResponse(jsonDictionary: historySinceResponseDictionary)
                    
                    var deletes = Set<String>()
                    var messageChanges = [MessageItem]()
                    
                    if let messages = historySinceResponse.getData()?.getMessages() {
                        for message in messages {
                            if message.isDeleted() {
                                if let id = message.getServerSideID() {
                                    deletes.insert(id)
                                }
                            } else {
                                messageChanges.append(message)
                            }
                        }
                    }
                    WebimInternalLogger.shared.log(
                        entry: "Request history success. New \(messageChanges.count) messages",
                        verbosityLevel: .verbose,
                        logType: .networkRequest)
                    completion(self.historyMessageMapper.mapAll(messages: messageChanges), deletes, (historySinceResponse.getData()?.isHasMore() == true), (since == nil), historySinceResponse.getData()?.getRevision())
                }
            } else {
                WebimInternalLogger.shared.log(
                    entry: "Request history completed. Data is nil",
                    logType: .networkRequest)
                completion([MessageImpl](), Set<String>(), false, (since == nil), since)
            }
        }
        WebimInternalLogger.shared.log(
            entry: "Request history",
            verbosityLevel: .verbose,
            logType: .networkRequest)
    }
}

// MARK: -
/**
 - author:
 Nikita Kaberov
 - copyright:
 2021 Webim
 */
final class LocationStatusPoller {
    // MARK: - Properties
    private let queue: DispatchQueue
    private let sessionDestroyer: SessionDestroyer
    private let webimActions: WebimActions
    private let messageStream: MessageStreamImpl
    private var dispatchWorkItem: DispatchWorkItem?
    private var locationStatusCompletionHandler: ((_ locationStatusResponse: LocationStatusResponse?) -> ())?
    private let location: String
    private var lastPollingTime: Int64
    private let onlineStatusRequestFrequencyInMillis: Int64
    private var running: Bool?
    
    // MARK: - Initialization
    init(withSessionDestroyer sessionDestroyer: SessionDestroyer,
         queue: DispatchQueue,
         webimActions: WebimActions,
         messageStream: MessageStreamImpl,
         location: String,
         onlineStatusRequestFrequencyInMillis: Int64) {
        self.sessionDestroyer = sessionDestroyer
        self.queue = queue
        self.webimActions = webimActions
        self.messageStream = messageStream
        self.location = location
        self.onlineStatusRequestFrequencyInMillis = onlineStatusRequestFrequencyInMillis
        self.lastPollingTime = -onlineStatusRequestFrequencyInMillis
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
        
        locationStatusCompletionHandler = createLocationStatusCompletionHandler()
        guard locationStatusCompletionHandler != nil else {
            WebimInternalLogger.shared.log(
                entry: "Creating Location Status Completion Handler failure in WebimSessionImpl.\(#function)")
            return
        }
        
        let uptime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
        if uptime - lastPollingTime > onlineStatusRequestFrequencyInMillis {
            requestLocationStatus(location: location)
        } else {
            let dispatchTime = DispatchTime(uptimeNanoseconds: (UInt64((lastPollingTime + onlineStatusRequestFrequencyInMillis) * 1_000_000) - UInt64((uptime) * 1_000_000)))
            
            dispatchWorkItem = DispatchWorkItem() { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.requestLocationStatus(location: self.location)
            }
                
            guard let dispatchWorkItem = dispatchWorkItem else {
                WebimInternalLogger.shared.log(
                    entry: "Creating Dispatch Work Item failure in WebimSessionImpl.\(#function)")
                return
            }
            
            queue.asyncAfter(deadline: dispatchTime,
                             execute: dispatchWorkItem)
        }
    }
    
    // MARK: Private methods
    
    private func createLocationStatusCompletionHandler() -> (_ locationStatusResponse: LocationStatusResponse?) -> () {
        return { [weak self] (locationStatusResponse: LocationStatusResponse?) in
            guard let `self` = self,
                !self.sessionDestroyer.isDestroyed() else {
                return
            }
            
            self.lastPollingTime = Int64(ProcessInfo.processInfo.systemUptime) * 1000
            
            if self.running != true {
                self.lastPollingTime = -self.onlineStatusRequestFrequencyInMillis
                return
            }
            self.dispatchWorkItem = DispatchWorkItem() { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.requestLocationStatus(location: self.location)
            }
            guard let dispatchWorkItem = self.dispatchWorkItem else {
                WebimInternalLogger.shared.log(
                    entry: "Creating Dispatch Work Item failure in WebimSessionImpl.\(#function)")
                return
            }
                    
            let interval = Int(self.onlineStatusRequestFrequencyInMillis)
            self.queue.asyncAfter(deadline: (.now() + .milliseconds(interval)),
                                  execute: dispatchWorkItem)
        }
    }

    public func requestLocationStatus(location: String) {
        guard let locationStatusCompletionHandler = self.locationStatusCompletionHandler else {
            WebimInternalLogger.shared.log(
                entry: "Location Status Completion Handler is nil in WebimSessionImpl.\(#function)")
            return
        }
        requestLocationStatus(location: location,
                              completion: locationStatusCompletionHandler)
    }
    
    private func requestLocationStatus(location: String,
                                       completion: @escaping (_ locationStatusResponse: LocationStatusResponse?) -> ()) {
        webimActions.getOnlineStatus(location: location) { data in
            self.queue.async {
                
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: [])
                    if let locationStatusResponseDictionary = json as? [String: Any?] {
                        let locationStatusResponse = LocationStatusResponse(jsonDictionary: locationStatusResponseDictionary)
                        completion(locationStatusResponse)
                        WebimInternalLogger.shared.log(
                            entry: "Request location status success complete.",
                            logType: .networkRequest)
                        if let onlineStatusString = locationStatusResponse.getOnlineStatus(),
                           let onlineStatus = OnlineStatusItem(rawValue: onlineStatusString) {
                            self.messageStream.onOnlineStatusChanged(to: onlineStatus)
                        }
                    }
                } else {
                    WebimInternalLogger.shared.log(
                        entry: "Request location status complete. Data is nil",
                        logType: .networkRequest)
                    completion(nil)
                }
            }
        }
        WebimInternalLogger.shared.log(
            entry: "Request location status",
            verbosityLevel: .verbose,
            logType: .networkRequest)
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
    init(withWMKeychainWrapperKey userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    // MARK: - Methods
    // MARK: SessionParametersListener methods
    func onSessionParametersChanged(visitorFieldsJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData) {
        if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[WMKeychainWrapperMainPrefix.visitor.rawValue] = visitorFieldsJSONString
            userDefaults[WMKeychainWrapperMainPrefix.sessionID.rawValue] = sessionID
            userDefaults[WMKeychainWrapperMainPrefix.pageID.rawValue] = authorizationData.getPageID()
            userDefaults[WMKeychainWrapperMainPrefix.authorizationToken.rawValue] = authorizationData.getAuthorizationToken()
            WMKeychainWrapper.standard.setDictionary(userDefaults,
                                      forKey: userDefaultsKey)
        } else {
            WMKeychainWrapper.standard.setDictionary(
                [WMKeychainWrapperMainPrefix.visitor.rawValue: visitorFieldsJSONString,
                 WMKeychainWrapperMainPrefix.sessionID.rawValue: sessionID,
                 WMKeychainWrapperMainPrefix.pageID.rawValue: authorizationData.getPageID(),
                 WMKeychainWrapperMainPrefix.authorizationToken.rawValue: authorizationData.getAuthorizationToken() as Any],
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
    private let notFatalErrorHandler: NotFatalErrorHandler?
    private var sessionDestroyer: SessionDestroyer
    
    // MARK: - Initialization
    init(sessionDestroyer: SessionDestroyer,
         internalErrorListener: InternalErrorListener?,
         notFatalErrorHandler: NotFatalErrorHandler?) {
        self.sessionDestroyer = sessionDestroyer
        self.internalErrorListener = internalErrorListener
        self.notFatalErrorHandler = notFatalErrorHandler
    }
    
    // MARK: - Methods
    // MARK: InternalErrorListener protocol methods
    func on(error: String) {
        if !sessionDestroyer.isDestroyed() {
            sessionDestroyer.destroy()
            
            internalErrorListener?.on(error: error)
        }
    }
    
    func onNotFatal(error: NotFatalErrorType) {
        if !sessionDestroyer.isDestroyed() {
            notFatalErrorHandler?.on(error: WebimNotFatalErrorImpl(errorType: error))
        }
    }
    
    func connectionStateChanged(connected: Bool) {
        if !sessionDestroyer.isDestroyed() {
            notFatalErrorHandler?.connectionStateChanged(connected: connected)
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
    
    func onNotFatal(error: NotFatalErrorType) {
    }
    
    func connectionStateChanged(connected: Bool) {
    }
    
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
            return .accountBlocked
        case WebimInternalError.visitorBanned.rawValue:
            return .visitorBanned
        case WebimInternalError.wrongProvidedVisitorFieldsHashValue.rawValue:
            return .wrongProvidedVisitorHash
        case WebimInternalError.providedVisitorFieldsExpired.rawValue:
            return .providedVisitorFieldsExpired
        case WebimInternalError.wrongInit.rawValue:
            return .initializationFailed
        default:
            return .unknown
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
        if let historyEnded = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)?[WMKeychainWrapperMainPrefix.historyEnded.rawValue] as? Bool {
            return historyEnded
        }
        
        return false
    }
    
    func set(historyEnded: Bool) {
        if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[WMKeychainWrapperMainPrefix.historyEnded.rawValue] = historyEnded
            WMKeychainWrapper.standard.setDictionary(userDefaults,
                                      forKey: userDefaultsKey)
        } else {
            WMKeychainWrapper.standard.setDictionary([WMKeychainWrapperMainPrefix.historyEnded.rawValue: historyEnded],
                                           forKey: userDefaultsKey)
        }
    }
    
    func set(revision: String?) {
        if let revision = revision {
            if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey) {
                userDefaults[WMKeychainWrapperMainPrefix.historyRevision.rawValue] = revision
                WMKeychainWrapper.standard.setDictionary(userDefaults,
                                          forKey: userDefaultsKey)
            } else {
                WMKeychainWrapper.standard.setDictionary([WMKeychainWrapperMainPrefix.historyRevision.rawValue: revision],
                                               forKey: userDefaultsKey)
            }
        }
    }
    
    func getRevision() -> String? {
        guard let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey),
            let revision = userDefaults[WMKeychainWrapperMainPrefix.historyRevision.rawValue] as? String? else {
                return nil
        }
        return revision
    }
    
}
