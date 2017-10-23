//
//  OperatorItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class OperatorItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case AVATAR_URL_STRING = "avatar"
        case DEPARTMENT_KEYS = "departmentKeys"
        case ID = "id"
        case FULL_NAME = "fullname"
    }
    
    
    // MARK: - Properties
    private var avatarURLString: String?
    private var departmentKeys = [String]()
    private var id: String?
    private var fullName: String?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let departmentKeysArray = jsonDictionary[JSONField.DEPARTMENT_KEYS.rawValue] as? [Any] {
            for departmentKey in departmentKeysArray {
                departmentKeys.append(departmentKey as! String)
            }
        }
        
        if let avatarURLString = jsonDictionary[JSONField.AVATAR_URL_STRING.rawValue] as? String {
            self.avatarURLString = avatarURLString
        }
        
        if let id = jsonDictionary[JSONField.ID.rawValue] as? String {
            self.id = id
        }
        
        if let fullName = jsonDictionary[JSONField.FULL_NAME.rawValue] as? String {
            self.fullName = fullName
        }
    }
    
    
    // MARK: - Methods
    
    func getID() -> String? {
        return id
    }
    
    func getDepartmentKeys() -> [String]? {
        return departmentKeys
    }
    
    func getAvatarURLString() -> String? {
        return avatarURLString
    }
    
    func getFullName() -> String? {
        return fullName
    }
    
}
