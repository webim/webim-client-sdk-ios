//
//  OperatorFactoryTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 19.02.18.
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
@testable import WebimMobileSDK
import XCTest

class OperatorFactoryTests: XCTestCase {
    
    // MARK: - Constants
    private static let serverURLString = "http://demo.webim.ru"
    
    // MARK: - Properties
    private let operatorFactory = OperatorFactory(withServerURLString: serverURLString)
    
    // MARK: - Tests
    func testCreateOperator() {
        let operatorItemDictionary = try! JSONSerialization.jsonObject(with: OPERATOR_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                       options: []) as! [String : Any?]
        var operatorItem = OperatorItem(jsonDictionary: operatorItemDictionary)
        let `operator` = operatorFactory.createOperatorFrom(operatorItem: operatorItem)
        
        XCTAssertEqual(`operator`!.getID(),
                       operatorItem!.getID())
        XCTAssertEqual(`operator`!.getName(),
                       operatorItem!.getFullName())
        XCTAssertEqual(URL(string: (OperatorFactoryTests.serverURLString + operatorItem!.getAvatarURLString()!)),
                       `operator`!.getAvatarURL()!)
        
        operatorItem = nil
        XCTAssertNil(operatorFactory.createOperatorFrom(operatorItem: operatorItem))
    }
    
}
