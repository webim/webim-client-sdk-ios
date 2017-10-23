//
//  InternalErrorListener.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

protocol InternalErrorListener {
    
    func on(error: String?,
            urlString: String)
    
}
