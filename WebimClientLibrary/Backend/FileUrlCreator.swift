//
//  FileUrlCreator.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 03.03.2021.
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

import Foundation

/**
 - author:
 Nikita Kaberov
 - copyright:
 2021 Webim
 */

final class FileUrlCreator {
    
    // MARK: - Constants
    private enum Period: Int64 {
        case attachmentURLExpires = 300 // (seconds) = 5 (minutes).
    }

    // MARK: - Properties
    private weak var webimClient: WebimClient?
    private let serverURL: String
    
    // MARK: - Initialization
    init(webimClient: WebimClient,
         serverURL: String) {
        self.webimClient = webimClient
        self.serverURL = serverURL
    }
    
    // MARK: - Methods
    func createFileURL(byFilename filename: String, guid: String, isThumb: Bool = false) -> String? {
        guard let pageID = webimClient?.getDeltaRequestLoop().getAuthorizationData()?.getPageID(),
            let authorizationToken = webimClient?.getDeltaRequestLoop().getAuthorizationData()?.getAuthorizationToken() else {
                WebimInternalLogger.shared.log(entry: "Tried to access to message attachment without authorization data.")
                
                return nil
        }
        let expires = Int64(Date().timeIntervalSince1970) + Period.attachmentURLExpires.rawValue
        let data: String = guid + String(expires)
        if let hash = data.hmacSHA256(withKey: authorizationToken) {
            var formatedFilename = filename
            if let filenameWithAllowedCharacters = filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                formatedFilename = filenameWithAllowedCharacters
            } else {
                WebimInternalLogger.shared.log(entry: "Adding Percent Encoding With Allowed Characters failure in MessageImpl.\(#function)",
                                               verbosityLevel: .warning)
            }
            let fileURLString = serverURL + WebimActions.ServerPathSuffix.downloadFile.rawValue + "/"
                + guid + "/"
                + formatedFilename + "?"
                + "page-id" + "=" + pageID + "&"
                + "expires" + "=" + String(expires) + "&"
                + "hash" + "=" + hash
                + (isThumb ? "&thumb=ios" : "")
            
            return fileURLString
        }
        WebimInternalLogger.shared.log(entry: "Error creating message attachment link due to HMAC SHA256 encoding error.")
        
        return nil
    }
}
