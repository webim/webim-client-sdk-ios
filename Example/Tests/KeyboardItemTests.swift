//
//  KeyboardItemTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 25.08.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
import XCTest
@testable import WebimMobileSDK

class KeyboardItemTests: XCTestCase {

    var sut: KeyboardItem!

    //MARK: Methods
    override func setUp() {
        super.setUp()
        sut = KeyboardItem(jsonDictionary: convertToDict(getJsonString()))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func getJsonString(state: String = "completed") -> String {
        """
            {
               "buttons":[
                  [
                     {
                        "id":"1",
                        "text":"text1",
                        "config":{
                          "active":true,
                          "link":"someData",
                          "state":"showing"
                        }
                     },
                     {
                        "id":"2",
                        "text":"text2",
                        "config":{
                          "active":true,
                          "link":"someData",
                          "state":"showing"
                        }
                     }
                  ],
                  [
                     {
                        "id":"3",
                        "text":"text3",
                        "config":{
                          "active":true,
                          "link":"someData",
                          "state":"showing"
                        }
                     }
                  ]
               ],
               "state":"\(state)",
               "response":{
                  "buttonId":"responseButtonId",
                  "messageId":"responseMessageId"
               }
            }
        """
    }

    //MARK: Tests

    func testInitButtons() {
        let expectedButtonsCount = 2

        XCTAssertEqual(sut.getButtons().count, expectedButtonsCount)
    }

    func test_InitButtons_NullValue() {
        let jsonDict = [String: Any?]()

        let sut = KeyboardItem(jsonDictionary: jsonDict)
        XCTAssertNil(sut)
    }

    func test_InitButtons_InvalidJson() {
        let jsonDict: [String: Any?] = ["state": "completed", "buttons": [[["some":"some"]]]]

        let sut = KeyboardItem(jsonDictionary: jsonDict)

        XCTAssertNil(sut)
    }

    func test_Init_Response() {
        let expectedResponseButtonId = "responseButtonId"
        let expectedResponseMessageId = "responseMessageId"

        XCTAssertEqual(sut.getResponse()?.getButtonId(), expectedResponseButtonId)
        XCTAssertEqual(sut.getResponse()?.getMessageId(), expectedResponseMessageId)
    }

    func test_Init_ResponseNullValue() {
        let nullResponseJson = """
            {
               "buttons":[
                  [
                     {
                        "id":"3",
                        "text":"text3",
                        "config":{
                          "active":true,
                          "link":"someData",
                          "state":"showing"
                        }
                     }
                  ]
               ],
               "state": "some",
               "response":null
            }
        """

        let sut = KeyboardItem(jsonDictionary: convertToDict(nullResponseJson))

        XCTAssertNil(sut?.getResponse())

    }

    func test_InitState_CompletedState() {
        let expectedType = KeyboardState.completed

        XCTAssertEqual(sut.getState(), expectedType)
    }

    func test_InitState_PendingState() {
        let json = getJsonString(state: "pending")
        let expectedState = KeyboardState.pending

        let sut = KeyboardItem(jsonDictionary: convertToDict(json))

        XCTAssertEqual(sut?.getState(), expectedState)
    }

    func test_InitState_WrongState() {
        let json = getJsonString(state: "someWrongState")
        let expectedState = KeyboardState.canceled

        let sut = KeyboardItem(jsonDictionary: convertToDict(json))

        XCTAssertEqual(sut?.getState(), expectedState)
    }

    func test_InitState_NullValue() {
        let nullStateJson = """
            {
               "buttons":[
                  [
                     {
                        "id":"3",
                        "text":"text3",
                        "config":{
                           "active":true,
                           "link":"someData",
                           "state":"showing"
                        }
                     }
                  ]
               ],
               "state": null,
               "response":{
                  "buttonId":"responseButtonId",
                  "messageId":"responseMessageId"
               }
            }
        """

        let sut = KeyboardItem(jsonDictionary: convertToDict(nullStateJson))

        XCTAssertNil(sut?.getState())
    }
}


class KeyboardButtonItemTests: XCTestCase {

