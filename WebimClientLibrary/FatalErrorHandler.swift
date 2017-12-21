//
//  FatalErrorHandler.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
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
 - SeeAlso:
 `set(fatalErrorHandler:)` method of `SessionBuilder` class.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol FatalErrorHandler {
    
    /**
     This method is to be called when Webim service error is received.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     - parameter error:
     Error type.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func on(error: WebimError)
    
}
