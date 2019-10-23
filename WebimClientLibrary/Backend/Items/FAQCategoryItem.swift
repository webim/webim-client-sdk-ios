//
//  FAQCategoryItem.swift
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
final class FAQCategoryItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "categoryid"
        case title = "title"
        case childs = "childs"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var children = [Child]()
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
            self.id = String(id)
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let childs = jsonDictionary[JSONField.childs.rawValue] as? [Any] {
            for child in childs {
                if let childValue = child as? [String: Any?] {
                    let childItem = Child(jsonDictionary: childValue)
                    children.append(childItem)
                }
            }
        }
    }
    
}

extension FAQCategoryItem: FAQCategory {
    func getID() -> String {
        return id!
    }
    
    func getTitle() -> String {
        return title!
    }
    
    func getItems() -> [FAQItem] {
        var items = [FAQItem]()
        for child in children {
            if child.type == .ITEM {
                items.append(child.data as! FAQItemItem)
            }
        }
        return items
    }
    
    func getSubcategories() -> [FAQCategoryInfo] {
        var subCategories = [FAQCategoryInfo]()
        for child in children {
            if child.type == .CATEGORY {
                subCategories.append(child.data as! FAQCategoryInfoItem)
            }
        }
        return subCategories
    }
    
    
}

// MARK: - Equatable
extension FAQCategoryItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQCategoryItem,
                    rhs: FAQCategoryItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}

final class Child {
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case type = "type"
        case data = "data"
    }
    
    // MARK: - Properties
    public var type: RootType?
    public var data: Any?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            switch type {
            case "item":
                self.type = .ITEM
                if let data = jsonDictionary[JSONField.data.rawValue] as? [String: Any?] {
                    self.data = FAQItemItem(jsonDictionary: data)
                }
                break
            case "category":
                self.type = .CATEGORY
                if let data = jsonDictionary[JSONField.data.rawValue] as? [String: Any?]  {
                    self.data = FAQCategoryInfoItem(jsonDictionary: data)
                }
                break
            default:
                self.type = .UNKNOWN
            }
        }
    }
}
