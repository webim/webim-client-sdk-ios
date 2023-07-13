//
//  FileUrlCreatorTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 24.08.2022.
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

class FileUrlCreatorTests: XCTestCase {

    private let userDefaultsKey = "userDefaultsKey"
    private let urlString = "http://webim.ru"
    private let expectedPageID = "expectedPageID"
    private let expectedAuthorizationToken = "expectedAuthorizationToken"
    private let fileName = "filename"
    private let invalidFileName = "123@"
    private let guid = "guidnumber"

    var sessionDestroyer: SessionDestroyer!
    var globalQueue: DispatchQueue!
    var execIfNotDestroyedHandlerExecutor: ExecIfNotDestroyedHandlerExecutor!
    var internalErrorListener: InternalErrorListenerForTests!
    var actionRequestLoop: ActionRequestLoopForTests!
    var authData: AuthorizationData!
    var deltaRequestLoop: DeltaRequestLoop!
    var webimClient: WebimClient!

    override func setUp() {
        super.setUp()
        sessionDestroyer = SessionDestroyer(userDefaultsKey: userDefaultsKey)
        globalQueue = DispatchQueue.global()
        execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer, queue: globalQueue)
        internalErrorListener = InternalErrorListenerForTests()
        actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor, internalErrorListener: internalErrorListener)
        authData = AuthorizationData(pageID: expectedPageID, authorizationToken: expectedAuthorizationToken)

        deltaRequestLoop = DeltaRequestLoop(
            deltaCallback: DeltaCallback(
                currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: urlString),
                historyMessageMapper: HistoryMessageMapper(withServerURLString: urlString),
                userDefaultsKey: userDefaultsKey),
            completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
            sessionParametersListener: nil,
            internalErrorListener: internalErrorListener,
            baseURL: urlString,
            title: "title",
            location: "location",
            appVersion: nil,
            visitorFieldsJSONString: nil,
            providedAuthenticationTokenStateListener: nil,
            providedAuthenticationToken: nil,
            deviceID: "id",
            deviceToken: nil,
            remoteNotificationSystem: nil,
            visitorJSONString: nil,
            sessionID: nil,
            prechat: nil,
            authorizationData: authData)

        webimClient = WebimClient(
            withActionRequestLoop: actionRequestLoop,
            deltaRequestLoop: deltaRequestLoop,
            webimActions: WebimActionsImpl(
                baseURL: urlString,
                actionRequestLoop: actionRequestLoop))
    }

    override func tearDown() {
        sessionDestroyer = nil
        globalQueue = nil
        execIfNotDestroyedHandlerExecutor = nil
        internalErrorListener = nil
        actionRequestLoop = nil
        authData = nil
        deltaRequestLoop = nil
        webimClient = nil
        super.tearDown()
    }


    func testCreateFileURLThumbFalse() {
        let expires = String(Int64(Date().timeIntervalSince1970) + 300)
        let data = guid + String(expires)
        let expectedValue = urlString +
            ServerPathSuffix.downloadFile.rawValue +
            "/"
            + guid + "/"
            + fileName + "?"
            + "page-id" + "=" + expectedPageID + "&"
            + "expires" + "=" + expires + "&"
            + "hash" + "=" + (data.hmacSHA256(withKey: expectedAuthorizationToken) ?? "")

        let sut = FileUrlCreator(webimClient: webimClient, serverURL: urlString)

        XCTAssertEqual(sut.createFileURL(byFilename: fileName, guid: guid), expectedValue)
    }

    func testCreateFileURLThumbTrue() {
        let expires = String(Int64(Date().timeIntervalSince1970) + 300)
        let data = guid + String(expires)
        let expectedValue = urlString +
            ServerPathSuffix.downloadFile.rawValue +
            "/"
            + guid + "/"
            + fileName + "?"
            + "page-id" + "=" + expectedPageID + "&"
            + "expires" + "=" + expires + "&"
            + "hash" + "=" + (data.hmacSHA256(withKey: expectedAuthorizationToken) ?? "")
            + "&thumb=ios"

        let sut = FileUrlCreator(webimClient: webimClient, serverURL: urlString)

        XCTAssertEqual(sut.createFileURL(byFilename: fileName, guid: guid, isThumb: true), expectedValue)
    }

    func testCreateFileURLAuthorizationDataNil() {
        deltaRequestLoop = DeltaRequestLoop(
            deltaCallback: DeltaCallback(
                currentChatMessageMapper: CurrentChatMessageMapper(withServerURLString: urlString),
                historyMessageMapper: HistoryMessageMapper(withServerURLString: urlString),
                userDefaultsKey: userDefaultsKey),
            completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
            sessionParametersListener: nil,
            internalErrorListener: internalErrorListener,
            baseURL: urlString,
            title: "title",
            location: "location",
            appVersion: nil,
            visitorFieldsJSONString: nil,
            providedAuthenticationTokenStateListener: nil,
            providedAuthenticationToken: nil,
            deviceID: "id",
            deviceToken: nil,
            remoteNotificationSystem: nil,
            visitorJSONString: nil,
            sessionID: nil,
            prechat: nil,
            authorizationData: nil)

        webimClient = WebimClient(
            withActionRequestLoop: actionRequestLoop,
            deltaRequestLoop: deltaRequestLoop,
            webimActions: WebimActionsImpl(
                baseURL: urlString,
                actionRequestLoop: actionRequestLoop))

        let sut = FileUrlCreator(webimClient: webimClient, serverURL: urlString)

        XCTAssertNil(sut.createFileURL(byFilename: fileName, guid: guid))
    }

    func testCreateFileURLFileNameContainsSpecialSymbols() {
        let expires = String(Int64(Date().timeIntervalSince1970) + 300)
        let data = guid + String(expires)
        let expectedValue = urlString +
            ServerPathSuffix.downloadFile.rawValue +
            "/"
            + guid + "/"
            + "123%40" + "?"
            + "page-id" + "=" + expectedPageID + "&"
            + "expires" + "=" + expires + "&"
            + "hash" + "=" + (data.hmacSHA256(withKey: expectedAuthorizationToken) ?? "")

        let sut = FileUrlCreator(webimClient: webimClient, serverURL: urlString)

        XCTAssertEqual(sut.createFileURL(byFilename: invalidFileName, guid: guid), expectedValue)
    }
}
