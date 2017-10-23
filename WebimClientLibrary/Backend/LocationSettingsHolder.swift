//
//  LocationSettingsHolder.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class LocationSettingsHolder {
    
    // MARK: - Properties
    private let locationSettings: LocationSettingsImpl
    private let userDefaultsKey: String
    
    
    // MARK: - Initialization
    init(withUserDefaults userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        self.locationSettings = LocationSettingsImpl.getFrom(userDefaults: userDefaultsKey)
    }
    
    
    // MARK: - Methods
    func getLocationSettings() -> LocationSettingsImpl {
        return locationSettings
    }
    
    func receiving(locationSettings: LocationSettingsImpl) -> Bool {
        if locationSettings != self.locationSettings {
            locationSettings.saveTo(userDefaults: userDefaultsKey)
            return true
        }
        
        return false
    }
    
}
