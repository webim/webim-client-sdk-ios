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
fileprivate enum UserDefaultsName: String {
    case main = "ru.webim.WebimClientSDKiOS.faq"
}
fileprivate enum UserDefaultsMainPrefix: String {
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
        
        let userDefaults = UserDefaults.standard.dictionary(forKey: UserDefaultsName.main.rawValue)
        
        let cache = FAQSQLiteHistoryStorage(dbName: "faqcache.db", queue: DispatchQueue.global(qos: .userInteractive))
        
        let historyMajorVersion = cache.getMajorVersion()
        if (userDefaults?[UserDefaultsMainPrefix.historyMajorVersion.rawValue] as? Int) != historyMajorVersion {
            if var userDefaults = UserDefaults.standard.dictionary(forKey: UserDefaultsName.main.rawValue) {
                userDefaults.removeValue(forKey: UserDefaultsMainPrefix.historyMajorVersion.rawValue)
                userDefaults.updateValue(historyMajorVersion, forKey: UserDefaultsMainPrefix.historyMajorVersion.rawValue)
                cache.updateDB()
                UserDefaults.standard.setValue(userDefaults,
                                               forKey: UserDefaultsName.main.rawValue)
            }
        }
        
        return FAQImpl(accessChecker: accessChecker,
                       faqDestroyer: faqDestroyer,
                       faqClient: faqClient,
                       cache: cache)
    }
}

// MARK: - FAQ
extension FAQImpl: FAQ {
    
    func getCategory(id: String, completionHandler: @escaping (Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
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
                completionHandler(.failure(.ERROR))
            }
        }
    }
    
    func getCategoriesForApplication(completionHandler: @escaping (Result<[String], FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
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
                    completionHandler(.failure(.ERROR))
                }
            }
        } else {
            completionHandler(.failure(.ERROR))
        }
    }
    
    func getCachedCategory(id: String, completionHandler: @escaping (Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
            return
        }
        
        self.cache.get(categoryId: id) { data in
            if let data = data {
                completionHandler(.success(FAQCategoryItem(jsonDictionary: data)))
            } else {
                completionHandler(.failure(.ERROR))
            }
            
        }
    }
    
    func getStructure(id: String, completionHandler: @escaping (Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
            return
        }
        faqClient.getActions().getStructure(categoryId: id) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqStructureDictionary = json as? [String: Any?] {
                let faqStructure = FAQStructureItem(jsonDictionary: faqStructureDictionary)
                    
                completionHandler(.success(faqStructure))
            } else {
                completionHandler(.failure(.ERROR))
            }
        }
        
    }
    
    func getItem(id: String, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
            return
        }
        
        faqClient.getActions().getItem(itemId: id) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []),
                let faqItemDictionary = json as? [String: Any?] {
                let faqItem = FAQItemItem(jsonDictionary: faqItemDictionary)
                    
                completionHandler(.success(faqItem))
            } else {
                completionHandler(.failure(.ERROR))
            }
        }
    }
    
    func like(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
            return
        }
        
        faqClient.getActions().like(itemId: item.getID()) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []) as? [String: Any?],
                json["result"] as? String == "ok" {
                completionHandler(.success(FAQItemItem(faqItem: item, userRate: .LIKE)))
            } else {
                completionHandler(.failure(.ERROR))
            }
        }
    }
    
    func dislike(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void) {
        do {
            try accessChecker.checkAccess()
        } catch {
            completionHandler(.failure(.ERROR))
            return
        }
        
        faqClient.getActions().dislike(itemId: item.getID()) { data in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: []) as? [String: Any?],
                json["result"] as? String == "ok" {
                completionHandler(.success(FAQItemItem(faqItem: item, userRate: .DISLIKE)))
            } else {
                completionHandler(.failure(.ERROR))
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
            completionHandler(.failure(.ERROR))
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
                completionHandler(.failure(.ERROR))
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
