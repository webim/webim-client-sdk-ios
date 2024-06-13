//
//  WebimActionsImpl.swift
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
final class WebimActionsImpl {
    
    // MARK: - Constants
    private enum ChatMode: String {
        case online = "online"
    }
    private enum Action: String {
        case closeChat = "chat.close"
        case geoResponse = "geo_response"
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
        case clearHistory = "chat.clear_history"
        case reaction = "chat.react_message"
        case uploadFileProgress = "file_upload_progress"
    }
    
    // MARK: - Properties
    private let baseURL: String
    let actionRequestLoop: ActionRequestLoop
    private var sendingFiles = [String: SendingFile]()
    
    // MARK: - Initialization
    init(baseURL: String,
         actionRequestLoop: ActionRequestLoop
    ) {
        self.baseURL = baseURL
        self.actionRequestLoop = actionRequestLoop
    }
    
    func getSendingFiles() -> [String: SendingFile] {
        return sendingFiles
    }
    
    func getSendingFile(id: String) -> SendingFile? {
        return sendingFiles[id] ?? nil
    }
    
    func deleteSendingFile(id: String) {
        sendingFiles[id] = nil
    }
}

extension WebimActionsImpl: WebimActions {
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
        let max = (actionRequestLoop.getWebimServerSideSettings()?.accountConfig.maxVisitorUploadFileSize ?? 10) * 1024 * 1024
        guard max > file.count else {
            completionHandler?.onFailure(messageID: clientSideID, error: SendFileError.fileSizeExceeded)
            return
        }
        let dataToPost = [Parameter.chatMode.rawValue: ChatMode.online.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.uploadFile.rawValue
        
        let boundaryString = NSUUID().uuidString
        
        let sendingFile = SendingFile(
            fileName: filename,
            clientSideId: clientSideID,
            fileSize: Int(file.count)
        )
        sendingFiles[clientSideID] = sendingFile
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
    
    func sendFileProgress(fileSize: Int,
                          filename: String,
                          mimeType: String,
                          clientSideID: String,
                          error: SendFileError?,
                          progress: Int?,
                          state: SendFileProgressState,
                          completionHandler: SendFileCompletionHandler? = nil,
                          uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler? = nil) {
        let pageId = self.actionRequestLoop.authorizationData?.getPageID() ?? ""
        var dataToPost = [Parameter.actionn.rawValue: Action.uploadFileProgress.rawValue,
                          Parameter.clientSideID.rawValue: clientSideID,
                          Parameter.fileName.rawValue: filename,
                          Parameter.fileSize.rawValue: fileSize.description,
                          Parameter.fileState.rawValue: state.rawValue,
                          Parameter.pageID.rawValue: pageId] as [String: Any]
        var sendFileError: WebimInternalError? = nil
        switch error {
        case .fileSizeExceeded:
            sendFileError = .fileSizeExceeded
            break
        case .fileSizeTooSmall:
            sendFileError = .fileSizeTooSmall
            break
        case .fileTypeNotAllowed:
            sendFileError = .fileTypeNotAllowed
            break
        case .maxFilesCountPerChatExceeded:
            sendFileError = .uploadedFileNotFound
            break
        case .maliciousFileDetected:
            sendFileError = .maliciousFileDetected
            break
        case .uploadedFileNotFound:
            sendFileError = .unauthorized
            break
        default:
            break
        }
        if let error = sendFileError {
            dataToPost[Parameter.fileError.rawValue] = error.rawValue
        }
        
        if let progress = progress {
            dataToPost[Parameter.fileProgress.rawValue] = progress.description
        }
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        let sendingFile = SendingFile(
            fileName: filename,
            clientSideId: clientSideID,
            fileSize: fileSize
        )
        sendingFiles[clientSideID] = sendingFile
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        messageID: clientSideID,
                                                        mimeType: mimeType,
                                                        contentType: ContentType.urlEncoded.rawValue,
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
    
    func searchMessagesBy(query: String, completion: @escaping (_ data: Data?) throws -> ()) {
        let pageId = self.actionRequestLoop.authorizationData?.getPageID() ?? ""
        let authToken = self.actionRequestLoop.authorizationData?.getAuthorizationToken() ?? ""
        
        let parameterDictionary: [String: String] = [Parameter.pageID.rawValue: pageId, Parameter.query.rawValue: query, Parameter.authorizationToken.rawValue:authToken]
        let urlString = baseURL + ServerPathSuffix.search.rawValue
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: parameterDictionary,
                                                        baseURLString: urlString,
                                                        searchMessagesCompletionHandler: completion))
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
    
    
    func sendSticker(stickerId: Int,
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
    
    func sendReaction(reaction: ReactionString,
                      clientSideId: String,
                      completionHandler: ReactionCompletionHandler?) {
        let react: String
        switch reaction {
            case .like:
                react = "like"
            case .dislike:
                react = "dislike"
        }
        let dataToPost = [
            Parameter.actionn.rawValue: Action.reaction.rawValue,
            Parameter.reaction.rawValue: react,
            Parameter.clientSideID.rawValue: clientSideId
        ] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(
            httpMethod: .post,
            primaryData: dataToPost,
            contentType: ContentType.urlEncoded.rawValue,
            baseURLString: urlString,
            reacionCompletionHandler: completionHandler
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
    
    func clearHistory() {
        let dataToPost = [Parameter.actionn.rawValue: Action.clearHistory.rawValue] as [String: Any]
        
        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString))
    }
    
    func getServerSettings(forLocation location: String, completion: @escaping (Data?) throws -> ()) {
        let dataToPost = [String: Any]()

        let urlString = baseURL + ServerPathSuffix.getConfig.rawValue + "/\(location)"
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        locationSettingsCompletionHandler: completion))
    }
    
    func autocomplete(forText text: String, url: String, completion: AutocompleteCompletionHandler?) {
        let dataToPost = ["text": text]
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.jsonEncoded.rawValue,
                                                        baseURLString: url,
                                                        autocompleteCompletionHandler: completion),
                                                        withAuthData: false)
    }


    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?) {
        let urlString = baseURL + ServerPathSuffix.getServerSideSettings.rawValue

        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .get,
                                                        primaryData: [:],
                                                        baseURLString: urlString,
                                                        serverSideSettingsCompletionHandler: completionHandler))
    }
    
    func sendGeolocation(latitude: Double, longitude: Double, completionHandler: GeolocationCompletionHandler?) {
        let dataToPost = [Parameter.actionn.rawValue: Action.geoResponse.rawValue,
                          Parameter.latitude.rawValue: latitude,
                          Parameter.longitude.rawValue: longitude] as [String: Any]

        let urlString = baseURL + ServerPathSuffix.doAction.rawValue
        
        actionRequestLoop.enqueue(request: WebimRequest(httpMethod: .post,
                                                        primaryData: dataToPost,
                                                        contentType: ContentType.urlEncoded.rawValue,
                                                        baseURLString: urlString,
                                                        geolocationCompletionHandler: completionHandler))
    }

}
