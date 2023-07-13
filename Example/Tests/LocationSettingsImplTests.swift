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
@testable import WebimMobileSDK

class LocationSettingsImplTests: XCTestCase {
    
    // MARK: - Constants
    private let userDefaultsKey = "LocationSettingsImplTests"
    private let getFrom_UserDefaultsKey = "test_GetFrom"
    private let getFrom_NilValue_UserDefaultsKey = "test_GetFrom_Null"
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        WMKeychainWrapper.standard.setDictionary([:], forKey: userDefaultsKey)
        WMKeychainWrapper.standard.setDictionary([:], forKey: getFrom_UserDefaultsKey)
        WMKeychainWrapper.standard.setDictionary([:], forKey: getFrom_NilValue_UserDefaultsKey)
    }
    
    override func tearDown() {
        WMKeychainWrapper.standard.setDictionary([:], forKey: userDefaultsKey)
        WMKeychainWrapper.standard.setDictionary([:], forKey: getFrom_UserDefaultsKey)
        WMKeychainWrapper.standard.setDictionary([:], forKey: getFrom_NilValue_UserDefaultsKey)
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_Init_AreHintsEnabled() {
        let sut = LocationSettingsImpl(hintsEnabled: true)

        XCTAssertTrue(sut.areHintsEnabled())
    }

    func test_GetFrom() {
        let locationSettingsToSave = LocationSettingsImpl(hintsEnabled: true)
        locationSettingsToSave.saveTo(userDefaults: getFrom_UserDefaultsKey)
        let expectedValue = locationSettingsToSave.areHintsEnabled()

        let sut = LocationSettingsImpl.getFrom(userDefaults: getFrom_UserDefaultsKey)

        XCTAssertEqual(sut.areHintsEnabled(), expectedValue)
    }

    func test_GetFrom_NullLocationSettings() {
        WMKeychainWrapper.standard.setDictionary([:], forKey: getFrom_NilValue_UserDefaultsKey)

        let sut = LocationSettingsImpl.getFrom(userDefaults: getFrom_UserDefaultsKey)

        XCTAssertFalse(sut.areHintsEnabled())
    }

    func test_SaveTo() {
        let locationSettingsToSave = LocationSettingsImpl(hintsEnabled: true)
        locationSettingsToSave.saveTo(userDefaults: getFrom_UserDefaultsKey)
        let expectedValue = locationSettingsToSave.areHintsEnabled()

        let sut = LocationSettingsImpl.getFrom(userDefaults: getFrom_UserDefaultsKey)

        XCTAssertEqual(sut.areHintsEnabled(), expectedValue)



        let secondLocationSettingsToSave = LocationSettingsImpl(hintsEnabled: false)
        secondLocationSettingsToSave.saveTo(userDefaults: getFrom_UserDefaultsKey)
        let secondExpectedValue = secondLocationSettingsToSave.areHintsEnabled()

        let secondSut = LocationSettingsImpl.getFrom(userDefaults: getFrom_UserDefaultsKey)

        XCTAssertEqual(secondSut.areHintsEnabled(), secondExpectedValue)
    }

    func test_EqualOperation() {
        let firstSut = LocationSettingsImpl(hintsEnabled: true)
        let secondSut = LocationSettingsImpl(hintsEnabled: true)
        let thirdSut = LocationSettingsImpl(hintsEnabled: false)

        XCTAssertEqual(firstSut.areHintsEnabled(), secondSut.areHintsEnabled())
        XCTAssertNotEqual(firstSut, thirdSut)
        XCTAssertNotEqual(secondSut, thirdSut)
    }
}
