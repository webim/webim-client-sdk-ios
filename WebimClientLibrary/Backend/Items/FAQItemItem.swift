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
        case userRate = "userRate"
    }
    
    // MARK: - Properties
    private var id: String?
    private var categories: [String]?
    private var title: String?
    private var tags: [String]?
    private var content: String?
    private var likes: Int?
    private var dislikes: Int?
    private var userRate: UserRate = .noRate
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }
        
        if let categories = jsonDictionary[JSONField.categories.rawValue] as? [Int] {
            self.categories = categories.map { i in String(i) }
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
        
        if let userRateItem = jsonDictionary[JSONField.userRate.rawValue] as? String {
            switch userRateItem {
            case "like":
                userRate = .like
                break
            case "dislike":
                userRate = .dislike
                break
            default:
                userRate = .noRate
            }
        }
    }
    
    init(faqItem: FAQItem, userRate: UserRate) {
        let previousUserRate = faqItem.getUserRate()
        self.id = faqItem.getID()
        self.categories = faqItem.getCategories()
        self.title = faqItem.getTitle()
        self.tags = faqItem.getTags()
        self.content = faqItem.getContent()
        self.likes = faqItem.getLikeCount() + (userRate == .like ? 1 : 0) - (previousUserRate == .like ? 1 : 0)
        self.dislikes = faqItem.getDislikeCount()  + (userRate == .dislike ? 1 : 0) - (previousUserRate == .dislike ? 1 : 0)
        self.userRate = userRate
    }
    
}

extension FAQItemItem: FAQItem {
    
    func getID() -> String {
        guard let id = id else {
            WebimInternalLogger.shared.log(entry: "ID is nil in FAQItemItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getCategories() -> [String] {
        guard let categories = categories else {
            WebimInternalLogger.shared.log(entry: "Categories is nil in FAQItemItem.\(#function)")
            return []
        }
        return categories
    }
    
    func getTitle() -> String {
        guard let title = title else {
            WebimInternalLogger.shared.log(entry: "Title is nil in FAQItemItem.\(#function)")
            return String()
        }
        return title
    }
    
    func getTags() -> [String] {
        guard let tags = tags else {
            WebimInternalLogger.shared.log(entry: "Tags is nil in FAQItemItem.\(#function)")
            return []
        }
        return tags
    }
    
    func getContent() -> String {
        guard let content = content else {
            WebimInternalLogger.shared.log(entry: "Content is nil in FAQItemItem.\(#function)")
            return String()
        }
        return content
    }
    
    func getLikeCount() -> Int {
        guard let likes = likes else {
            WebimInternalLogger.shared.log(entry: "Likes is nil in FAQItemItem.\(#function)")
            return -1
        }
        return likes
    }
    
    func getDislikeCount() -> Int {
        guard let dislikes = dislikes else {
            WebimInternalLogger.shared.log(entry: "Dislikes is nil in FAQItemItem.\(#function)")
            return -1
        }
        return dislikes
    }
    
    func getUserRate() -> UserRate {
        return userRate
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

/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class FAQSearchItemItem {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case title = "title"
        case score = "score"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var score: Double?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let score = jsonDictionary[JSONField.score.rawValue] as? Double {
            self.score = score
        }
    }
}

extension FAQSearchItemItem: FAQSearchItem {
    func getID() -> String {
        guard let id = id else {
            WebimInternalLogger.shared.log(entry: "ID is nil in FAQSearchItemItem.\(#function)")
            return String()
        }
        return id
    }
    
    func getTitle() -> String {
        guard let title = title else {
            WebimInternalLogger.shared.log(entry: "Title is nil in FAQSearchItemItem.\(#function)")
            return String()
        }
        return title
    }
    
    func getScore() -> Double {
        guard let score = score else {
            WebimInternalLogger.shared.log(entry: "Score is nil in FAQSearchItemItem.\(#function)")
            return -1.0
        }
        return score
    }
    
}

// MARK: - Equatable
extension FAQSearchItemItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQSearchItemItem,
                    rhs: FAQSearchItemItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}
