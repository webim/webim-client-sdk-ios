//
//  InvitationStateItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
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

import Foundation

/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
enum InvitationStateItem: String {
    
    // Raw values equal to field names received in responses from server.
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
    
    // MARK: - Properties
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
        for invitationStateType in InvitationStateItem.invitationStateValues {
            if typeValue == invitationStateType.rawValue {
                self = invitationStateType
                
                return
            }
        }
        
        self = .UNKNOWN
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
    
}
