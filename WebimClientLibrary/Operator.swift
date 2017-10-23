//
//  Operator.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 Abstracts a chat operator.
 - SeeAlso:
 `MessageStream.getCurrentOperator()`
 */
public protocol Operator {
    
    /**
     - returns:
     Unique ID of the operator.
     - SeeAlso:
     `MessageStream.rateOperatorWith(id:,byRate rate:)`
     `MessageStream.getLastRatingOfOperatorWith(id:)`
     */
    func getID() -> String?
    
    /**
     - returns:
     A display name of the operator.
     */
    func getName() -> String?
    
    /**
     - returns:
     A URL String of the operator’s avatar.
     */
    func getAvatarURLString() -> String?
    
}
