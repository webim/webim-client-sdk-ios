//
//  FAQImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 07.02.19.
//  Copyright © 2019 Webim. All rights reserved.
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

// MARK: - Constants
fileprivate enum WMKeychainWrapperName: String {
    case main = "ru.webim.WebimClientSDKiOS.faq"
}
fileprivate enum WMKeychainWrapperMainPrefix: String {
    case historyMajorVersion = "history_major_version"
}

// MARK: -
/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class FAQImpl {
    
    // MARK: - Properties
    private var accessChecker: FAQAccessChecker
    private var clientStarted = false
    private var faqDestroyer: FAQDestroyer
    private var faqClient: FAQClient
    private var cache: FAQSQLiteHistoryStorage
    
    // MARK: - Initialization
    private init(accessChecker: FAQAccessChecker,
                 faqDestroyer: FAQDestroyer,
                 faqClient: FAQClient,
                 cache: FAQSQLiteHistoryStorage) {
        self.accessChecker = accessChecker
        self.faqDestroyer = faqDestroyer
        self.faqClient = faqClient
        self.cache = cache
    }
    
    // MARK: - Methods
    
    static func newInstanceWith(accountName: String,
                                application: String?,
                                departmentKey: String?,
                                language: String?) -> FAQImpl {
        
        let faqDestroyer = FAQDestroyer()
        
        let serverURLString = InternalUtils.createServerURLStringBy(accountName: accountName)
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        let faqClient = FAQClientBuilder()
            .set(baseURL: serverURLString)
            .set(completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor(faqDestroyer: faqDestroyer,
                                                                              queue: queue))
            .set(application: application)
            .set(departmentKey: departmentKey)
            .set(language: language)
            .build() as FAQClient
        
        let accessChecker = FAQAccessChecker(thread: Thread.current,
                                             faqDestroyer: faqDestroyer)
        
        faqDestroyer.add() {
            faqClient.stop()
        }
        
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapperName.main.rawValue)
        
        let cache = FAQSQLiteHistoryStorage(dbName: "faqcache.db", queue: DispatchQueue.global(qos: .userInteractive))
        
        let historyMajorVersion = cache.getMajorVersion()
        if (userDefaults?[WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue] as? Int) != historyMajorVersion {
            if var userDefaults = WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapperName.main.rawValue) {
                if let version = userDefaults[WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue] as? Int {
                    if version < 3 {
                        deleteDBFileFor()
                    } else if version < 5 {
                        transferDBFiles()
                    }
                }
                userDefaults.removeValue(forKey: WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue)
                userDefaults.updateValue(historyMajorVersion, forKey: WMKeychainWrapperMainPrefix.historyMajorVersion.rawValue)
                cache.updateDB()
                WMKeychainWrapper.standard.setDictionary(userDefaults,
                                               forKey: WMKeychainWrapperName.main.rawValue)
            }
        }
        
        return FAQImpl(accessChecker: accessChecker,
                       faqDestroyer: faqDestroyer,
                       faqClient: faqClient,
                       cache: cache)
    }
    
    private static func deleteDBFileFor() {
        let fileManager = FileManager.default
        let optionalDocumentsDirectory = try? fileManager.url(for: .documentDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: false)
        guard let documentsDirectory = optionalDocumentsDirectory else {
            WebimInternalLogger.shared.log(entry: "Error getting access to Documents directory.",
            verbosityLevel: .verbose)
            return
        }
        let dbURL = documentsDirectory.appendingPathComponent("faqcache.db")
            
        do {
            try fileManager.removeItem(at: dbURL)
        } catch {
            WebimInternalLogger.shared.log(entry: "Error deleting DB file at \(dbURL) or file doesn't exist.",
                                           verbosityLevel: .verbose)
        }
    }
    
    private static func transferDBFiles() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first,
            let libraryDirectory = FileManager.default.urls(for: .libraryDirectory,
                                                            in: .userDomainMask).first
            else { return }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let dbFilesURLs = fileURLs.filter{ $0.pathExtension == "db" }
            for dbFileURL in dbFilesURLs {
                let fileName = dbFileURL.lastPathComponent
                let fileData = try Data(contentsOf: dbFileURL)
                let destanationURL = libraryDirectory.appendingPathComponent(fileName)
                try fileData.write(to: destanationURL)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
}

// MARK: - FAQ
extension FAQImpl: FAQ {
    
