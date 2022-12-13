//
//  WebimRequestTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 01.09.2022.
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
@testable import WebimClientLibrary

class WebimRequestTests: XCTestCase {

    var sut: WebimRequest!
    let httpMethod = AbstractRequestLoop.HTTPMethods.post
    let baseURL = "anyBaseURL"
    let contentType = "anyContentType"
    let fileName = "fileName"
    let mimeType = "mimeType"
    let fileData = Data()
    let boundaryString = "boundaryString"
    let messageID = "messageID"
    let primaryData: [String: Any] = ["key1": "value1", "key2": 5]

    var historyCompletionCalled = false
    var locationStatusCompletionCalled = false
    var FAQCompletionCalled = false
    var searchMessagesCompletionCalled = false
    var locationSettingsRequestCompletionCalled = false

    //MARK: Methods
    override func setUp() {
        super.setUp()
        let surveyController = SurveyController(surveyListener: SurveyListenerMock())
        let sendSurveyAnswerCompletionHandlerWrapper = SendSurveyAnswerCompletionHandlerWrapper(surveyController: surveyController)
        sut = WebimRequest(httpMethod: httpMethod,
                           primaryData: primaryData,
                           messageID: messageID,
                           filename: fileName,
                           mimeType: mimeType,
                           fileData: fileData,
                           boundaryString: boundaryString,
                           contentType: contentType,
                           baseURLString: baseURL,
                           historyRequestCompletionHandler: historyRequestCompletionHandler(_:),
                           locationSettingsCompletionHandler: locationSettingsRequestCompletionHandler(_:),
                           locationStatusRequestCompletionHandler: locationStatusRequestCompletionHandler(_:),
                           faqCompletionHandler: faqCompletionHandler(_:),
                           searchMessagesCompletionHandler: searchMessagesCompletionHandler(_:),
                           dataMessageCompletionHandler: DataMessageCompletionHandlerMock(),
                           rateOperatorCompletionHandler: RateOperatorCompletionHandlerMock(),
                           sendFileCompletionHandler: SendFileCompletionHandlerMock(),
                           deleteMessageCompletionHandler: DeleteMessageCompletionHandlerMock(),
                           editMessageCompletionHandler: EditMessageCompletionHandlerMock(),
                           keyboardResponseCompletionHandler: SendKeyboardRequestCompletionHandlerMock(),
                           sendDialogToEmailAddressCompletionHandler: SendDialogToEmailAddressCompletionHandlerMock(),
                           sendStickerCompletionHandler: SendStickerCompletionHandlerMock(),
                           sendMessageCompletionHandler: SendMessageCompletionHandlerMock(),
                           sendSurveyAnswerCompletionHandler: sendSurveyAnswerCompletionHandlerWrapper,
                           surveyCloseCompletionHandler: SurveyCloseCompletionHandlerMock(),
                           sendFilesCompletionHandler: SendFilesCompletionHandlerMock(),
                           deleteUploadedFileCompletionHandler: DeleteUploadedFileCompletionHandlerMock(),
                           uploadFileToServerCompletionHandler: UploadFileToServerCompletionHandlerMock(),
                           reacionCompletionHandler: ReactionCompletionHandlerMock(),
                           geolocationCompletionHandler: GeolocationCompletionHandlerMock(),
                           serverSideSettingsCompletionHandler: ServerSideSettingsCompletionHandlerMock())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func test_Init_Properties() {
        XCTAssertEqual(sut.getHTTPMethod(), httpMethod)
        XCTAssertEqual(sut.getBaseURLString(), baseURL)
        XCTAssertEqual(sut.getContentType(), contentType)
        XCTAssertEqual(sut.getFileName(), fileName)
        XCTAssertEqual(sut.getMimeType(), mimeType)
        XCTAssertEqual(sut.getFileData(), fileData)
        XCTAssertEqual(sut.getBoundaryString(), boundaryString)
        XCTAssertEqual(sut.getMessageID(), messageID)
        XCTAssertEqual(sut.getPrimaryData().count, primaryData.count)
    }

    func test_Init_HistoryRequestCompletionHandler() throws {
        let completion = sut.getCompletionHandler()

        try completion?(Data())

        XCTAssertTrue(historyCompletionCalled)
    }

    func test_Init_LocationStatusRequestCompletionHandler() throws {
        let completion = sut.getLocationStatusCompletionHandler()

        try completion?(Data())

        XCTAssertTrue(locationStatusCompletionCalled)
    }

    func test_Init_FaqCompletionHandler() throws {
        let completion = sut.getFAQCompletionHandler()

        try completion?(Data())

        XCTAssertTrue(FAQCompletionCalled)
    }

    func test_Init_SearchMessagesCompletionHandler() throws {
        let completion = sut.getSearchMessagesCompletionHandler()

        try completion?(Data())

        XCTAssertTrue(searchMessagesCompletionCalled)
    }

    func test_Init_LocationSettingsRequestCompletionHandler() throws {
        let completion = sut.getLocationSettingsRequestCompletionHandler()

        try completion?(Data())

        XCTAssertTrue(locationSettingsRequestCompletionCalled)
    }

    func test_Init_Completions() {
        XCTAssertNotNil(sut.getDataMessageCompletionHandler())
        XCTAssertNotNil(sut.getRateOperatorCompletionHandler())
        XCTAssertNotNil(sut.getSendMessageCompletionHandler())
        XCTAssertNotNil(sut.getSendFileCompletionHandler())
        XCTAssertNotNil(sut.getDeleteMessageCompletionHandler())
        XCTAssertNotNil(sut.getEditMessageCompletionHandler())
        XCTAssertNotNil(sut.getKeyboardResponseCompletionHandler())
        XCTAssertNotNil(sut.getSendDialogToEmailAddressCompletionHandler())
        XCTAssertNotNil(sut.getSendStickerCompletionHandler())
        XCTAssertNotNil(sut.getSendSurveyAnswerCompletionHandler())
        XCTAssertNotNil(sut.getSurveyCloseCompletionHandler())
        XCTAssertNotNil(sut.getSendFilesCompletionHandler())
        XCTAssertNotNil(sut.getDeleteUploadedFileCompletionHandler())
        XCTAssertNotNil(sut.getUploadFileToServerCompletionHandler())
        XCTAssertNotNil(sut.getReactionCompletionHandler())
        XCTAssertNotNil(sut.getGeolocationCompletionHandler())
        XCTAssertNotNil(sut.getServerSideCompletionHandler())
    }

    private func historyRequestCompletionHandler(_ data: Data?) throws {
        historyCompletionCalled = true
    }

    private func locationStatusRequestCompletionHandler(_ data: Data?) throws {
        locationStatusCompletionCalled = true
    }

    private func faqCompletionHandler(_ data: Data?) throws {
        FAQCompletionCalled = true
    }

    private func searchMessagesCompletionHandler(_ data: Data?) throws {
        searchMessagesCompletionCalled = true
    }

    private func locationSettingsRequestCompletionHandler(_ data: Data?) throws {
        locationSettingsRequestCompletionCalled = true
    }
}
