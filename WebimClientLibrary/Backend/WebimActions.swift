//
//  WebimActions.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
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
 Class that is responsible for history storage when it is set to memory mode.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class WebimActions {
    
    // MARK: - Constants
    
    enum Event: String {
        case INITIALIZATION = "init"
    }
    
    enum Parameter: String {
        case ACTION = "action"
        case APP_VERSION = "app-version"
        case AUTHORIZATION_TOKEN = "auth-token"
        case BEFORE_TIMESTAMP = "before-ts"
        case CHAT_MODE = "chat-mode"
        case CLIENT_SIDE_ID = "client-side-id"
        case DATA = "data"
        case DELETE_DRAFT = "del-message-draft"
        case DEPARTMENT_KEY = "department-key"
        case DEVICE_ID = "device-id"
        case DEVICE_TOKEN = "push-token"
        case DRAFT = "message-draft"
        case EVENT = "event"
        case FIRST_QUESTION = "first-question"
        case FORCE_ONLINE = "force-online"
        case HINT_QUESTION = "hint_question"
        case LOCATION = "location"
        case MESSAGE = "message"
        case OPERATOR_ID = "operator-id"
        case PAGE_ID = "page-id"
        case PLATFORM = "platform"
        case PROVIDED_AUTHENTICATION_TOKEN = "provided_auth_token"
        case RATING = "rate"
        case RESPOND_IMMEDIATELY = "respond-immediately"
        case SESSION_ID = "visit-session-id"
        case SINCE = "since"
        case TIMESTAMP = "ts"
        case TITLE = "title"
        case VISITOR = "visitor"
        case VISITOR_FIELDS = "visitor-ext"
        case VISITOR_TYPING = "typing"
    }
    
    enum Platform: String {
        case IOS = "ios"
    }
    
    enum ServerPathSuffix: String {
        case ACTION = "/l/v/m/action"
        case GET_DELTA = "/l/v/m/delta"
        case DOWNLOAD_FILE = "/l/v/m/download"
        case GET_HISTORY = "/l/v/m/history"
        case UPLOAD_FILE = "/l/v/m/upload"
    }
    
    private enum Action: String {
        case CLOSE_CHAT = "chat.close"
        case RATE_OPERATOR = "chat.operator_rate_select"
        case SEND_MESSAGE = "chat.message"
        case SET_DEVICE_TOKEN = "set_push_token"
        case SET_VISITOR_TYPING = "chat.visitor_typing"
        case START_CHAT = "chat.start"
    }
    
    private enum ChatMode: String {
        case ONLINE = "online"
    }
    
    private enum ContentType: String {
        case MULTIPART_BODY = "multipart/form-data; boundary=" // + boundary string
        case URL_ENCODED = "application/x-www-form-urlencoded"
    }
    
    private enum MultipartBody: String {
        case NAME = "webim_upload_file"
    }
    
    
    // MARK: - Properties
    private let baseURL: String
    private let actionRequestLoop: ActionRequestLoop
    
    
    // MARK: - Initialization
    init(baseURL: String,
         actionRequestLoop: ActionRequestLoop) {
        self.baseURL = baseURL
        self.actionRequestLoop = actionRequestLoop
    }
    
    
    // MARK: - Methods
    
    func send(message: String,
              clientSideID: String,
              dataJSONString: String?,
              isHintQuestion: Bool?,
              dataMessageCompletionHandler: DataMessageCompletionHandler?) {
        var dataToPost = [Parameter.ACTION.rawValue: Action.SEND_MESSAGE.rawValue,
                          Parameter.CLIENT_SIDE_ID.rawValue: clientSideID,
                          Parameter.MESSAGE.rawValue: message] as [String: Any]
        if let isHintQuestion = isHintQuestion {
            dataToPost[Parameter.HINT_QUESTION.rawValue] = isHintQuestion ? "1" : "0" // true / false
        }
        if let dataJSONString = dataJSONString {
            dataToPost[Parameter.DATA.rawValue] = dataJSONString
        }
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString))
    }
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              clientSideID: String,
              completionHandler: SendFileCompletionHandler?) {
        let dataToPost = [Parameter.CHAT_MODE.rawValue: ChatMode.ONLINE.rawValue,
                          Parameter.CLIENT_SIDE_ID.rawValue: clientSideID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.UPLOAD_FILE.rawValue
        
        let boundaryString = createBoundaryString()
        
        let httpBody = createHTTPBody(filename: filename,
                                      mimeType: mimeType,
                                      fileData: file,
                                      boundaryString: boundaryString)
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        httpBody: httpBody,
                                                        contentType: (ContentType.MULTIPART_BODY.rawValue + boundaryString),
                                                        baseURLString: urlString,
                                                        sendFileCompletionHandler: completionHandler))
    }
    
    func startChat(withClientSideID clientSideID: String,
                   firstQuestion: String? = nil,
                   departmentKey: String? = nil) {
        var dataToPost = [Parameter.ACTION.rawValue: Action.START_CHAT.rawValue,
                          Parameter.FORCE_ONLINE.rawValue: "1", // true
                          Parameter.CLIENT_SIDE_ID.rawValue: clientSideID] as [String: Any]
        if let firstQuestion = firstQuestion {
            dataToPost[Parameter.FIRST_QUESTION.rawValue] = firstQuestion
        }
        if let departmentKey = departmentKey {
            dataToPost[Parameter.DEPARTMENT_KEY.rawValue] = departmentKey
        }
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString))
    }
    
    func closeChat() {
        let dataToPost = [Parameter.ACTION.rawValue: Action.CLOSE_CHAT.rawValue] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString))
    }
    
    func set(visitorTyping: Bool,
             draft: String?,
             deleteDraft: Bool) {
        var dataToPost = [Parameter.ACTION.rawValue: Action.SET_VISITOR_TYPING.rawValue,
                          Parameter.DELETE_DRAFT.rawValue: deleteDraft ? "1" : "0", // true / false
                          Parameter.VISITOR_TYPING.rawValue: visitorTyping ? "1" : "0"] as [String: Any]  // true / false
        if let draft = draft {
            dataToPost[Parameter.DRAFT.rawValue] = draft
        }
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString))
    }
    
    func requestHistory(since: String?,
                        completion: @escaping (_ data: Data?) throws -> ()) {
        var dataToPost = [String: Any]()
        if let since = since {
            dataToPost[Parameter.SINCE.rawValue] = since
        }
        
        let urlString = baseURL + ServerPathSuffix.GET_HISTORY.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .GET,
                                                        primaryData: dataToPost,
                                                        baseURLString: urlString,
                                                        historyRequestCompletionHandler: completion))
    }
    
    func requestHistory(beforeMessageTimestamp: Int64,
                        completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.BEFORE_TIMESTAMP.rawValue: String(beforeMessageTimestamp)] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.GET_HISTORY.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .GET,
                                                        primaryData: dataToPost,
                                                        baseURLString: urlString,
                                                        historyRequestCompletionHandler: completion))
    }
    
    func rateOperatorWith(id: String?,
                          rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) {
        var dataToPost = [Parameter.ACTION.rawValue: Action.RATE_OPERATOR.rawValue,
                          Parameter.RATING.rawValue: String(rating)] as [String: Any]
        if let id = id {
            dataToPost[Parameter.OPERATOR_ID.rawValue] = id
        }
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString,
                                                        rateOperatorCompletionHandler: completionHandler))
    }
    
    func update(deviceToken: String) {
        let dataToPost = [Parameter.ACTION.rawValue: Action.SET_DEVICE_TOKEN.rawValue,
                          Parameter.DEVICE_TOKEN.rawValue: deviceToken] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.ACTION.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .POST,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.URL_ENCODED.rawValue,
                                                        baseURLString: urlString))
    }
    
    // MARK: Private methods
    
    private func createBoundaryString() -> String {
        return NSUUID().uuidString
    }
    
    private func createHTTPBody(filename: String,
                                mimeType: String,
                                fileData: Data,
                                boundaryString: String) -> Data {
        let boundaryStart = "--\(boundaryString)\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(MultipartBody.NAME.rawValue)\"; filename=\"\(filename)\"\r\n"
        let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"
        let boundaryEnd = "--\(boundaryString)--\r\n"
        
        var requestBodyData = Data()
        requestBodyData.append(boundaryStart.data(using: .utf8)!)
        requestBodyData.append(contentDispositionString.data(using: .utf8)!)
        requestBodyData.append(contentTypeString.data(using: .utf8)!)
        requestBodyData.append(fileData)
        requestBodyData.append("\r\n".data(using: .utf8)!)
        requestBodyData.append(boundaryEnd.data(using: .utf8)!)
        
        return requestBodyData
    }
    
}