    var sut: KeyboardButtonItem!

    static let defaultKeyboardButtonItemJson = """
    {
        "id":"3",
        "text":"text3",
        "config":{
           "active":true,
           "link":"someData",
           "state":"showing"
        }
    }
    """

    //MARK: Methods
    override func setUp() {
        super.setUp()
        sut = KeyboardButtonItem(jsonDictionary: convertToDict(KeyboardButtonItemTests.defaultKeyboardButtonItemJson))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func test_Init_Id() {
        let expectedId = "3"

        XCTAssertEqual(sut.getId(), expectedId)
    }

    func test_Init_IdNullValue() {
        let nullIdJson = """
        {
        "id":null,
        "text":"text3",
        "config":{
           "active":true,
           "link":"someData",
           "state":"showing"
            }
        }
        """

        let sut = KeyboardButtonItem(jsonDictionary: convertToDict(nullIdJson))

        XCTAssertNil(sut)
    }

    func test_Init_Text() {
        let expectedText = "text3"

        XCTAssertEqual(sut.getText(), expectedText)
    }

    func test_Init_TextNullValue() {
        let nullIdJson = """
        {
        "id":"3",
        "text":null,
        "config":{
           "active":true,
           "link":"someData",
           "state":"showing"
            }
        }
        """

        let sut = KeyboardButtonItem(jsonDictionary: convertToDict(nullIdJson))

        XCTAssertNil(sut)
    }

    func test_Init_Config() {
        let expectedConfigState = ButtonState.showing

        XCTAssertEqual(sut.getConfiguration()?.getState(), expectedConfigState)
    }

    func test_Init_ConfigNullValue() {
        let nullIdJson = """
        {
        "id":"3",
        "text":"someText",
        "config":null
        }
        """

        let sut = KeyboardButtonItem(jsonDictionary: convertToDict(nullIdJson))

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.getConfiguration())
    }
}

class KeyboardResponseItemTests: XCTestCase {

    var sut: KeyboardResponseItem!

    let defaultKeyboardResponseItemJson = """
    {
        "buttonId":"3",
        "messageId":"text3"
    }
    """

    //MARK: Methods
    override func setUp() {
        super.setUp()
        sut = KeyboardResponseItem(jsonDictionary: convertToDict(defaultKeyboardResponseItemJson))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func test_Init_ButtonId() {
        let expectedButtonId = "3"

        XCTAssertEqual(sut.getButtonId(), expectedButtonId)
    }

    func test_Init_ButtonIdNullValue() {
        let nullButtonIDJson = """
        {
            "buttonId":null,
            "messageId":"text3"
        }
        """

        let sut = KeyboardResponseItem(jsonDictionary: convertToDict(nullButtonIDJson))

        XCTAssertNil(sut)
    }

    func test_Init_MessageId() {
        let expectedMessageId = "text3"

        XCTAssertEqual(sut.getMessageId(), expectedMessageId)
    }

    func test_Init_MessageIdNullValue() {
        let nullButtonIDJson = """
        {
            "buttonId":"3",
            "messageId":null
        }
        """

        let sut = KeyboardResponseItem(jsonDictionary: convertToDict(nullButtonIDJson))

        XCTAssertNil(sut)
    }
}

class KeyboardRequestItemTests: XCTestCase {

    var sut: KeyboardRequestItem!

    let defaultKeyboardRequestItemJson = """
    {
       "button":{
          "id":"3",
          "text":"someText",
          "config":null
       },
       "request":{
          "messageId":"someMessageId"
       }
    }
    """

