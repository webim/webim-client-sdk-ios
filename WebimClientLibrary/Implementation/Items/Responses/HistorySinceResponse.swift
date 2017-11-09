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
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class HistorySinceResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    enum JSONField: String {
        case HISTORY_RESPONSE_DATA = "data"
        case RESULT = "result"
    }
    
    
    // MARK: - Properties
    private var historyResponseData: HistoryResponseData?
    private var result: String?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let dataDictionary = jsonDictionary[JSONField.HISTORY_RESPONSE_DATA.rawValue] as? [String: Any?] {
            historyResponseData = HistoryResponseData(withJSONDictionary: dataDictionary)
        }
        
        if let result = jsonDictionary[JSONField.RESULT.rawValue] as? String {
            self.result = result
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
            case HAS_MORE = "hasMore"
            case MESSAGES = "messages"
            case REVISION = "revision"
        }
        
        
        // MARK: - Properties
        private var hasMore: Bool?
        private var messages: [MessageItem]?
        private var revision: String?
        
        
        // MARK: - Initialization
        init(withJSONDictionary jsonDictionary: [String : Any?]) {
            var messages = [MessageItem]()
            if let messagesArray = jsonDictionary[JSONField.MESSAGES.rawValue] as? [Any?] {
                for item in messagesArray {
                    if let messageDictionary = item as? [String : Any?] {
                        let messageItem = MessageItem(withJSONDictionary: messageDictionary)
                        messages.append(messageItem)
                    }
                }
            }
            self.messages = messages
            
            self.hasMore = jsonDictionary[JSONField.HAS_MORE.rawValue] as! Bool?
            self.revision = jsonDictionary[JSONField.REVISION.rawValue] as! String?
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
