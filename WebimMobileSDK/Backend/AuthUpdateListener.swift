//
//  AuthUpdateListener.swift
//  webim-client-sdk-ios
//
//  Created by Anna Frolova on 03.11.2026.
//

import Foundation

/**
 Class for update auth .
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
protocol AuthUpdateListener {
    
    /**
     Notifies that the server rejected `oldAuthorizationData` (`reinit-required`).
     - parameter oldAuthorizationData: Credentials the rejected request was signed with.
     The listener must ignore the call if the credentials have been already replaced by newer ones.
     */
    func sessionParametersNeedsToUpdate(oldAuthorizationData: AuthorizationData)
    
}
