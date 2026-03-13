//
//  ResourcesConfig.swift
//
//  Created by Anna Frolova on 16.12.2024.
//  Copyright © 2024 Webim. All rights reserved.
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

final class ResourcesConfigItem: ResourcesConfig {
    
    private var leaveMessage: String?
    private var firstQuestionMessage: String?
    private var chatOperatorTitle: String?
    private var personalAgreement: String?
    
    enum JSONField: String {
        case leaveMessage = "leavemessage-descr"
        case firstQuestionMessage = "first_question-descr"
        case chatOperatorTitle = "chat-operator-default_title"
        case personalAgreement = "chat-window-personal_data_agreement"
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let leaveMessage = jsonDictionary[JSONField.leaveMessage.rawValue] as? String {
            self.leaveMessage = leaveMessage
        }
        
        if let firstQuestionMessage = jsonDictionary[JSONField.firstQuestionMessage.rawValue] as? String {
            self.firstQuestionMessage = firstQuestionMessage
        }
        
        if let chatOperatorTitle = jsonDictionary[JSONField.chatOperatorTitle.rawValue] as? String {
            self.chatOperatorTitle = chatOperatorTitle
        }
        
        if let personalAgreement = jsonDictionary[JSONField.personalAgreement.rawValue] as? String {
            self.personalAgreement = personalAgreement
        }
    }
    
    func getLeaveMessage() -> String? {
        return leaveMessage
    }
    
    func getFirstQuestionMessage() -> String? {
        return firstQuestionMessage
    }
    
    func getChatOperatorTitle() -> String? {
        return chatOperatorTitle
    }
   
    func getPersonalAgreement() -> String? {
        return personalAgreement
    }
    
}
