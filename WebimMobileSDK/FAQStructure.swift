//
//  FAQStructure.swift
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
 Category subtree.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol FAQStructure {
    /**
     Every structure has root.
     - returns:
     Unique ID of the tree root.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Root type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getType() -> RootType
    
    /**
     - returns:
     Root's children.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getChildren() -> [FAQStructure]
    
    /**
     - returns:
     Root title.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getTitle() -> String
}

// MARK: -
/**
 Supported structure root types.
 - seealso:
 `FAQStructure.getType()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum RootType {
    /**
     Root is category.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case category
    
    @available(*, unavailable, renamed: "category")
    case CATEGORY
    
    /**
     Root is item.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case item
    
    @available(*, unavailable, renamed: "item")
    case ITEM
    
    /**
    Unknown root type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case unknown
    
    @available(*, unavailable, renamed: "unknown")
    case UNKNOWN
    
}
