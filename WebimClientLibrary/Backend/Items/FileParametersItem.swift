//
//  FileParametersItem.swift
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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class FileParametersItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case contentType = "content_type"
        case clientContentType = "client_content_type"
        case fileName = "filename"
        case guid = "guid"
        case imageParameters = "image"
        case size = "size"
        case visitorID = "visitor_id"
    }
    
    // MARK: - Properties
    private var contentType: String?
    private var clientContentType: String?
    private var filename: String?
    private var guid: String?
    private var imageParameters: ImageParameters?
    private var size: Int64?
    private var visitorID: String?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let imageParametersDictionary = jsonDictionary[JSONField.imageParameters.rawValue] as? [String: Any?] {
            imageParameters = ImageParameters(jsonDictionary: imageParametersDictionary)
        }
        
        if let contentType = jsonDictionary[JSONField.contentType.rawValue] as? String {
            self.contentType = contentType
        }
        
        if let clientContentType = jsonDictionary[JSONField.clientContentType.rawValue] as? String {
            self.clientContentType = clientContentType
        }
        
        if let filename = jsonDictionary[JSONField.fileName.rawValue] as? String {
            self.filename = filename
        }
        
        if let guid = jsonDictionary[JSONField.guid.rawValue] as? String {
            self.guid = guid
        }
        
        if let size = jsonDictionary[JSONField.size.rawValue] as? Int64 {
            self.size = size
        }
        
        if let visitorID = jsonDictionary[JSONField.visitorID.rawValue] as? String {
            self.visitorID = visitorID
        }
    }
    
    // MARK: - Methods
    
    func getSize() -> Int64? {
        return size
    }
    
    func getGUID() -> String? {
        return guid
    }
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getClientContentType() -> String? {
        return clientContentType
    }
    
    func getFilename() -> String? {
        return filename
    }
    
    func getImageParameters() -> ImageParameters? {
        return imageParameters
    }
    
    func getVisitorID() -> String? {
        return visitorID
    }
}

// MARK: -
final class ImageParameters {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case size = "size"
    }
    
    // MARK: - Properties
    private var size: ImageSize?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let sizeDictionary = jsonDictionary[JSONField.size.rawValue] as? [String: Any?] {
            self.size = ImageSize(jsonDictionary: sizeDictionary)
        }
    }
    
    // MARK: - Methods
    func getSize() -> ImageSize? {
        return size
    }
    
}

// MARK: -
struct ImageSize {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case height = "height"
        case width = "width"
    }
    
    // MARK: - Properties
    private var width: Int?
    private var height: Int?
    
    // MARK: - Initialization
    init(jsonDictionary: [String: Any?]) {
        if let height = jsonDictionary[JSONField.height.rawValue] as? Int {
            self.height = height
        }
        
        if let width = jsonDictionary[JSONField.width.rawValue] as? Int {
            self.width = width
        }
    }
    
    // MARK: - Methods
    
    func getWidth() -> Int? {
        return width
    }
    
    func getHeight() -> Int? {
        return height
    }
    
}
