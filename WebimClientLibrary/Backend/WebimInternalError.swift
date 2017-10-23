//
//  WebimInternalError.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
//  Copyright © 2017 Webim. All rights reserved.
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
