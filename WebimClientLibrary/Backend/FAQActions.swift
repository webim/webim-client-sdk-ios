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
        case itemId = "itemid"
        case categoryId = "categoryid"
    }
    enum ServerPathSuffix: String {
        case item = "/services/faq/v1/item"
        case category = "/services/faq/v1/category"
        case structure = "/services/faq/v1/structure"
    }
    
    // MARK: - Properties
    private let baseURL: String
    private let faqRequestLoop: FAQRequestLoop
    
    // MARK: - Initialization
    init(baseURL: String,
         faqRequestLoop: FAQRequestLoop) {
        self.baseURL = baseURL
        self.faqRequestLoop = faqRequestLoop
    }
    
    // MARK: - Methods
    
    func getItem(itemId: String,
                 completion: @escaping (_ faqItem: Data?) throws -> ()) {
        let dataToPost = [Parameter.itemId.rawValue: itemId] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.item.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqItemRequestCompletionHandler: completion))
    }
    
    func getCategory(categoryId: Int,
                     completion: @escaping (_ faqCategory: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: String(categoryId)] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.category.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqCategoryRequestCompletionHandler: completion))
    }
    
    func getStructure(categoryId: Int,
                      completion: @escaping (_ faqStructure: Data?) throws -> ()) {
        let dataToPost = [Parameter.categoryId.rawValue: String(categoryId)] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.structure.rawValue
        
        faqRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                     primaryData: dataToPost,
                                                     baseURLString: urlString,
                                                     faqStructureRequestCompletionHandler: completion))
    }
}
