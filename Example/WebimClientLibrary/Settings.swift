//
//  Settings.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 28.11.17.
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
 Abstraction for present account settings in Webim service.
 Uses Singleton pattern. Accessible by `Settings.shared`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class Settings {
    
    // MARK: - Constants
    enum Defaults: String {
        case ACCOUNT_NAME = "https://wmtest2.webim.ru"//"demo"
        case LOCATION = "mobile"
        case PAGE_TITLE = "iOS demo app"
    }
    
    // MARK: - Properties
    static let shared = Settings(accountName: Defaults.ACCOUNT_NAME.rawValue,
                                 location: Defaults.LOCATION.rawValue,
                                 pageTitle: Defaults.PAGE_TITLE.rawValue)
    var accountName: String
    var location: String
    var pageTitle: String
    
    // MARK: - Initialization
    private init(accountName: String,
                 location: String,
                 pageTitle: String) {
        self.accountName = accountName
        self.location = location
        self.pageTitle = pageTitle
    }
    
}
