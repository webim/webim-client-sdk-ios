//
//  FAQActions.swift
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

/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
class FAQActions {
    
    // MARK: - Constants
    enum Parameter: String {
        case application = "app"
        case categoryId = "categoryid"
        case departmentKey = "department-key"
        case itemId = "itemid"
        case language = "lang"
        case limit = "limit"
        case open = "open"
        case platform = "platform"
        case query = "query"
        case userId = "userid"
    }
    enum ServerPathSuffix: String {
        case item = "/services/faq/v1/item"
        case category = "/services/faq/v1/category"
        case categories = "/webim/api/v1/faq/category"
        case structure = "/services/faq/v1/structure"
        case search = "/services/faq/v1/search"
        case like = "/services/faq/v1/like"
        case dislike = "/services/faq/v1/dislike"
        case track = "/services/faq/v1/track"
    }
    
    // MARK: - Properties
    private let baseURL: String
    private let faqRequestLoop: FAQRequestLoop
    private static let deviceID = ClientSideID.generateClientSideID()
    
    // MARK: - Initialization
    init(baseURL: String,
         faqRequestLoop: FAQRequestLoop) {
        self.baseURL = baseURL
        self.faqRequestLoop = faqRequestLoop
    }
    
    // MARK: - Methods
    
    func getItem(itemId: String,
                 completion: @escaping (_ faqItem: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.item.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getCategory(categoryId: String,
                     completion: @escaping (_ faqCategory: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.category.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getCategoriesFor(application: String,
                          language: String,
                          departmentKey: String,
                          completion: @escaping (_ faqCategories: Data?) throws -> ()) {
        let dataToPost = [Parameter.application.rawValue: application,
                          Parameter.platform.rawValue: "ios",
                          Parameter.language.rawValue: language,
                          Parameter.departmentKey.rawValue: departmentKey] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.categories.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func getStructure(categoryId: String,
                      completion: @escaping (_ faqStructure: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.structure.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func search(query: String,
                categoryId: String,
                limit: Int,
                completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: categoryId,
                          Parameter.query.rawValue: query,
                          Parameter.limit.rawValue: limit] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.search.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func like(itemId: String,
              completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.like.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func dislike(itemId: String,
                 completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.userId.rawValue: FAQActions.deviceID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.dislike.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCompletionHandler: completion))
    }
    
    func track(itemId: String,
               openFrom: FAQItemSource) {
        let source: String
        switch openFrom {
            case .search:
                source = "search"
            case .tree:
                source = "tree"
        }
        let dataToPost = [Parameter.itemId.rawValue: itemId,
                          Parameter.open.rawValue: source] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.track.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString))
    }
}
