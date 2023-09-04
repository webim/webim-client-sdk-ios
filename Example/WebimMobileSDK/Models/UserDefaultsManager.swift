//
//  UserDefaultsManager.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 25.04.2023.
//  Copyright © 2023 Webim. All rights reserved.
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

protocol PropertyListValue: Codable {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

struct Key: RawRepresentable {
    let rawValue: String
}

extension Key: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

enum UserDefaultsDomain: String {
    case shareModule = "group.Webim.Share"
}

@propertyWrapper
struct UserDefault<T: PropertyListValue> {
    private let key: Key
    private var encode: Bool
    private let domain: String?
    private var storage: UserDefaults
    
    var wrappedValue: T? {
        get {
            let tmp = encode ? decodeAndGetValue() : (storage.object(forKey: key.rawValue) as? T)
            return tmp
        }
        set {
            encode ? encodeAndSetValue(newValue) : storage.set(newValue, forKey: key.rawValue)
        }
    }
    
    init(key: String, encode: Bool = false, domain: String? = nil) {
        self.key = Key(rawValue: key)
        self.domain = domain
        self.encode = encode
        storage = UserDefaults(suiteName: domain) ?? .standard
    }
    
    private func encodeAndSetValue(_ newValue: T?) {
        let encodedValue = try? PropertyListEncoder().encode(newValue)
        storage.set(encodedValue, forKey: key.rawValue)
    }
    
    private func decodeAndGetValue() -> T? {
        guard let data = storage.object(forKey: key.rawValue) as? Data else { return nil }
        return try? PropertyListDecoder().decode(T.self, from: data)
    }
}
