//
//  FAQCategory.swift
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
 FAQ category contains pages with some information and subcategories.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol FAQCategory {
    
    /**
     Every category can be uniquefied by its ID.
     - returns:
     Unique ID of the category.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Title of the category.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getTitle() -> String
    
    /**
     Every category contains items.
     - returns:
     List of category items.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getItems() -> [FAQItem]
    
    /**
     Every category can be contains subcategories.
     - returns:
     List of categories that contains the item.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getSubcategories() -> [FAQCategoryInfo]
}
