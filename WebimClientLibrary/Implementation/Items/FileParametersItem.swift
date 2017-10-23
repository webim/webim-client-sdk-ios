//
//  FileParametersItem.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

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
    init(withJSONDictionary jsonDictionary: [String : Any?]) {
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
