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

// MARK: - DepartmentListHandlerDelegate

protocol DepartmentListHandlerDelegate: AnyObject {
    
    // MARK: - Methods
    
    func showDepartmentsList(
        _ departaments: [Department],
        action: @escaping (String) -> Void
    )
}

extension DepartmentListHandlerDelegate {
    
    func showDepartmentsList(_ departmentList: [Department], action: @escaping (String) -> Void) {}
}
