//
//  WebimServiceController.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 18.03.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

import UIKit
import WebimClientLibrary

class WebimServiceController {
    
    static let shared = WebimServiceController()
    
    private var webimService: WebimService?
    
    weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    weak var notFatalErrorHandler: NotFatalErrorHandler?
    
    private func createSession() -> WebimService {
        
        stopSession()
        
        let service = WebimService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        service.createSession()
        service.startSession()
        service.setMessageStream()
        
        self.webimService = service
        return service
    }
    
    static var currentSession: WebimService {
        return WebimServiceController.shared.currentSession()
    }
    
    func currentSession() -> WebimService {
        return self.webimService ?? createSession()
    }
    
    func stopSession() {
        self.webimService?.stopSession()
        self.webimService = nil
    }
}

extension WebimServiceController: FatalErrorHandlerDelegate {
    
    func showErrorDialog(withMessage message: String) {
        self.fatalErrorHandlerDelegate?.showErrorDialog(withMessage: message)
    }
}

extension WebimServiceController: DepartmentListHandlerDelegate {
    
    func show(departmentList: [Department], message: String?, action: @escaping (String) -> Void ) {
        self.departmentListHandlerDelegate?.show(departmentList: departmentList, message: message, action: action)
    }
}

extension WebimServiceController: NotFatalErrorHandler {
    
    func on(error: WebimNotFatalError) {
        self.notFatalErrorHandler?.on(error: error)
    }
    
    func connectionStateChanged(connected: Bool) {
        self.notFatalErrorHandler?.connectionStateChanged(connected: connected)
    }
}
