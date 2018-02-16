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

// MARK: - Global constants
let USER_DEFAULTS_NAME = "settings"
enum UserDefaultsKey: String {
    case ACCOUNT_NAME = "account_name"
    case COLOR_SCHEME = "color_scheme"
    case LOCATION = "location"
    case PAGE_TITLE = "page_title"
}

// MARK: -
final class Settings {
    
    // MARK: - Constants
    enum Defaults: String {
        case ACCOUNT_NAME = "demo"
        case LOCATION = "mobile"
        case PAGE_TITLE = "iOS demo app"
    }
    
    // MARK: - Properties
    static let shared = Settings()
    var accountName: String
    var location: String
    var pageTitle: String
    
    // MARK: - Initialization
    private init() {
        if let settings = UserDefaults.standard.object(forKey: USER_DEFAULTS_NAME) as? [String : String] {
            self.accountName = settings[UserDefaultsKey.ACCOUNT_NAME.rawValue] ?? Defaults.ACCOUNT_NAME.rawValue
            self.location = settings[UserDefaultsKey.LOCATION.rawValue] ?? Defaults.LOCATION.rawValue
            self.pageTitle = settings[UserDefaultsKey.PAGE_TITLE.rawValue] ?? Defaults.PAGE_TITLE.rawValue
        } else {
            self.accountName = Defaults.ACCOUNT_NAME.rawValue
            self.location = Defaults.LOCATION.rawValue
            self.pageTitle = Defaults.PAGE_TITLE.rawValue
        }
    }
    
    // MARK: - Methods
    func save() {
        let settings = [UserDefaultsKey.ACCOUNT_NAME.rawValue : accountName,
                        UserDefaultsKey.LOCATION.rawValue : location,
                        UserDefaultsKey.PAGE_TITLE.rawValue : pageTitle,
                        UserDefaultsKey.COLOR_SCHEME.rawValue : ColorScheme.shared.option.rawValue]
        UserDefaults.standard.set(settings,
                                  forKey: USER_DEFAULTS_NAME)
    }
    
}