    override func setUp() {
        super.setUp()
        sut = KeyboardRequestItem(jsonDictionary: convertToDict(defaultKeyboardRequestItemJson))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_Init_Button() {
        let expectedButtonId = "3"

        XCTAssertEqual(sut.getButton().getId(), expectedButtonId)
    }

    func test_Init_ButtonNullValue() {
        let buttonNullValueJson = """
        {
           "button":null,
           "request":{
              "messageId":"someMessageId"
           }
        }
        """

        let sut = KeyboardRequestItem(jsonDictionary: convertToDict(buttonNullValueJson))

        XCTAssertNil(sut)
    }

    func test_Init_Request() {
        let expectedMessageId = "someMessageId"

        XCTAssertEqual(sut.getMessageId(), expectedMessageId)
    }

    func test_Init_RequestNullValue() {
        let requestNullValueJson = """
        {
           "button":{
              "id":"3",
              "text":"someText",
              "config":null
           },
           "request":null
        }
        """

        let sut = KeyboardRequestItem(jsonDictionary: convertToDict(requestNullValueJson))

        XCTAssertNil(sut)
    }

}

class ConfigurationItemTests: XCTestCase {

    var sut: ConfigurationItem!

    let defaultConfigurationItemJson = """
    {
    "active":true,
    "link":"someData",
    "state":"showing"
    }
    """

    override func setUp() {
        super.setUp()
        sut = ConfigurationItem(jsonDictionary: convertToDict(defaultConfigurationItemJson))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_Init_IsActive() {
        let expectedValue = true

        XCTAssertEqual(sut.isActive(), expectedValue)
    }

    func test_Init_IsActiveNullValue() {
        let nullIsActiveJson = """
        {
        "active":null,
        "link":"someData",
        "state":"showing"
        }
        """

        let sut = ConfigurationItem(jsonDictionary: convertToDict(nullIsActiveJson))

        XCTAssertNil(sut.isActive())
    }

    func test_Init_DataLink() {
        let expectedData = "someData"
        let expectedType = ButtonType.url

        XCTAssertEqual(sut.getData(), expectedData)
        XCTAssertEqual(sut.getButtonType(), expectedType)
    }

    func test_Init_DataText() {
        let nullDataJson = """
        {
        "active":true,
        "text_to_insert":"someData",
        "state":"showing"
        }
        """
        let expectedData = "someData"
        let expectedType = ButtonType.insert

        let sut = ConfigurationItem(jsonDictionary: convertToDict(nullDataJson))

        XCTAssertEqual(sut.getData(), expectedData)
        XCTAssertEqual(sut.getButtonType(), expectedType)
    }

    func test_Init_DataNullLinkValue() {
        let nullIsDataJson = """
        {
        "active":true,
        "link":null,
        "state":"showing"
        }
        """

        let sut = ConfigurationItem(jsonDictionary: convertToDict(nullIsDataJson))

        XCTAssertNil(sut.getButtonType())
    }

    func test_Init_DataNullTextValue() {
        let nullDataJson = """
        {
        "active":true,
        "text_to_insert":null,
        "state":"showing"
        }
        """

        let sut = ConfigurationItem(jsonDictionary: convertToDict(nullDataJson))

        XCTAssertNil(sut.getButtonType())
    }

    func test_Init_StateShowing() {
        let expectedValue = ButtonState.showing

        XCTAssertEqual(sut.getState(), expectedValue)
    }

    func test_Init_StateShowingSelected() {
        let showingSelectedStateJson = """
        {
        "active":true,
        "link":"someData",
        "state":"showing_selected"
        }
        """
        let expectedValue = ButtonState.showingSelected

        let sut = ConfigurationItem(jsonDictionary: convertToDict(showingSelectedStateJson))

        XCTAssertEqual(sut.getState(), expectedValue)
    }

    func test_Init_StateWrongValue() {
        let wrongStateJson = """
        {
        "active":true,
        "link":"someData",
        "state":"someWrongValue"
        }
        """
        let expectedValue = ButtonState.hidden

        let sut = ConfigurationItem(jsonDictionary: convertToDict(wrongStateJson))

        XCTAssertEqual(sut.getState(), expectedValue)
    }

    func test_Init_StateNullValue() {
        let nullStateJson = """
        {
        "active":true,
        "text_to_insert":null,
        "state":null
        }
        """

        let sut = ConfigurationItem(jsonDictionary: convertToDict(nullStateJson))

        XCTAssertNil(sut.getState())
    }
}

fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}
