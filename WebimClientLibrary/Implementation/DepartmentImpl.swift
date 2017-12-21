//
//  DepartmentImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 12.12.17.
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

final class DepartmentImpl: Department {
    
    // MARK: - Properties
    private let departmentOnlineStatus: DepartmentOnlineStatus
    private let key: String
    private let name: String
    private let order: Int
    private var localizedNames: [String : String]?
    private var logoURL: URL?
    
    // MARK: - Initialization
    init(key: String,
         name: String,
         departmentOnlineStatus: DepartmentOnlineStatus,
         order: Int,
         localizedNames: [String : String]? = nil,
         logo: URL? = nil) {
        self.key = key
        self.name = name
        self.departmentOnlineStatus = departmentOnlineStatus
        self.order = order
        self.localizedNames = localizedNames
        self.logoURL = logo
    }
    
    // MARK: - Methods
    // MARK: Department protocol methods
    
    func getKey() -> String {
        return key
    }
    
    func getName() -> String {
        return name
    }
    
    func getDepartmentOnlineStatus() -> DepartmentOnlineStatus {
        return departmentOnlineStatus
    }
    
    func getOrder() -> Int {
        return order
    }
    
    func getLocalizedNames() -> [String : String]? {
        return localizedNames
    }
    
    func getLogoURL() -> URL? {
        return logoURL
    }
    
}
