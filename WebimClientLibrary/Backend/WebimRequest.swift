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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class WebimRequest {
    
    // MARK: - Properties
    private let baseURLString: String
    private let httpMethod: AbstractRequestLoop.HTTPMethods
    private let primaryData: [String: Any]
    private var contentType: String?
    private weak var dataMessageCompletionHandler: DataMessageCompletionHandler?
    private var historyRequestCompletionHandler: ((_ data: Data?) throws -> ())?
    private var faqItemRequestCompletionHandler: ((_ item: Data?) throws -> ())?
    private var faqCategoryRequestCompletionHandler: ((_ item: Data?) throws -> ())?
    private var faqStructureRequestCompletionHandler: ((_ item: Data?) throws -> ())?
    private var httpBody: Data?
    private var messageID: String?
    private var filename: String?
    private var mimeType: String?
    private var fileData: Data?
    private var boundaryString: String?
    private weak var rateOperatorCompletionHandler: RateOperatorCompletionHandler?
    private var sendFileCompletionHandler: SendFileCompletionHandler?
    private var deleteMessageCompletionHandler: DeleteMessageCompletionHandler?
    private var editMessageCompletionHandler: EditMessageCompletionHandler?
    private var sendKeyboardRequestCompletionHandler: SendKeyboardRequestCompletionHandler?
    
    // MARK: - Initialization
    init(httpMethod: AbstractRequestLoop.HTTPMethods,
         primaryData: [String: Any],
         messageID: String? = nil,
         filename: String? = nil,
         mimeType: String? = nil,
         fileData: Data? = nil,
         boundaryString: String? = nil,
         contentType: String? = nil,
         baseURLString: String,
         historyRequestCompletionHandler: ((_ data: Data?) throws -> ())? = nil,
         faqItemRequestCompletionHandler: ((_ item: Data?) throws -> ())? = nil,
         faqCategoryRequestCompletionHandler: ((_ item: Data?) throws -> ())? = nil,
         faqStructureRequestCompletionHandler: ((_ item: Data?) throws -> ())? = nil,
         dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
         rateOperatorCompletionHandler: RateOperatorCompletionHandler? = nil,
         sendFileCompletionHandler: SendFileCompletionHandler? = nil,
         deleteMessageCompletionHandler: DeleteMessageCompletionHandler? = nil,
         editMessageCompletionHandler: EditMessageCompletionHandler? = nil,
         keyboardResponseCompletionHandler: SendKeyboardRequestCompletionHandler? = nil) {
        self.httpMethod = httpMethod
        self.primaryData = primaryData
        self.messageID = messageID
        self.filename = filename
        self.mimeType = mimeType
        self.fileData = fileData
        self.boundaryString = boundaryString
        self.contentType = contentType
        self.baseURLString = baseURLString
        self.historyRequestCompletionHandler = historyRequestCompletionHandler
        self.dataMessageCompletionHandler = dataMessageCompletionHandler
        self.rateOperatorCompletionHandler = rateOperatorCompletionHandler
        self.sendFileCompletionHandler = sendFileCompletionHandler
        self.deleteMessageCompletionHandler = deleteMessageCompletionHandler
        self.editMessageCompletionHandler = editMessageCompletionHandler
        self.sendKeyboardRequestCompletionHandler = keyboardResponseCompletionHandler
        self.faqItemRequestCompletionHandler = faqItemRequestCompletionHandler
        self.faqCategoryRequestCompletionHandler = faqCategoryRequestCompletionHandler
        self.faqStructureRequestCompletionHandler = faqStructureRequestCompletionHandler
    }
    
    
    // MARK: - Methods
    
    func getHTTPMethod() -> AbstractRequestLoop.HTTPMethods {
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
    
    func getFAQItemRequestCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return faqItemRequestCompletionHandler
    }
    
    func getFAQCategoryRequestCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return faqCategoryRequestCompletionHandler
    }
    
    func getFAQStructureRequestCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return faqStructureRequestCompletionHandler
    }
    
    func getFileName() -> String? {
        return filename
    }
    
    func getMimeType() -> String? {
        return mimeType
    }
    
    func getFileData() -> Data? {
        return fileData
    }
    
    func getBoundaryString() -> String? {
        return boundaryString
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
    
    func getDeleteMessageCompletionHandler() -> DeleteMessageCompletionHandler? {
        return deleteMessageCompletionHandler
    }
    
    func getEditMessageCompletionHandler() -> EditMessageCompletionHandler? {
        return editMessageCompletionHandler
    }
    
    func getKeyboardResponseCompletionHandler() -> SendKeyboardRequestCompletionHandler? {
        return sendKeyboardRequestCompletionHandler
    }
}
