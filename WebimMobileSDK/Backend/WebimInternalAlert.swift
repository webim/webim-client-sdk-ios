//
//  WebimInternalAlert.swift
//  WebimClientLibrary
//
//  Created by Никита on 10.10.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
 Class that wraps `WebimAlert` into singleton pattern.
 First, one should call `setup(webimAlert:)` method with particular parameters, then it will be possible to use `WebimInternalAlert.shared`.
 - seealso:
 `WebimAlert`.
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
final class WebimInternalAlert {
    
    // MARK: - Properties
    static let shared = WebimInternalAlert()
    private static let setup = WebimInternalAlertParametersHelper()
    
    // MARK: - Initialization
    private init() {
        // Needed for singleton pattern.
    }
    
    // MARK: - Methods
    
    class func setup(webimAlert: WebimAlert?) {
        WebimInternalAlert.setup.webimAlert = webimAlert
    }
    
    func present(title: WebimAlertTitle, message: WebimAlertMessage) {
        WebimInternalAlert.setup.webimAlert?.present(title: title, message: message)
    }
}

/**
 Helper class for `WebimInternalAlert` singleton instance setup.
 - seealso:
 `WebimInternalAlert`.
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
final class WebimInternalAlertParametersHelper {
    
    // MARK: - Properties
    weak var webimAlert: WebimAlert?
    
}
