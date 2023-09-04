//
//  Dictionary.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.10.17.
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

extension Dictionary {
    
    // MARK: - Methods
    /**
     Build string representation of HTTP parameter dictionary of keys and objects.
     This percent escapes in compliance with RFC 3986.
     - important:
     Supports only non-optional String keys and values.
     - seealso:
     http://www.ietf.org/rfc/rfc3986.txt
     - returns:
     String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func stringFromHTTPParameters() -> String {
        let parameterArray = map { (key, value) -> String in
            guard let key = key as? String else {
                    WebimInternalLogger.shared.log(entry: "Key has incorrect type or nil in extension Dictionary.\(#function)")
                    return String()
            }
            
            return getPercentEscapedString(forKey: key, value: value)
        }
        
        return parameterArray.joined(separator: "&")
    }
    
    private func getPercentEscapedString<T>(forKey key: String, value: T?) -> String {
        guard let value = value else {
            WebimInternalLogger.shared.log(entry: "Value is nil in extension Dictionary.\(#function)")
            return String()
        }
        
        var stringValue: String
        switch value {
        case is String,
             is Int,
             is Int64,
             is Double:
            stringValue = "\(value)"
        case is Bool:
            stringValue = (value as? Bool ?? false) ? "1" : "0"
        default:
            WebimInternalLogger.shared.log(entry: "Value has incorrect type in extension Dictionary.\(#function)")
            return String()
        }
        
        guard let percentEscapedKey = key.addingPercentEncodingForURLQueryValue() else {
            WebimInternalLogger.shared.log(entry: "Adding Percent Encoding For URL Query Value to Key failure in Extension Dictionary.\(#function)")
            return "\(key)=\(stringValue)"
        }
        
        guard let percentEscapedValue = stringValue.addingPercentEncodingForURLQueryValue() else {
            WebimInternalLogger.shared.log(entry: "Adding Percent Encoding For URL Query Value to Value failure in Extension Dictionary.\(#function)")
            return "\(key)=\(stringValue)"
        }
        
        return "\(percentEscapedKey)=\(percentEscapedValue)"
    }
    
}
