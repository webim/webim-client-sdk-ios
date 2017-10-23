//
//  HistoryMetaInformationStorage.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

protocol HistoryMetaInformationStorage {
    
    func isHistoryEnded() -> Bool
    
    func set(historyEnded: Bool)
    
    func getRevision() -> String?
    
    func set(revision: String?)
    
    func clear()
    
}
