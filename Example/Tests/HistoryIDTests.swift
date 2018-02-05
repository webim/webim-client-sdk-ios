//
//  HistoryIDTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 01.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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
import XCTest
@testable import WebimClientLibrary

class HistoryIDTests: XCTestCase {
    
    // MARK: - Tests
    func testEquals() {
        let dbID = "db_id"
        let timeInMicrosecond: Int64 = 1
        
        // MARK: Test 1
        // Two different normal HistoryID objects.
        
        var historyID1: HistoryID? = HistoryID(dbID: "db_id1",
                                               timeInMicrosecond: 1)
        var historyID2: HistoryID? = HistoryID(dbID: "db_id2",
                                               timeInMicrosecond: 2)
        
        XCTAssertFalse(historyID1 == historyID2)
        
        // MARK: Test 2
        // Two same normal HistoryID objects.
        
        historyID1 = HistoryID(dbID: dbID,
                               timeInMicrosecond: timeInMicrosecond)
        historyID2 = HistoryID(dbID: dbID,
                               timeInMicrosecond: timeInMicrosecond)
        
        XCTAssertTrue(historyID1 == historyID2)
        
        // MARK: Test 3
        // One normal HistoryID object and one nil.
        
        historyID1 = HistoryID(dbID: dbID,
                               timeInMicrosecond: timeInMicrosecond)
        historyID2 = nil
        
        XCTAssertFalse(historyID1 == historyID2)
        
        // MARK: Test 4
        // Two nil objects.
        
        historyID1 = nil
        historyID2 = nil
        
        XCTAssertTrue(historyID1 == historyID2)
    }
    
}
