//
//  AccountConfigItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 01.11.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
 2022 Webim
 */
final class AccountConfigItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case hintsEndpoint = "visitor_hints_api_endpoint"
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
    }
    
    // MARK: - Properties
    private var hintsEndpoint: String?
    private var webAndMobileQuoting: Bool?
    private var visitorMessageEditing: Bool?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let hintsEndpoint = jsonDictionary[JSONField.hintsEndpoint.rawValue] as? String {
            self.hintsEndpoint = hintsEndpoint
        }
        if let webAndMobileQuoting = jsonDictionary[JSONField.webAndMobileQuoting.rawValue] as? Bool {
            self.webAndMobileQuoting = webAndMobileQuoting
        }
        if let visitorMessageEditing = jsonDictionary[JSONField.visitorMessageEditing.rawValue] as? Bool {
            self.visitorMessageEditing = visitorMessageEditing
        }
    }
    
    // MARK: - Methods
    func getHintsEndpoint() -> String? {
        return hintsEndpoint
    }
    
    func getWebAndMobileQuoting() -> Bool {
        return webAndMobileQuoting ?? true
    }
    
    func getVisitorMessageEditing() -> Bool {
        return visitorMessageEditing ?? true
    }
}
