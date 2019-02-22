//
//  FAQStructureItem.swift
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
final class FAQStructureItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case id = "id"
        case type = "type"
        case childs = "childs"
        case title = "title"
    }
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var type: RootType?
    private var children = [FAQStructureItem]()
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let id = jsonDictionary[JSONField.id.rawValue] as? String {
            self.id = id
        }
        
        if let title = jsonDictionary[JSONField.title.rawValue] as? String {
            self.title = title
        }
        
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            self.type = toRootType(type: type)
        }
        
        if type == .ITEM {
            if let id = jsonDictionary[JSONField.id.rawValue] as? String {
                self.id = id
            }
        } else {
            if let id = jsonDictionary[JSONField.id.rawValue] as? Int {
                self.id = String(id)
            }
        }
        
        if let childs = jsonDictionary[JSONField.childs.rawValue] as? [Any] {
            for child in childs {
                if let childValue = child as? [String: Any?] {
                    let childItem = FAQStructureItem(jsonDictionary: childValue)
                    children.append(childItem)
                }
            }
        }
    }
    
    private func toRootType(type: String) -> RootType? {
        switch type {
        case "item":
            return .ITEM
        case "category":
            return .CATEGORY
        default:
            return nil
        }
    }
    
}

extension FAQStructureItem: FAQStructure {
    func getID() -> String {
        return id!
    }
    
    func getType() -> RootType {
        return type!
    }
    
    func getChildren() -> [FAQStructure] {
        return children
    }
    
    func getTitle() -> String {
        return title!
    }
    
    
    
}

// MARK: - Equatable
extension FAQStructureItem: Equatable {
    
    // MARK: - Methods
    static func == (lhs: FAQStructureItem,
                    rhs: FAQStructureItem) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        
        return false
    }
    
}
