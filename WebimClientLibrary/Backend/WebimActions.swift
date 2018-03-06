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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class WebimActions {
    
    // MARK: - Constants
    enum ContentType: String {
        case multipartBody = "multipart/form-data; boundary=" // + boundary string
        case urlEncoded = "application/x-www-form-urlencoded"
    }
    enum Event: String {
        case initialization = "init"
    }
    enum Parameter: String {
        case actionn = "action"
        case applicationVersion = "app-version"
        case authorizationToken = "auth-token"
        case beforeTimestamp = "before-ts"
        case chatMode = "chat-mode"
        case clientSideID = "client-side-id"
        case data = "data"
        case deleteDraft = "del-message-draft"
        case departmentKey = "department-key"
        case deviceID = "device-id"
        case deviceToken = "push-token"
        case draft = "message-draft"
        case event = "event"
        case firstQuestion = "first-question"
        case forceOnline = "force-online"
        case hintQuestion = "hint_question"
        case location = "location"
        case message = "message"
        case operatorID = "operator_id"
        case pageID = "page-id"
        case platform = "platform"
        case providedAuthenticationToken = "provided_auth_token"
        case rating = "rate"
        case respondImmediately = "respond-immediately"
        case visitSessionID = "visit-session-id"
        case since = "since"
        case timestamp = "ts"
        case title = "title"
        case visitor = "visitor"
        case visitorExt = "visitor-ext"
        case visitorTyping = "typing"
    }
    enum Platform: String {
        case ios = "ios"
    }
    enum ServerPathSuffix: String {
        case doAction = "/l/v/m/action"
        case getDelta = "/l/v/m/delta"
        case downloadFile = "/l/v/m/download"
        case getHistory = "/l/v/m/history"
        case uploadFile = "/l/v/m/upload"
    }
    private enum Action: String {
        case closeChat = "chat.close"
        case rateOperator = "chat.operator_rate_select"
        case sendMessage = "chat.message"
        case setDeviceToken = "set_push_token"
        case setVisitorTyping = "chat.visitor_typing"
        case startChat = "chat.start"
    }
    private enum ChatMode: String {
        case online = "online"
    }
    private enum MultipartBody: String {
        case name = "webim_upload_file"
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
        var dataToPost = [Parameter.actionn.rawValue: Action.sendMessage.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID,
                          Parameter.message.rawValue: message] as [String: Any]
        if let isHintQuestion = isHintQuestion {
            dataToPost[Parameter.hintQuestion.rawValue] = isHintQuestion ? "1" : "0" // True / false.
        }
        if let dataJSONString = dataJSONString {
            dataToPost[Parameter.data.rawValue] = dataJSONString
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              clientSideID: String,
              completionHandler: SendFileCompletionHandler?) {
        let dataToPost = [Parameter.chatMode.rawValue: ChatMode.online.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.uploadFile.rawValue
        
        let boundaryString = createBoundaryString()
        
        let httpBody = createHTTPBody(filename: filename,
                                      mimeType: mimeType,
                                      fileData: file,
                                      boundaryString: boundaryString)
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        httpBody: httpBody,
                                                        contentType: (ContentType.multipartBody.rawValue + boundaryString),
                                                        baseURLString: urlString,
                                                        sendFileCompletionHandler: completionHandler))
    }
    
    func startChat(withClientSideID clientSideID: String,
                   firstQuestion: String? = nil,
                   departmentKey: String? = nil) {
        var dataToPost = [Parameter.actionn.rawValue: Action.startChat.rawValue,
                          Parameter.forceOnline.rawValue: "1", // true
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        if let firstQuestion = firstQuestion {
            dataToPost[Parameter.firstQuestion.rawValue] = firstQuestion
        }
        if let departmentKey = departmentKey {
            dataToPost[Parameter.departmentKey.rawValue] = departmentKey
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func closeChat() {
        let dataToPost = [Parameter.actionn.rawValue: Action.closeChat.rawValue] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func set(visitorTyping: Bool,
             draft: String?,
             deleteDraft: Bool) {
        var dataToPost = [Parameter.actionn.rawValue: Action.setVisitorTyping.rawValue,
                          Parameter.deleteDraft.rawValue: deleteDraft ? "1" : "0", // true / false
                          Parameter.visitorTyping.rawValue: visitorTyping ? "1" : "0"] as [String: Any]  // true / false
        if let draft = draft {
            dataToPost[Parameter.draft.rawValue] = draft
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func requestHistory(since: String?,
                        completion: @escaping (_ data: Data?) throws -> ()) {
        var dataToPost = [String: Any]()
        if let since = since {
            dataToPost[Parameter.since.rawValue] = since
        }
        
        let urlString = baseURL + ServerPathSuffix.getHistory.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        baseURLString: urlString,
                                                        historyRequestCompletionHandler: completion))
    }
    
    func requestHistory(beforeMessageTimestamp: Int64,
                        completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.beforeTimestamp.rawValue: String(beforeMessageTimestamp)] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.getHistory.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        baseURLString: urlString,
                                                        historyRequestCompletionHandler: completion))
    }
    
    func rateOperatorWith(id: String?,
                          rating: Int,
                          completionHandler: RateOperatorCompletionHandler?) {
        var dataToPost = [Parameter.actionn.rawValue: Action.rateOperator.rawValue,
                          Parameter.rating.rawValue: String(rating)] as [String: Any]
        if let id = id {
            dataToPost[Parameter.operatorID.rawValue] = id
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        rateOperatorCompletionHandler: completionHandler))
    }
    
    func update(deviceToken: String) {
        let dataToPost = [Parameter.actionn.rawValue: Action.setDeviceToken.rawValue,
                          Parameter.deviceToken.rawValue: deviceToken] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
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
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(MultipartBody.name.rawValue)\"; filename=\"\(filename)\"\r\n"
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
