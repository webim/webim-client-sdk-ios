//
//  RatingItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that encapsulates operator rating data.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
struct RatingItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case operatorID = "operatorId"
        case rating = "rating"
    }
    
    // MARK: - Properties
    private var operatorID: String
    private var rating: Int
    
    // MARK: - Initialization
    init?(jsonDictionary: [String : Any?]) {
        guard let operatorID = jsonDictionary[JSONField.operatorID.rawValue] as? Int,
            let rating = jsonDictionary[JSONField.rating.rawValue] as? Int else {
            return nil
        }
        
        self.operatorID = String(operatorID)
        self.rating = rating
    }
    
    // MARK: - Methods
    
    func getOperatorID() -> String {
        return operatorID
    }
    
    func getRating() -> Int {
        return rating
    }

    static func ==(rhs: RatingItem, lhs: RatingItem) -> Bool {
        return rhs.operatorID == lhs.operatorID && rhs.rating == lhs.rating
    }
}
