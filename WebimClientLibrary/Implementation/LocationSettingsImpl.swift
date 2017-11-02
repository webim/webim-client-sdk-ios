//
//  LocationSettingsImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
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

final class LocationSettingsImpl: LocationSettings {
    
    // MARK: - Constants
    enum UserDefaultsKey: String {
        case HINTS_ENABLED = "hints_enabled"
    }
    
    // MARK: - Properties
    fileprivate var hintsEnabled: Bool
    
    
    // MARK: - Initialization
    init(withHintsEnabled hintsEnabled: Bool) {
        self.hintsEnabled = hintsEnabled
    }
    
    
    // MARK: - Methods
    
    static func getFrom(userDefaults userDefaultsKey: String) -> LocationSettingsImpl {
        if let userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            if let hintsEnabled = userDefaults[UserDefaultsKey.HINTS_ENABLED.rawValue] as? Bool {
                return LocationSettingsImpl(withHintsEnabled: hintsEnabled)
            }
        }
        
        return LocationSettingsImpl(withHintsEnabled: false)
    }
    
    func saveTo(userDefaults userDefaultsKey: String) {
        if var userDefaults = UserDefaults.standard.dictionary(forKey: userDefaultsKey) {
            userDefaults[UserDefaultsKey.HINTS_ENABLED.rawValue] = hintsEnabled
            UserDefaults.standard.set(userDefaults,
                                      forKey: userDefaultsKey)
        }
        
        UserDefaults.standard.setValue([UserDefaultsKey.HINTS_ENABLED.rawValue : hintsEnabled],
                                       forKey: userDefaultsKey)
    }
    
    
    // MARK: - LocationSettings protocol methods
    func areHintsEnabled() -> Bool {
        return hintsEnabled
    }
    
}

// MARK: - Equatable
extension LocationSettingsImpl: Equatable {
    
    static func == (lhs: LocationSettingsImpl,
                    rhs: LocationSettingsImpl) -> Bool {
        return lhs.hintsEnabled == lhs.hintsEnabled
    }
    
}
