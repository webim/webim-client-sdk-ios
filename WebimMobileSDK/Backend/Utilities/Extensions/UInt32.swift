//
//  UInt32.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.01.18.
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

extension UInt32 {
    
    // MARK: - Initialization
    /**
     Part or HMAC SHA256 generation system.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    @_specialize(where T == ArraySlice<UInt8>)
    init<T: Collection>(bytes: T,
                        fromIndex index: T.Index) where T.Element == UInt8, T.Index == Int {
        if bytes.isEmpty {
            self = 0
            
            return
        }
        
        let count = bytes.count
        
        let val0 = ((count > 0) ? (UInt32(bytes[index.advanced(by: 0)]) << 24) : 0)
        let val1 = ((count > 1) ? (UInt32(bytes[index.advanced(by: 1)]) << 16) : 0)
        let val2 = ((count > 2) ? (UInt32(bytes[index.advanced(by: 2)]) << 8) : 0)
        let val3 = ((count > 3) ? UInt32(bytes[index.advanced(by: 3)]) : 0)
        
        self = val0 | val1 | val2 | val3
    }
    
}
