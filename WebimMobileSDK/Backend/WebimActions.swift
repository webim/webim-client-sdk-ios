//
//  WebimActions.swift
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

protocol WebimActions {
    
    func send(message: String,
              clientSideID: String,
              dataJSONString: String?,
              isHintQuestion: Bool?,
              dataMessageCompletionHandler: DataMessageCompletionHandler?,
              editMessageCompletionHandler: EditMessageCompletionHandler?,
              sendMessageCompletionHandler: SendMessageCompletionHandler?)
    
    func send(file: Data,
              filename: String,
              mimeType: String,
              clientSideID: String,
              completionHandler: SendFileCompletionHandler?,
              uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler?)
    
    func sendFileProgress(fileSize: Int,
                          filename: String,
                          mimeType: String,
                          clientSideID: String,
                          error: SendFileError?,
                          progress: Int?,
                          state: SendFileProgressState,
                          completionHandler: SendFileCompletionHandler?,
                          uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandler?)
    
    func sendFiles(message: String,
                   clientSideID: String,
                   isHintQuestion: Bool?,
                   sendFilesCompletionHandler: SendFilesCompletionHandler?)
    
    func replay(message: String,
                clientSideID: String,
                quotedMessageID: String)
    
    func delete(clientSideID: String,
                completionHandler: DeleteMessageCompletionHandler?)
    
    func deleteUploadedFile(fileGuid: String,
                            completionHandler: DeleteUploadedFileCompletionHandler?)
    
    func startChat(withClientSideID clientSideID: String,
                   firstQuestion: String?,
                   departmentKey: String?,
                   customFields: String?)
    
    func closeChat()
    
    func set(visitorTyping: Bool,
             draft: String?,
             deleteDraft: Bool)
    
    func set(prechatFields: String)
    
    func requestHistory(since: String?,
                        completion: @escaping (_ data: Data?) throws -> ())
    
    func requestHistory(beforeMessageTimestamp: Int64,
                        completion: @escaping (_ data: Data?) throws -> ())
    
    func rateOperatorWith(id: String?,
                          rating: Int,
                          visitorNote: String?,
                          threadId: Int?,
                          completionHandler: RateOperatorCompletionHandler?)
    
    func sendResolutionSurvey(id: String,
                              answer: Int,
                              threadId: Int?,
                              completionHandler: SendResolutionCompletionHandler?)
    
    func respondSentryCall(id: String)
    
    func update(deviceToken: String)
    
    func setChatOrMessageRead(messageID: String?)
    
    func updateWidgetStatusWith(data: String)
    
    func sendKeyboardRequest(buttonId: String,
                             messageId: String,
                             completionHandler: SendKeyboardRequestCompletionHandler?)
    
    func sendDialogTo(emailAddress: String,
                      completionHandler: SendDialogToEmailAddressCompletionHandler?)
    
    func sendSticker(stickerId: Int,
                     clientSideId: String,
                     completionHandler: SendStickerCompletionHandler?)
    
    func sendReaction(reaction: ReactionString,
                     clientSideId: String,
                     completionHandler: ReactionCompletionHandler?)
    
    func sendQuestionAnswer(surveyID: String,
                            formID: Int,
                            questionID: Int,
                            surveyAnswer: String,
                            sendSurveyAnswerCompletionHandler: SendSurveyAnswerCompletionHandlerWrapper?)
    
    func closeSurvey(surveyID: String,
                     surveyCloseCompletionHandler: SurveyCloseCompletionHandler?)
    
    func getOnlineStatus(location: String,
                         completion: @escaping (_ data: Data?) throws -> ()) 
    
    func searchMessagesBy(query: String,
                          completion: @escaping (_ data: Data?) throws -> ())
    
    func clearHistory()
    
    func getServerSettings(forLocation: String,
                          completion: @escaping (_ data: Data?) throws -> ())
    
    func autocomplete(forText: String,
                      url: String,
                      completion: AutocompleteCompletionHandler?)

    func getServerSideSettings(completionHandler: ServerSideSettingsCompletionHandler?)
    
    func sendGeolocation(latitude: Double,
                         longitude: Double,
                         completionHandler: GeolocationCompletionHandler?)
}
