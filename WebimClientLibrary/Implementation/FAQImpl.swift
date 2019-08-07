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
    
    static func newInstanceWith(accountName: String) -> FAQImpl {
        
        let faqDestroyer = FAQDestroyer()
        
        let serverURLString = InternalUtils.createServerURLStringBy(accountName: accountName)
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        let faqClient = FAQClientBuilder()
            .set(baseURL: serverURLString)
            .set(completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor(faqDestroyer: faqDestroyer,
                                                                              queue: queue))
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
    func getCategory(id: Int, completion: @escaping (FAQCategory?) -> ()) throws {
        try accessChecker.checkAccess()
        
        faqClient.getActions().getCategory(categoryId: id) { data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let faqCategoryDictionary = json as? [String: Any?] {
                    let faqCategory = FAQCategoryItem(jsonDictionary: faqCategoryDictionary)
                    completion(faqCategory)
                    
                    self.cache.insert(categoryId: faqCategory.getID(), categoryDictionary: faqCategoryDictionary)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getCachedCategory(id: Int, completion: @escaping (FAQCategory?) -> ()) throws {
        try accessChecker.checkAccess()
        
        self.cache.get(categoryId: id) { data in
            if let data = data {
                completion(FAQCategoryItem(jsonDictionary: data))
            } else {
                completion(nil)
            }
            
        }
    }
    
    func getStructure(id: Int, completion: @escaping (FAQStructure?) -> ()) throws {
        try accessChecker.checkAccess()
        faqClient.getActions().getStructure(categoryId: id) { data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let faqStructureDictionary = json as? [String: Any?] {
                    let faqStructure = FAQStructureItem(jsonDictionary: faqStructureDictionary)
                    
                    completion(faqStructure)
                }
            } else {
                completion(nil)
            }
        }
        
    }
    
    func getItem(id: String, completion: @escaping (FAQItem?) -> ()) throws {
        try accessChecker.checkAccess()
        
        faqClient.getActions().getItem(itemId: id) { data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let faqItemDictionary = json as? [String: Any?] {
                    let faqItem = FAQItemItem(jsonDictionary: faqItemDictionary)
                    
                    completion(faqItem)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func like(item: FAQItem) throws {
        try accessChecker.checkAccess()
        
        faqClient.getActions().like(itemId: item.getID())
    }
    
    func dislike(item: FAQItem) throws {
        try accessChecker.checkAccess()
        
        faqClient.getActions().dislike(itemId: item.getID())
    }
    
    func search(query: String,
                category: Int,
                limitOfItems: Int,
                completion: @escaping (_ result: [FAQSearchItem]) -> ()) throws {
        try accessChecker.checkAccess()
        
        faqClient.getActions().search(query: query, categoryId: category, limit: limitOfItems) { data in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data,
                                                             options: [])
                if let faqItemsArray = json as? [[String: Any?]] {
                    var items = [FAQSearchItem]()
                    for item in faqItemsArray {
                        items.append(FAQSearchItemItem(jsonDictionary: item))
                    }
                    completion(items)
                } else {
                    completion([FAQSearchItem]())
                }
            } else {
                completion([FAQSearchItem]())
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
