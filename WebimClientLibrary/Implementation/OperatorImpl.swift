//
//  OperatorImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class OperatorImpl: Operator {
    
    // MARK: - Properties
    fileprivate let id: String?
    fileprivate let name: String?
    fileprivate let avatarURLString: String?
    
    
    // MARK: - Initialization
    init(withID id: String?,
         name: String?,
         avatarURLString: String? = nil) {
        self.id = id
        self.name = name
        self.avatarURLString = avatarURLString
    }
    
    
    // MARK: - Methods
    // MARK: Operator protocol methods
    
    func getID() -> String? {
        return id
    }
    
    func getName() -> String? {
        return name
    }
    
    func getAvatarURLString() -> String? {
        return avatarURLString
    }
    
}

// MARK: - Equatable
extension OperatorImpl: Equatable {
    
    static func == (lhs: OperatorImpl,
                    rhs: OperatorImpl) -> Bool {
        return ((lhs.id == rhs.id)
            && (lhs.name == rhs.name))
            && (lhs.avatarURLString == rhs.avatarURLString)
    }
    
}
