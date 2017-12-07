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
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class FileParametersItem {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case CONTENT_TYPE = "content_type"
        case FILENAME = "filename"
        case GUID = "guid"
        case IMAGE_PARAMETERS = "image"
        case SIZE = "size"
    }
    
    // MARK: - Properties
    private var contentType: String?
    private var filename: String?
    private var guid: String?
    private var imageParameters: ImageParameters?
    private var size: Int64?
    
    
    // MARK: - Initialization
    init(jsonDictionary: [String : Any?]) {
        if let imageParametersDictionary = jsonDictionary[JSONField.IMAGE_PARAMETERS.rawValue] as? [String : Any?] {
            imageParameters = ImageParameters(withJSONDictionary: imageParametersDictionary)
        }
        
        if let contentType = jsonDictionary[JSONField.CONTENT_TYPE.rawValue] as? String {
            self.contentType = contentType
        }
        
        if let filename = jsonDictionary[JSONField.FILENAME.rawValue] as? String {
            self.filename = filename
        }
        
        if let guid = jsonDictionary[JSONField.GUID.rawValue] as? String {
            self.guid = guid
        }
        
        if let size = jsonDictionary[JSONField.SIZE.rawValue] as? Int64 {
            self.size = size
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
    
    func getFilename() -> String? {
        return filename
    }
    
    func getImageParameters() -> ImageParameters? {
        return imageParameters
    }
    
}

// MARK: -
final class ImageParameters {
    
    // MARK: - Constants
    // Raw values equal to field names received in responses from server.
    private enum JSONField: String {
        case IMAGE_SIZE = "size"
    }
    
    // MARK: - Properties
    private var size: ImageSize?
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let sizeDictionary = jsonDictionary[JSONField.IMAGE_SIZE.rawValue] as? [String : Any?] {
            self.size = ImageSize(withJSONDictionary: sizeDictionary)
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
        case HEIGHT = "height"
        case WIDTH = "width"
    }
    
    
    // MARK: - Properties
    private var width: Int?
    private var height: Int?
    
    
    // MARK: - Initialization
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
        if let height = jsonDictionary[JSONField.HEIGHT.rawValue] as? Int {
            self.height = height
        }
        
        if let width = jsonDictionary[JSONField.WIDTH.rawValue] as? Int {
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
