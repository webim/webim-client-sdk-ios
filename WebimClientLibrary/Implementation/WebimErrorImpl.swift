//
//  WebimErrorImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class WebimErrorImpl: WebimError {
    
    // MARK: - Properties
    var errorType: FatalErrorType?
    var errorString: String?
    
    // MARK: - Initialization
    init(errorType: FatalErrorType,
         errorString: String) {
        self.errorType = errorType
        self.errorString = errorString
    }
    
    // MARK: - WebimError protocol methods
    
    func getErrorType() -> FatalErrorType {
        return errorType!
    }
    
    func getErrorString() -> String {
        return (errorString == nil) ? String(describing: errorType) : errorString!
    }
    
}
