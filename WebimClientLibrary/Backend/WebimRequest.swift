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

/**
 Class that encapsulates paramters or HTTP-requests sending by WebimClientLibrary.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class WebimRequest {
    
    // MARK: - Properties
    private let baseURLString: String
    private let httpMethod: AbstractRequestLoop.HTTPMethod
    private let primaryData: [String: Any]
    private var contentType: String?
    private var dataMessageCompletionHandler: DataMessageCompletionHandler?
    private var historyRequestCompletionHandler: ((_ data: Data?) throws -> ())?
    private var httpBody: Data?
    private var messageID: String?
    private var rateOperatorCompletionHandler: RateOperatorCompletionHandler?
    private var sendFileCompletionHandler: SendFileCompletionHandler?
    
    // MARK: - Initialization
    init(httpMethod: AbstractRequestLoop.HTTPMethod,
         primaryData: [String: Any],
         messageID: String? = nil,
         httpBody: Data? = nil,
         contentType: String? = nil,
         baseURLString: String,
         historyRequestCompletionHandler: ((_ data: Data?) throws -> ())? = nil,
         dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
         rateOperatorCompletionHandler: RateOperatorCompletionHandler? = nil,
         sendFileCompletionHandler: SendFileCompletionHandler? = nil) {
        self.httpMethod = httpMethod
        self.primaryData = primaryData
        self.messageID = messageID
        self.httpBody = httpBody
        self.contentType = contentType
        self.baseURLString = baseURLString
        self.historyRequestCompletionHandler = historyRequestCompletionHandler
        self.dataMessageCompletionHandler = dataMessageCompletionHandler
        self.rateOperatorCompletionHandler = rateOperatorCompletionHandler
        self.sendFileCompletionHandler = sendFileCompletionHandler
    }
    
    
    // MARK: - Methods
    
    func getHTTPMethod() -> AbstractRequestLoop.HTTPMethod {
        return httpMethod
    }
    
    func getBaseURLString() -> String {
        return baseURLString
    }
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return historyRequestCompletionHandler
    }
    
    func getHTTPBody() -> Data? {
        return httpBody
    }
    
    func getMessageID() -> String? {
        return messageID
    }
    
    func getPrimaryData() -> [String: Any] {
        return primaryData
    }
    
    func getDataMessageCompletionHandler() -> DataMessageCompletionHandler? {
        return dataMessageCompletionHandler
    }
    
    func getRateOperatorCompletionHandler() -> RateOperatorCompletionHandler? {
        return rateOperatorCompletionHandler
    }
    
    func getSendFileCompletionHandler() -> SendFileCompletionHandler? {
        return sendFileCompletionHandler
    }
    
}

// MARK: - NSCopying
extension WebimRequest: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return WebimRequest(httpMethod: httpMethod,
                            primaryData: primaryData,
                            messageID: messageID,
                            httpBody: httpBody,
                            baseURLString: baseURLString,
                            historyRequestCompletionHandler: historyRequestCompletionHandler,
                            sendFileCompletionHandler: sendFileCompletionHandler)
    }
    
}
