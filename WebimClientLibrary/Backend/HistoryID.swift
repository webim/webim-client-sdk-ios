//
//  HistoryID.swift
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
 Class that encapsulates message ID in history context.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class HistoryID {

    // MARK: - Properties
    private let dbID: String
    private let timeInMicrosecond: Int64
    
    // MARK: - Initialization
    init(dbID: String,
         timeInMicrosecond: Int64) {
        self.dbID = dbID
        self.timeInMicrosecond = timeInMicrosecond
    }
    
    // MARK: - Methods
    
    func getDBid() -> String {
        return dbID
    }
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
}

// MARK: - Equatable
extension HistoryID: Equatable {
    
    // MARK: - Methods
    static func == (lhs: HistoryID,
                    rhs: HistoryID) -> Bool {
        return ((lhs.dbID == rhs.dbID)
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond))
    }
    
}
