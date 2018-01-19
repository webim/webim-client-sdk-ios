//
//  OperatorItem.swift
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
 Class that encapsulates chat operator data, received from a server.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
struct OperatorItem {
    
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
    init(jsonDictionary: [String: Any?]) {
        if let departmentKeysArray = jsonDictionary[JSONField.DEPARTMENT_KEYS.rawValue] as? [Any] {
            for departmentKey in departmentKeysArray {
                departmentKeys.append(departmentKey as! String)
            }
        }
        
        if let avatarURLString = jsonDictionary[JSONField.AVATAR_URL_STRING.rawValue] as? String {
            self.avatarURLString = avatarURLString
        }
        
        if let id = jsonDictionary[JSONField.ID.rawValue] as? Int {
            self.id = String(id)
        }
        
        if let fullName = jsonDictionary[JSONField.FULL_NAME.rawValue] as? String {
            self.fullName = fullName
        }
    }
    
    
    // MARK: - Methods
    
    func getID() -> String? {
        return id
    }
    
    func getAvatarURLString() -> String? {
        return avatarURLString
    }
    
    func getFullName() -> String? {
        return fullName
    }
    
}
