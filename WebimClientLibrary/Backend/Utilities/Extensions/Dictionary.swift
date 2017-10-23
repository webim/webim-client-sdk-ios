//
//  Dictionary.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /**
     Build string representation of HTTP parameter dictionary of keys and objects.
     This percent escapes in compliance with RFC 3986.
     - SeeAlso:
     http://www.ietf.org/rfc/rfc3986.txt
     - returns:
     String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped.
     */
    func stringFromHTTPParameters() -> String {
        let parameterArray = map { key, value -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
