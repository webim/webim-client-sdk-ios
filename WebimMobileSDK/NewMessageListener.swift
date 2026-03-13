//
//  NewMessageCountListener.swift
//  WebimMobileSDK
//
//  Copyright © 2025 Webim. All rights reserved.
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


/**
 This method call indicates that client app can change new message count.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Anna Frolova
 - copyright:
 2025 Webim
 */
public protocol InfoListener: AnyObject {
    
    /**
     When this method is called, client server must send provided authorization token to Webim service.
     - parameter count:
     The number of new messages.
     - author:
     Anna Frolova
     - copyright:
     2025 Webim
     */
    func update(newMessageCount: Int)
    
}
