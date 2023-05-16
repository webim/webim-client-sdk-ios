//
//  WebimService.swift
//  WebimClientLibrary
//
//  Created by Anna Frolova on 29.01.2021.
//  Copyright © 2021 Webim. All rights reserved.
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
    case latitude = "latitude"
    case location = "location"
    case longitude = "longitude"
    case message = "message"
    case operatorID = "operator_id"
    case pageID = "page-id"
    case platform = "platform"
    case providedAuthenticationToken = "provided_auth_token"
    case pushService = "push-service"
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
    case query = "query"
    case reaction = "reaction"
    case fileState = "state"
    case fileProgress = "progress"
    case fileError = "error"
    case fileSize = "file-size"
    case fileName = "file-name"
}

enum Platform: String {
    case ios = "ios"
}

enum ServerPathSuffix: String {
    case doAction = "/l/v/m/action"
    case fileDelete = "/l/v/file-delete"
    case getDelta = "/l/v/m/delta"
    case initPath = "/l/v/m/init"
    case getOnlineStatus = "/l/v/m/get-online-status"
    case downloadFile = "/l/v/m/download"
    case getHistory = "/l/v/m/history"
    case uploadFile = "/l/v/m/upload"
    case search = "/l/v/m/search-messages"
    case getConfig = "/api/visitor/v1/configs"
    case getServerSideSettings = "/x/js/v/all-settings-mobile.js"
}

enum MultipartBody: String {
    case name = "webim_upload_file"
}
