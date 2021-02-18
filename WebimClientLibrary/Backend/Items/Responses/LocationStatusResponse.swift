//
//  LocationStatusResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 10.02.21.
//  Copyright © 2021 Webim. All rights reserved.
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
 2021 Webim
 */
final class LocationStatusResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case onlineOperators = "onlineOperators"
        case onlineStatus = "onlineStatus"
    }
    
    // MARK: - Properties
    private var onlineOperators: Bool?
    private var onlineStatus: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let onlineOperators = jsonDictionary[JSONField.onlineOperators.rawValue] as? Bool {
            self.onlineOperators = onlineOperators
        }
        
        if let onlineStatus = jsonDictionary[JSONField.onlineStatus.rawValue] as? String {
            self.onlineStatus = onlineStatus
        }
    }
    
    // MARK: - Methods
    
    func getOnlineOperator() -> Bool? {
        return onlineOperators
    }
    
    func getOnlineStatus() -> String? {
        return onlineStatus
    }
    
}
