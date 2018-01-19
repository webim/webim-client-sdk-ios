//
//  ChatViewControllerTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 15.01.18.
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

import UIKit
import XCTest
@testable import WebimClientLibrary
@testable import WebimClientLibrary_Example

class ChatViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    var chatViewController: ChatViewController!
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: nil)
        chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
    }
    
    // MARK: - Tests
    
    func testBackgroundViewNotEmpty() {
        // When: Table view is empty.
        let tableView = chatViewController.tableView!
        tableView.reloadData()
        
        // Then: Table view background has the message.
        let label = tableView.backgroundView as! UILabel
        XCTAssertEqual(label.attributedText?.string, EMPTY_TABLE_VIEW_TEXT.string)
    }
    
    func testBackgroundViewEmpty() {
        // MARK: Set up
        var messages = [Message]()
        for index in 0...2 {
            let message = MessageImpl(serverURLString: "http://demo.webim.ru/",
                                      id: String(index),
                                      operatorID: nil,
                                      senderAvatarURLString: nil,
                                      senderName: "Sender name",
                                      type: .VISITOR,
                                      data: nil,
                                      text: "Text",
                                      timeInMicrosecond: Int64(index),
                                      attachment: nil,
                                      historyMessage: false,
                                      internalID: nil,
                                      rawText: nil)
            messages.append(message as Message)
        }
        
        // When: Table view is not empty.
        chatViewController.set(messages: messages)
        chatViewController.tableView?.reloadData()
        
        // Then: Table view background view is empty.
        XCTAssertNil(chatViewController.tableView!.backgroundView)
    }
    
}
