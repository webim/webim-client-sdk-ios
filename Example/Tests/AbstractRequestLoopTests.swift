//
//  AbstractRequestLoopTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 30.01.18.
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
import XCTest
@testable import WebimClientLibrary

class AbstractRequestLoopTests: XCTestCase {
    
    // MARK: - Properties
    private let abstractRequestLoop = AbstractRequestLoopForTests(completionHandlerExecutor: nil,
                                                                  internalErrorListener: nil)

    private let webimServerSideSettingsResponse = """
webimApplyServerSideSettings({
    "accountConfig": {
        "multilang": true,
        "chatting_timer": true,
        "google_analytics": true,
        "yandex_metrika_counter_id": null,
        "teleport": true,
        "client_php_url": null,
        "hide_referrer": false,
        "force_visitor_https": false,
        "visitor_tracking": false,
        "force_visitor_disable": false,
        "visitor_enabling_probability": 100,
        "default_lang": "ru",
        "rate_operator": true,
        "allowed_upload_file_types": "png, jpg, jpeg, doc, docx, rtf, gif, txt, pdf, webp, oga, ogg",
        "show_processing_personal_data_checkbox": true,
        "visitor_websockets": false,
        "visitor_upload_file": true,
        "operator_check_status_online": 300,
        "visitor_hints_api_endpoint": null,
        "file_url_expiring_timeout": 60,
        "check_visitor_auth": false,
        "operator_status_timer": true,
        "visitor_message_editing": true,
        "web_and_mobile_quoting": true,
        "offline_chat_processing": true,
        "open_chat_in_new_tab_for_mobile": true,
        "max_visitor_upload_file_size": 10
    },
});
"""
    
    // MARK: - Tests
    
    func testResume() {
        abstractRequestLoop.resume()
        abstractRequestLoop.pause()
        abstractRequestLoop.resume()
        
        XCTAssertFalse(abstractRequestLoop.isPaused())
    }
    
    func testPause() {
        abstractRequestLoop.resume()
        abstractRequestLoop.pause()
        
        XCTAssertTrue(abstractRequestLoop.isPaused())
    }

    func testStop() {
        abstractRequestLoop.resume()
        abstractRequestLoop.stop()

        XCTAssertFalse(abstractRequestLoop.isRunning())
        XCTAssertFalse(abstractRequestLoop.isPaused())
    }

    func testHandleRequestLoop() {
        XCTAssertNotNil(abstractRequestLoop.handleRequestLoop(error: .serverError))
        XCTAssertNotNil(abstractRequestLoop.handleRequestLoop(error: .interrupted))
    }

    func testPrepareServerSideEmptyData() {
        // Given
        let rawData = Data()

        // When
        let data = abstractRequestLoop.prepareServerSideData(rawData: rawData)

        //Then
        XCTAssertTrue(data.isEmpty)
        XCTAssertEqual(data, Data())
    }

    func testPrepareServerSideSmallData() {
        let rawData = "Some small data".data(using: .utf8) ?? Data()
        let data = abstractRequestLoop.prepareServerSideData(rawData: rawData)
        XCTAssertNotNil(data)
        XCTAssertTrue(data.isEmpty)
    }

    func testPrepareServerSideData() {
        let rawData = webimServerSideSettingsResponse.data(using: .utf8) ?? Data()
        let data = abstractRequestLoop.prepareServerSideData(rawData: rawData)
        XCTAssertNotNil(data)
        XCTAssertFalse(data.isEmpty)
    }

    func testDecodeToServerSideSettingsSmallData() {
        let rawData = "Some wrong data".data(using: .utf8) ?? Data()
        XCTAssertThrowsError(try abstractRequestLoop.decodeToServerSideSettings(data: rawData))
    }

    func testDecodeToServerSideSettingsEmptyData() {
        let rawData = Data()
        XCTAssertThrowsError(try abstractRequestLoop.decodeToServerSideSettings(data: rawData))
    }

    func testSuccessDecodeToServerSideSettings() {
        let rawData = webimServerSideSettingsResponse.data(using: .utf8) ?? Data()
        let serverSideSettings = try? abstractRequestLoop.decodeToServerSideSettings(data: rawData)
        XCTAssertNotNil(serverSideSettings)
        XCTAssertNoThrow(serverSideSettings)
    }
}

// MARK: - Mocking AbstractRequestLoop
fileprivate final class AbstractRequestLoopForTests: AbstractRequestLoop {
    
    // MARK: - Methods
    func isPaused() -> Bool {
        return paused
    }
    
}
