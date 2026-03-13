//
//  Visitor.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 29.11.2024.
//  Copyright © 2024 Webim. All rights reserved.
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
import UIKit

/**
 Abstracts a chat operator.
 - seealso:
 `MessageStream.getVisitor()`
 - author:
 Anna Frolova
 - copyright:
 2024 Webim
 */
public protocol Visitor {
    
    /**
     - returns:
     Icon of the visitor.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getIcon() -> Icon?
    
    /**
     - returns:
     Unique ID of the visitor.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Visitor fields.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getVisitorFields() -> VisitorFields?
    
    /**
     - returns:
     Visitor fields in dictionary.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getVisitorFieldsInDictionary() -> [String: String]?
    
    
}


/**
 Provides information about visitor.
 - seealso:
 `Visitor.getVisitorFields()`
 - author:
 Anna Frolova
 - copyright:
 2024 Webim
 */
public protocol VisitorFields {
    
    /**
     - returns:
     Visitor name.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getName() -> String?
    
    /**
     - returns:
     Visitor email.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getEmail() -> String?
    
    /**
     - returns:
     Visitor phone.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getPhone() -> String?
    
    /**
     - returns:
     Visitor first custom field.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getFirstCustomField() -> String?
    
    /**
     - returns:
     Visitor second custom field.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getSecondCustomField() -> String?
    
    /**
     - returns:
     Visitor third custom field.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getThirdCustomField() -> String?
    
}

/**
 Provides visitor icon.
 - seealso:
 `Visitor.getIcon()`
 - author:
 Anna Frolova
 - copyright:
 2024 Webim
 */
public protocol Icon {
    
    /**
     - returns:
     Color of the visitor icon.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getColor() -> UIColor?
    
    /**
     - returns:
     Shape of the visitor icon.
     - author:
     Anna Frolova
     - copyright:
     2024 Webim
     */
    func getShape() -> String?
}
