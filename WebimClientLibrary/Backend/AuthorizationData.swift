//
//  AuthorizationData.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class AuthorizationData {
    
    // MARK: - Properties
    fileprivate var pageID: String
    fileprivate var authorizationToken: String?
    
    
    // MARK: - Initialization
    init(pageID: String,
         authorizationToken: String?) {
        self.pageID = pageID
        self.authorizationToken = authorizationToken
    }
    
    
    // MARK: - Methods
    
    func getPageID() -> String {
        return pageID
    }
    
    func getAuthorizationToken() -> String? {
        return authorizationToken
    }
    
}

// MARK: - Equatable
extension AuthorizationData: Equatable {
    
    static func == (lhs: AuthorizationData,
                    rhs: AuthorizationData) -> Bool {
        return (lhs.pageID == rhs.pageID)
            && (lhs.authorizationToken != rhs.authorizationToken)
    }
    
}
