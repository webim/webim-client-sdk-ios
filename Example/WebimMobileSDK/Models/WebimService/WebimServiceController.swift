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
import WebimMobileSDK

class WebimServiceController {
    
    static let shared = WebimServiceController()
    
    static var currentSession: WebimService {
        return WebimServiceController.shared.currentSession()
    }
    
    static var currentSessionShare: WebimService {
        return WebimServiceController.shared.createSession()
    }
    
    weak var fatalErrorHandlerDelegate: FatalErrorHandlerDelegate?
    weak var departmentListHandlerDelegate: DepartmentListHandlerDelegate?
    weak var notFatalErrorHandler: NotFatalErrorHandler?
    
    private var webimService: WebimService?
    
    func createSession(jsonString: String? = nil, jsonData: Data? = nil) -> WebimService {
        
        stopSession()
        print("createSession")
        let service = WebimService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        service.createSession(jsonString: jsonString, jsonData: jsonData)
        service.resumeSession()
        service.setMessageStream()
        
        self.webimService = service
        return service
    }
    
    func setCurrentSession(_ session: WebimSession) {
        stopSession()
        print("createSession")
        let webimService = WebimService(
            fatalErrorHandlerDelegate: self,
            departmentListHandlerDelegate: self,
            notFatalErrorHandler: self
        )
        
        webimService.set(session: session)
        webimService.resumeSession()
        webimService.setMessageStream()
        
        self.webimService = webimService
    }
    
    func currentSession() -> WebimService {
        return self.webimService ?? createSession()
    }
    
    func stopSession() {
        print("stopSession")
        self.webimService?.stopSession()
        self.webimService = nil
    }
    
    func sessionState() -> ChatState {
        return webimService?.sessionState() ?? .unknown
    }
}

extension WebimServiceController: FatalErrorHandlerDelegate {
    
    func showErrorDialog(withMessage message: String) {
        self.fatalErrorHandlerDelegate?.showErrorDialog(withMessage: message)
    }
}

extension WebimServiceController: DepartmentListHandlerDelegate {
    
    func showDepartmentsList(_ departaments: [Department], action: @escaping (String) -> Void ) {
        self.departmentListHandlerDelegate?.showDepartmentsList(departaments, action: action)
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
