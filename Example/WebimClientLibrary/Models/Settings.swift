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
import WebimMobileSDK
// MARK: - Global constants
let USER_DEFAULTS_NAME = "settings_demo"
enum WMSettingsKeychainKey: String {
    case accountName = "account_name"
    case location = "location"
    case pageTitle = "page_title"
    case userDataJson = "userDataJson"
}

// MARK: -
final class Settings {
    
    // MARK: - Constants
    enum DefaultSettings: String {
        case accountName = "demo"
        case location = "mobile"
        case pageTitle = "iOS app"
        case userDataJson = ""
    }
    
    // MARK: - Properties
    static let shared = Settings()
    var accountName: String
    var location: String
    var pageTitle: String
    var userDataJson: String
    
    // MARK: - Initialization
    private init() {
        if let settings = WMKeychainWrapper.standard.dictionary(forKey: USER_DEFAULTS_NAME)
            as? [String: String] {
            self.accountName = settings[WMSettingsKeychainKey.accountName.rawValue] ??
                DefaultSettings.accountName.rawValue
            self.location = settings[WMSettingsKeychainKey.location.rawValue] ??
                DefaultSettings.location.rawValue
            self.pageTitle = settings[WMSettingsKeychainKey.pageTitle.rawValue] ??
                DefaultSettings.pageTitle.rawValue
            self.userDataJson = settings[WMSettingsKeychainKey.userDataJson.rawValue] ??
                DefaultSettings.userDataJson.rawValue
        } else {
            self.accountName = DefaultSettings.accountName.rawValue
            self.location = DefaultSettings.location.rawValue
            self.pageTitle = DefaultSettings.pageTitle.rawValue
            self.userDataJson = DefaultSettings.userDataJson.rawValue
        }
        validateData()
    }
    
    func validateData() {
        if !"https://\(accountName).webim.ru/".validateURLString() {
            self.accountName = "demo"
        }
    }
    
    // MARK: - Methods
    func save() {
        validateData()
        let settings = [
            WMSettingsKeychainKey.accountName.rawValue: accountName,
            WMSettingsKeychainKey.location.rawValue: location,
            WMSettingsKeychainKey.pageTitle.rawValue: pageTitle
        ]
        
        WMKeychainWrapper.standard.setDictionary(settings,
                                  forKey: USER_DEFAULTS_NAME)
    }
    
}
