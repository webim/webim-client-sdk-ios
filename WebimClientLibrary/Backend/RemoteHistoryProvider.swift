//
//  RemoteHistoryProvider.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

class RemoteHistoryProvider {
    
    // MARK: - Properties
    private var webimActions: WebimActions
    private var historyMessageMapper: MessageFactoriesMapper
    private var historyMetaInformation: HistoryMetaInformationStorage
    
    // MARK: - Initialization
    init(withWebimActions webimActions: WebimActions,
         historyMessageMapper: MessageFactoriesMapper,
         historyMetaInformation: HistoryMetaInformationStorage) {
        self.webimActions = webimActions
        self.historyMessageMapper = historyMessageMapper
        self.historyMetaInformation = historyMetaInformation
    }
    
    // MARK: - Methods
    func requestHistory(beforeTimeSince: Int64,
                        completion: @escaping ([MessageImpl], Bool) throws -> ()) {
        webimActions.requestHistory(beforeMessageTimeSince: beforeTimeSince) { data in
            guard data != nil else {
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!,
                                                         options: [])
            if let historyBeforeResponseDictionary = json as? [String: Any?] {
                let historyBeforeResponse = HistoryBeforeResponse(withJSONDictionary: historyBeforeResponseDictionary)
                
                if let messages = historyBeforeResponse.getData()?.getMessages() {
                    try completion(self.historyMessageMapper.mapAll(messages: messages), (historyBeforeResponse.getData()?.isHasMore() == true))
                    
                    if historyBeforeResponse.getData()?.isHasMore() != true {
                        self.historyMetaInformation.set(historyEnded: true)
                    }
                }
            }
        }
    }
    
}
