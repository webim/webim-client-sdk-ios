//
//  FAQItemItem.swift
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
final class FAQItemItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case categories = "categories"
        case title = "title"
        case tags = "tags"
        case content = "content"
        case likes = "likes"
        case dislikes = "dislikes"
    }
    
    // MARK: - Properties
    private var id: String?
    private var categories: [Int]?
    private var title: String?
    private var tags: [String]?
    private var content: String?
    private var likes: Int?
    private var dislikes: Int?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }
        
        if let categories = jsonDictionary[JSONField.categories.rawValue] as? [Int] {
            self.categories = categories
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let tags = jsonDictionary[JSONField.tags.rawValue] as? [String] {
            self.tags = tags
        }
        
        if let content = jsonDictionary[JSONField.content.rawValue] as? String {
            self.content = content
        }
        
        if let likes = jsonDictionary[JSONField.likes.rawValue] as? Int {
            self.likes = likes
        }
        
        if let dislikes = jsonDictionary[JSONField.dislikes.rawValue] as? Int {
            self.dislikes = dislikes
        }
    }
    
}

extension FAQItemItem: FAQItem {
    
    func getID() -> String {
        return id!
    }
    
    func getCategories() -> [Int] {
        return categories!
    }
    
    func getTitle() -> String {
        return title!
    }
    
    func getTags() -> [String] {
        return tags!
    }
    
    func getContent() -> String {
        return content!
    }
    
    func getLikeCount() -> Int {
        return likes!
    }
    
    func getDislikeCount() -> Int {
        return dislikes!
    }
    
    
}

// MARK: - Equatable
extension FAQItemItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQItemItem,
                    rhs: FAQItemItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}
