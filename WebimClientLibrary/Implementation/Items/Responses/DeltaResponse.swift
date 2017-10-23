//
//  DeltaResponse.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class DeltaResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case DELTA_LIST = "deltaList"
        case FULL_UPDATE = "fullUpdate"
        case REVISION = "revision"
    }
    
    
    // MARK: - Properties
    private lazy var deltaList = [DeltaItem]()
    private var fullUpdate: FullUpdate?
    private var revision: Int64?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let revision = jsonDictionary[JSONField.REVISION.rawValue] as? Int64 {
            self.revision = revision
        }
        
        if let fullUpdateValue = jsonDictionary[JSONField.FULL_UPDATE.rawValue] as? [String : Any?] {
            fullUpdate = FullUpdate(withJSONDictionary: fullUpdateValue)
        }
        
        if let deltaItemArray = jsonDictionary[JSONField.DELTA_LIST.rawValue] as? [Any] {
            for arrayItem in deltaItemArray {
                let deltaItem = DeltaItem(withJSONDictionary: arrayItem as! [String : Any?])
                deltaList.append(deltaItem)
            }
        }
    }
    
    
    // MARK: - Methods
    
    func getRevision() -> Int64? {
        return revision
    }
    
    func getFullUpdate() -> FullUpdate? {
        return fullUpdate
    }
    
    func getDeltaList() -> [DeltaItem]? {
        return deltaList
    }
    
}
