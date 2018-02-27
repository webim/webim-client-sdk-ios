//
//  FileParametersItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 16.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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
@testable import WebimClientLibrary
import XCTest

class FileParametersItemTests: XCTestCase {
 
    // MARK: - Constants
    static let FILE_PARAMETERS_JSON_STRING = """
{
    "client_content_type" : "image/jpeg",
    "image" : {
        "size" : {
            "width" : 700,
            "height" : 501
        }
    },
    "visitor_id" : "877a920ede7082412656ac1cdec7ecde",
    "filename" : "asset.JPG",
    "content_type" : "image/png",
    "guid" : "010a56da72ee41e2a78d0509155de755",
    "size" : 758611
}
"""
    
    // MARK: - Properties
    private let fileParametersItemDictionary = try! JSONSerialization.jsonObject(with: FileParametersItemTests.FILE_PARAMETERS_JSON_STRING.data(using: .utf8)!,
                                                                                 options: []) as! [String : Any?]
    
    // MARK: - Tests
    func testInit() {
        let fileParametersItem = FileParametersItem(jsonDictionary: fileParametersItemDictionary)
        
        XCTAssertEqual(fileParametersItem.getSize(),
                       758611)
        XCTAssertEqual(fileParametersItem.getGUID(),
                       "010a56da72ee41e2a78d0509155de755")
        XCTAssertEqual(fileParametersItem.getContentType(),
                       "image/png")
        XCTAssertEqual(fileParametersItem.getFilename(),
                       "asset.JPG")
        XCTAssertEqual(fileParametersItem.getImageParameters()!.getSize()!.getWidth(),
                       700)
        XCTAssertEqual(fileParametersItem.getImageParameters()!.getSize()!.getHeight(),
                       501)
    }
    
}
