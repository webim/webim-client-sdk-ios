//
//  ChatViewControllerTests.swift
//  WebimClientLibrary_Example
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

class ChatTableViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    var chatTableViewController: ChatTableViewController!
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: nil)
        chatTableViewController = storyboard.instantiateViewController(withIdentifier: "ChatTableViewController") as? ChatTableViewController
        
    }
    
    // MARK: - Tests
    
    func testBackgroundViewEmpty() {
        // When: Table view is empty.
        let tableView = chatTableViewController.tableView!
        tableView.reloadData()

        // Then: Table view background has the message.
        let label = tableView.backgroundView as! UILabel
        XCTAssertEqual(label.attributedText?.string, TableView.emptyTableViewText.rawValue.localized)
    }
    
    func testBackgroundViewNotEmpty() {
        // MARK: Set up
        var messages = [Message]()
        for index in 0 ... 2 {
            let message = MessageImpl(serverURLString: "http://demo.webim.ru/",
                                      id: String(index),
                                      keyboard: nil,
                                      keyboardRequest: nil,
                                      operatorID: nil,
                                      quote: nil,
                                      senderAvatarURLString: nil,
                                      senderName: "Sender name",
                                      sticker: nil,
                                      type: .visitorMessage,
                                      rawData: nil,
                                      data: nil,
                                      text: "Text",
                                      timeInMicrosecond: Int64(index),
                                      historyMessage: false,
                                      internalID: nil,
                                      rawText: nil,
                                      read: false,
                                      messageCanBeEdited: false,
                                      messageCanBeReplied: false,
                                      messageIsEdited: false)
            messages.append(message as Message)
        }
        
        // When: Table view is not empty.
        chatTableViewController.set(messages: messages)
        chatTableViewController.tableView?.reloadData()
        
        // Then: Table view background view is empty.
        XCTAssertNil(chatTableViewController.tableView!.backgroundView)
    }
}
