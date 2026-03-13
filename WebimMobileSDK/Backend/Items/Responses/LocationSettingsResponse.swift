//
//  LocationStatusResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 22.08.21.
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

/**
 - author:
 Nikita Kaberov
 - copyright:
 2021 Webim
 */
final class ServerSettingsResponse: ServerSettings {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case accountConfig
        case locationSettings
        case chat
        case resources
        case routingRules
    }
    
    // MARK: - Properties
    private var accountConfig: AccountConfig?
    private var locationSettings: [String: Any?]?
    private var chatConfig: ChatConfig?
    private var resourcesConfig: ResourcesConfig?
    private var routingRules: [RoutingItem]?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let accountConfig = jsonDictionary[JSONField.accountConfig.rawValue] as? [String: Any?] {
            self.accountConfig = AccountConfigItem(jsonDictionary: accountConfig)
        }
        if let locationSettings = jsonDictionary[JSONField.locationSettings.rawValue] as? [String: Any?] {
            self.locationSettings = locationSettings
            if let chatConfig = locationSettings[JSONField.chat.rawValue] as? [String: Any?] {
                self.chatConfig = ChatConfigItem(jsonDictionary: chatConfig)
            }
            if let resourcesConfig = locationSettings[JSONField.resources.rawValue] as? [String: Any?] {
                self.resourcesConfig = ResourcesConfigItem(jsonDictionary: resourcesConfig)
            }
            
        }
        if let routingRules = jsonDictionary[JSONField.routingRules.rawValue] as? [[String: Any]] {
            self.routingRules = routingRules.compactMap { RoutingItem(jsonDictionary: $0) }
        }
    }
    
    // MARK: - Methods
    func getAccountConfig() -> AccountConfig? {
        return accountConfig
    }
    
    func getLocationSettings() -> [String: Any?] {
        if let accountConfig = accountConfig {
            if locationSettings == nil {
                locationSettings = [:]
            }
            locationSettings?["max_visitor_upload_file_size"] = accountConfig.getMaxVisitorUploadFileSize()
            locationSettings?["allowed_upload_file_types"] = accountConfig.getAllowedUploadFileTypes()
        }
        return locationSettings ?? [:]
    }
    
    func getChatConfig() -> ChatConfig? {
        return chatConfig
    }
    
    func getResources() -> ResourcesConfig? {
        return resourcesConfig
    }
    
    func getRoutingRules() -> [RoutingItem]? {
        return routingRules
    }
    
}
