//
//  ChatConfigItem.swift
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

final class ChatConfigItem: ChatConfig {
    
    private var visitorFields: ContactsSettingsItem?
    private var visitorFieldLabels: [String: String?]?
    
    enum JSONField: String {
        case visitorFields
        case visitorFieldLabels
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let visitorFields = jsonDictionary[JSONField.visitorFields.rawValue] as? [String: Any?] {
            self.visitorFields = ContactsSettingsItem(jsonDictionary: visitorFields)
        }
        
        if let visitorFieldLabels = jsonDictionary[JSONField.visitorFieldLabels.rawValue] as? [String: String?] {
            self.visitorFieldLabels = visitorFieldLabels
        }
    }
    
    
    func getVisitorFields() -> ContactsSettings? {
        return visitorFields
    }
    
    func getVisitorFieldLabels() -> [String: String?]? {
        return visitorFieldLabels
    }
    
}

private class ContactsSettingsItem: ContactsSettings {
    
    private var def: [String: ContactItem]?
    private var offlineMode: [String: ContactItem]?
    private var firstQuestion: [String: ContactItem]?
    private var contactsRequest: [String: ContactItem]?
    
    enum JSONField: String {
        case def
        case offlineMode
        case firstQuestion
        case contactsRequest
    }
    
    func getDef() -> [String: Contact]? {
        return def
    }

    func getOfflineModeVsDef() -> [String: Contact]? {
        return mergeContacts(first: def, second: offlineMode)
    }
       
    func getFirstQuestionVsDef() -> [String: Contact]? {
        return mergeContacts(first: def, second: firstQuestion)
    }
       
    func getContactsRequestVsDef() -> [String: Contact]? {
        return mergeContacts(first: def, second: contactsRequest)
    }
   
    private func mergeContacts(first: [String: ContactItem]?, second: [String: ContactItem]?) -> [String: ContactItem]? {
        var contactsDict = first
        second?.compactMap { $0 }.forEach { item in
            contactsDict?[item.key] = item.value
        }
        return contactsDict
    }
    
    private func convertContacts(_ dictionary: [String: Any?]) -> [String: ContactItem]? {
        let contacts = dictionary.compactMap{ (key, value) -> (String, ContactItem)? in
            if let contactValue = value as? [String : Any?] {
                let contact = ContactItem(jsonDictionary: contactValue)
                return (key, contact)
            } else {
                return nil
            }
        }
        return Dictionary(uniqueKeysWithValues: contacts)
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let def = jsonDictionary[JSONField.def.rawValue] as? [String: Any] {
            self.def = convertContacts(def)
        }
        
        if let offlineMode = jsonDictionary[JSONField.offlineMode.rawValue] as? [String: Any] {
            self.offlineMode = convertContacts(offlineMode)
        }
        
        if let firstQuestion = jsonDictionary[JSONField.firstQuestion.rawValue] as? [String: Any] {
            self.firstQuestion = convertContacts(firstQuestion)
        }
        
        if let contactsRequest = jsonDictionary[JSONField.contactsRequest.rawValue] as? [String: Any] {
            self.contactsRequest = convertContacts(contactsRequest)
        }
    }
    
}

final class ContactItem: Contact {
    
    private var presence: Presence?
    private var validation: Validation?
    
    enum JSONField: String {
        case presence
        case validation
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let presence = jsonDictionary[JSONField.presence.rawValue] as? String {
            self.presence = Presence(rawValue: presence)
        }
        
        if let validation = jsonDictionary[JSONField.validation.rawValue] as? [String: Any?] {
            self.validation = ValidationItem(jsonDictionary: validation)
        }
    }
    
    func getPresence() -> Presence? {
        return presence
    }
    
    func getValidation() -> Validation? {
        return validation
    }
}


final class ValidationItem: Validation {
    private var maxLength: Int?
    private var type: String?
    private var mask: String?
    
    enum JSONField: String {
        case maxLength
        case type
        case mask
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let maxLength = jsonDictionary[JSONField.maxLength.rawValue] as? Int {
            self.maxLength = maxLength
        }
        
        if let type = jsonDictionary[JSONField.type.rawValue] as? String {
            self.type = type
        }
        
        if let mask = jsonDictionary[JSONField.mask.rawValue] as? String {
            self.mask = mask
        }
    }
    
    func getMaxLength() -> Int? {
        return maxLength
    }
    
    func getType() -> String? {
        return type
    }
    
    func getMask() -> String? {
        return mask
    }

}
