//
//  String.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

extension String {
    
    /**
     Percent escapes values to be added to a URL query as specified in RFC 3986.
     This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
     - SeeAlso:
     http://www.ietf.org/rfc/rfc3986.txt
     - returns:
     Percent-escaped string.
     */
    func addingPercentEncodingForURLQueryValue() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
}
