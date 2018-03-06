//
//  Int.swift
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

extension Int {
    
    // MARK: - Methods
    /**
     Part or HMAC SHA256 generation system.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    @_transparent
    func bytes(totalBytes: Int) -> Array<UInt8> {
        let valuePointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        valuePointer.pointee = self
        
        let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
        var bytes = Array<UInt8>(repeating: 0,
                                 count: totalBytes)
        let memoryLayoutSize = MemoryLayout<Int>.size
        let constraint = ((memoryLayoutSize < totalBytes) ? memoryLayoutSize : totalBytes)
        for j in 0 ..< constraint {
            bytes[(totalBytes - 1 - j)] = (bytesPointer + j).pointee
        }
        
        valuePointer.deinitialize()
        valuePointer.deallocate(capacity: 1)
        
        return bytes
    }
 
}
