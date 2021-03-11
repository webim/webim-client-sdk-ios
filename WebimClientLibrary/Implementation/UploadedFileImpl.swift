//
//  UploadedFileImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 15.11.20.
//  Copyright © 2020 Webim. All rights reserved.
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
 Internal uploaded file representasion.
 - author:
 Nikita Kaberov
 - copyright:
 2020 Webim
 */
class UploadedFileImpl {
    
    // MARK: - Properties
    private let size: Int64
    private let guid: String
    private let contentType: String?
    private let filename: String
    private let visitorID: String
    private let clientContentType: String
    private let imageParameters: ImageParameters?
    
    // MARK: - Initialization
    init(size: Int64,
         guid: String,
         contentType: String?,
         filename: String,
         visitorID: String,
         clientContentType: String,
         imageParameters: ImageParameters?) {
        self.size = size
        self.guid = guid
        self.contentType = contentType
        self.filename = filename
        self.visitorID = visitorID
        self.clientContentType = clientContentType
        self.imageParameters = imageParameters
    }
}

extension UploadedFileImpl: UploadedFile {
    public var description: String {
        let imageSize = imageParameters?.getSize()
        return "{\"client_content_type\":\"\(clientContentType)\"" +
            ",\"visitor_id\":\"\(visitorID)\"" +
            ",\"filename\":\"\(filename)\"" +
            ",\"content_type\":\"\(contentType ?? "")\"" +
            ",\"guid\":\"\(guid)\"" +
            (imageSize != nil ? ",\"image\":{\"size\":{\"width\":\( imageSize?.getWidth() ?? 0),\"height\":\(imageSize?.getHeight() ?? 0)}}" : "") +
            ",\"size\":\(size)}"
    }
    
    func getSize() -> Int64 {
        return size
    }
    
    func getGuid() -> String {
        return guid
    }
    
    func getFileName() -> String {
        return filename
    }
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getVisitorID() -> String {
        return visitorID
    }
    
    func getClientContentType() -> String {
        return clientContentType
    }
    
    func getImageInfo() -> ImageInfo? {
        return ImageInfoImpl(withThumbURLString: "",
                             fileUrlCreator: nil,
                             filename: filename,
                             guid: guid,
                             width: imageParameters?.getSize()?.getWidth(),
                             height: imageParameters?.getSize()?.getHeight())
    }
}
