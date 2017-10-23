//
//  WebimPushNotificationImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class WebimPushNotificationImpl: WebimPushNotification {
    
    // MARK: - Constants
    
    enum APNsField: String {
        case APS = "aps"
    }
    
    enum APSField: String {
        case ALERT = "alert"
        case CUSTOM = "custom"
    }
    
    enum CustomField: String {
        case WEBIM = "webim"
    }
    
    private enum AlertField: String {
        case EVENT = "event"
        case PARAMETERS = "loc-args"
        case TYPE = "loc-key"
    }
    
    private enum InternalNotificationEvent: String {
        case ADD = "add"
        case DELETE = "del"
    }
    
    private enum InternalNotificationType: String {
        case OPERATOR_ACCEPTED = "P.OA"
        case OPERATOR_FILE = "P.OF"
        case OPERATOR_MESSAGE = "P.OM"
    }
    
    // MARK: - Properties
    private var event: InternalNotificationEvent
    private lazy var parameters = [String]()
    private var type: InternalNotificationType
    
    
    // MARK: - Initialization
    init?(withJSONDictionary jsonDictionary: [String : Any?]) {
        guard let event = jsonDictionary[AlertField.EVENT.rawValue] as? String else {
            return nil
        }
        
        guard let parameters = jsonDictionary[AlertField.PARAMETERS.rawValue] as? [String] else {
            return nil
        }
        
        guard let type = jsonDictionary[AlertField.TYPE.rawValue] as? String else {
            return nil
        }
        
        switch event {
        case InternalNotificationEvent.ADD.rawValue:
            self.event = .ADD
        case InternalNotificationEvent.DELETE.rawValue:
            self.event = .DELETE
        default:
            return nil
        }
        
        switch type {
        case InternalNotificationType.OPERATOR_ACCEPTED.rawValue:
            self.type = .OPERATOR_ACCEPTED
        case InternalNotificationType.OPERATOR_FILE.rawValue:
            self.type = .OPERATOR_FILE
        case InternalNotificationType.OPERATOR_MESSAGE.rawValue:
            self.type = .OPERATOR_MESSAGE
        default:
            return nil
        }

        self.parameters = parameters
    }
    
    
    // MARK: - Methods
    
    func getType() -> NotificationType {
        switch type {
        case .OPERATOR_ACCEPTED:
            return .OPERATOR_ACCEPTED
        case .OPERATOR_FILE:
            return .OPERATOR_FILE
        case .OPERATOR_MESSAGE:
            return .OPERATOR_MESSAGE
        }
    }
    
    func getEvent() -> NotificationEvent {
        switch event {
        case .ADD:
            return .ADD
        case .DELETE:
            return .DELETE
        }
    }
    
    func getParameters() -> [String] {
        return parameters
    }
    
}
