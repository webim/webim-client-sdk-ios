//
//  DecodePercentEscapedLinksIfPresentTests.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 31.01.18.
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
import WebimMobileSDK_Example
import XCTest

class DecodePercentEscapedLinksIfPresentTests: XCTestCase {
    
    // MARK: - Tests
    
    func testNormalString() {
        let initialString = "Normal string"
        let expectedString = initialString
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testOneLinkWithoutPercentEscapingOnlyString() {
        let initialString = "https://www.webim.ru/"
        let expectedString = initialString
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testOneLinkWithPercentEscapingOnlyString() {
        let initialString = "https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%82/"
        let expectedString = "https://www.webim.ru/тест/"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testOneLinkWithPercentEscapingAndStartingTextString() {
        let initialString = "Link: https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%82/"
        let expectedString = "Link: https://www.webim.ru/тест/"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testOneLinkWithPercentEscapingAndClosingTextString() {
        let initialString = "https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%82/ – link"
        let expectedString = "https://www.webim.ru/тест/ – link"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testOneLinkWithPercentEscapingInsideTextString() {
        let initialString = "Link: https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%82/ – check it!"
        let expectedString = "Link: https://www.webim.ru/тест/ – check it!"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testMultipleLinksWithPercentEscapingString() {
        let initialString = "https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%821/ https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%822/"
        let expectedString = "https://www.webim.ru/тест1/ https://www.webim.ru/тест2/"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
    func testMultipleLinksWithPercentEscapingInsideComplexTextString() {
        let initialString = "First link: https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%821/ Second link: https://www.webim.ru/%D1%82%D0%B5%D1%81%D1%822/ That's it!"
        let expectedString = "First link: https://www.webim.ru/тест1/ Second link: https://www.webim.ru/тест2/ That's it!"
        
        XCTAssertEqual(initialString.decodePercentEscapedLinksIfPresent(),
                       expectedString)
    }
    
}
