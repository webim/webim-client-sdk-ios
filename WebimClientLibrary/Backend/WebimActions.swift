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
        case buttonId = "button-id"
        case chatMode = "chat-mode"
        case clientSideID = "client-side-id"
        case data = "data"
        case deleteDraft = "del-message-draft"
        case departmentKey = "department-key"
        case deviceID = "device-id"
        case deviceToken = "push-token"
        case draft = "message-draft"
        case email = "email"
        case event = "event"
        case firstQuestion = "first-question"
        case forceOnline = "force-online"
        case guid = "guid"
        case hintQuestion = "hint_question"
        case kind = "kind"
        case location = "location"
        case message = "message"
        case operatorID = "operator_id"
        case pageID = "page-id"
        case platform = "platform"
        case providedAuthenticationToken = "provided_auth_token"
        case quote = "quote"
        case rating = "rate"
        case respondImmediately = "respond-immediately"
        case requestMessageId = "request-message-id"
        case visitorNote = "visitor_note"
        case visitSessionID = "visit-session-id"
        case since = "since"
        case stickerId = "sticker-id"
        case surveyAnswer = "answer"
        case surveyFormID = "form-id"
        case surveyID = "survey-id"
        case surveyQuestionID = "question-id"
        case timestamp = "ts"
        case title = "title"
        case visitor = "visitor"
        case visitorExt = "visitor-ext"
        case visitorTyping = "typing"
        case prechat = "prechat-key-independent-fields"
        case customFields = "custom_fields"
        case webimSDKVersion = "x-webim-sdk-version"
    }
    enum Platform: String {
        case ios = "ios"
    }
    enum ServerPathSuffix: String {
        case doAction = "/l/v/m/action"
        case fileDelete = "/l/v/file-delete"
        case getDelta = "/l/v/m/delta"
        case getOnlineStatus = "/l/v/get-online-status"
        case downloadFile = "/l/v/m/download"
        case getHistory = "/l/v/m/history"
        case uploadFile = "/l/v/m/upload"
    }
    enum MultipartBody: String {
        case name = "webim_upload_file"
    }
    private enum ChatMode: String {
        case online = "online"
    }
    private enum Action: String {
        case closeChat = "chat.close"
        case rateOperator = "chat.operator_rate_select"
        case respondSentryCall = "chat.action_request.call_sentry_action_request"
        case sendMessage = "chat.message"
        case deleteMessage = "chat.delete_message"
        case sendChatHistory = "chat.send_chat_history"
        case setDeviceToken = "set_push_token"
        case setPrechat = "chat.set_prechat_fields"
        case setVisitorTyping = "chat.visitor_typing"
        case startChat = "chat.start"
        case surveyAnswer = "survey.answer"
        case surveyCancel = "survey.cancel"
        case chatRead = "chat.read_by_visitor"
        case widgetUpdate = "widget.update"
        case keyboardResponse = "chat.keyboard_response"
        case sendSticker = "sticker"
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
              dataMessageCompletionHandler: DataMessageCompletionHandler? = nil,
              editMessageCompletionHandler: EditMessageCompletionHandler? = nil,
              sendMessageCompletionHandler: SendMessageCompletionHandler? = nil) {
        var dataToPost = [Parameter.actionn.rawValue: Action.sendMessage.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID,
                          Parameter.message.rawValue: message] as [String: Any]
        if let isHintQuestion = isHintQuestion {
            dataToPost[Parameter.hintQuestion.rawValue] = isHintQuestion
        }
        if let dataJSONString = dataJSONString {
            dataToPost[Parameter.data.rawValue] = dataJSONString
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        dataMessageCompletionHandler: dataMessageCompletionHandler,
                                                        editMessageCompletionHandler: editMessageCompletionHandler,
                                                        sendMessageCompletionHandler: sendMessageCompletionHandler))
    }
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              clientSideID: String,
              completionHandler: SendFileCompletionHandler? = nil,
              uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler? = nil) {
        let dataToPost = [Parameter.chatMode.rawValue: ChatMode.online.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.uploadFile.rawValue
        
        let boundaryString = NSUUID().uuidString
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        filename: filename,
                                                        mimeType: mimeType,
                                                        fileData: file,
                                                        boundaryString: boundaryString,
                                                        contentType: (ContentType.multipartBody.rawValue + boundaryString),
                                                        baseURLString: urlString,
                                                        sendFileCompletionHandler: completionHandler,
                                                        uploadFileToServerCompletionHandler: uploadFileToServerCompletionHandler))
    }
    
    func sendFiles(message: String,
                   clientSideID: String,
                   isHintQuestion: Bool?,
                   sendFilesCompletionHandler: SendFilesCompletionHandler?) {
        var dataToPost = [Parameter.actionn.rawValue: Action.sendMessage.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID,
                          Parameter.message.rawValue: message,
                          Parameter.kind.rawValue: "file_visitor"] as [String: Any]
        if let isHintQuestion = isHintQuestion {
            dataToPost[Parameter.hintQuestion.rawValue] = isHintQuestion
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        sendFilesCompletionHandler: sendFilesCompletionHandler))
        
    }
    
    func replay(message: String,
                clientSideID: String,
                quotedMessageID: String) {
        let dataToPost = [Parameter.actionn.rawValue: Action.sendMessage.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID,
                          Parameter.message.rawValue: message,
                          Parameter.quote.rawValue: getQuotedMessage(repliedMessageId: quotedMessageID)] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    private func getQuotedMessage(repliedMessageId: String) -> String {
        return "{\"ref\":{\"msgId\":\"\(repliedMessageId)\",\"msgChannelSideId\":null,\"chatId\":null}}";
    }
    
    func delete(clientSideID: String,
                completionHandler: DeleteMessageCompletionHandler?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.deleteMessage.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        deleteMessageCompletionHandler: completionHandler))
    }
    
    func deleteUploadedFile(fileGuid: String,
                            completionHandler: DeleteUploadedFileCompletionHandler?) {
        let dataToPost = [Parameter.guid.rawValue: fileGuid] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.fileDelete.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        deleteUploadedFileCompletionHandler: completionHandler))
    }
    
    func startChat(withClientSideID clientSideID: String,
                   firstQuestion: String? = nil,
                   departmentKey: String? = nil,
                   customFields: String? = nil) {
        var dataToPost = [Parameter.actionn.rawValue: Action.startChat.rawValue,
                          Parameter.forceOnline.rawValue: true,
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        if let firstQuestion = firstQuestion {
            dataToPost[Parameter.firstQuestion.rawValue] = firstQuestion
        }
        if let departmentKey = departmentKey {
            dataToPost[Parameter.departmentKey.rawValue] = departmentKey
        }
        if let custom_fields = customFields {
            dataToPost[Parameter.customFields.rawValue] = custom_fields
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
    
    func set(prechatFields: String) {
        let dataToPost = [Parameter.actionn.rawValue: Action.setPrechat.rawValue,
                          Parameter.prechat.rawValue: prechatFields] as [String: Any]
        
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
        let dataToPost = [Parameter.beforeTimestamp.rawValue: beforeMessageTimestamp] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.getHistory.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        baseURLString: urlString,
                                                        historyRequestCompletionHandler: completion))
    }
    
    func rateOperatorWith(id: String?,
                          rating: Int,
                          visitorNote: String?,
                          completionHandler: RateOperatorCompletionHandler?) {
        var dataToPost = [Parameter.actionn.rawValue: Action.rateOperator.rawValue,
                          Parameter.rating.rawValue: String(rating)] as [String: Any]
        if let id = id {
            dataToPost[Parameter.operatorID.rawValue] = id
        }
        if let visitorNote = visitorNote {
            dataToPost[Parameter.visitorNote.rawValue] = visitorNote
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        rateOperatorCompletionHandler: completionHandler))
    }
    
    func respondSentryCall(id: String) {
        let dataToPost = [Parameter.actionn.rawValue: Action.respondSentryCall.rawValue,
                          Parameter.clientSideID.rawValue: id] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
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
    
    func setChatRead() {
        let dataToPost = [Parameter.actionn.rawValue: Action.chatRead.rawValue] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func updateWidgetStatusWith(data: String) {
        let dataToPost = [Parameter.actionn.rawValue: Action.widgetUpdate.rawValue,
                          Parameter.data.rawValue: data] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func sendKeyboardRequest(buttonId: String,
                             messageId: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.keyboardResponse.rawValue,
                          Parameter.buttonId.rawValue: buttonId,
                          Parameter.requestMessageId.rawValue: messageId] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: messageId,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        keyboardResponseCompletionHandler: completionHandler))
    }
    
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.sendChatHistory.rawValue,
                          Parameter.email.rawValue: emailAddress] as [String: Any]

        let urlString = baseURL + ServerPathSuffix.doAction.rawValue

        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        sendDialogToEmailAddressCompletionHandler: completionHandler))
    }
    
    func sendSticker(stickerId:Int,
                     clientSideId: String,
                     completionHandler: SendStickerCompletionHandler? = nil) {
        let dataToPost = [
            Parameter.actionn.rawValue: Action.sendSticker.rawValue,
            Parameter.stickerId.rawValue: stickerId,
            Parameter.clientSideID.rawValue: clientSideId
        ] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(
            httpMethod: .post,
            primaryData: dataToPost,
            contentType: ContentType.urlEncoded.rawValue,
            baseURLString: urlString,
            sendStickerCompletionHandler: completionHandler
        ))
    }
    
    func sendQuestionAnswer(surveyID: String,
                            formID: Int,
                            questionID: Int,
                            surveyAnswer: String,
                            sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.surveyAnswer.rawValue,
                          Parameter.surveyID.rawValue: surveyID,
                          Parameter.surveyFormID.rawValue: formID,
                          Parameter.surveyQuestionID.rawValue: questionID,
                          Parameter.surveyAnswer.rawValue: surveyAnswer] as [String: Any]

        let urlString = baseURL + ServerPathSuffix.doAction.rawValue

        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        sendSurveyAnswerCompletionHandler: sendSurveyAnswerCompletionHandler))
    }
    
    func closeSurvey(surveyID: String,
                     surveyCloseCompletionHandler: SurveyCloseCompletionHandler?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.surveyAnswer.rawValue,
                          Parameter.surveyID.rawValue: surveyID] as [String: Any]

        let urlString = baseURL + ServerPathSuffix.doAction.rawValue

        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        surveyCloseCompletionHandler: surveyCloseCompletionHandler))
    }
    
    func getOnlineStatus(location: String,
                         completion: @escaping (_ data: Data?) throws -> ()) {
        let dataToPost = [Parameter.location.rawValue: location] as [String: Any]

        let urlString = baseURL + ServerPathSuffix.getOnlineStatus.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        locationStatusRequestCompletionHandler: completion))
    }
    
}
