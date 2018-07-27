//
//  MemoryHistoryStorage.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
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
 Class that is responsible for history storage when it is set to memory mode.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MemoryHistoryStorage: HistoryStorage {
    
    // MARK: - Properties
    private let majorVersion = Int(InternalUtils.getCurrentTimeInMicrosecond() % Int64(Int.max))
    private lazy var historyMessages = [MessageImpl]()
    private var reachedHistoryEnd = false
    
    // MARK: - Initialization
    
    init() {
        // Empty initializer introduced because of init(with:) existence.
    }
    
    // For testing purposes only.
    init(messagesToAdd: [MessageImpl]) {
        for message in messagesToAdd {
            historyMessages.append(message)
        }
    }
    
    // MARK: - Methods
    // MARK: HistoryStorage protocol methods
    
    func getMajorVersion() -> Int {
        return majorVersion
    }
    
    func set(reachedHistoryEnd: Bool) {
        // No need in this implementation.
    }
    
    func getFullHistory(completion: @escaping ([Message]) -> ()) {
        completion(historyMessages as [Message])
    }
    
    func getLatestHistory(byLimit limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        respondTo(messages: historyMessages,
                  limitOfMessages: limitOfMessages,
                  completion: completion)
    }
    
    func getHistoryBefore(id: HistoryID,
                          limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        let sortedMessages = historyMessages.sorted { $0.getHistoryID()!.getTimeInMicrosecond() < $1.getHistoryID()!.getTimeInMicrosecond() }
        
        if sortedMessages[0].getHistoryID()!.getTimeInMicrosecond() > id.getTimeInMicrosecond() {
            completion([MessageImpl]())
            
            return
        }
        
        for (index, message) in sortedMessages.enumerated() {
            if message.getHistoryID() == id {
                respondTo(messages: sortedMessages,
                          limitOfMessages: limitOfMessages,
                          offset: index,
                          completion: completion)
                
                break
            }
        }
    }
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool) {
        if !hasMoreMessages {
            reachedHistoryEnd = true
        }
        
        historyMessages = messages + historyMessages
    }
    
    func receiveHistoryUpdate(withMessages messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        deleteFromHistory(idsToDelete: idsToDelete,
                          completion: completion)
        mergeHistoryChanges(messages: messages,
                            completion: completion)
        
        completion(true, false, nil, false, nil, false, nil, nil)
    }
    
    // MARK: Private methods
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           completion: ([Message]) -> ()) {
        completion((messages.count == 0) ? messages : ((messages.count <= limitOfMessages) ? messages : Array(messages[(messages.count - limitOfMessages) ..< messages.count])))
    }
    
    private func respondTo(messages: [MessageImpl],
                           limitOfMessages: Int,
                           offset: Int,
                           completion: ([Message]) -> ()) {
        let supposedQuantity = offset - limitOfMessages
        completion(Array(messages[((supposedQuantity > 0) ? supposedQuantity : 0) ..< offset]))
    }
    
    private func deleteFromHistory(idsToDelete: Set<String>,
                                   completion: (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        for idToDelete in idsToDelete {
            for (index, message) in historyMessages.enumerated() {
                if message.getHistoryID()?.getDBid() == idToDelete {
                    historyMessages.remove(at: index)
                    completion(false, true, message.getHistoryID()?.getDBid(), false, nil, false, nil, nil)
                    
                    break
                }
            }
        }
    }
    
    private func mergeHistoryChanges(messages: [MessageImpl],
                                     completion: (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        /*
         Algorithm merges messages with history messages.
         Messages before first history message are ignored.
         Messages with the same time in Microseconds with corresponding history messages are replacing them.
         Messages after last history message are added in the end.
         The rest of the messages are merged in the middle of history messages.
         */
        
        var receivedMessages = messages
        var result = [MessageImpl]()
        
        outerLoop: for historyMessage in historyMessages {
            while receivedMessages.count > 0 {
                for message in receivedMessages {
                    if message.getTimeInMicrosecond() < historyMessage.getTimeInMicrosecond() {
                        if !result.isEmpty {
                            result.append(message)
                            completion(false, false, nil, false, nil, true, message, historyMessage.getHistoryID())
                            
                            receivedMessages.remove(at: 0)
                            
                            continue
                        } else {
                            receivedMessages.remove(at: 0)
                            
                            break
                        }
                    }
                    
                    if message.getTimeInMicrosecond() > historyMessage.getTimeInMicrosecond() {
                        result.append(historyMessage)
                        
                        continue outerLoop
                    }
                    
                    if message.getTimeInMicrosecond() == historyMessage.getTimeInMicrosecond() {
                        result.append(message)
                        completion(false, false, nil, true, message, false, nil, nil)
                        
                        receivedMessages.remove(at: 0)
                        
                        continue outerLoop
                    }
                }
            }
            
            result.append(historyMessage)
        }
        
        if receivedMessages.count > 0 {
            for message in receivedMessages {
                result.append(message)
                completion(false, false, nil, false, nil, true, message, nil)
            }
        }
        
        historyMessages = result
    }
        
}
