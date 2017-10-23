//
//  IconItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class IconItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case COLOR = "color"
        case SHAPE = "shape"
    }
    
    
    // MARK: - Properties
    private var color: String?
    private var shape: String?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let color = jsonDictionary[JSONField.COLOR.rawValue] as? String {
            self.color = color
        }
        
        if let shape = jsonDictionary[JSONField.SHAPE.rawValue] as? String {
            self.shape = shape
        }
    }
    
    
    // MARK: - Methods
    
    func getColor() -> String? {
        return color
    }
    
    func getShape() -> String? {
        return shape
    }
    
}
