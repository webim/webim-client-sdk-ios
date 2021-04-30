//
//  NotFatalErrorHandler.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 06.10.19.
//  Copyright © 2019 Webim. All rights reserved.
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
 Protocol that provides methods to handle not fatal errors are sent by Webim service.
 - seealso:
 `set(fatalErrorHandler:)` method of `SessionBuilder` class.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol NotFatalErrorHandler: class {
    
    /**
     This method is to be called when Webim service error is received.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     - parameter error:
     Error type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func on(error: WebimNotFatalError)
    
    /**
     This method is to be called when Webim service receive any data from server or connection error.
     - important:
     Method called NOT FROM THE MAIN THREAD!
     */
    func connectionStateChanged(connected: Bool)
    
}
