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

/**
 Errors that can be received from a server after a HTTP-request.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
enum WebimInternalError: String, Error {
    case accountBlocked = "account-blocked"
    case fileSizeExceeded = "max_file_size_exceeded"
    case fileTypeNotAllowed = "not_allowed_file_type"
    case providedVisitorFieldsExpired = "provided-visitor-expired"
    case reinitializationRequired = "reinit-required"
    case serverNotReady = "server-not-ready"
    case visitorBanned = "visitor_banned"
    case wrongArgumentValue = "wrong-argument-value"
    case wrongProvidedVisitorFieldsHashValue = "wrong-provided-visitor-hash-value"
    
    // Data errors
    // Quoting message errors
    case quotedMessageCannotBeReplied = "quoting-message-that-cannot-be-replied"
    case quotedMessageFromAnotherVisitor = "quoting-message-from-another-visitor"
    case quotedMessageCorruptedID = "corrupted-quoted-message-id"
    case quotedMessageMultipleID = "multiple-quoted-messages-found"
    case quotedMessageNotFound = "quoted-message-not-found"
    case quotedMessageRequiredArgumentsMissing = "required-quote-args-missing"
    
    // Provided authonication token errors
    case providedAuthenticationTokenNotFound = "provided-auth-token-not-found"
    
    // Rate operator errors
    case noChat = "no-chat"
    case operatorNotInChat = "operator-not-in-chat"
}
