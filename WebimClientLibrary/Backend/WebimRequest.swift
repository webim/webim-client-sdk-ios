//
//  WebimRequest.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
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

final class WebimRequest {
    
    // MARK: - Properties
    fileprivate var baseURLString: String
    fileprivate var boundaryString: String?
    fileprivate var completionHandler: ((_ data: Data?) throws -> ())?
    fileprivate var httpBody: Data?
    fileprivate var messageID: String?
    fileprivate var primaryData: [String : Any]
    fileprivate var sendFileCompletionHandler: SendFileCompletionHandler?
    
    // MARK: - Initialization
    init(withData primaryData: [String : Any],
         messageID: String? = nil,
         httpBody: Data? = nil,
         boundaryString: String? = nil,
         baseURLString: String,
         completionHandler: ((_ data: Data?) throws -> ())? = nil,
         sendFileCompletionHandler: SendFileCompletionHandler? = nil) {
        self.primaryData = primaryData
        self.messageID = messageID
        self.httpBody = httpBody
        self.boundaryString = boundaryString
        self.baseURLString = baseURLString
        self.completionHandler = completionHandler
        self.sendFileCompletionHandler = sendFileCompletionHandler
    }
    
    
    // MARK: - Methods
    
    func getBaseURLString() -> String {
        return baseURLString
    }
    
    func getBoundaryString() -> String? {
        return boundaryString
    }
    
    func getCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return completionHandler
    }
    
    func getHTTPBody() -> Data? {
        return httpBody
    }
    
    func getMessageID() -> String? {
        return messageID
    }
    
    func getPrimaryData() -> [String : Any] {
        return primaryData
    }
    
    func getSendFileCompletionHandler() -> SendFileCompletionHandler? {
        return sendFileCompletionHandler
    }
    
}

// MARK: - NSCopying
extension WebimRequest: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return WebimRequest(withData: primaryData,
                            messageID: messageID,
                            httpBody: httpBody,
                            boundaryString: boundaryString,
                            baseURLString: baseURLString,
                            completionHandler: completionHandler,
                            sendFileCompletionHandler: sendFileCompletionHandler)
    }
    
}
