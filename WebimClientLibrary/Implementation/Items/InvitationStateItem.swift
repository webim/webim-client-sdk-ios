//
//  InvitationStateItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

// Raw values equal to field names received in responses from server.
enum InvitationStateItem: String {
    
    case CHAT = "chat"
    case DEPARTMENT_SELECTION = "department-selection"
    case FIRST_QUESTION = "first-question"
    case IDLE = "idle"
    case IDLE_AFTER_CHAT = "idle-after-chat"
    case OFFLINE_MESSAGE = "offline-message"
    case SHOWING = "showing"
    case SHOWING_AUTO = "showing-auto"
    case SHOWING_BY_URL_PARAMETER = "showing-by-url-param"
    case UNKNOWN = "unknown"
    
    // Setted for getTypeBy(string:) method.
    private static let invitationStateValues = [CHAT,
                                                DEPARTMENT_SELECTION,
                                                FIRST_QUESTION,
                                                IDLE,
                                                IDLE_AFTER_CHAT,
                                                OFFLINE_MESSAGE,
                                                SHOWING,
                                                SHOWING_AUTO,
                                                SHOWING_BY_URL_PARAMETER,
                                                UNKNOWN]
    
    
    // MARK: - Initialization
    init(withType typeValue: String) {
        self = InvitationStateItem(rawValue: typeValue)!
    }
    
    
    // MARK: - Methods
    
    static func getTypeBy(string: String) -> InvitationStateItem {
        for invitationStateType in InvitationStateItem.invitationStateValues {
            if invitationStateType == InvitationStateItem(withType: string) {
                return invitationStateType
            }
        }
        
        return .UNKNOWN
    }
    
    func getTypeValue() -> String {
        return self.rawValue
    }
    
}
