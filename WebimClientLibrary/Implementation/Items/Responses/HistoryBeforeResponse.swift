//
//  HistoryBeforeResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class HistoryBeforeResponse {
    
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
        }
        
        // MARK: - Properties
        private var hasMore: Bool?
        private var messages: [MessageItem]?
        
        
        // MARK: - Initialization
        init(withJSONDictionary jsonDictionary: [String : Any?]) {
            messages = [MessageItem]()
            if let messagesArray = jsonDictionary[JSONField.MESSAGES.rawValue] as? [Any?] {
                for item in messagesArray {
                    if let messageDictionary = item as? [String : Any?] {
                        let messageItem = MessageItem(withJSONDictionary: messageDictionary)
                        messages?.append(messageItem)
                    }
                }
            }
            
            if let hasMore = jsonDictionary[JSONField.HAS_MORE.rawValue] as? Bool {
                self.hasMore = hasMore
            }
        }
        
        
        // MARK: - Methods
        
        func isHasMore() -> Bool? {
            return hasMore
        }
        
        func getMessages() -> [MessageItem]? {
            return messages
        }
        
    }
    
}
