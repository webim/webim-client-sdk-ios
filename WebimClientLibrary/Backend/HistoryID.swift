//
//  HistoryID.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class HistoryID {

    // MARK: - Properties
    fileprivate let dbID: String
    fileprivate let timeInMicrosecond: Int64
    
    
    // MARK: - Initialization
    init(withDBid dbID: String,
         timeInMicrosecond: Int64) {
        self.dbID = dbID
        self.timeInMicrosecond = timeInMicrosecond
    }
    
    
    // MARK: - Methods
    
    func getDBid() -> String {
        return dbID
    }
    
}

// MARK: - MicrosecondsTimeHolder
extension HistoryID: MicrosecondsTimeHolder {
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
}

// MARK: - Equatable
extension HistoryID: Equatable {
    
    static func == (lhs: HistoryID,
                    rhs: HistoryID) -> Bool {
        return (lhs.dbID == rhs.dbID)
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond)
    }
    
}
