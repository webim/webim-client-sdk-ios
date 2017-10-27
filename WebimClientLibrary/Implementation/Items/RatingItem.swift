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

final class RatingItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case OPERATOR_ID = "operatorID"
        case RATING = "rating"
    }
    
    
    // MARK: - Properties
    private var operatorID: String?
    private var rating: Int?
    
    
    // MARK: - Initialization
    init?(withJSONDictionary jsonDictionary: [String : Any?]) {
        guard let operatorID = jsonDictionary[JSONField.OPERATOR_ID.rawValue] as? String else {
            return nil
        }
        
        guard let rating = jsonDictionary[JSONField.RATING.rawValue] as? Int else {
            return nil
        }
        
        self.operatorID = operatorID
        self.rating = rating
    }
    
    
    // MARK: - Methods
    
    func getOperatorID() -> String? {
        return operatorID
    }
    
    func getRating() -> Int? {
        return rating
    }
    
}
