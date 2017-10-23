//
//  LocationSettingsImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class LocationSettingsImpl: LocationSettings {
    
    // MARK: - Constants
    enum UserDefaultsKey: String {
        case HINTS_ENABLED = "hints_enabled"
    }
    
    // MARK: - Properties
    fileprivate var hintsEnabled: Bool?
    
    
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
        return hintsEnabled == true
    }
    
}

// MARK: - Equatable
extension LocationSettingsImpl: Equatable {
    
    static func == (lhs: LocationSettingsImpl,
                    rhs: LocationSettingsImpl) -> Bool {
        return lhs.hintsEnabled == lhs.hintsEnabled
    }
    
}
