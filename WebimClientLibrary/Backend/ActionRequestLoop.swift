//
//  ActionRequestLoop.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that handles HTTP-requests sended by WebimClientLibrary with visitor requested actions (e.g. sending messages, operator rating, chat closing etc.).
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class ActionRequestLoop: AbstractRequestLoop {
    
    // MARK: - Properties
    var actionOperationQueue: OperationQueue?
    var historyRequestOperationQueue: OperationQueue?
    private var authorizationData: AuthorizationData?
    
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener, notFatalErrorHandler: NotFatalErrorHandler?) {
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener) {
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    // MARK: - Methods
    
    override func start() {
        guard actionOperationQueue == nil && historyRequestOperationQueue == nil else {
            return
        }
        
        actionOperationQueue = OperationQueue()
        actionOperationQueue?.maxConcurrentOperationCount = 1
        actionOperationQueue?.qualityOfService = .userInitiated
        
        historyRequestOperationQueue = OperationQueue()
        historyRequestOperationQueue?.maxConcurrentOperationCount = 1
        historyRequestOperationQueue?.qualityOfService = .userInitiated
    }
    
    override func stop() {
        super.stop()
        
        actionOperationQueue?.cancelAllOperations()
        actionOperationQueue = nil
        
        historyRequestOperationQueue?.cancelAllOperations()
        historyRequestOperationQueue = nil
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: WebimRequest) {
        let operationQueue = request.getCompletionHandler() != nil ? historyRequestOperationQueue : actionOperationQueue
        operationQueue?.addOperation { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if self.authorizationData == nil {
                do {
                    try self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: nil)
                } catch {
                    return
                }
            }
            
            guard let usedAuthorizationData = self.authorizationData else {
                WebimInternalLogger.shared.log(entry: "Authorization Data is nil in ActionRequestLoop.\(#function)")
                return
            }
            
            if !self.isRunning() {
                return
            }
            
            var parameterDictionary = request.getPrimaryData()
            parameterDictionary[WebimActions.Parameter.pageID.rawValue] = usedAuthorizationData.getPageID()
            parameterDictionary[WebimActions.Parameter.authorizationToken.rawValue] = usedAuthorizationData.getAuthorizationToken()
            let parametersString = parameterDictionary.stringFromHTTPParameters()
            
            var urlRequest: URLRequest?
            let httpMethod = request.getHTTPMethod()
            if httpMethod == .get {
                guard let url = URL(string: (request.getBaseURLString() + "?" + parametersString)) else {
                    WebimInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                    return
                }
                urlRequest = URLRequest(url: url)
            } else { // POST
                if let fileName = request.getFileName(),
                    let mimeType = request.getMimeType(),
                    let fileData = request.getFileData(),
                    let boundaryString = request.getBoundaryString() {
                    // Assuming that ready HTTP body is passed only for multipart requests.
                    guard let url = URL(string: (request.getBaseURLString())) else {
                        WebimInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                        return
                    }
                    urlRequest = URLRequest(url: url)
                    urlRequest?.httpBody = self.createHTTPBody(
                        filename: fileName,
                        mimeType: mimeType,
                        fileData: fileData,
                        boundaryString: boundaryString,
                        primaryData: parameterDictionary
                    )
                } else {
                    // For URL encoded requests.
                    guard let url = URL(string: (request.getBaseURLString())) else {
                        WebimInternalLogger.shared.log(entry: "Invalid URL in ActionRequestLoop.\(#function)")
                        return
                    }
                    urlRequest = URLRequest(url: url)
                    urlRequest?.httpBody = parametersString.data(using: .utf8)
                }
                
                // Assuming that content type field is always exists when it is POST request, and does not when request is of GET type.
                urlRequest?.setValue(request.getContentType(),
                                     forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest?.httpMethod = httpMethod.rawValue
            
            do {
                guard let urlRequest = urlRequest else {
                    WebimInternalLogger.shared.log(entry: "Unwrapping url request failure in ActionRequestLoop.\(#function)")
                    return
                }
                let data = try self.perform(request: urlRequest)
                if let dataJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = dataJSON[AbstractRequestLoop.ResponseFields.error.rawValue] as? String {
                        switch error {
                        case WebimInternalError.reinitializationRequired.rawValue:
                            do {
                                try self.authorizationData = self.awaitForNewAuthorizationData(withLastAuthorizationData: nil)
                            } catch {
                                return
                            }
                            self.enqueue(request: request)
                            
                            break
                        case WebimInternalError.fileSizeExceeded.rawValue,
                             WebimInternalError.fileTypeNotAllowed.rawValue,
                             WebimInternalError.uploadedFileNotFound.rawValue,
                             WebimInternalError.notAllowedMimeType.rawValue,
                             WebimInternalError.notMatchingMagicNumbers.rawValue,
                             WebimInternalError.unauthorized.rawValue,
                             WebimInternalError.maxFilesCountPerChatExceeded.rawValue,
                             WebimInternalError.fileSizeTooSmall.rawValue:
                            self.handleSendFile(error: error,
                                                ofRequest: request)
                            
                            break
                        case WebimInternalError.fileNotFound.rawValue,
                             WebimInternalError.fileHasBeenSent.rawValue:
                            self.handleDeleteUploadedFileFile(error: error,
                                                  ofRequest: request)
                            
                            break
                        case WebimInternalError.wrongArgumentValue.rawValue:
                            self.handleWrongArgumentValueError(ofRequest: request)
                            
                            break
                        case WebimInternalError.noChat.rawValue,
                             WebimInternalError.operatorNotInChat.rawValue:
                            self.handleRateOperator(error: error,
                                                    ofRequest: request)
                            
                            break
                        case WebimInternalError.messageNotFound.rawValue,
                             WebimInternalError.notAllowed.rawValue,
                             WebimInternalError.messageNotOwned.rawValue:
                            self.handleDeleteMessage(error: error,
                                                    ofRequest: request)
                            break
                        case WebimInternalError.buttonIdNotSet.rawValue,
                             WebimInternalError.requestMessageIdNotSet.rawValue,
                             WebimInternalError.canNotCreateResponse.rawValue:
                            self.handleKeyboardResponse(error: error,
                                                        ofRequest: request)
                            break
                        case WebimInternalError.sentTooManyTimes.rawValue:
                            self.handleSendDialogResponse(error: error,
                                                          ofRequest: request)
                            
                            break
                        case WebimInternalError.surveyDisabled.rawValue,
                             WebimInternalError.noCurrentSurvey.rawValue,
                             WebimInternalError.incorrectSurveyID.rawValue,
                             WebimInternalError.incorrectStarsValue.rawValue,
                             WebimInternalError.maxCommentLenghtExceeded.rawValue,
                             WebimInternalError.questionNotFound.rawValue:
                            self.handleSendSurveyAnswer(error: error,
                                                        ofRequest: request)
                            self.handleSurveyClose(error: error,
                                                   ofRequest: request)
                            
                            break
                        case WebimInternalError.noStickerId.rawValue:
                            self.handleSendStickerError(error: error,
                                                        ofRequest: request)
                        default:
                            self.running = false
                            
                            self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                                self.internalErrorListener?.on(error: error)
                            })
                            
                            break
                        }
                        
                        return
                    }
                    
                    // Some internal errors can be received inside "error" field inside "data" field.
                    if let dataDictionary = dataJSON[AbstractRequestLoop.ResponseFields.data.rawValue] as? [String: Any],
                        let errorString = dataDictionary[AbstractRequestLoop.DataFields.error.rawValue] as? String {
                        self.handleDataMessage(error: errorString,
                                               ofRequest: request)
                    }
                    
                    if let completionHandler = request.getCompletionHandler() {
                        self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                            } catch {
                                WebimInternalLogger.shared.log(entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                                    verbosityLevel: .warning)
                            }
                            
                        })
                    }
                    
                    if let completionHandler = request.getLocationStatusCompletionHandler() {
                        self.completionHandlerExecutor?.execute(task: DispatchWorkItem {
                            do {
                                try completionHandler(data)
                            } catch {
                                WebimInternalLogger.shared.log(entry: "Error executing callback on receiver data: \(String(data: data, encoding: .utf8) ?? "unreadable data").",
                                    verbosityLevel: .warning)
                            }
                            
                        })
                    }
                    
                    self.handleClientCompletionHandlerOf(request: request, dataJSON: dataJSON[AbstractRequestLoop.ResponseFields.data.rawValue] as? [String : Any?])
                } else {
                    WebimInternalLogger.shared.log(entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data")",
                        verbosityLevel: .warning)
                }
            } catch let sendFileError as SendFileError {
                // SendFileErrors are generated from HTTP code.
                if let sendFileCompletionHandler = request.getSendFileCompletionHandler() {
                    guard let messageID = request.getMessageID() else {
                        WebimInternalLogger.shared.log(entry: "Request has not message ID in ActionRequestLoop.\(#function)")
                        return
                    }
                    sendFileCompletionHandler.onFailure(messageID: messageID,
                                                        error: sendFileError)
                }
            } catch let unknownError as UnknownError {
                self.handleRequestLoop(error: unknownError)
            } catch {
                WebimInternalLogger.shared.log(entry: "Request failed with unknown error: \(request.getBaseURLString()).",
                    verbosityLevel: .warning)
            }
        }
    }
    
    // MARK: Private methods
    
    private func createHTTPBody(filename: String,
                                mimeType: String,
                                fileData: Data,
                                boundaryString: String,
                                primaryData: [String: Any]) -> Data {
        
        let boundaryStart = "--\(boundaryString)\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"webim_upload_file\"; filename=\"\(filename)\"\r\n"
        let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"
        let boundaryEnd = "--\(boundaryString)--\r\n"
        
        var requestBodyData = Data()
        for (key, value) in primaryData {
            guard let boundaryData = "--\(boundaryString)\r\n".data(using: .utf8),
            let keyData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8),
            let valueData = "\(value)\r\n".data(using: .utf8) else {
                WebimInternalLogger.shared.log(entry: "Data configuration failure in ActionRequestLoop.\(#function)")
                return requestBodyData
            }
            requestBodyData.append(boundaryData)
            requestBodyData.append(keyData)
            requestBodyData.append(valueData)
        }
        guard let boundaryStartData = boundaryStart.data(using: .utf8),
            let contentDispositionStringData = contentDispositionString.data(using: .utf8),
            let contentTypeStringData = contentTypeString.data(using: .utf8),
            let lineBreakData = "\r\n".data(using: .utf8),
            let boundaryEndData = boundaryEnd.data(using: .utf8) else {
            WebimInternalLogger.shared.log(entry: "Data configuration failure in ActionRequestLoop.\(#function)")
            return requestBodyData
            
        }
        requestBodyData.append(boundaryStartData)
        requestBodyData.append(contentDispositionStringData)
        requestBodyData.append(contentTypeStringData)
        requestBodyData.append(fileData)
        requestBodyData.append(lineBreakData)
        requestBodyData.append(boundaryEndData)
        
        return requestBodyData
    }
    
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) throws -> AuthorizationData {
        while isRunning()
            && (lastAuthorizationData == authorizationData) {
                usleep(100_000) // 0.1 s.
        }
        
        guard let authorizationData = authorizationData else {
            // Interrupted request.
            throw AbstractRequestLoop.UnknownError.interrupted
        }
        
        return authorizationData
    }
    
    private func handleDataMessage(error errorString: String,
                                   ofRequest webimRequest: WebimRequest) {
        if let dataMessageCompletionHandler = webimRequest.getDataMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                guard let messageID = webimRequest.getMessageID() else {
                    WebimInternalLogger.shared.log(entry: "Webim Request has not message ID in ActionRequestLoop.\(#function)")
                    return
                }
                dataMessageCompletionHandler.onFailure(messageID: messageID,
                                                       error: ActionRequestLoop.convertToPublic(dataMessageErrorString: errorString))
            })
        }
    }
    
    private func handleRateOperator(error errorString: String,
                                    ofRequest webimRequest: WebimRequest) {
        if let rateOperatorCompletionhandler = webimRequest.getRateOperatorCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let rateOperatorError: RateOperatorError
                switch errorString {
                case WebimInternalError.noChat.rawValue:
                    rateOperatorError = .noChat
                case WebimInternalError.noteIsTooLong.rawValue:
                    rateOperatorError = .noteIsTooLong
                default:
                    rateOperatorError = .wrongOperatorId
                }
                
                rateOperatorCompletionhandler.onFailure(error: rateOperatorError)
            })
        }
    }
    
    private func handleEditMessage(error errorString: String,
                                   ofRequest webimRequest: WebimRequest) {
        if let editMessageCompletionHandler = webimRequest.getEditMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let editMessageError: EditMessageError
                switch errorString {
                case WebimInternalError.messageEmpty.rawValue:
                    editMessageError = .messageEmpty
                    break
                case WebimInternalError.maxMessageLengthExceeded.rawValue:
                    editMessageError = .maxLengthExceeded
                    break
                case WebimInternalError.notAllowed.rawValue:
                    editMessageError = .notAllowed
                    break
                case WebimInternalError.messageNotOwned.rawValue:
                    editMessageError = .messageNotOwned
                    break
                case WebimInternalError.wrongMessageKind.rawValue:
                    editMessageError = .wrongMesageKind
                    break
                default:
                    editMessageError = .unknown
                }
                
                guard let messageID = webimRequest.getMessageID() else {
                    WebimInternalLogger.shared.log(entry: "Webim Request has not message ID in ActionRequestLoop.\(#function)")
                    return
                }
                editMessageCompletionHandler.onFailure(messageID: messageID,
                                                       error: editMessageError)
            })
        }
    }
    
    private func handleDeleteMessage(error errorString: String,
                                    ofRequest webimRequest: WebimRequest) {
        if let deleteMessageCompletionHandler = webimRequest.getDeleteMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let deleteMessageError: DeleteMessageError
                switch errorString {
                case WebimInternalError.messageNotFound.rawValue:
                    deleteMessageError = .messageNotFound
                    break
                case WebimInternalError.notAllowed.rawValue:
                    deleteMessageError = .notAllowed
                    break
                case WebimInternalError.messageNotOwned.rawValue:
                    deleteMessageError = .messageNotOwned
                    break
                default:
                    deleteMessageError = .unknown
                }
                
                guard let messageID = webimRequest.getMessageID() else {
                    WebimInternalLogger.shared.log(entry: "Webim Request has not message ID in ActionRequestLoop.\(#function)")
                    return
                }
                deleteMessageCompletionHandler.onFailure(messageID: messageID,
                                                         error: deleteMessageError)
            })
        }
    }
    
    private func handleSendFile(error errorString: String,
                                ofRequest webimRequest: WebimRequest) {
        let sendFileCompletionHandler = webimRequest.getSendFileCompletionHandler()
        let uploadFileToServerCompletionHandler = webimRequest.getUploadFileToServerCompletionHandler()
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            let sendFileError: SendFileError
            switch errorString {
            case WebimInternalError.fileSizeExceeded.rawValue:
                sendFileError = .fileSizeExceeded
                break
            case WebimInternalError.fileTypeNotAllowed.rawValue:
                sendFileError = .fileTypeNotAllowed
                break
            case WebimInternalError.uploadedFileNotFound.rawValue:
                sendFileError = .uploadedFileNotFound
                break
            case WebimInternalError.unauthorized.rawValue:
                sendFileError = .unauthorized
                break
            default:
                sendFileError = .unknown
            }
                
            guard let messageID = webimRequest.getMessageID() else {
                WebimInternalLogger.shared.log(entry: "Webim Request has not message ID in ActionRequestLoop.\(#function)")
                return
            }
            sendFileCompletionHandler?.onFailure(messageID: messageID,
                                                 error: sendFileError)
            uploadFileToServerCompletionHandler?.onFailure(messageID: messageID, error: sendFileError)
        })
    }
    
    private func handleDeleteUploadedFileFile(error errorString: String,
                                  ofRequest webimRequest: WebimRequest) {
        if let deleteUploadedFileCompletionHandler = webimRequest.getDeleteUploadedFileCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let deleteUploadedFileError: DeleteUploadedFileError
                switch errorString {
                case WebimInternalError.fileNotFound.rawValue:
                    deleteUploadedFileError = .fileNotFound
                    break
                case WebimInternalError.fileHasBeenSent.rawValue:
                    deleteUploadedFileError = .fileHasBeenSent
                    break
                default:
                    deleteUploadedFileError = .unknown
                }
                deleteUploadedFileCompletionHandler.onFailure(error: deleteUploadedFileError)
            })
        }
    }
    
    private func handleSendStickerError(error errorString: String,
                                        ofRequest webimRequest: WebimRequest) {
        if let sendStickerCompletionHandler = webimRequest.getSendStickerCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendStickerError: SendStickerError
                switch errorString {
                case WebimInternalError.noStickerId.rawValue:
                    sendStickerError = .noStickerId
                default:
                    sendStickerError = .noChat
                }
                sendStickerCompletionHandler.onFailure(error: sendStickerError)
            })
        }
    }
    
    private func handleKeyboardResponse(error errorString: String,
                                        ofRequest webimRequest: WebimRequest) {
        if let keyboardResponseCompletionHandler = webimRequest.getKeyboardResponseCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let keyboardResponseError: KeyboardResponseError
                switch errorString {
                case WebimInternalError.buttonIdNotSet.rawValue:
                    keyboardResponseError = .buttonIdNotSet
                    break
                case WebimInternalError.requestMessageIdNotSet.rawValue:
                    keyboardResponseError = .requestMessageIdNotSet
                    break
                case WebimInternalError.canNotCreateResponse.rawValue:
                    keyboardResponseError = .canNotCreateResponse
                    break
                default:
                    keyboardResponseError = .unknown
                }
                
                guard let messageID = webimRequest.getMessageID() else {
                    WebimInternalLogger.shared.log(entry: "Webim Request has not message ID in ActionRequestLoop.\(#function)")
                    return
                }
                keyboardResponseCompletionHandler.onFailure(messageID: messageID, error: keyboardResponseError)
            })
        }
    }
    
    private func handleSendDialogResponse(error errorString: String,
                                          ofRequest webimRequest: WebimRequest) {
        if let sendDialogResponseCompletionHandler = webimRequest.getSendDialogToEmailAddressCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendDialogResponseError: SendDialogToEmailAddressError
                switch errorString {
                case WebimInternalError.sentTooManyTimes.rawValue:
                    sendDialogResponseError = .sentTooManyTimes
                    break
                default:
                    sendDialogResponseError = .unknown
                }
                
                sendDialogResponseCompletionHandler.onFailure(error: sendDialogResponseError)
            })
        }
    }
    
    private func handleSendSurveyAnswer(error errorString: String,
                                        ofRequest webimRequest: WebimRequest) {
        if let sendSurveyAnswerCompletionHandler = webimRequest.getSendSurveyAnswerCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendSurveyAnswerError: SendSurveyAnswerError
                switch errorString {
                case WebimInternalError.surveyDisabled.rawValue:
                    sendSurveyAnswerError = .surveyDisabled
                    break
                case WebimInternalError.noCurrentSurvey.rawValue:
                    sendSurveyAnswerError = .noCurrentSurvey
                    break
                case WebimInternalError.incorrectSurveyID.rawValue:
                    sendSurveyAnswerError = .incorrectSurveyID
                    break
                case WebimInternalError.incorrectStarsValue.rawValue:
                    sendSurveyAnswerError = .incorrectStarsValue
                    break
                case WebimInternalError.maxCommentLenghtExceeded.rawValue:
                    sendSurveyAnswerError = .maxCommentLength_exceeded
                    break
                case WebimInternalError.questionNotFound.rawValue:
                    sendSurveyAnswerError = .questionNotFound
                    break
                default:
                    sendSurveyAnswerError = .unknown
                }
                
                sendSurveyAnswerCompletionHandler.onFailure(error: sendSurveyAnswerError)
            })
        }
    }
    
    private func handleSurveyClose(error errorString: String,
                                    ofRequest webimRequest: WebimRequest) {
        if let surveyCloseCompletionHandler = webimRequest.getSurveyCloseCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let surveyCloseError: SurveyCloseError
                switch errorString {
                case WebimInternalError.surveyDisabled.rawValue:
                    surveyCloseError = .surveyDisabled
                    break
                case WebimInternalError.noCurrentSurvey.rawValue:
                    surveyCloseError = .noCurrentSurvey
                    break
                case WebimInternalError.incorrectSurveyID.rawValue:
                    surveyCloseError = .incorrectSurveyID
                    break
                default:
                    surveyCloseError = .unknown
                }
                
                surveyCloseCompletionHandler.onFailure(error: surveyCloseError)
            })
        }
    }
    
    private func handleWrongArgumentValueError(ofRequest webimRequest: WebimRequest) {
        WebimInternalLogger.shared.log(entry: "Request \(webimRequest.getBaseURLString()) with parameters \(webimRequest.getPrimaryData().stringFromHTTPParameters()) failed with error \(WebimInternalError.wrongArgumentValue.rawValue)",
            verbosityLevel: .warning)
    }
    
    private func handleClientCompletionHandlerOf(request: WebimRequest, dataJSON: [String: Any?]?) {
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            request.getSendDialogToEmailAddressCompletionHandler()?.onSuccess()
            request.getSendSurveyAnswerCompletionHandler()?.onSuccess()
            request.getSurveyCloseCompletionHandler()?.onSuccess()
            request.getRateOperatorCompletionHandler()?.onSuccess()
            request.getSendStickerCompletionHandler()?.onSuccess()
            guard let messageID = request.getMessageID() else {
                WebimInternalLogger.shared.log(entry: "Request has not message ID in ActionRequestLoop.\(#function)")
                return
            }
            request.getDataMessageCompletionHandler()?.onSuccess(messageID: messageID)
            request.getSendFileCompletionHandler()?.onSuccess(messageID: messageID)
            request.getDeleteMessageCompletionHandler()?.onSuccess(messageID: messageID)
            request.getEditMessageCompletionHandler()?.onSuccess(messageID: messageID)
            request.getKeyboardResponseCompletionHandler()?.onSuccess(messageID: messageID)
            request.getSendFilesCompletionHandler()?.onSuccess(messageID: messageID)
            if let dataJSON = dataJSON {
                request.getUploadFileToServerCompletionHandler()?.onSuccess(id: messageID, uploadedFile: self.getUploadedFileFrom(dataJSON: dataJSON))
            }
            request.getDeleteMessageCompletionHandler()?.onSuccess(messageID: messageID)
        })
    }
    
    private func getUploadedFileFrom(dataJSON: [String: Any?]) -> UploadedFile {
        let fileParameters = FileParametersItem(jsonDictionary: dataJSON)
        return UploadedFileImpl(size: fileParameters.getSize() ?? 0,
                                guid: fileParameters.getGUID() ?? "",
                                contentType: fileParameters.getContentType(),
                                filename: fileParameters.getFilename() ?? "",
                                visitorID: fileParameters.getVisitorID() ?? "",
                                clientContentType: fileParameters.getClientContentType() ?? "",
                                imageParameters: fileParameters.getImageParameters())
    }
    
    private static func convertToPublic(dataMessageErrorString: String) -> DataMessageError {
        switch dataMessageErrorString {
        case WebimInternalError.quotedMessageCannotBeReplied.rawValue:
            return .quotedMessageCanNotBeReplied
        case WebimInternalError.quotedMessageCorruptedID.rawValue:
            return .quotedMessageWrongId
        case WebimInternalError.quotedMessageFromAnotherVisitor.rawValue:
            return .quotedMessageFromAnotherVisitor
        case WebimInternalError.quotedMessageMultipleID.rawValue:
            return .quotedMessageMultipleIds
        case WebimInternalError.quotedMessageNotFound.rawValue:
            return .quotedMessageWrongId
        case WebimInternalError.quotedMessageRequiredArgumentsMissing.rawValue:
            return .quotedMessageRequiredArgumentsMissing
        default:
            return .unknown
        }
    }
    
}
