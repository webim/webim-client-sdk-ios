//
//  RatingItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
//  Copyright © 2017 Webim. All rights reserved.
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
