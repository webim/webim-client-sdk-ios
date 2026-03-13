//
//  WebimService+Delegate.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 19.02.2025.
//  Copyright © 2025 Webim. All rights reserved.
//

import WebimMobileSDK

// MARK: - FatalErrorHandlerDelegate

protocol FatalErrorHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    
    func showErrorDialog(withMessage message: String)
    
}
