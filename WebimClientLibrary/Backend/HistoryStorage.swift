//
//  HistoryStorage.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

protocol HistoryStorage {
    
    // When this values is changed history will be re-requested.
    func getMajorVersion() -> Int
    
    func set(reachedHistoryEnd: Bool)
    
    func getLatestBy(limitOfMessages: Int,
                     completion: @escaping ([Message]) throws -> ()) throws
    
    func getBefore(id: HistoryID,
                   limitOfMessages: Int,
                   completion: @escaping ([Message]) throws -> ()) throws
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool)
    
    func receiveHistoryUpdate(messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) throws -> ()) throws
    
}
