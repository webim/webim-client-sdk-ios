//
//  ProvidedAuthorizationTokenStateListener.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 06.12.17.
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
 When client provides custom visitor authorization mechanism, it can be realised by providing custom authorization token which is used instead of visitor fields.
 When provided authorization token is generated (or passed to session by client app), `update(providedAuthorizationToken:)` method is called. This method call indicates that client app must send provided authorisation token to its server which is responsible to send it to Webim service.
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol ProvidedAuthorizationTokenStateListener: class {
    
    /**
     Method is called in two cases:
     1. Provided authorization token is genrated (or set by client app) and must be sent to client server which is responsible to send it to Webim service.
     2. Passed provided authorization token is not valid. Provided authorization token can be invalid if Webim service did not receive it from client server yet.
     When this method is called, client server must send provided authorization token to Webim service.
     - parameter providedAuthorizationToken:
     Provided authorization token which corresponds to session.
     - seealso:
     `set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func update(providedAuthorizationToken: String)
    
}
