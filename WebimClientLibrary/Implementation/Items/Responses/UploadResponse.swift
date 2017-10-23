//
//  UploadResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

class UploadResponse: DefaultResponse {
    
    // MARK: - Properties
    private var fileParameters: FileParametersItem?
    
    // MARK: - Methods
    func getFileParameters() -> FileParametersItem? {
        return fileParameters
    }
    
}
