//
//  MessageTrackerImplTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 29.08.2022.
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

class MessageTrackerImplTests: XCTestCase {

    var sut: MessageTrackerImpl!
    var messageHolder: MessageHolder!
    let listener = MessageListenerMock()
    let webimLogger = WebimLoggerMock()

    // MARK: - Properties
    private var lastAddedMessage: MessageImpl?
    private var lastMessageBeforeAdded: MessageImpl?
    private var lastRemovedMessage: MessageImpl?
    private var lastNewVersionChangedMessage: MessageImpl?
    private var lastOldVersionChangedMessage: MessageImpl?
    private var messagesCount = 0
    let sessionDestroyer_UserDefaultsKey = "MessageTrackerImplTests_SessionDestroyer"

    // MARK: - Methods
    // MARK: Private methods
    private func generateHistory(ofCount numberOfMessages: Int) -> [MessageImpl] {
        var history = [MessageImpl]()

        for index in messagesCount ..< (messagesCount + numberOfMessages) {
            history.append(MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                       id: String(index),
                                       serverSideID: nil,
                                       keyboard: nil,
                                       keyboardRequest: nil,
                                       operatorID: MessageImplMockData.operatorID.rawValue,
                                       quote: nil,
                                       senderAvatarURLString: MessageImplMockData.avatarURLString.rawValue,
                                       senderName: MessageImplMockData.senderName.rawValue,
                                       sticker: nil,
                                       type: MessageType.operatorMessage,
                                       rawData: nil,
                                       data: nil,
                                       text: MessageImplMockData.text.rawValue + String(index),
                                       timeInMicrosecond: 0,
                                       historyMessage: true,
                                       internalID: String(index),
                                       rawText: nil,
                                       read: false,
                                       messageCanBeEdited: false,
                                       messageCanBeReplied: false,
                                       messageIsEdited: false,
                                       visitorReactionInfo: nil,
                                       visitorCanReact: nil,
                                       visitorChangeReaction: nil))
        }

        messagesCount = messagesCount + numberOfMessages

