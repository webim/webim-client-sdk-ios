//
//  ProvidedVisitorFields.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class ProvidedVisitorFields {
    
    // MARK: - Properties
    private let id: String
    private let jsonString: String
    
    
    // MARK: - Initialization
    
    init(withJSONString jsonString: String,
         JSONObject: Data) throws {
        if let jsonData = try JSONSerialization.jsonObject(with: JSONObject) as? [String : Any] {
            if let fields = jsonData["fields"] as? [String : String] {
                if let id = fields["id"] {
                    self.id = id
                } else {
                    throw VisitorFieldsError.invalidVisitorFields("Visitor fields JSON object must contain ID field")
                }
            } else if let id = jsonData["id"] as? String {
                self.id = id
            } else {
                throw VisitorFieldsError.invalidVisitorFields("Visitor fields JSON object must contain ID field")
            }
        } else {
            throw VisitorFieldsError.serializingFail("Error serializing visitor JSON data.")
        }
        
        self.jsonString = jsonString
    }
    
    convenience init?(withJSONString jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                try self.init(withJSONString: jsonString,
                              JSONObject: jsonData)
            } catch VisitorFieldsError.invalidVisitorFields(let error) {
                print(error)
                return nil
            } catch VisitorFieldsError.serializingFail(let error) {
                print(error)
                return nil
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    convenience init?(withJSONObject jsonData: Data) {
        let jsonString = String(data: jsonData,
                                encoding: .utf8)
        
        do {
            try self.init(withJSONString: jsonString!,
                          JSONObject: jsonData)
        } catch VisitorFieldsError.invalidVisitorFields(let error) {
            print(error)
            return nil
        } catch VisitorFieldsError.serializingFail(let error) {
            print(error)
            return nil
        } catch {
            return nil
        }
        
    }
    
    
    // MARK: - Methods
    
    func getID() -> String {
        return id
    }
    
    func getJSONString() -> String {
        return jsonString
    }
    
    
    // MARK:
    enum VisitorFieldsError: Error {
        case serializingFail(String)
        case invalidVisitorFields(String)
    }
    
}
