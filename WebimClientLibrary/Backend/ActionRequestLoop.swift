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
    var operationQueue: OperationQueue?
    private var authorizationData: AuthorizationData?
    
    
    // MARK: - Initialization
    init(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor,
         internalErrorListener: InternalErrorListener) {
        super.init(completionHandlerExecutor: completionHandlerExecutor, internalErrorListener: internalErrorListener)
    }
    
    // MARK: - Methods
    
    override func start() {
        guard operationQueue == nil else {
            return
        }
        
        operationQueue = OperationQueue()
        operationQueue?.maxConcurrentOperationCount = 1
        operationQueue?.qualityOfService = .userInitiated
    }
    
    override func stop() {
        super.stop()
        
        operationQueue?.cancelAllOperations()
        operationQueue = nil
    }
    
    func set(authorizationData: AuthorizationData?) {
        self.authorizationData = authorizationData
    }
    
    func enqueue(request: WebimRequest) {
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
            let usedAuthorizationData = self.authorizationData!
            
            if !self.isRunning() {
                return
            }
            
            var parameterDictionary = request.getPrimaryData()
            parameterDictionary[WebimActions.Parameter.pageID.rawValue] = usedAuthorizationData.getPageID()
            parameterDictionary[WebimActions.Parameter.authorizationToken.rawValue] = usedAuthorizationData.getAuthorizationToken()
            let parametersString = parameterDictionary.stringFromHTTPParameters()
            
            var url: URL?
            var urlRequest: URLRequest?
            let httpMethod = request.getHTTPMethod()
            if httpMethod == .get {
                url = URL(string: (request.getBaseURLString() + "?" + parametersString))
                urlRequest = URLRequest(url: url!)
            } else { // POST
                if let fileName = request.getFileName(),
                    let mimeType = request.getMimeType(),
                    let fileData = request.getFileData(),
                    let boundaryString = request.getBoundaryString() {
                    // Assuming that ready HTTP body is passed only for multipart requests.
                    url = URL(string: (request.getBaseURLString()))
                    urlRequest = URLRequest(url: url!)
                    urlRequest!.httpBody = self.createHTTPBody(filename: fileName,
                                                               mimeType: mimeType,
                                                               fileData: fileData,
                                                               boundaryString: boundaryString,
                                                               primaryData: parameterDictionary)
                } else {
                    // For URL encoded requests.
                    url = URL(string: request.getBaseURLString())
                    urlRequest = URLRequest(url: url!)
                    urlRequest!.httpBody = parametersString.data(using: .utf8)
                }
                
                // Assuming that content type field is always exists when it is POST request, and does not when request is of GET type.
                urlRequest!.setValue(request.getContentType(),
                                     forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest!.httpMethod = httpMethod.rawValue
            
            do {
                let data = try self.perform(request: urlRequest!)
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
                             WebimInternalError.notMatchingMagicNumbers.rawValue:
                            self.handleSendFile(error: error,
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
                                    verbosityLevel: .WARNING)
                            }
                            
                        })
                    }
                    
                    self.handleClientCompletionHandlerOf(request: request)
                } else {
                    WebimInternalLogger.shared.log(entry: "Error de-serializing server response: \(String(data: data, encoding: .utf8) ?? "unreadable data")",
                        verbosityLevel: .WARNING)
                }
            } catch let sendFileError as SendFileError {
                // SendFileErrors are generated from HTTP code.
                if let sendFileCompletionHandler = request.getSendFileCompletionHandler() {
                    sendFileCompletionHandler.onFailure(messageID: request.getMessageID()!,
                                                        error: sendFileError)
                }
            } catch let unknownError as UnknownError {
                self.handleRequestLoop(error: unknownError)
            } catch {
                WebimInternalLogger.shared.log(entry: "Request failed with unknown error: \(request.getBaseURLString()).",
                    verbosityLevel: .WARNING)
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
            requestBodyData.append("--\(boundaryString)\r\n".data(using: .utf8)!)
            requestBodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            requestBodyData.append("\(value)\r\n".data(using: .utf8)!)
        }
        requestBodyData.append(boundaryStart.data(using: .utf8)!)
        requestBodyData.append(contentDispositionString.data(using: .utf8)!)
        requestBodyData.append(contentTypeString.data(using: .utf8)!)
        requestBodyData.append(fileData)
        requestBodyData.append("\r\n".data(using: .utf8)!)
        requestBodyData.append(boundaryEnd.data(using: .utf8)!)
        
        return requestBodyData
    }
    
    private func awaitForNewAuthorizationData(withLastAuthorizationData lastAuthorizationData: AuthorizationData?) throws -> AuthorizationData {
        while isRunning()
            && (lastAuthorizationData == authorizationData) {
                usleep(100_000) // 0.1 s.
        }
        
        if authorizationData == nil {
            // Interrupted request.
            throw AbstractRequestLoop.UnknownError.interrupted
        }
        
        return authorizationData!
    }
    
    private func handleDataMessage(error errorString: String,
                                   ofRequest webimRequest: WebimRequest) {
        if let dataMessageCompletionHandler = webimRequest.getDataMessageCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                dataMessageCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
                                                       error: ActionRequestLoop.convertToPublic(dataMessageErrorString: errorString))
            })
        }
    }
    
    private func handleRateOperator(error errorString: String,
                                    ofRequest webimRequest: WebimRequest) {
        if let rateOperatorCompletionhandler = webimRequest.getRateOperatorCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let rateOperatorError: RateOperatorError
                if errorString == WebimInternalError.noChat.rawValue {
                    rateOperatorError = .NO_CHAT
                } else {
                    rateOperatorError = .WRONG_OPERATOR_ID
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
                    editMessageError = .MESSAGE_EMPTY
                    break
                case WebimInternalError.maxMessageLengthExceeded.rawValue:
                    editMessageError = .MAX_LENGTH_EXCEEDED
                    break
                case WebimInternalError.notAllowed.rawValue:
                    editMessageError = .NOT_ALLOWED
                    break
                case WebimInternalError.messageNotOwned.rawValue:
                    editMessageError = .MESSAGE_NOT_OWNED
                    break
                case WebimInternalError.wrongMessageKind.rawValue:
                    editMessageError = .WRONG_MESSAGE_KIND
                    break
                default:
                    editMessageError = .UNKNOWN
                }
                
                editMessageCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
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
                    deleteMessageError = .MESSAGE_NOT_FOUND
                    break
                case WebimInternalError.notAllowed.rawValue:
                    deleteMessageError = .NOT_ALLOWED
                    break
                case WebimInternalError.messageNotOwned.rawValue:
                    deleteMessageError = .MESSAGE_NOT_OWNED
                    break
                default:
                    deleteMessageError = .UNKNOWN
                }
                
                deleteMessageCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
                                                         error: deleteMessageError)
            })
        }
    }
    
    private func handleSendFile(error errorString: String,
                                ofRequest webimRequest: WebimRequest) {
        if let sendFileCompletionHandler = webimRequest.getSendFileCompletionHandler() {
            completionHandlerExecutor?.execute(task: DispatchWorkItem {
                let sendFileError: SendFileError
                switch errorString {
                case WebimInternalError.fileSizeExceeded.rawValue:
                    sendFileError = .FILE_SIZE_EXCEEDED
                    break
                case WebimInternalError.fileTypeNotAllowed.rawValue:
                    sendFileError = .FILE_TYPE_NOT_ALLOWED
                    break
                case WebimInternalError.uploadedFileNotFound.rawValue:
                    sendFileError = .UPLOADED_FILE_NOT_FOUND
                    break
                default:
                    sendFileError = .UNKNOWN
                }
                
                sendFileCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!,
                                                    error: sendFileError)
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
                    keyboardResponseError = .BUTTON_ID_NOT_SET
                    break
                case WebimInternalError.requestMessageIdNotSet.rawValue:
                    keyboardResponseError = .REQUEST_MESSAGE_ID_NOT_SET
                    break
                case WebimInternalError.canNotCreateResponse.rawValue:
                    keyboardResponseError = .CAN_NOT_CREATE_RESPONSE
                    break
                default:
                    keyboardResponseError = .UNKNOWN
                }
                
                keyboardResponseCompletionHandler.onFailure(messageID: webimRequest.getMessageID()!, error: keyboardResponseError)
            })
        }
    }
    
    private func handleWrongArgumentValueError(ofRequest webimRequest: WebimRequest) {
        WebimInternalLogger.shared.log(entry: "Request \(webimRequest.getBaseURLString()) with parameters \(webimRequest.getPrimaryData().stringFromHTTPParameters()) failed with error \(WebimInternalError.wrongArgumentValue.rawValue)",
            verbosityLevel: .WARNING)
    }
    
    private func handleClientCompletionHandlerOf(request: WebimRequest) {
        completionHandlerExecutor?.execute(task: DispatchWorkItem {
            request.getDataMessageCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
            request.getSendFileCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
            request.getRateOperatorCompletionHandler()?.onSuccess()
            request.getDeleteMessageCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
            request.getEditMessageCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
            request.getKeyboardResponseCompletionHandler()?.onSuccess(messageID: request.getMessageID()!)
        })
    }
    
    private static func convertToPublic(dataMessageErrorString: String) -> DataMessageError {
        switch dataMessageErrorString {
        case WebimInternalError.quotedMessageCannotBeReplied.rawValue:
            return .QUOTED_MESSAGE_CANNOT_BE_REPLIED
        case WebimInternalError.quotedMessageCorruptedID.rawValue:
            return .QUOTED_MESSAGE_WRONG_ID
        case WebimInternalError.quotedMessageFromAnotherVisitor.rawValue:
            return .QUOTED_MESSAGE_FROM_ANOTHER_VISITOR
        case WebimInternalError.quotedMessageMultipleID.rawValue:
            return .QUOTED_MESSAGE_MULTIPLE_IDS
        case WebimInternalError.quotedMessageNotFound.rawValue:
            return .QUOTED_MESSAGE_WRONG_ID
        case WebimInternalError.quotedMessageRequiredArgumentsMissing.rawValue:
            return .QUOTED_MESSAGE_REQUIRED_ARGUMENTS_MISSING
        default:
            return .UNKNOWN
        }
    }
    
}
