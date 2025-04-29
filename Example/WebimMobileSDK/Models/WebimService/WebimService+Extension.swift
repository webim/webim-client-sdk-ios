//
//  WebimService+Extension.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 29.01.2025.
//  Copyright © 2025 Webim. All rights reserved.
//

import WebimMobileSDK

// MARK: - WEBIM: FatalErrorHandler

extension WebimService: FatalErrorHandler {
    
    // MARK: - Methods
    
    func on(error: WebimError) {
        let errorType = error.getErrorType()
        switch errorType {
        case .accountBlocked:
            // Assuming to contact with Webim support.
            print("Account with used account name is blocked by Webim service.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "AccountBlocked".localized)
            
        case .providedVisitorFieldsExpired:
            // Assuming to re-authorize it and re-create session object.
            print("Provided visitor fields expired. See \"expires\" key of this fields.")
            
        case .unknown:
            print("An unknown error occured: \(error.getErrorString()).")
            
        case .visitorBanned:
            print("Visitor with provided visitor fields is banned by an operator.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Your visitor account is in the black list.".localized)
            
        case .wrongProvidedVisitorHash:
            // Assuming to check visitor field generating.
            print("Wrong CRC passed with visitor fields.")
            
        case .initializationFailed:
            print("Session initialization failed.")
            fatalErrorHandlerDelegate?.showErrorDialog(withMessage: "Session initialization failed.".localized)
        }
    }
    
}

// MARK: - WEBIM: NotFatalErrorHandler

extension WebimService: NotFatalErrorHandler {
    
    func on(error: WebimNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
    
}
