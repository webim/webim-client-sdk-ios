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
final class AccountConfigItem {
    
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
        case rateForm = "rate_form"
        case ratedEntity = "rated_entity"
        case visitorSegment = "visitor_segment"
        case messagesTranslator = "messages_translator"
    }
    
    // MARK: - Properties
    private var hintsEndpoint: String?
    private var webAndMobileQuoting: Bool?
    private var visitorMessageEditing: Bool?
    private var maxVisitorUploadFileSize: Int?
    private var allowedUploadFileTypes: [String]?
    private var rateOperator: Bool?
    private var showRateOperator: Bool?
    private var disablingMessageInputField: Bool?
    private var rateForm: String?
    private var ratedEntity: String?
    private var visitorSegment: String?
    private var messagesTranslator: Bool?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
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
        
        if let rateForm = jsonDictionary[JSONField.rateForm.rawValue] as? String {
            self.rateForm = rateForm
        }
        
        if let ratedEntity = jsonDictionary[JSONField.ratedEntity.rawValue] as? String {
            self.ratedEntity = ratedEntity
        }
        
        if let visitorSegment = jsonDictionary[JSONField.visitorSegment.rawValue] as? String {
            self.visitorSegment = visitorSegment
        }
        
        if let messagesTranslator = jsonDictionary[JSONField.messagesTranslator.rawValue] as? Bool {
            self.messagesTranslator = messagesTranslator
        }
    }
    
    // MARK: - Methods
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
    
    func getRateForm() -> String? {
        return rateForm
    }
    
    func getRatedEntity() -> String? {
        return ratedEntity
    }
    
    func getVisitorSegment() -> String? {
        return visitorSegment
    }
    
    func getMessagesTranslator() -> Bool? {
        return messagesTranslator
    }
}
