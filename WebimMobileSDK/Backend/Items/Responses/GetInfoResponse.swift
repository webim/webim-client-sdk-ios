//
//  GetInfoResponse.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 03.08.2025.
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
 - author:
 Anna Frolova
 - copyright:
 2025 Webim
 */
struct GetInfoResponse {
    
    enum JSONField: String {
        case unreadMessagesCount
        case historyLastChangeTs
    }
    
    // MARK: - Properties
    private var unreadMessagesCount: Int?
    private var historyLastChangeTs: Double?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let unreadMessagesCount = jsonDictionary[JSONField.unreadMessagesCount.rawValue] as? Int {
            self.unreadMessagesCount = unreadMessagesCount
        }
        
        if let historyLastChangeTs = jsonDictionary[JSONField.historyLastChangeTs.rawValue] as? Double {
            self.historyLastChangeTs = historyLastChangeTs
        }
    }
    
    // MARK: - Methods
    func getUnreadMessagesCount() -> Int? {
        return unreadMessagesCount
    }
    
    func getHistoryLastChangeTs() -> Double? {
        return historyLastChangeTs
    }
}