    func getCategory(id: String, completionHandler: @escaping (Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        faqClient.getActions().getCategory(categoryId: id) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqCategoryDictionary = json as? [String: Any?] {
                let faqCategory = FAQCategoryItem(jsonDictionary: faqCategoryDictionary)
                completionHandler(.success(faqCategory))
                    
                self.cache.insert(categoryId: faqCategory.getID(), categoryDictionary: faqCategoryDictionary)
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func getCategoriesForApplication(completionHandler: @escaping (Result<[String], FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        if let application = faqClient.getApplication(),
            let departmentKey = faqClient.getDepartmentKey(),
            let language = faqClient.getLanguage() {
            faqClient.getActions().getCategoriesFor(application: application, language: language, departmentKey: departmentKey) { data in
                if let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: []),
                    let faqCategoriesIDArray = json as? [Int] {
                    let ids = faqCategoriesIDArray.map { i in String(i) }
                    completionHandler(.success(ids))
                } else {
                    completionHandler(.failure(.error))
                }
            }
        } else {
            completionHandler(.failure(.error))
        }
    }
    
    func getCachedCategory(id: String, completionHandler: @escaping (Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        self.cache.get(categoryId: id) { data in
            if let data = data {
                completionHandler(.success(FAQCategoryItem(jsonDictionary: data)))
            } else {
                completionHandler(.failure(.error))
            }
            
        }
    }
    
    func getStructure(id: String, completionHandler: @escaping (Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        faqClient.getActions().getStructure(categoryId: id) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqStructureDictionary = json as? [String: Any?] {
                let faqStructure = FAQStructureItem(jsonDictionary: faqStructureDictionary)
                    
                completionHandler(.success(faqStructure))
                
                self.cache.insert(structureId: id, structureDictionary: faqStructureDictionary)
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func getCachedStructure(id: String, completionHandler: @escaping (Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        self.cache.get(structureId: id) { data in
            if let data = data {
                completionHandler(.success(FAQStructureItem(jsonDictionary: data)))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func getItem(id: String, openFrom: FAQItemSource? = nil, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        if let openFrom = openFrom {
            faqClient.getActions().track(itemId: id, openFrom: openFrom)
        }
        
        faqClient.getActions().getItem(itemId: id) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqItemDictionary = json as? [String: Any?] {
                let faqItem = FAQItemItem(jsonDictionary: faqItemDictionary)
                    
                completionHandler(.success(faqItem))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func getCachedItem(id: String, openFrom: FAQItemSource? = nil, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        if let openFrom = openFrom {
            faqClient.getActions().track(itemId: id, openFrom: openFrom)
        }
        self.cache.get(itemId: id) { data in
            if let data = data {
                completionHandler(.success(FAQItemItem(jsonDictionary: data)))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func like(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        faqClient.getActions().like(itemId: item.getID()) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []) as? [String: Any?],
                json["result"] as? String == "ok" {
                completionHandler(.success(FAQItemItem(faqItem: item, userRate: .like)))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func dislike(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        
        faqClient.getActions().dislike(itemId: item.getID()) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []) as? [String: Any?],
                json["result"] as? String == "ok" {
                completionHandler(.success(FAQItemItem(faqItem: item, userRate: .dislike)))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    func search(query: String,
                category: String,
                limitOfItems: Int,
                completionHandler: @escaping (Result<[FAQSearchItem], FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.error))
            return
        }
        faqClient.getActions().search(query: query, categoryId: category, limit: limitOfItems) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqItemsArray = json as? [[String: Any?]] {
                var items = [FAQSearchItem]()
                for item in faqItemsArray {
                    items.append(FAQSearchItemItem(jsonDictionary: item))
                }
                completionHandler(.success(items))
            } else {
                completionHandler(.failure(.error))
            }
        }
    }
    
    
    func resume() throws {
        try checkAccess()
        
        if !clientStarted {
            faqClient.start()
            clientStarted = true
        }
        
        faqClient.resume()
    }
    
    func pause() throws {
        if faqDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        faqClient.pause()
    }
    
    func destroy() throws {
        if faqDestroyer.isDestroyed() {
            return
        }
        
        try checkAccess()
        
        faqDestroyer.destroy()
    }
    
    // MARK: Private methods
    private func checkAccess() throws {
        try accessChecker.checkAccess()
    }
    
}
