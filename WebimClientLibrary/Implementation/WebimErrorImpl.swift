//
//  WebimErrorImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
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
 Public Webim service error representation.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimErrorImpl: WebimError {
    
    // MARK: - Properties
    private var errorType: FatalErrorType
    private var errorString: String?
    
    // MARK: - Initialization
    init(errorType: FatalErrorType,
         errorString: String?) {
        self.errorType = errorType
        self.errorString = errorString
    }
    
    // MARK: - Methods
    // MARK: WebimError protocol methods
    
    func getErrorType() -> FatalErrorType {
        return errorType
    }
    
    func getErrorString() -> String {
        return (errorString ?? String(describing: errorType))
    }
    
}
