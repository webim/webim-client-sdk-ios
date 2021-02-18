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
    private var dataMessageCompletionHandler: DataMessageCompletionHandler?
    private var historyRequestCompletionHandler: ((_ data: Data?) throws -> ())?
    private var locationStatusRequestCompletionHandler: ((_ data: Data?) throws -> ())?
    private var faqCompletionHandler: ((_ data: Data?) throws -> ())?
    private var messageID: String?
    private var filename: String?
    private var mimeType: String?
    private var fileData: Data?
    private var boundaryString: String?
    private var rateOperatorCompletionHandler: RateOperatorCompletionHandler?
    private var sendMessageComplitionHandler: SendMessageCompletionHandler?
    private var sendFileCompletionHandler: SendFileCompletionHandler?
    private var deleteMessageCompletionHandler: DeleteMessageCompletionHandler?
    private var editMessageCompletionHandler: EditMessageCompletionHandler?
    private var sendKeyboardRequestCompletionHandler: SendKeyboardRequestCompletionHandler?
    private var sendDialogToEmailAddressCompletionHandler: SendDialogToEmailAddressCompletionHandler?
    private var sendStickerCompletionHandler: SendStickerCompletionHandler?
    private var sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper?
    private var surveyCloseCompletionHandler: SurveyCloseCompletionHandler?
    private var sendFilesCompletionHandler: SendFilesCompletionHandler?
    private var deleteUploadedFileCompletionHandler: DeleteUploadedFileCompletionHandler?
    private var uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler?
    
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
         locationStatusRequestCompletionHandler: ((_ data: Data?) throws -> ())? = nil,
         faqCompletionHandler: ((_ data: Data?) throws -> ())? = nil,
         dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
         rateOperatorCompletionHandler: RateOperatorCompletionHandler? = nil,
         sendFileCompletionHandler: SendFileCompletionHandler? = nil,
         deleteMessageCompletionHandler: DeleteMessageCompletionHandler? = nil,
         editMessageCompletionHandler: EditMessageCompletionHandler? = nil,
         keyboardResponseCompletionHandler: SendKeyboardRequestCompletionHandler? = nil,
         sendDialogToEmailAddressCompletionHandler: SendDialogToEmailAddressCompletionHandler? = nil,
         sendStickerCompletionHandler: SendStickerCompletionHandler? = nil,
         sendMessageCompletionHandler: SendMessageCompletionHandler? = nil,
         sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper? = nil,
         surveyCloseCompletionHandler: SurveyCloseCompletionHandler? = nil,
         sendFilesCompletionHandler: SendFilesCompletionHandler? = nil,
         deleteUploadedFileCompletionHandler: DeleteUploadedFileCompletionHandler? = nil,
         uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler? = nil) {
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
        self.locationStatusRequestCompletionHandler = locationStatusRequestCompletionHandler
        self.dataMessageCompletionHandler = dataMessageCompletionHandler
        self.rateOperatorCompletionHandler = rateOperatorCompletionHandler
        self.sendMessageComplitionHandler = sendMessageCompletionHandler
        self.sendFileCompletionHandler = sendFileCompletionHandler
        self.deleteMessageCompletionHandler = deleteMessageCompletionHandler
        self.editMessageCompletionHandler = editMessageCompletionHandler
        self.sendKeyboardRequestCompletionHandler = keyboardResponseCompletionHandler
        self.faqCompletionHandler = faqCompletionHandler
        self.sendDialogToEmailAddressCompletionHandler = sendDialogToEmailAddressCompletionHandler
        self.sendStickerCompletionHandler = sendStickerCompletionHandler
        self.sendSurveyAnswerCompletionHandler = sendSurveyAnswerCompletionHandler
        self.surveyCloseCompletionHandler = surveyCloseCompletionHandler
        self.sendFilesCompletionHandler = sendFilesCompletionHandler
        self.deleteUploadedFileCompletionHandler = deleteUploadedFileCompletionHandler
        self.uploadFileToServerCompletionHandler = uploadFileToServerCompletionHandler
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
    
    func getLocationStatusCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return locationStatusRequestCompletionHandler
    }
    
    func getFAQCompletionHandler() -> ((_ data: Data?) throws -> ())? {
        return faqCompletionHandler
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
    
    func getSendMessageCompletionHandler() -> SendMessageCompletionHandler? {
        return sendMessageComplitionHandler
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
    
    func getSendDialogToEmailAddressCompletionHandler() -> SendDialogToEmailAddressCompletionHandler? {
        return sendDialogToEmailAddressCompletionHandler
    }
    
    func getSendStickerCompletionHandler() -> SendStickerCompletionHandler? {
        return sendStickerCompletionHandler
    }
    
    func getSendSurveyAnswerCompletionHandler() -> SendSurveyAnswerCompletionHandlerWrapper? {
        return sendSurveyAnswerCompletionHandler
    }
    
    func getSurveyCloseCompletionHandler() -> SurveyCloseCompletionHandler? {
        return surveyCloseCompletionHandler
    }
    
    func getSendFilesCompletionHandler() -> SendFilesCompletionHandler? {
        return sendFilesCompletionHandler
    }
    
    func getDeleteUploadedFileCompletionHandler() -> DeleteUploadedFileCompletionHandler? {
        return deleteUploadedFileCompletionHandler
    }
    
    func getUploadFileToServerCompletionHandler() -> UploadFileToServerCompletionHandler? {
        return uploadFileToServerCompletionHandler
    }
}
