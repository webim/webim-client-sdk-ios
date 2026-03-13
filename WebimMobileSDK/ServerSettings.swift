//
//  Department.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 12.12.17.
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

/**
 Abstracts a server settings.
 - seealso:
 `MessageStream.getServerSideSettings()`
 `ServerSideSettingsCompletionHandler`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol ServerSettings {
    
    /**
     - returns:
     Account configuration object.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getAccountConfig() -> AccountConfig?
    
    /**
     - returns:
     Location settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getLocationSettings() -> [String: Any?]
    
    /**
     - returns:
     Chat configuration object.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getChatConfig() -> ChatConfig?
    
    /**
     - returns:
     Resources configuration object.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getResources() -> ResourcesConfig?
}

/**
 Abstracts an account configuration.
 - seealso:
 `ServerSettings.getAccountConfig()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol AccountConfig {
    
    /**
     - returns:
     Raw account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getRawAccountConfig() -> [String: Any?]
    
    /**
     - returns:
     Hints endpoint from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getHintsEndpoint() -> String?
    
    /**
     - returns:
     True if web and mobile quoting enadled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getWebAndMobileQuoting() -> Bool
    
    /**
     - returns:
     True if visitor message editing enadled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorMessageEditing() -> Bool
    
    /**
     - returns:
     Max visitor upload file size from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getMaxVisitorUploadFileSize() -> Int?
    
    /**
     - returns:
     Allowed upload file types from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getAllowedUploadFileTypes() -> [String]
    
    /**
     - returns:
     True if rate operator enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getAllowedRateOperator() -> Bool
    
    /**
     - returns:
     True if needs to show rate operator button.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getShowRateOperator() -> Bool
    
    /**
     - returns:
     True if needs disabling message input field .
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDisablingMessageInputField() -> Bool
    
    /**
     - returns:
     True if needs to show processing personal data checkbox.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getShowProcessingPersonalDataCheckbox() -> Bool
    
    /**
     - returns:
     True if needs to show personal data agreement confirmation.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getPersonalDataAgreementConfirmationMandatory() -> Bool
    
    /**
     - returns:
     Processing personal data url from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getProcessingPersonalDataUrl() -> String?
    
    /**
     - returns:
     Rate form from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getRateForm() -> String?
    
    /**
     - returns:
     Rated entity from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getRatedEntity() -> String?
    
    /**
     - returns:
     Visitor segment from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorSegment() -> String?
    
    /**
     - returns:
     True if visitor upload file enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorUploadFile() -> Bool
    
    /**
     - returns:
     Logo from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getLogo() -> String?
    
    /**
     - returns:
     True if multilang enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getMultilang() -> Bool
    
    /**
     - returns:
     Visitor enabling probability from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorEnablingProbability() -> Int?
    
    /**
     - returns:
     True if needs show rate operator by click on avatar.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getRateOperatorByClickOnAvatar() -> Bool
    
    /**
     - returns:
     True if force visitor is disabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getForceVisitorDisable() -> Bool
    
    /**
     - returns:
     Default phone number from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDefaultPhoneNumber() -> String?
    
    /**
     - returns:
     True if visitor tracking enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorTracking() -> Bool
    
    /**
     - returns:
     Operator check status online.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getOperatorCheckStatusOnline() -> Int?
    
    /**
     - returns:
     True if visitor websockets is enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorWebsockets() -> Bool
    
    /**
     - returns:
     Default prompter id from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDefaultPrompterId() -> String?
    
    /**
     - returns:
     True if check visitor auth.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getCheckVisitorAuth() -> Bool
    
    /**
     - returns:
     True if offline chat processing is enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getOfflineChatProcessing() -> Bool
    
    /**
     - returns:
     Client php url from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getClientPhpUrl() -> String?
    
    /**
     - returns:
     True if operator status timer enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getOperatorStatusTimer() -> Bool
    
    /**
     - returns:
     True if open chat in new tab for mobile enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getOpenChatInNewTabForMobile() -> Bool
    
    /**
     - returns:
     Default survey id.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDefaultSurveyId() -> Int?
    
    /**
     - returns:
     True if teleport enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getTeleport() -> Bool
    
    /**
     - returns:
     File url expiring timeout.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getFileUrlExpiringTimeout() -> Int?
    
    /**
     - returns:
     True if hide referrer enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getHideReferrer() -> Bool
    
    /**
     - returns:
     True if surveys enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getSurveys() -> Bool
    
    /**
     - returns:
     True if track visitor typing enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getTrackVisitorTyping() -> Bool
    
    /**
     - returns:
     True if chatting timer enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getChattingTimer() -> Bool
    
    /**
     - returns:
     Default lang from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDefaultLang() -> String?
    
    /**
     - returns:
     True if use emoji annotations enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getUseEmojiAnnotations() -> Bool
    
    /**
     - returns:
     True if messages translator enabled.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getMessagesTranslator() -> Bool?
    
    /**
     - returns:
     Privacy policy url from account configuration.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getPrivacyPolicyUrl() -> String?
}

/**
 Abstracts a resources configuration.
 - seealso:
 `ServerSettings.getResources()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol ResourcesConfig {
    
    /**
     - returns:
     Leave message text.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getLeaveMessage() -> String?
    
    /**
     - returns:
     First question message text.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getFirstQuestionMessage() -> String?
    
    /**
     - returns:
     Chat operator title text.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getChatOperatorTitle() -> String?
    
    /**
     - returns:
     Personal agreement text.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getPersonalAgreement() -> String?
}

/**
 Abstracts a chat configuration.
 - seealso:
 `ServerSettings.getChatConfig()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol ChatConfig {
    
    /**
     - returns:
     Visitor fields settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorFields() -> ContactsSettings?
    
    /**
     - returns:
     Visitor fields labels.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getVisitorFieldLabels() -> [String: String?]?
   
}

/**
 Abstracts a contact forms configuration.
 - seealso:
 `ChatConfig.getVisitorFields()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol ContactsSettings {
    
    /**
     - returns:
     Default settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getDef() -> [String: Contact]?
    
    /**
     - returns:
     Offline mode settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getOfflineModeVsDef() -> [String: Contact]?
    
    /**
     - returns:
     First question settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getFirstQuestionVsDef() -> [String: Contact]?
    
    /**
     - returns:
     Contacts request settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getContactsRequestVsDef() -> [String: Contact]?
}

/**
 Abstracts a field configuration.
 - seealso:
 `ContactsSettings`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol Contact {
    
    /**
     - returns:
     Presence settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getPresence() -> Presence?
    
    /**
     - returns:
     Validation settings.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getValidation() -> Validation?
    
}

/**
 Abstracts a contact validation configuration.
 - seealso:
 `Contact.getValidation()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public protocol Validation {
    
    /**
     - returns:
     Max length of field.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getMaxLength() -> Int?
    
    /**
     - returns:
     Type of field.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getType() -> String?
    
    /**
     - returns:
     Mask of field.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    func getMask() -> String?
    
}

/**
 Abstracts a contact presence configuration.
 - seealso:
 `Contact.getPresence()`
 - author:
 Anna Frolova
 - copyright:
 2026 Webim
 */
public enum Presence: String {
    
    /**
     Means that presence is none.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    case none
    
    /**
     Means that presence is mandatory.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    case mandatory
    
    /**
     Means that presence is optional.
     - author:
     Anna Frolova
     - copyright:
     2026 Webim
     */
    case optional
}
