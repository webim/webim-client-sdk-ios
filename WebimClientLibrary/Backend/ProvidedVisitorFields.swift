//
//  ProvidedVisitorFields.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 08.08.17.
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
 Class that encapsulates unique visitor data.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class ProvidedVisitorFields {
    
    // MARK: - Properties
    private let id: String
    private let jsonString: String
    
    
    // MARK: - Initialization
    
    init?(withJSONString jsonString: String,
         JSONObject: Data) throws {
        do {
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
        } catch {
            print("Error serializing provided visitor fields")
            return nil
        }
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
