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
    
    func sessionParametersNeedsToUpdate()
    
}
