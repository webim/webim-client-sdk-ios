//
//  TranslationOptionsItem.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 15.12.2025.
//  Copyright © 2025 Webim. All rights reserved.
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
 Class that encapsulates translation options data.
 - author:
 Anna Frolova
 - copyright:
 2025 Webim
 */
struct TranslationOptionsItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case enabled
        case language
    }
    
    // MARK: - Properties
    private var enabled: Bool?
    private var language: String?
    
    // MARK: - Initialization
    init?(jsonDictionary: [String : Any?]) {
        self.enabled = jsonDictionary[JSONField.enabled.rawValue] as? Bool
        self.language = jsonDictionary[JSONField.language.rawValue] as? String
    }
    
    // MARK: - Methods
    
    func isEnabled() -> Bool? {
        return enabled
    }
    
    func getLanguage() -> String? {
        return language
    }

    static func ==(rhs: TranslationOptionsItem, lhs: TranslationOptionsItem) -> Bool {
        return rhs.enabled == lhs.enabled && rhs.language == lhs.language
    }
}
