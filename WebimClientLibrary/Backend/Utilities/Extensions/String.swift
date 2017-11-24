//
//  String.swift
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

import CryptoSwift
import Foundation

extension String {
    
    /**
     Percent escapes values to be added to a URL query as specified in RFC 3986.
     This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
     - SeeAlso:
     http://ietf.org/rfc/rfc3986.txt
     - returns:
     Percent-escaped string.
     - author:
     Nikita Lazarev-Lubov
     - copyright:
     2017 Webim
     */
    func addingPercentEncodingForURLQueryValue() -> String? {
        let generalDelimitersToEncode = ":#[]@" // Does not include "?" or "/" due to RFC 3986 - Section 3.4.
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
    /**
     Generates HMAC SHA256 code taken on passed key value for self.
     Using CryptoSwift.
     - parameter key:
     Key to generate hash code.
     - returns:
     Hash code of string taken with passed key.
     - author:
     Nikita Lazarev-Lubov
     - copyright:
     2017 Webim
     */
    func hmacSHA256(withKey key: String) -> String? {
        let stringBytes: [UInt8] = Array(self.utf8)
        let keyBytes: [UInt8] = Array(key.utf8)
        let hmac = try! HMAC(key: keyBytes,
                             variant: .sha256).authenticate(stringBytes).toHexString()
        
        return hmac
    }
    
}
