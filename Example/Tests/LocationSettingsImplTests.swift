//
//  LocationSettingsImplTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 20.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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
import XCTest
@testable import WebimClientLibrary

class LocationSettingsImplTests: XCTestCase {
    
    // MARK: - Constants
    private static let USER_DEFAULTS_KEY = "mock"
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        
        WMKeychainWrapper.removeObject(key: LocationSettingsImplTests.USER_DEFAULTS_KEY)
    }
    
    override func tearDown() {
        WMKeychainWrapper.removeObject(key: LocationSettingsImplTests.USER_DEFAULTS_KEY)
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInit() {
        let locationSettings = LocationSettingsImpl(hintsEnabled: true)
        
        XCTAssertTrue(locationSettings.areHintsEnabled())
    }
    
    func testGetSave() {
        let USER_DEFAULTS_KEY = "test"
        
        let locationSettings = LocationSettingsImpl(hintsEnabled: true)
        locationSettings.saveTo(userDefaults: USER_DEFAULTS_KEY)
        
        let restoredLocationSettings = LocationSettingsImpl.getFrom(userDefaults: USER_DEFAULTS_KEY)
        
        XCTAssertEqual(locationSettings.areHintsEnabled(),
                       restoredLocationSettings.areHintsEnabled())
    }
    
}
