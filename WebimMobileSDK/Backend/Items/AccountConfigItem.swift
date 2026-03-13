//
//  AccountConfigItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 01.11.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
 - author:
 Nikita Kaberov
 - copyright:
 2022 Webim
 */
final class AccountConfigItem: AccountConfig {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case hintsEndpoint = "visitor_hints_api_endpoint"
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
        case maxVisitorUploadFileSize = "max_visitor_upload_file_size"
        case allowedUploadFileTypes = "allowed_upload_file_types"
        case rateOperator = "rate_operator"
        case showRateOperator = "show_visitor_rate_operator_button"
        case disablingMessageInputField = "disabling_message_input_field"
        case showProcessingPersonalDataCheckbox = "show_processing_personal_data_checkbox"
        case personalDataAgreementConfirmationMandatory = "personal_data_agreement_confirmation_mandatory"
        case processingPersonalDataUrl = "processing_personal_data_url"
        case rateForm = "rate_form"
        case ratedEntity = "rated_entity"
        case visitorSegment = "visitor_segment"
        case visitorUploadFile = "visitor_upload_file"
        case logo = "logo"
        case multilang = "multilang"
        case visitorEnablingProbability = "visitor_enabling_probability"
        case rateOperatorByClickOnAvatar = "rate_operator_by_click_on_avatar"
        case forceVisitorDisable = "force_visitor_disable"
        case defaultPhoneNumber = "default_phone_number"
        case visitorTracking = "visitor_tracking"
        case operatorCheckStatusOnline = "operator_check_status_online"
        case visitorWebsockets = "visitor_websockets"
        case defaultPrompterId = "default_prompter_id"
        case checkVisitorAuth = "check_visitor_auth"
        case offlineChatProcessing = "offline_chat_processing"
        case clientPhpUrl = "client_php_url"
        case operatorStatusTimer = "operator_status_timer"
        case openChatInNewTabForMobile = "open_chat_in_new_tab_for_mobile"
        case defaultSurveyId = "default_survey_id"
        case teleport = "teleport"
        case fileUrlExpiringTimeout = "file_url_expiring_timeout"
        case hideReferrer = "hide_referrer"
        case surveys = "surveys"
        case trackVisitorTyping = "track_visitor_typing"
        case chattingTimer = "chatting_timer"
        case defaultLang = "default_lang"
        case useEmojiAnnotations = "use_emoji_annotations"
        case messagesTranslator = "messages_translator"
        case privacyPolicyUrl = "privacy_policy_url"
    }
    
    // MARK: - Properties
    private var rawAccountConfig: [String: Any?]
    private var hintsEndpoint: String?
    private var webAndMobileQuoting: Bool?
    private var visitorMessageEditing: Bool?
    private var maxVisitorUploadFileSize: Int?
    private var allowedUploadFileTypes: [String]?
    private var rateOperator: Bool?
    private var showRateOperator: Bool?
    private var disablingMessageInputField: Bool?
    private var showProcessingPersonalDataCheckbox: Bool?
    private var personalDataAgreementConfirmationMandatory: Bool?
    private var processingPersonalDataUrl: String?
    private var rateForm: String?
    private var ratedEntity: String?
    private var visitorSegment: String?
    private var visitorUploadFile: Bool?
    private var logo: String?
    private var multilang: Bool?
    private var visitorEnablingProbability: Int?
    private var rateOperatorByClickOnAvatar: Bool?
    private var forceVisitorDisable: Bool?
    private var defaultPhoneNumber: String?
    private var visitorTracking: Bool?
    private var operatorCheckStatusOnline: Int?
    private var visitorWebsockets: Bool?
    private var defaultPrompterId: String?
    private var checkVisitorAuth: Bool?
    private var offlineChatProcessing: Bool?
    private var clientPhpUrl: String?
    private var operatorStatusTimer: Bool?
    private var openChatInNewTabForMobile: Bool?
    private var defaultSurveyId: Int?
    private var teleport: Bool?
    private var fileUrlExpiringTimeout: Int?
    private var hideReferrer: Bool?
    private var surveys: Bool?
    private var trackVisitorTyping: Bool?
    private var chattingTimer: Bool?
    private var defaultLang: String?
    private var useEmojiAnnotations: Bool?
    private var messagesTranslator: Bool?
    private var privacyPolicyUrl: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        self.rawAccountConfig = jsonDictionary
        if let hintsEndpoint = jsonDictionary[JSONField.hintsEndpoint.rawValue] as? String {
            self.hintsEndpoint = hintsEndpoint
        }
        if let webAndMobileQuoting = jsonDictionary[JSONField.webAndMobileQuoting.rawValue] as? Bool {
            self.webAndMobileQuoting = webAndMobileQuoting
        }
        if let visitorMessageEditing = jsonDictionary[JSONField.visitorMessageEditing.rawValue] as? Bool {
            self.visitorMessageEditing = visitorMessageEditing
        }
        
        if let rateOperator = jsonDictionary[JSONField.rateOperator.rawValue] as? Bool {
            self.rateOperator = rateOperator
        }
        
        if let showRateOperator = jsonDictionary[JSONField.showRateOperator.rawValue] as? Bool {
            self.showRateOperator = showRateOperator
        }
        
        if let maxVisitorUploadFileSize = jsonDictionary[JSONField.maxVisitorUploadFileSize.rawValue] as? Int {
            if maxVisitorUploadFileSize != 0 {
                self.maxVisitorUploadFileSize = maxVisitorUploadFileSize
            } else {
                self.maxVisitorUploadFileSize = 10
            }
        }
        
        if let allowedUploadFileTypes = jsonDictionary[JSONField.allowedUploadFileTypes.rawValue] as? String {
            self.allowedUploadFileTypes = allowedUploadFileTypes.components(separatedBy: ", ")
        }
        
        if let disablingMessageInputField = jsonDictionary[JSONField.disablingMessageInputField.rawValue] as? Bool {
            self.disablingMessageInputField = disablingMessageInputField
        }
        
        if let showProcessingPersonalDataCheckbox = jsonDictionary[JSONField.showProcessingPersonalDataCheckbox.rawValue] as? Bool {
            self.showProcessingPersonalDataCheckbox = showProcessingPersonalDataCheckbox
        }
        
        if let personalDataAgreementConfirmationMandatory = jsonDictionary[JSONField.personalDataAgreementConfirmationMandatory.rawValue] as? Bool {
            self.personalDataAgreementConfirmationMandatory = personalDataAgreementConfirmationMandatory
        }
        
        if let processingPersonalDataUrl = jsonDictionary[JSONField.processingPersonalDataUrl.rawValue] as? String {
            self.processingPersonalDataUrl = processingPersonalDataUrl
        }
        
        if let rateForm = jsonDictionary[JSONField.rateForm.rawValue] as? String {
            self.rateForm = rateForm
        }
        
        if let ratedEntity = jsonDictionary[JSONField.ratedEntity.rawValue] as? String {
            self.ratedEntity = ratedEntity
        }
        
        if let visitorSegment = jsonDictionary[JSONField.visitorSegment.rawValue] as? String {
            self.visitorSegment = visitorSegment
        }
        
        if let visitorUploadFile = jsonDictionary[JSONField.visitorUploadFile.rawValue] as? Bool {
            self.visitorUploadFile = visitorUploadFile
        }
        
        if let logo = jsonDictionary[JSONField.logo.rawValue] as? String {
            self.logo = logo
        }
        
        if let multilang = jsonDictionary[JSONField.multilang.rawValue] as? Bool {
            self.multilang = multilang
        }
        
        if let visitorEnablingProbability = jsonDictionary[JSONField.visitorEnablingProbability.rawValue] as? Int {
            self.visitorEnablingProbability = visitorEnablingProbability
        }
        
        if let rateOperatorByClickOnAvatar = jsonDictionary[JSONField.rateOperatorByClickOnAvatar.rawValue] as? Bool {
            self.rateOperatorByClickOnAvatar = rateOperatorByClickOnAvatar
        }
        
        if let forceVisitorDisable = jsonDictionary[JSONField.forceVisitorDisable.rawValue] as? Bool {
            self.forceVisitorDisable = forceVisitorDisable
        }
        
        if let defaultPhoneNumber = jsonDictionary[JSONField.defaultPhoneNumber.rawValue] as? String {
            self.defaultPhoneNumber = defaultPhoneNumber
        }
        
        if let visitorTracking = jsonDictionary[JSONField.visitorTracking.rawValue] as? Bool {
            self.visitorTracking = visitorTracking
        }
        
        if let operatorCheckStatusOnline = jsonDictionary[JSONField.operatorCheckStatusOnline.rawValue] as? Int {
            self.operatorCheckStatusOnline = operatorCheckStatusOnline
        }
        
        if let visitorWebsockets = jsonDictionary[JSONField.visitorWebsockets.rawValue] as? Bool {
            self.visitorWebsockets = visitorWebsockets
        }
        
        if let defaultPrompterId = jsonDictionary[JSONField.defaultPrompterId.rawValue] as? String {
            self.defaultPrompterId = defaultPrompterId
        }
        
        if let checkVisitorAuth = jsonDictionary[JSONField.checkVisitorAuth.rawValue] as? Bool {
            self.checkVisitorAuth = checkVisitorAuth
        }
        
        if let offlineChatProcessing = jsonDictionary[JSONField.offlineChatProcessing.rawValue] as? Bool {
            self.offlineChatProcessing = offlineChatProcessing
        }
        
        if let clientPhpUrl = jsonDictionary[JSONField.clientPhpUrl.rawValue] as? String {
            self.clientPhpUrl = clientPhpUrl
        }
        
        if let operatorStatusTimer = jsonDictionary[JSONField.operatorStatusTimer.rawValue] as? Bool {
            self.operatorStatusTimer = operatorStatusTimer
        }
        
        if let openChatInNewTabForMobile = jsonDictionary[JSONField.openChatInNewTabForMobile.rawValue] as? Bool {
            self.openChatInNewTabForMobile = openChatInNewTabForMobile
        }
        
        if let defaultSurveyId = jsonDictionary[JSONField.defaultSurveyId.rawValue] as? Int {
            self.defaultSurveyId = defaultSurveyId
        }
        
        if let teleport = jsonDictionary[JSONField.teleport.rawValue] as? Bool {
            self.teleport = teleport
        }
        
        if let fileUrlExpiringTimeout = jsonDictionary[JSONField.fileUrlExpiringTimeout.rawValue] as? Int {
            self.fileUrlExpiringTimeout = fileUrlExpiringTimeout
        }
        
        if let hideReferrer = jsonDictionary[JSONField.hideReferrer.rawValue] as? Bool {
            self.hideReferrer = hideReferrer
        }
        
        if let surveys = jsonDictionary[JSONField.surveys.rawValue] as? Bool {
            self.surveys = surveys
        }
        
        if let trackVisitorTyping = jsonDictionary[JSONField.trackVisitorTyping.rawValue] as? Bool {
            self.trackVisitorTyping = trackVisitorTyping
        }
        
        if let chattingTimer = jsonDictionary[JSONField.chattingTimer.rawValue] as? Bool {
            self.chattingTimer = chattingTimer
        }
        
        if let defaultLang = jsonDictionary[JSONField.defaultLang.rawValue] as? String {
            self.defaultLang = defaultLang
        }
        
        if let useEmojiAnnotations = jsonDictionary[JSONField.useEmojiAnnotations.rawValue] as? Bool {
            self.useEmojiAnnotations = useEmojiAnnotations
        }
        
        if let messagesTranslator = jsonDictionary[JSONField.messagesTranslator.rawValue] as? Bool {
            self.messagesTranslator = messagesTranslator
        }
        
        if let privacyPolicyUrl = jsonDictionary[JSONField.privacyPolicyUrl.rawValue] as? String {
            self.privacyPolicyUrl = privacyPolicyUrl
        }
    }
    
    // MARK: - Methods
    func getRawAccountConfig() -> [String: Any?] {
        return rawAccountConfig
    }
    
    func getHintsEndpoint() -> String? {
        return hintsEndpoint
    }
    
    func getWebAndMobileQuoting() -> Bool {
        return webAndMobileQuoting ?? true
    }
    
    func getVisitorMessageEditing() -> Bool {
        return visitorMessageEditing ?? true
    }
    
    func getMaxVisitorUploadFileSize() -> Int? {
        return maxVisitorUploadFileSize
    }
    
    func getAllowedUploadFileTypes() -> [String] {
        return allowedUploadFileTypes ?? []
    }
    
    func getAllowedRateOperator() -> Bool {
        return rateOperator ?? true
    }
    
    func getShowRateOperator() -> Bool {
        return showRateOperator ?? true
    }
    
    func getDisablingMessageInputField() -> Bool {
        return disablingMessageInputField ?? false
    }
    
    func getShowProcessingPersonalDataCheckbox() -> Bool {
        return showProcessingPersonalDataCheckbox ?? true
    }
    
    func getPersonalDataAgreementConfirmationMandatory() -> Bool {
        return personalDataAgreementConfirmationMandatory ?? true
    }
    
    func getProcessingPersonalDataUrl() -> String? {
        return processingPersonalDataUrl
    }

    func getRateForm() -> String? {
        return rateForm
    }
    
    func getRatedEntity() -> String? {
        return ratedEntity
    }
    
    func getVisitorSegment() -> String? {
        return visitorSegment
    }
    
    func getVisitorUploadFile() -> Bool {
        return visitorUploadFile ?? true
    }
    
    func getLogo() -> String? {
        return logo
    }
    
    func getMultilang() -> Bool {
        return multilang ?? false
    }
    func getVisitorEnablingProbability() -> Int? {
        return visitorEnablingProbability
    }
    
    func getRateOperatorByClickOnAvatar() -> Bool {
        return rateOperatorByClickOnAvatar ?? true
    }
    
    func getForceVisitorDisable() -> Bool {
        return forceVisitorDisable ?? false
    }
    
    func getDefaultPhoneNumber() -> String? {
        return defaultPhoneNumber
    }
    
    func getVisitorTracking() -> Bool {
        return visitorTracking ?? false
    }
    
    func getOperatorCheckStatusOnline() -> Int? {
        return operatorCheckStatusOnline
    }
    
    func getVisitorWebsockets() -> Bool {
        return visitorWebsockets ?? false
    }
    
    func getDefaultPrompterId() -> String? {
        return defaultPrompterId
    }
    
    func getCheckVisitorAuth() -> Bool {
        return checkVisitorAuth ?? false
    }
    
    func getOfflineChatProcessing() -> Bool {
        return offlineChatProcessing ?? false
    }
    
    func getClientPhpUrl() -> String? {
        return clientPhpUrl
    }
    
    func getOperatorStatusTimer() -> Bool {
        return operatorStatusTimer ?? false
    }
    
    func getOpenChatInNewTabForMobile() -> Bool {
        return openChatInNewTabForMobile ?? false
    }
    
    func getDefaultSurveyId() -> Int? {
        return defaultSurveyId
    }
    
    func getTeleport() -> Bool {
        return teleport ?? false
    }
    
    func getFileUrlExpiringTimeout() -> Int? {
        return fileUrlExpiringTimeout
    }
    
    func getHideReferrer() -> Bool {
        return hideReferrer ?? false
    }
    
    func getSurveys() -> Bool {
        return surveys ?? false
    }
    
    func getTrackVisitorTyping() -> Bool {
        return trackVisitorTyping ?? false
    }
    
    func getChattingTimer() -> Bool {
        return chattingTimer ?? false
    }
    
    func getDefaultLang() -> String? {
        return defaultLang
    }
    
    func getUseEmojiAnnotations() -> Bool {
        return useEmojiAnnotations ?? false
    }
    
    func getMessagesTranslator() -> Bool? {
        return messagesTranslator
    }
    
    func getPrivacyPolicyUrl() -> String? {
        return privacyPolicyUrl
    }
}
