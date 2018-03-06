//
//  HistorySinceResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
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
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
struct HistorySinceResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum JSONField: String {
        case data = "data"
    }
    
    // MARK: - Properties
    private var historyResponseData: HistoryResponseData?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let dataDictionary = jsonDictionary[JSONField.data.rawValue] as? [String: Any?] {
            historyResponseData = HistoryResponseData(jsonDictionary: dataDictionary)
        }
    }
    
    // MARK: - Methods
    func getData() -> HistoryResponseData? {
        return historyResponseData
    }
    
    // MARK: -
    struct HistoryResponseData {
        
        // MARK: - Constants
        // Raw values equal to field names received in responses from server.
        enum JSONField: String {
            case hasMore = "hasMore"
            case messages = "messages"
            case revision = "revision"
        }
        
        // MARK: - Properties
        private var hasMore: Bool?
        private var messages: [MessageItem]?
        private var revision: String?
        
        // MARK: - Initialization
        init(jsonDictionary: [String: Any?]) {
            var messages = [MessageItem]()
            if let messagesArray = jsonDictionary[JSONField.messages.rawValue] as? [Any?] {
                for item in messagesArray {
                    if let messageDictionary = item as? [String: Any?] {
                        let messageItem = MessageItem(jsonDictionary: messageDictionary)
                        messages.append(messageItem)
                    }
                }
            }
            self.messages = messages
            
            hasMore = ((jsonDictionary[JSONField.hasMore.rawValue] as? Bool) ?? false)
            revision = jsonDictionary[JSONField.revision.rawValue] as! String?
        }
        
        // MARK: - Methods
        
        func getMessages() -> [MessageItem]? {
            return messages
        }
        
        func isHasMore() -> Bool? {
            return hasMore
        }
        
        func getRevision() -> String? {
            return revision
        }
        
    }
    
}
