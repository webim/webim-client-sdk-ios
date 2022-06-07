//
//  MimeTypeTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 12.02.18.
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

@testable import WebimClientLibrary_Example
import Foundation
import XCTest

class MimeTypeTests: XCTestCase {
    
    func testValue() {
        // MARK: Test 1
        
        var urlString = "/image.jpg"
        var url = URL(string: urlString)!
        
        XCTAssertEqual(MimeType(url: url).value,
                       "image/jpeg")
        XCTAssertTrue(MimeType.isImage(contentType: MimeType(url: url).value))
        
        // MARK: Test 2
        // Unknown extension
        
        urlString = "/db.db"
        url = URL(string: urlString)!
        
        XCTAssertEqual(MimeType(url: url).value,
                       "application/octet-stream")
        XCTAssertFalse(MimeType.isImage(contentType: MimeType(url: url).value))
        
        // MARK: Test 3
        // No extension
        
        urlString = "/unknown"
        url = URL(string: urlString)!
        
        XCTAssertEqual(MimeType(url: url).value,
                       "application/octet-stream")
    }
    
}
