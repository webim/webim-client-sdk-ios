//
//  WebimLogger.swift
//  Cosmos
//
//  Created by Nikita Lazarev-Zubov on 08.12.17.
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

/**
 Protocol that provides methods for implementing custom WebimClientLibrary network requests logging.
 It can be useful for debugging production releases if debug logs are not available.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol WebimLogger: AnyObject {
    
    /**
     Method which is called after new WebimClientLibrary network request log entry came out.
     - parameter entry:
     New WebimClientLibrary network request log entry.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func log(entry: String)
    
}
