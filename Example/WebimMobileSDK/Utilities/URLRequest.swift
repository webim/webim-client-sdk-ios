//
//  URLRequest.swift
//  WebimMobileSDK_Example
//
//  Created by Anna Frolova on 12.03.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import Foundation
extension URLRequest {
    var isSendFileRequest: Bool {
        guard let url = url else { return false }
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return (urlComponents?.queryItems?.contains { $0.value == "upload_file" } == true)
    }
}
