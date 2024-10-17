//
//  WebimServerSideSettingsImpl.swift
//  WebimClientLibrary
//
//  Created by Аслан Кутумбаев on 15.06.2022.
//  
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

// Unused fields disabled to avoid crash in case of API field type changes

// MARK: - WebimServerSideSettings
public struct WebimServerSideSettings: Codable {
//    let accountBlocked: Bool
    public let accountConfig: AccountConfig
}

// MARK: - AccountConfig
public struct AccountConfig: Codable {
    public let webAndMobileQuoting: Bool
    public let visitorMessageEditing: Bool
    public let maxVisitorUploadFileSize: Int
    public let allowedUploadFileTypes: String
    public let rateOperator: Bool
    public let showRateOperator: Bool?
    public let disablingMessageInputField: Bool?
//    let multilang, chattingTimer, googleAnalytics: Bool
//    let yandexMetrikaCounterID: JSONNull?
//    let teleport: Bool
//    let clientPHPURL: JSONNull?
//    let hideReferrer, forceVisitorHTTPS, visitorTracking, forceVisitorDisable: Bool
//    let visitorEnablingProbability: Int
//    let defaultLang: String
//    let showProcessingPersonalDataCheckbox, visitorWebsockets, visitorUploadFile: Bool
//    let operatorCheckStatusOnline: Int
//    let visitorHintsAPIEndpoint: JSONNull?
//    let fileURLExpiringTimeout: Int
//    let checkVisitorAuth, operatorStatusTimer, ,
//    let offlineChatProcessing, openChatInNewTabForMobile: Bool

    enum CodingKeys: String, CodingKey {
        case webAndMobileQuoting = "web_and_mobile_quoting"
        case visitorMessageEditing = "visitor_message_editing"
        case maxVisitorUploadFileSize = "max_visitor_upload_file_size"
        case allowedUploadFileTypes = "allowed_upload_file_types"
        case rateOperator = "rate_operator"
        case showRateOperator = "show_visitor_rate_operator_button"
        case disablingMessageInputField = "disabling_message_input_field"
//        case multilang
//        case chattingTimer = "chatting_timer"
//        case googleAnalytics = "google_analytics"
//        case yandexMetrikaCounterID = "yandex_metrika_counter_id"
//        case teleport
//        case clientPHPURL = "client_php_url"
//        case hideReferrer = "hide_referrer"
//        case forceVisitorHTTPS = "force_visitor_https"
//        case visitorTracking = "visitor_tracking"
//        case forceVisitorDisable = "force_visitor_disable"
//        case visitorEnablingProbability = "visitor_enabling_probability"
//        case defaultLang = "default_lang"
//        case showProcessingPersonalDataCheckbox = "show_processing_personal_data_checkbox"
//        case visitorWebsockets = "visitor_websockets"
//        case visitorUploadFile = "visitor_upload_file"
//        case operatorCheckStatusOnline = "operator_check_status_online"
//        case visitorHintsAPIEndpoint = "visitor_hints_api_endpoint"
//        case fileURLExpiringTimeout = "file_url_expiring_timeout"
//        case checkVisitorAuth = "check_visitor_auth"
//        case operatorStatusTimer = "operator_status_timer"
//        case offlineChatProcessing = "offline_chat_processing"
//        case openChatInNewTabForMobile = "open_chat_in_new_tab_for_mobile"
    }
}
