//
//  MessageStreamImplTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Nikita Lazarev-Zubov on 22.02.18.
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

class MessageStreamImplTests: XCTestCase {
    
    // MARK: - Constants
    let serverURLString = "https://demo.webim.ru"
    private static let userDefaultsKey = "userDefaultsKey"
    private let locationSettingsHolderUserDefaultsKey = "MessageStreamImplTests_LocationSettingsHolder"
    
    // MARK: - Properties
    var messageHolder: MessageHolder!
    var messageStream: MessageStreamImpl?
    var webimActions: WebimActionsImpl?
    var actionRequestLoop: ActionRequestLoopForTests!
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: MessageStreamImplTests.userDefaultsKey)
        let accessChecker = AccessChecker(thread: Thread.current, sessionDestroyer: sessionDestroyer)
        let queue = DispatchQueue.main
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer, queue: queue)
        let listener = InternalErrorListenerForTests()
        actionRequestLoop = ActionRequestLoopForTests(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor, internalErrorListener: listener)
        let currentChatMessageMapper = CurrentChatMessageMapper(withServerURLString: serverURLString)
        let sendingFactory = SendingFactory(withServerURLString: serverURLString)
        let operatorFactory = OperatorFactory(withServerURLString: serverURLString)
        let surveyFactory = SurveyFactory()
        let historyStorage = MemoryHistoryStorage()
        let historyMessageMapper = HistoryMessageMapper(withServerURLString: serverURLString)
        let memHistoryMetaInfo = MemoryHistoryMetaInformationStorage()
        let locationSettingsHolder = LocationSettingsHolder(userDefaultsKey: locationSettingsHolderUserDefaultsKey)

        webimActions = WebimActionsImpl(baseURL: serverURLString,
                                        actionRequestLoop: actionRequestLoop)

        let messageComposingHandler = MessageComposingHandler(webimActions: webimActions!, queue: queue)
        let remoteHistoryProvider = RemoteHistoryProvider(webimActions: webimActions!,
                                                          historyMessageMapper: historyMessageMapper,
                                                          historyMetaInformationStorage: memHistoryMetaInfo)
        messageHolder = MessageHolder(accessChecker: accessChecker,
                                      remoteHistoryProvider: remoteHistoryProvider,
                                      historyStorage: historyStorage,
                                      reachedEndOfRemoteHistory: true)

        messageStream = MessageStreamImpl(serverURLString: serverURLString,
                                          currentChatMessageFactoriesMapper: currentChatMessageMapper,
                                          sendingMessageFactory: sendingFactory,
                                          operatorFactory: operatorFactory,
                                          surveyFactory: surveyFactory,
                                          accessChecker: accessChecker,
                                          webimActions: webimActions!,
                                          messageHolder: messageHolder,
                                          messageComposingHandler: messageComposingHandler,
                                          locationSettingsHolder: locationSettingsHolder)
    }

    override func tearDown() {
        super.tearDown()
        WMKeychainWrapper.standard.setDictionary([:], forKey: locationSettingsHolderUserDefaultsKey)
    }
    
    // MARK: - Tests
    
    func testSetVisitSessionState() {
        messageStream!.set(visitSessionState: .chat)
        
        XCTAssertEqual(messageStream!.getVisitSessionState(),
                       VisitSessionState.chat)
    }
    
    func testSetUnreadByOperatorTimestamp() {
        let date = Date()
        messageStream!.set(unreadByOperatorTimestamp: date)
        
        XCTAssertEqual(messageStream!.getUnreadByOperatorTimestamp(),
                       date)
    }
    
    func testSetUnreadByVisitorTimestamp() {
        let date = Date()
        messageStream!.set(unreadByVisitorTimestamp: date)
        
        XCTAssertEqual(messageStream!.getUnreadByVisitorTimestamp(),
                       date)
    }
    
    func testOnReceivingDepartmentList() {
        let departmentItemDictionary = try! JSONSerialization.jsonObject(with: DEPARTMENT_ITEM_JSON_STRING.data(using: .utf8)!,
                                                                         options: []) as! [String : Any?]
        let departmentItem = DepartmentItem(jsonDictionary: departmentItemDictionary)!
        messageStream!.onReceiving(departmentItemList: [departmentItem])
        
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getKey(),
                       "mobile_test_1")
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getName(),
                       "Mobile Test 1")
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getDepartmentOnlineStatus(),
                       DepartmentOnlineStatus.offline)
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getOrder(),
                       100)
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getLocalizedNames()!,
                       ["ru" : "Mobile Test 1"])
        XCTAssertEqual(messageStream!.getDepartmentList()![0].getLogoURL()!,
                       URL(string: "https://demo.webim.ru/webim/images/department_logo/wmtest2_1.png")!)
    }
    
    func testGetChatState() {
        XCTAssertEqual(messageStream!.getChatState(),
                       ChatState.unknown)
    }
    
    func testGetLocationSettings() {
        XCTAssertFalse(messageStream!.getLocationSettings().areHintsEnabled()) // Initial value must be false.
    }
    
    func testGetCurrentOperator() {
        XCTAssertNil(messageStream!.getCurrentOperator()) // Initially operator does not exist.
    }
    
    func testSetVisitSessionStateListener() {
        let visitSessionStateListener = VisitSessionStateListenerMock()
        messageStream!.set(visitSessionStateListener: visitSessionStateListener)
        
        messageStream!.set(visitSessionState: .chat)
        
        XCTAssertTrue(visitSessionStateListener.called)
        XCTAssertEqual(visitSessionStateListener.state!,
                       VisitSessionState.chat)
    }
    
    func testSetOnlineStatusChangeListener() {
        let onlineStatusChangeListener = OnlineStatusChangeListenerMock()
        messageStream!.set(onlineStatusChangeListener: onlineStatusChangeListener)
        
        messageStream!.set(onlineStatus: .busyOnline)
        XCTAssertFalse(onlineStatusChangeListener.called)
        
        messageStream!.onOnlineStatusChanged(to: .busyOffline)
        
        XCTAssertTrue(onlineStatusChangeListener.called)
        XCTAssertEqual(onlineStatusChangeListener.status!,
                       OnlineStatus.busyOffline)
    }
    
    func testChangingChatState() {
        messageStream!.changingChatStateOf(chat: getDefaultChatItem())
        
        XCTAssertEqual(messageStream!.getChatState(),
                       ChatState.chatting)
        XCTAssertNotNil(messageStream!.getUnreadByOperatorTimestamp())
        XCTAssertNil(messageStream!.getUnreadByVisitorTimestamp())
        XCTAssertEqual(messageStream!.getCurrentOperator()!.getID(), "33201")
    }
    
    func testGetWebimActions() {
        XCTAssertTrue(webimActions! === messageStream!.getWebimActions())
    }

    func testSaveLocationSettingsOn() {
        let fullUpdateJson = FullUpdateTests.defaultFullUpdateJson
        let fullUpdate = FullUpdate(jsonDictionary: convertToDict(fullUpdateJson))
        let listener = LocationSettingsChangeListenerMock()

        messageStream?.set(locationSettingsChangeListener: listener)
        messageStream?.saveLocationSettingsOn(fullUpdate: fullUpdate)

        XCTAssertTrue(listener.called)
    }

    func testOnReceivedSurveyItem() {
        let listener = SurveyListenerMock()

        messageStream?.set(surveyListener: listener)
        messageStream?.onReceived(surveyItem: getDefaultSurveyItem())

        XCTAssertTrue(listener.onSurveyCalled)
    }

    func testOnSurveyCancelled() {
        let listener = SurveyListenerMock()

        messageStream?.set(surveyListener: listener)
        messageStream?.onSurveyCancelled()

        XCTAssertTrue(listener.onSurveyCancelledCalled)
    }

    func testHandleHelloMessage() {
        let listener = HelloMessageListenerMock()

        messageStream?.set(helloMessageListener: listener)
        messageStream?.handleHelloMessage(showHelloMessage: true,
                                          chatStartAfterMessage: true,
                                          currentChatEmpty: true,
                                          helloMessageDescr: "expectedHelloMessage")

        XCTAssertTrue(listener.helloMessageCalled)
        XCTAssertEqual(listener.helloMessageText, "expectedHelloMessage")
    }

    func test_HandleHelloMessage_ListenerDontCalled() {
        let listener = HelloMessageListenerMock()

        messageStream?.set(helloMessageListener: listener)
        messageStream?.handleHelloMessage(showHelloMessage: false,
                                          chatStartAfterMessage: false,
                                          currentChatEmpty: false,
                                          helloMessageDescr: "expectedHelloMessage")

        XCTAssertFalse(listener.helloMessageCalled)
        XCTAssertNil(listener.helloMessageText)
    }

    func test_GetLastRatingOfOperatorWith() {
        messageStream!.changingChatStateOf(chat: getDefaultChatItem())

        XCTAssertEqual(messageStream?.getLastRatingOfOperatorWith(id: "firstOperatorId"), 5)
    }

    func test_RateOperatorWith_NoteNil() throws {
        let completionHandler = RateOperatorCompletionHandlerMock()
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.rateOperatorWith(id: "firstOperatorId",
                                            byRating: 2,
                                            completionHandler: completionHandler)

        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_RateOperatorWith_RatingOutOfBounds() throws {
        let completionHandler = RateOperatorCompletionHandlerMock()
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.rateOperatorWith(id: "firstOperatorId",
                                            byRating: 8,
                                            completionHandler: completionHandler)

        try messageStream?.rateOperatorWith(id: "firstOperatorId",
                                            byRating: -4,
                                            completionHandler: completionHandler)

        XCTAssertFalse(actionRequestLoop.enqueueCalled)
    }

    func test_RespondSentryCall() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.respondSentryCall(id: "12314")

        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SearchStreamMessagesBy() {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        messageStream?.searchStreamMessagesBy(query: "query", completionHandler: nil)

        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SearchStreamMessagesBy_completionCall() {
        let completionHandler = SearchMessagesCompletionHandlerMock()
        messageStream?.searchStreamMessagesBy(query: "query", completionHandler: completionHandler)

        XCTAssertTrue(completionHandler.completionCalled)
        XCTAssertEqual(completionHandler.completionSuccess, false)
    }

    func testStartChat() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat()
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testStartChatFirstQuestion() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat(firstQuestion: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testStartChatDepartmentKey() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat(departmentKey: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testStartChatCustomFields() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat(customFields: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_StartChatFirstQuestion_CustomFields() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat(firstQuestion: "Any", customFields: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_StartChat_DepartmentKey_CustomFields() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.startChat(departmentKey: "Any", customFields: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.start")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testCloseChat() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        messageStream?.changingChatStateOf(chat: getDefaultChatItem())
        try messageStream?.closeChat()
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.close")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSetVisitorTyping() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.setVisitorTyping(draftMessage: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.visitor_typing")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SetVisitorTyping_NilValue() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.setVisitorTyping(draftMessage: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.visitor_typing")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendMessage() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any")
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Send_MessageCompletionHandler() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any", completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Send_MessageDataCompletionHandler() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any", data: ["some": 12], completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Send_MessageDataCompletionHandler_DataIsNil() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any", data: nil, completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Send_MessageHintQuestion() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any", isHintQuestion: true)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Send_MessageHintQuestion_NullValue() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let _ = try messageStream?.send(message: "Any",isHintQuestion: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendFile() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let id = try messageStream?.send(file: Data(),
                                        filename: "someFileName",
                                        mimeType: "AnyMimeType",
                                        completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SendFile_AsImage() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let imageData = UIImage(named: "ConnectionImage")!.pngData()!

        let id = try messageStream?.send(file: imageData,
                                         filename: "ConnectionImage",
                                         mimeType: "image/heic",
                                         completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SendFile_AsImage_WrongData() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let id = try messageStream?.send(file: Data(),
                                         filename: "ConnectionImage",
                                         mimeType: "image/heic",
                                         completionHandler: nil)

        XCTAssertEqual(id?.isEmpty, true)
    }

    func testSendUploadedFiles() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let imageData = UIImage(named: "ConnectionImage")!.pngData()!
        let uploadedFile = UploadedFileImpl(size: Int64(imageData.count),
                                            guid: "AnyGuide",
                                            contentType: "image/heic",
                                            filename: "ConnectionImage",
                                            visitorID: "AnyVisitorId",
                                            clientContentType: "AnyClientContentType",
                                            imageParameters: nil)

        let id = try messageStream?.send(uploadedFiles: [uploadedFile],
                                         completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SendUploadedFiles_EmptyFiles() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let completionHandler = SendFilesCompletionHandlerMock()

        let _ = try messageStream?.send(uploadedFiles: [],
                                         completionHandler: completionHandler)

        XCTAssertTrue(completionHandler.completionCalled)
        XCTAssertEqual(completionHandler.completionSuccess, false)
        XCTAssertEqual(completionHandler.error, .fileNotFound)
    }

    func test_SendUploadedFiles_OverTenFiles() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let completionHandler = SendFilesCompletionHandlerMock()
        let imageData = UIImage(named: "ConnectionImage")!.pngData()!
        let uploadedFile = UploadedFileImpl(size: Int64(imageData.count),
                                            guid: "AnyGuide",
                                            contentType: "image/heic",
                                            filename: "ConnectionImage",
                                            visitorID: "AnyVisitorId",
                                            clientContentType: "AnyClientContentType",
                                            imageParameters: nil)

        let _ = try messageStream?.send(uploadedFiles: Array(repeating: uploadedFile, count: 15),
                                         completionHandler: completionHandler)

        XCTAssertTrue(completionHandler.completionCalled)
        XCTAssertEqual(completionHandler.completionSuccess, false)
        XCTAssertEqual(completionHandler.error, .maxFilesCountPerMessage)
    }

    func testUploadFilesToServer() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let id = try messageStream?.uploadFilesToServer(file: Data(),
                                                        filename: "someFileName",
                                                        mimeType: "AnyMimeType",
                                                        completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_UploadFilesToServer_AsImage() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let imageData = UIImage(named: "ConnectionImage")!.pngData()!

        let id = try messageStream?.uploadFilesToServer(file: imageData,
                                                        filename: "ConnectionImage",
                                                        mimeType: "image/heic",
                                                        completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_UploadFilesToServer_AsImage_WrongData() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let id = try messageStream?.uploadFilesToServer(file: Data(),
                                                        filename: "ConnectionImage",
                                                        mimeType: "image/heic",
                                                        completionHandler: nil)

        XCTAssertEqual(id?.isEmpty, true)
    }

    func testDeleteUploadedFiles() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let fileGuid = "AnyGuid"

        try messageStream?.deleteUploadedFiles(fileGuid: fileGuid, completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.guid.rawValue] as? String, fileGuid)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendKeyboardRequest_ButtonMessageCompletion() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let keyboardButtonItem = KeyboardButtonItem(jsonDictionary: convertToDict(KeyboardButtonItemTests.defaultKeyboardButtonItemJson))
        let keyboardButton = KeyboardButtonImpl(data: keyboardButtonItem)

        try messageStream?.sendKeyboardRequest(button: keyboardButton!,
                                               message: defaultMessage,
                                               completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.keyboard_response")
        XCTAssertEqual(primaryData?[Parameter.buttonId.rawValue] as? String, keyboardButton?.getID())
        XCTAssertEqual(primaryData?[Parameter.requestMessageId.rawValue] as? String, defaultMessage.getCurrentChatID())
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SendKeyboardRequest_ButtonIdMessageCurrentChatIdCompletion() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let buttonId = "AnybuttonId"
        let messageCurrentChatId = "AnyMessageCurrentChatID"

        try messageStream?.sendKeyboardRequest(buttonID: buttonId,
                                               messageCurrentChatID: messageCurrentChatId,
                                               completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.keyboard_response")
        XCTAssertEqual(primaryData?[Parameter.buttonId.rawValue] as? String, buttonId)
        XCTAssertEqual(primaryData?[Parameter.requestMessageId.rawValue] as? String, messageCurrentChatId)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendSticker() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let stickerId = 15

        try messageStream?.sendSticker(withId: stickerId, completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "sticker")
        XCTAssertEqual(primaryData?[Parameter.stickerId.rawValue] as? Int, stickerId)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testGetRawConfig() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.getRawConfig(forLocation: "AnyLocation",completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?.isEmpty, true)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testGetServerSideSettings() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.getServerSideSettings(completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?.isEmpty, true)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testUpdateWidgetStatus() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let dataString = "AnyData"

        try messageStream?.updateWidgetStatus(data: dataString)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "widget.update")
        XCTAssertEqual(primaryData?[Parameter.data.rawValue] as? String, dataString)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testReply() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let messageText = "AnyMessage"

        let id = try messageStream?.reply(message: messageText, repliedMessage: defaultMessage)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertEqual(primaryData?[Parameter.clientSideID.rawValue] as? String, id)
        XCTAssertEqual(primaryData?[Parameter.message.rawValue] as? String, messageText)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testEdit() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let editedText = "editedText"
        let listener = MessageListenerMock()
        messageHolder.set(currentChatMessages: [defaultMessage])
        let _ = try messageStream?.newMessageTracker(messageListener: listener)
        let isMessageEdited = try messageStream?.edit(message: defaultMessage,
                                                      text: editedText,
                                                      completionHandler: nil)

        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.message")
        XCTAssertEqual(primaryData?[Parameter.message.rawValue] as? String, editedText)
        XCTAssertEqual(isMessageEdited, true)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)

        messageHolder.set(messageTracker: nil)
        messageHolder.set(currentChatMessages: [])
    }

    func testEdit_UnknownMessage() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let isMessageEdited = try messageStream?.edit(message: defaultMessage,
                                                      text: "editedText",
                                                      completionHandler: nil)

        XCTAssertEqual(isMessageEdited, false)
        XCTAssertFalse(actionRequestLoop.enqueueCalled)
    }

    func testReact_VisitorCanReact() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let isMessageReacted = try messageStream?.react(message: defaultMessage,
                                                       reaction: ReactionString.like,
                                                       completionHandler: nil)

        XCTAssertEqual(isMessageReacted, true)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testReact_VisitorCantReact() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let isMessageReacted = try messageStream?.react(message: defaultMessage_2,
                                                        reaction: ReactionString.like,
                                                        completionHandler: nil)

        XCTAssertEqual(isMessageReacted, false)
        XCTAssertFalse(actionRequestLoop.enqueueCalled)
    }

    func test_DeleteMessage() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let listener = MessageListenerMock()
        messageHolder.set(currentChatMessages: [defaultMessage])

        let _ = try messageStream?.newMessageTracker(messageListener: listener)
        let isMessageDeleted = try messageStream?.delete(message: defaultMessage,
                                                         completionHandler: nil)

        XCTAssertEqual(isMessageDeleted, true)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)

        messageHolder.set(messageTracker: nil)
        messageHolder.set(currentChatMessages: [])
    }

    func test_DeleteMessage_CantDelete() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        let isMessageDeleted = try messageStream?.delete(message: defaultMessage_2,
                                                         completionHandler: nil)

        XCTAssertEqual(isMessageDeleted, false)
        XCTAssertFalse(actionRequestLoop.enqueueCalled)
    }

    func testSetChatRead() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.setChatRead()
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()


        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.read_by_visitor")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendDialogTo() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let emailAdress = "example@mail.ru"
        messageStream?.changingChatStateOf(chat: getDefaultChatItem())

        try messageStream?.sendDialogTo(emailAddress: emailAdress, completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.send_chat_history")
        XCTAssertEqual(primaryData?[Parameter.email.rawValue] as? String, emailAdress)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_SendDialogTo_NoChat() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let emailAdress = "example@mail.ru"

        try messageStream?.sendDialogTo(emailAddress: emailAdress, completionHandler: nil)

        XCTAssertFalse(actionRequestLoop.enqueueCalled)
    }

    func testSetPrechatFields() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let prechatFields = "anyFields"

        try messageStream?.set(prechatFields: prechatFields)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.set_prechat_fields")
        XCTAssertEqual(primaryData?[Parameter.prechat.rawValue] as? String, prechatFields)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testSendSurveyAnswer() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let listener = SurveyListenerMock()
        messageStream?.set(surveyListener: listener)
        messageStream?.onReceived(surveyItem: getDefaultSurveyItem())
        let answer = "AnyAnswer"

        try messageStream?.send(surveyAnswer: answer, completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "survey.answer")
        XCTAssertEqual(primaryData?[Parameter.surveyAnswer.rawValue] as? String, answer)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)

        messageStream?.onSurveyCancelled()
    }

    func testCloseSurvey() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let listener = SurveyListenerMock()
        messageStream?.set(surveyListener: listener)
        messageStream?.onReceived(surveyItem: getDefaultSurveyItem())

        try messageStream?.closeSurvey(completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "survey.answer")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)

        messageStream?.onSurveyCancelled()
    }

    func testSendGeolocation() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let latitude = Double(12)
        let longitude = Double(99)

        try messageStream?.sendGeolocation(latitude: latitude,
                                           longitude: longitude,
                                           completionHandler: nil)
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()

        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "geo_response")
        XCTAssertEqual(primaryData?[Parameter.latitude.rawValue] as? Double, latitude)
        XCTAssertEqual(primaryData?[Parameter.longitude.rawValue] as? Double, longitude)
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func testClearHistory() throws {
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil

        try messageStream?.clearHistory()
        let primaryData = actionRequestLoop.webimRequest?.getPrimaryData()


        XCTAssertEqual(primaryData?[Parameter.actionn.rawValue] as? String, "chat.clear_history")
        XCTAssertTrue(actionRequestLoop.enqueueCalled)
    }

    func test_Set_ChatStateListener() {
        let listener = ChatStateListenerMock()

        messageStream?.set(chatStateListener: listener)
        messageStream?.changingChatStateOf(chat: getDefaultChatItem())

        XCTAssertTrue(listener.chatStateChanged)
        XCTAssertEqual(listener.newChatState, .chatting)
    }


    func test_Set_CurrentOperatorChangeListener() {
        let listener = CurrentOperatorChangeListenerMock()

        messageStream?.set(currentOperatorChangeListener: listener)
        messageStream?.changingChatStateOf(chat: getDefaultChatItem())

        XCTAssertTrue(listener.operatorChanged)
        XCTAssertEqual(listener.newOperator?.getID(), "33201")
    }

    func test_Set_OperatorTypingListener() {
        let listener = OperatorTypingListenerMock()

        messageStream?.set(operatorTypingListener: listener)
        messageStream?.changingChatStateOf(chat: getDefaultChatItem())

        XCTAssertTrue(listener.typingStateChanged)
        XCTAssertEqual(listener.isTyping, false)
    }

    func test_Set_DepartmentListChangeListener() {
        let listener = DepartmentListChangeListenerMock()

        messageStream?.set(departmentListChangeListener: listener)
        messageStream?.onReceiving(departmentItemList: [])

        XCTAssertTrue(listener.received)
        XCTAssertTrue(listener.departmentList.isEmpty)
    }

    func test_Set_UnreadByOperatorTimestampChangeListener() {
        let listener = UnreadByOperatorTimestampChangeListenerMock()

        messageStream?.set(unreadByOperatorTimestampChangeListener: listener)
        messageStream?.set(unreadByOperatorTimestamp: Date())

        XCTAssertTrue(listener.timestampChanged)
        XCTAssertEqual(listener.newValue!, Date().timeIntervalSince1970, accuracy: 1)
    }

    func test_Set_UnreadByVisitorMessageCountChangeListener() {
        let listener = UnreadByVisitorMessageCountChangeListenerMock()

        messageStream?.set(unreadByVisitorMessageCountChangeListener: listener)
        messageStream?.set(unreadByVisitorMessageCount: 15)

        XCTAssertTrue(listener.unreadValueChanged)
        XCTAssertEqual(listener.newValue, 15)
    }

    func test_Set_UnreadByVisitorTimestampChangeListener() {
        let listener = UnreadByVisitorTimestampChangeListenerMock()

        messageStream?.set(unreadByVisitorTimestampChangeListener: listener)
        messageStream?.set(unreadByVisitorTimestamp: Date())

        XCTAssertTrue(listener.timestampChanged)
        XCTAssertEqual(listener.newValue!, Date().timeIntervalSince1970, accuracy: 1)
    }
}

//MARK: Fileprivate methods
fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}

fileprivate func getDefaultChatItem() -> ChatItem {
    let chatItemDictionary = try! JSONSerialization.jsonObject(with: ChatItemTests.CHAT_ITEM_JSON_STRING.data(using: .utf8)!, options: []) as! [String : Any?]
    return ChatItem(jsonDictionary: chatItemDictionary)
}

fileprivate func getDefaultSurveyItem() -> SurveyItem {
    let surveyJson = """
    {
       "id":"123",
       "config":{
          "id":12,
          "descriptor":{
             "forms":[
                {
                   "id":15123,
                   "questions":[
                      {
                         "type":"stars",
                         "text":"someText",
                         "options":[
                            "some"
                         ]
                      }
                   ]
                }
             ]
          },
          "version":"91"
       },
       "current_question":{
          "form_id":124,
          "question_id":89891
       }
    }
    """

    return SurveyItem(jsonDictionary: convertToDict(surveyJson))
}
