//
//  DeltaResponse.swift
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
 Class that encapsulates chat update respnonce, requested from a server.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class DeltaResponse {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case deltaList = "deltaList"
        case fullUpdate = "fullUpdate"
        case revision = "revision"
    }
    
    // MARK: - Properties
    private lazy var deltaList = [DeltaItem]()
    private var fullUpdate: FullUpdate?
    private var revision: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        let revision = jsonDictionary[JSONField.revision.rawValue] 
        if let revision = revision as? String {
            self.revision = revision
        } else if let revision = revision as? Int {
            self.revision = String(revision)
        }
        
        if let fullUpdateValue = jsonDictionary[JSONField.fullUpdate.rawValue] as? [String: Any?] {
            fullUpdate = FullUpdate(jsonDictionary: fullUpdateValue)
        }
        
        if let deltaItemArray = jsonDictionary[JSONField.deltaList.rawValue] as? [Any] {
            for arrayItem in deltaItemArray {
                if let arrayItem = arrayItem as? [String: Any?] {
                    if let deltaItem = DeltaItem(jsonDictionary: arrayItem) {
                        deltaList.append(deltaItem)
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func getRevision() -> String? {
        return revision
    }
    
    func getFullUpdate() -> FullUpdate? {
        return fullUpdate
    }
    
    func getDeltaList() -> [DeltaItem]? {
        return deltaList
    }
    
}
