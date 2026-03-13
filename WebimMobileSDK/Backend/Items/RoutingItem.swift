//
//  RoutingItem.swift
//  webim-client-sdk-ios
//
//  Created by Anna Frolova on 01.11.2025.
//

final class RoutingItem {
    
    private var visitorField: String?
    private var visitorFieldValue: String?
    private var locationKey: String?
    
    enum JSONField: String {
        case visitorField
        case visitorFieldValue
        case locationKey
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let visitorField = jsonDictionary[JSONField.visitorField.rawValue] as? String {
            self.visitorField = visitorField
        }
        
        if let visitorFieldValue = jsonDictionary[JSONField.visitorFieldValue.rawValue] as? String {
            self.visitorFieldValue = visitorFieldValue
        }
        
        if let locationKey = jsonDictionary[JSONField.locationKey.rawValue] as? String {
            self.locationKey = locationKey
        }
    }
    
    
    func getVisitorField() -> String? {
        return visitorField
    }
    
    func getVisitorFieldValue() -> String? {
        return visitorFieldValue
    }
    
    func getLocationKey() -> String? {
        return locationKey
    }
    
}
