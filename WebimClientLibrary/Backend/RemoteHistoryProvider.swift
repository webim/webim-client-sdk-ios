//
//  RemoteHistoryProvider.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
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
class RemoteHistoryProvider {
    
    // MARK: - Properties
    private var webimActions: WebimActions
    private var historyMessageMapper: MessageMapper
    private var historyMetaInformationStorage: HistoryMetaInformationStorage
    
    // MARK: - Initialization
    init(webimActions: WebimActions,
         historyMessageMapper: MessageMapper,
         historyMetaInformationStorage: HistoryMetaInformationStorage) {
        self.webimActions = webimActions
        self.historyMessageMapper = historyMessageMapper
        self.historyMetaInformationStorage = historyMetaInformationStorage
    }
    
    // MARK: - Methods
    func requestHistory(beforeTimestamp: Int64,
                        completion: @escaping ([MessageImpl], Bool) -> ()) {
        webimActions.requestHistory(beforeMessageTimestamp: beforeTimestamp) { [weak self] data in
            guard let `self` = self,
                let data = data else {
                completion([MessageImpl](), false)
                
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data,
                                                         options: [])
            if let historyBeforeResponseDictionary = json as? [String: Any?] {
                let historyBeforeResponse = HistoryBeforeResponse(jsonDictionary: historyBeforeResponseDictionary)
                
                if let messages = historyBeforeResponse.getData()?.getMessages() {
                    completion(self.historyMessageMapper.mapAll(messages: messages), (historyBeforeResponse.getData()?.isHasMore() == true))
                    
                    if historyBeforeResponse.getData()?.isHasMore() != true {
                        self.historyMetaInformationStorage.set(historyEnded: true)
                    }
                } else {
                    completion([MessageImpl](), false)
                    self.historyMetaInformationStorage.set(historyEnded: true)
                }
            }
        }
    }
    
}
