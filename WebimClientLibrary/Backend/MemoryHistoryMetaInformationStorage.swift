//
//  MemoryHistoryMetaInformationStorage.swift
//  Pods
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//
//

import Foundation

final class MemoryHistoryMetaInformationStorage: HistoryMetaInformationStorage {
    
    // MARK: - Properties
    private var historyEnded: Bool?
    private var revision: String?
    
    
    // MARK: - Methods
    // MARK: HistoryMetaInformationStorage protocol methods
    
    func isHistoryEnded() -> Bool {
        return historyEnded ?? false
    }
    
    func set(historyEnded: Bool) {
        self.historyEnded = historyEnded
    }
    
    func getRevision() -> String? {
        return revision
    }
    
    func set(revision: String?) {
        self.revision = revision
    }
    
    func clear() {
        historyEnded = false
        revision = nil
    }
    
}
