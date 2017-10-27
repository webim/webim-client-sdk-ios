//
//  WebimInternalError.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
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

enum WebimInternalError: String, Error {
    case ACCOUNT_BLOCKED = "account-blocked"
    case VISITOR_BANNED = "visitor-banned"
    case REINIT_REQUIRED = "reinit-required"
    case SERVER_NOT_READY = "server-not-ready"
    case OPERATOR_NOT_IN_CHAT = "operator-not-in-chat"
    case WRONG_PROVIDED_VISITOR_HASH = "wrong-provided-visitor-hash-value"
    case PROVIDED_VISITOR_EXPIRED = "provided-visitor-expired"
    case UNKNOWN
}