        return history
    }

    private func generateCurrentChat(ofCount numberOfMessages: Int) -> [MessageImpl] {
        var currentChat = [MessageImpl]()

        for index in messagesCount ..< (messagesCount + numberOfMessages) {
            currentChat.append(MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                           id: String(index),
                                           serverSideID: nil,
                                           keyboard: nil,
                                           keyboardRequest: nil,
                                           operatorID: MessageImplMockData.operatorID.rawValue,
                                           quote: nil,
                                           senderAvatarURLString: MessageImplMockData.avatarURLString.rawValue,
                                           senderName: MessageImplMockData.senderName.rawValue,
                                           sticker: nil,
                                           type: MessageType.operatorMessage,
                                           rawData: nil,
                                           data: nil,
                                           text: MessageImplMockData.text.rawValue + String(index),
                                           timeInMicrosecond: Int64(index),
                                           historyMessage: false,
                                           internalID: String(index),
                                           rawText: nil,
                                           read: false,
                                           messageCanBeEdited: false,
                                           messageCanBeReplied: false,
                                           messageIsEdited: false,
                                           visitorReactionInfo: nil,
                                           visitorCanReact: nil,
                                           visitorChangeReaction: nil))
        }

        messagesCount = messagesCount + numberOfMessages

        return currentChat
    }

    private func generateHistoryFrom(currentChat: [MessageImpl]) -> [MessageImpl] {
        var result = [MessageImpl]()

        for message in currentChat {
            let newMessage = MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                         id: message.getID(),
                                         serverSideID: message.getServerSideID(),
                                         keyboard: message.getKeyboard(),
                                         keyboardRequest: message.getKeyboardRequest(),
                                         operatorID: message.getOperatorID(),
                                         quote: nil,
                                         senderAvatarURLString: message.getSenderAvatarURLString(),
                                         senderName: message.getSenderName(),
                                         sticker: nil,
                                         type: message.getType(),
                                         rawData: nil,
                                         data: message.getData(),
                                         text: message.getText(),
                                         timeInMicrosecond: message.getTimeInMicrosecond(),
                                         historyMessage: true,
                                         internalID: String(message.getTimeInMicrosecond()),
                                         rawText: message.getRawText(),
                                         read: message.getRead(),
                                         messageCanBeEdited: message.canBeEdited(),
                                         messageCanBeReplied: false,
                                         messageIsEdited: false,
                                         visitorReactionInfo: message.getVisitorReaction(),
                                         visitorCanReact: message.canVisitorReact(),
                                         visitorChangeReaction: message.canVisitorChangeReaction())
            result.append(newMessage)
        }

        return result
    }

    private func newCurrentChat() -> MessageImpl {
        messagesCount = messagesCount + messagesCount

        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: String(messagesCount),
                           serverSideID: nil,
                           keyboard: nil,
                           keyboardRequest: nil,
                           operatorID: MessageImplMockData.operatorID.rawValue,
                           quote: nil,
                           senderAvatarURLString: MessageImplMockData.avatarURLString.rawValue,
                           senderName: MessageImplMockData.senderName.rawValue,
                           sticker: nil,
                           type: MessageType.operatorMessage,
                           rawData: nil,
                           data: nil,
                           text: MessageImplMockData.text.rawValue,
                           timeInMicrosecond: Int64(messagesCount),
                           historyMessage: false,
                           internalID: String(messagesCount),
                           rawText: nil,
                           read: false,
                           messageCanBeEdited: false,
                           messageCanBeReplied: false,
                           messageIsEdited: false,
                           visitorReactionInfo: nil,
                           visitorCanReact: nil,
                           visitorChangeReaction: nil)
    }

    private func newEdited(currentChatMessage: MessageImpl) -> MessageImpl {
        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: currentChatMessage.getID(),
                           serverSideID: nil,
                           keyboard: currentChatMessage.getKeyboard(),
                           keyboardRequest: currentChatMessage.getKeyboardRequest(),
                           operatorID: currentChatMessage.getOperatorID(),
                           quote: nil,
                           senderAvatarURLString: currentChatMessage.getSenderAvatarURLString(),
                           senderName: currentChatMessage.getSenderName(),
                           sticker: nil,
                           type: currentChatMessage.getType(),
                           rawData: nil,
                           data: nil,
                           text: (currentChatMessage.getText() + " One more thing."),
                           timeInMicrosecond: currentChatMessage.getTimeInMicrosecond(),
                           historyMessage: false,
                           internalID: currentChatMessage.getCurrentChatID(),
                           rawText: nil,
                           read: false,
                           messageCanBeEdited: false,
                           messageCanBeReplied: false,
                           messageIsEdited: false,
                           visitorReactionInfo: nil,
                           visitorCanReact: nil,
                           visitorChangeReaction: nil)
    }

    private func newEdited(historyMessage: MessageImpl) -> MessageImpl {
        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: historyMessage.getID(),
                           serverSideID: nil,
                           keyboard: historyMessage.getKeyboard(),
                           keyboardRequest: historyMessage.getKeyboardRequest(),
                           operatorID: historyMessage.getOperatorID(),
                           quote: nil,
                           senderAvatarURLString: historyMessage.getSenderAvatarURLString(),
                           senderName: historyMessage.getSenderName(),
                           sticker: nil,
                           type: historyMessage.getType(),
                           rawData: nil,
                           data: nil,
                           text: (historyMessage.getText() + " One more thing."),
                           timeInMicrosecond: historyMessage.getTimeInMicrosecond(),
                           historyMessage: true,
                           internalID: historyMessage.getHistoryID()?.getDBid(),
                           rawText: nil,
                           read: false,
                           messageCanBeEdited: false,
                           messageCanBeReplied: false,
                           messageIsEdited: false,
                           visitorReactionInfo: nil,
                           visitorCanReact: nil,
                           visitorChangeReaction: nil)
    }

    private func newMessageHolder(withHistory history: [MessageImpl] = [MessageImpl]()) -> MessageHolder {
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: MessageHolderTests.userDefaultsKey)
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                                  queue: DispatchQueue.global(qos: .userInteractive))
        let actionRequestLoop = ActionRequestLoop(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                  internalErrorListener: InternalErrorListenerForTests())
        let webimActions = WebimActionsImpl(baseURL: MessageImplMockData.serverURLString.rawValue,
                                            actionRequestLoop: actionRequestLoop)
        let remoteHistoryProvider = RemoteHistoryProviderMock(withWebimActions: webimActions,
                                                                  historyMessageMapper: HistoryMessageMapper(withServerURLString: MessageImplMockData.serverURLString.rawValue),
                                                                  historyMetaInformation: MemoryHistoryMetaInformationStorage(),
                                                                  history: history)

        return MessageHolder(accessChecker: accessChecker,
                             remoteHistoryProvider: remoteHistoryProvider,
                             historyStorage: MemoryHistoryStorage(),
                             reachedEndOfRemoteHistory: false)
    }

    private func newMessageHolder(withHistory history: [MessageImpl],
                                  localHistory: [MessageImpl]) -> MessageHolder {
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: MessageHolderTests.userDefaultsKey)
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                                  queue: DispatchQueue.global(qos: .userInteractive))
        let actionRequestLoop = ActionRequestLoop(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                  internalErrorListener: InternalErrorListenerForTests())
        let webimActions = WebimActionsImpl(baseURL: MessageImplMockData.serverURLString.rawValue,
                                            actionRequestLoop: actionRequestLoop)
        let remoteHistoryProvider = RemoteHistoryProviderMock(withWebimActions: webimActions,
                                                                  historyMessageMapper: HistoryMessageMapper(withServerURLString: MessageImplMockData.serverURLString.rawValue),
                                                                  historyMetaInformation: MemoryHistoryMetaInformationStorage(),
                                                                  history: history)
        let memoryHistoryStorage = MemoryHistoryStorage(messagesToAdd: localHistory)

        return MessageHolder(accessChecker: accessChecker,
                             remoteHistoryProvider: remoteHistoryProvider,
                             historyStorage: memoryHistoryStorage,
                             reachedEndOfRemoteHistory: false)
    }

    

    override func setUp() {
        super.setUp()
        WebimInternalLogger.setup(webimLogger: webimLogger, verbosityLevel: .verbose, availableLogTypes: [
            .manualCall,
            .messageHistory,
            .networkRequest,
            .undefined])

        messageHolder = newMessageHolder(withHistory: generateHistory(ofCount: 15))
        sut = MessageTrackerImpl(messageListener: listener, messageHolder: messageHolder)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    //MARK: Tests
    func test_AddedNewMessage_NotCurrentChat() {
        let expectedLog = "Message which is being added is not a part of current chat:"

        sut.addedNew(message: defaultMessage_2, of: messageHolder)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_ChangedCurrentChatMessage_PreviousMessage_NotCurrentChat() {
        webimLogger.reset()
        let expectedLog = "Message which is being changed is not a part of current chat:"

        sut.changedCurrentChatMessage(from: defaultMessage_2,
                                      to: defaultMessage,
                                      at: 5,
                                      of: messageHolder)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_ChangedCurrentChatMessage_NewMessage_NotCurrentChat() {
        webimLogger.reset()
        let expectedLog = "Replacement message for a current chat message is not a part of current chat:"

        sut.changedCurrentChatMessage(from: defaultMessage,
                                      to: defaultMessage_2,
                                      at: 5,
                                      of: messageHolder)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_DeletedCurrentChat_NotCurrentChat() {
        webimLogger.reset()
        let expectedLog = "Message which is being deleted is not a part of current chat:"

        sut.deletedCurrentChat(message: defaultMessage_2, at: 5, messageHolder: messageHolder)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_DeletedHistoryMessage() throws {
        //Given: MessageHolder has local history messages. CurrentChat is empty.
        let listener = MessageListenerMock()
        let history1 = generateHistory(ofCount: 20)
        let history2 = generateHistory(ofCount: 10)
        messageHolder = newMessageHolder(withHistory: history1, localHistory: history2)
        sut = try messageHolder.newMessageTracker(withMessageListener: listener)
        let messageId = "messageId"

        //When
        sut.idToHistoryMessageMap = [messageId: defaultMessage_2]
        try sut.getLastMessages(byLimit: 10) { res in }
        sut.deletedHistoryMessage(withID: messageId)

        //Then: GetLastMessages must return currentChat messages
        XCTAssertEqual(listener.removed, true)
    }

    func test_ChangedHistory_NotHistoryMessage() {
        webimLogger.reset()
        let expectedLog = "Message which is being changed is not a part of history:"

        sut.changedHistory(message: defaultMessage)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_AddedHistory_NotHistoryMessage() {
        webimLogger.reset()
        let expectedLog = "Message which is being added is not a part of history:"

        sut.addedHistory(message: defaultMessage, before: nil)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetLastMessages_StreamDestroyed() throws {
        webimLogger.reset()
        let expectedLog = "MessageTracker object is destroyed. Unable to perform request to get new messages."

        try sut.destroy()
        try sut.getLastMessages(byLimit: 10) { result in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetLastMessages_MessagesLoading() throws {
        webimLogger.reset()
        let expectedLog = "Messages are already loading. Unable to perform a second request to get new messages."

        sut.set(messagesLoading: true)
        try sut.getLastMessages(byLimit: 10) { result in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetLastMessages_NegativeMessageCount() throws {
        webimLogger.reset()
        let expectedLog = "Limit of messages to perform request to get new messages must be greater that zero. Passed value –"

        try sut.getLastMessages(byLimit: -1) { result in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetLastMessages_CurrentChatEmpty() throws {
        //Given: MessageHolder has 10 messages at local history storage.
        let listener = MessageListenerMock()
        let history1 = generateHistory(ofCount: 20)
        let history2 = generateHistory(ofCount: 10)
        messageHolder = newMessageHolder(withHistory: history1, localHistory: history2)
        sut = try messageHolder.newMessageTracker(withMessageListener: listener)


        //When
        var completionHandlerMessages = [Message]()
        try sut.getLastMessages(byLimit: 50) { result in
            completionHandlerMessages = result
        }

        //Then: GetLastMessages must return 10 messages, that contain local history storage
        XCTAssertEqual(completionHandlerMessages.count, 10)
    }

    func test_GetLastMessages_CurrentChatNotEmpty() throws {
        //Given: MessageHolder has currentChat messages.
        messageHolder.set(currentChatMessages: generateCurrentChat(ofCount: 30))

        //When
        var completionHandlerMessages = [Message]()
        try sut.getLastMessages(byLimit: 50) { result in
            completionHandlerMessages = result
        }

        //Then: GetLastMessages must return currentChat messages
        XCTAssertEqual(completionHandlerMessages.count, 30)
    }

    func test_GetNextMessages_MessageTrackerDestroyed() throws {
        webimLogger.reset()
        let expectedLog = "MessageTracker object is destroyed. Unable to perform request to get new messages."

        try sut.destroy()
        try sut.getNextMessages(byLimit: 10) { res in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetNextMessages_MessageLoading() throws {
        webimLogger.reset()
        let expectedLog = "Messages are already loading. Unable to perform a second request to get new messages."

        sut.set(messagesLoading: true)
        try sut.getNextMessages(byLimit: 10) { result in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetNextMessages_NegativeMessageCount() throws {
        webimLogger.reset()
        let expectedLog = "Limit of messages to perform request to get new messages must be greater that zero. Passed value –"

        try sut.getNextMessages(byLimit: -1) { result in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetNextMessages_CurrentChatEmpty() throws {
        //Given: MessageHolder has 10 messages at local history storage.
        let listener = MessageListenerMock()
        let history1 = generateHistory(ofCount: 20)
        let history2 = generateHistory(ofCount: 10)
        messageHolder = newMessageHolder(withHistory: history1, localHistory: history2)
        sut = try messageHolder.newMessageTracker(withMessageListener: listener)


        //When
        var completionHandlerMessages = [Message]()
        try sut.getNextMessages(byLimit: 50) { result in
            completionHandlerMessages = result
        }

        //Then: GetNextMessages must return 10 messages, that contain local history storage
        XCTAssertEqual(completionHandlerMessages.count, 10)
    }

    func test_GetAllMessages_MessageTrackerDestroyed() throws {
        webimLogger.reset()
        let expectedLog = "MessageTracker object is destroyed. Unable to perform request to get new messages."

        try sut.destroy()
        try sut.getAllMessages() { res in }

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_GetAllMessages() throws {
        //Given: MessageHolder has currentChat messages.
        let listener = MessageListenerMock()
        let history1 = generateHistory(ofCount: 5)
        let history2 = generateHistory(ofCount: 18)
        messageHolder = newMessageHolder(withHistory: history1, localHistory: history2)
        sut = try messageHolder.newMessageTracker(withMessageListener: listener)

        //When
        var completionHandlerMessages = [Message]()
        try sut.getAllMessages { result in
            completionHandlerMessages = result
        }

        //Then: GetAllMessages must return currentChat messages
        XCTAssertEqual(completionHandlerMessages.count, 18)
    }

    func test_ResetTo_MessageTrackerDestroyed() throws {
        webimLogger.reset()
        let expectedLog = "MessageTracker object was destroyed. Unable to perform a request to reset to a message."

        try sut.destroy()
        try sut.resetTo(message: defaultMessage)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }

    func test_ResetTo_MessageLoading() throws {
        webimLogger.reset()
        let expectedLog = "Messages is loading. Unable to perform a simultaneous request to reset to a message."

        sut.set(messagesLoading: true)
        try sut.resetTo(message: defaultMessage)

        XCTAssertTrue(webimLogger.logText.contains(expectedLog))
    }
}
