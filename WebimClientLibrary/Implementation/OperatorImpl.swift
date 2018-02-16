//
//  OperatorImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
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
 Internal representation of a chat operator data.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
struct OperatorImpl: Operator {
    
    // MARK: - Properties
    private let id: String
    private let name: String
    private let avatarURLString: String?
    
    // MARK: - Initialization
    init(id: String,
         name: String,
         avatarURLString: String? = nil) {
        self.id = id
        self.name = name
        self.avatarURLString = avatarURLString
    }
    
    // MARK: - Methods
    // MARK: Operator protocol methods
    
    func getID() -> String {
        return id
    }
    
    func getName() -> String {
        return name
    }
    
    func getAvatarURL() -> URL? {
        guard let avatarURLString = avatarURLString else {
            return nil
        }
        
        return URL(string: avatarURLString)
    }
    
}

// MARK: - Equatable
extension OperatorImpl: Equatable {
    
    // MARK: - Methods
    static func == (lhs: OperatorImpl,
                    rhs: OperatorImpl) -> Bool {
        return ((lhs.id == rhs.id)
            && (lhs.name == rhs.name))
            && (lhs.avatarURLString == rhs.avatarURLString)
    }
    
}
