//
//  MessageHolderTests.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 01.09.17.
//  Copyright © 2017 Webim. All rights reserved.
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

class MessageHolderTests: XCTestCase {
    
    // MARK: - Constants
    private static let userDefaultsKey = "userDefaultsKey"
    private enum MessageImplMockData: String {
        case serverURLString = "https://demo.webim.ru/"
        case operatorID = "operatorID"
        case avatarURLString = "image.jpg"
        case senderName = "Sender Name"
        case text = "Text."
    }
    
    // MARK: - Properties
    private var lastAddedMessage: MessageImpl?
    private var lastMessageBeforeAdded: MessageImpl?
    private var lastRemovedMessage: MessageImpl?
    private var lastNewVersionChangedMessage: MessageImpl?
    private var lastOldVersionChangedMessage: MessageImpl?
    private var messagesCount = 0
    
    // MARK: - Methods
    // MARK: Private methods
    
    private func generateHistory(ofCount numberOfMessages: Int) -> [MessageImpl] {
        var history = [MessageImpl]()
        
        for index in messagesCount ..< (messagesCount + numberOfMessages) {
            history.append(MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                       id: String(index),
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
                                       historyMessage: true,
                                       internalID: String(index),
                                       rawText: nil,
                                       read: false,
                                       messageCanBeEdited: false,
                                       messageCanBeReplied: false,
                                       messageIsEdited: false))
        }
        
        messagesCount = messagesCount + numberOfMessages
        
        return history
    }
    
    private func generateCurrentChat(ofCount numberOfMessages: Int) -> [MessageImpl] {
        var currentChat = [MessageImpl]()
        
        for index in messagesCount ..< (messagesCount + numberOfMessages) {
            currentChat.append(MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                           id: String(index),
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
                                           messageIsEdited: false))
        }
        
        messagesCount = messagesCount + numberOfMessages
        
        return currentChat
    }
    
    private func generateHistoryFrom(currentChat: [MessageImpl]) -> [MessageImpl] {
        var result = [MessageImpl]()
        
        for message in currentChat {
            let newMessage = MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                                         id: message.getID(),
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
                                         messageIsEdited: false)
            result.append(newMessage)
        }
        
        return result
    }
    
    private func newCurrentChat() -> MessageImpl {
        messagesCount = messagesCount + messagesCount
        
        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: String(messagesCount),
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
                           messageIsEdited: false)
    }
    
    private func newEdited(currentChatMessage: MessageImpl) -> MessageImpl {
        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: currentChatMessage.getID(),
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
                           messageIsEdited: false)
    }
    
    private func newEdited(historyMessage: MessageImpl) -> MessageImpl {
        return MessageImpl(serverURLString: MessageImplMockData.serverURLString.rawValue,
                           id: historyMessage.getID(),
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
                           messageIsEdited: false)
    }
    
    private func newMessageHolder(withHistory history: [MessageImpl] = [MessageImpl]()) -> MessageHolder {
        let sessionDestroyer = SessionDestroyer(userDefaultsKey: MessageHolderTests.userDefaultsKey)
        let accessChecker = AccessChecker(thread: Thread.current,
                                          sessionDestroyer: sessionDestroyer)
        let execIfNotDestroyedHandlerExecutor = ExecIfNotDestroyedHandlerExecutor(sessionDestroyer: sessionDestroyer,
                                                                                  queue: DispatchQueue.global(qos: .userInteractive))
        let actionRequestLoop = ActionRequestLoop(completionHandlerExecutor: execIfNotDestroyedHandlerExecutor,
                                                  internalErrorListener: InternalErrorListenerForTests())
        let webimActions = WebimActions(baseURL: MessageImplMockData.serverURLString.rawValue,
                                        actionRequestLoop: actionRequestLoop)
        let remoteHistoryProvider = RemoteHistoryProviderForTests(withWebimActions: webimActions,
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
        let webimActions = WebimActions(baseURL: MessageImplMockData.serverURLString.rawValue,
                                        actionRequestLoop: actionRequestLoop)
        let remoteHistoryProvider = RemoteHistoryProviderForTests(withWebimActions: webimActions,
                                                                  historyMessageMapper: HistoryMessageMapper(withServerURLString: MessageImplMockData.serverURLString.rawValue),
                                                                  historyMetaInformation: MemoryHistoryMetaInformationStorage(),
                                                                  history: history)
        let memoryHistoryStorage = MemoryHistoryStorage(messagesToAdd: localHistory)
        
        return MessageHolder(accessChecker: accessChecker,
                             remoteHistoryProvider: remoteHistoryProvider,
                             historyStorage: memoryHistoryStorage,
                             reachedEndOfRemoteHistory: false)
    }
    
    // MARK: - Tests
    
    func testGenerateHistory() {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        _ = generateCurrentChat(ofCount: 10)
        let history2 = generateHistory(ofCount: 10)
        
        // MARK: Test 1
        var index = 0
        for message in history1 {
            XCTAssertEqual(message.getPrimaryID(), String(index))
            index = index + 1
        }
        
        // MARK: Test 2
        index = 20
        for message in history2 {
            XCTAssertEqual(message.getPrimaryID(), String(index))
            index = index + 1
        }
    }
    
    func testMessageTrackerRespondsImmediatelyOnNewCurrentChatMessages() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        
        // MARK: Test
        // When: Request next 10 messages (which are of current chat).
        messageHolder.set(currentChatMessages: currentChat)
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on current chat. When requesting messages current chat receives it immediately.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
    }
    
    func testMessageTrackerAwaitsForHistoryResponse() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let history2 = generateHistory(ofCount: 10)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        
        // MARK: Test 1
        // When: Requesting next 10 messages (which are of history).
        let expectationNotToBeCalled = XCTestExpectation()
        expectationNotToBeCalled.isInverted = true
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            expectationNotToBeCalled.fulfill()
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion shouldn't be called. It was cached and will be called after history is received.
        wait(for: [expectationNotToBeCalled],
             timeout: 0.0)
        
        // MARK: Test 2
        // When: History is received.
        messageHolder.receiveHistoryUpdateWith(messages: history2,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Previously cached completion should be called.
        XCTAssertEqual(completionHandlerMessages!, history2)
        
        // MARK: Test 3
        // When: Requesting next 10 messages.
        completionHandlerMessages = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on history1.
        XCTAssertEqual(completionHandlerMessages!, history1)
    }
    
    func testMessageTrackerAwaitsForHistoryResponseWithCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let history2 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        
        // MARK: Test 1
        // When: Requesting all messages that are of current chat.
        messageHolder.set(currentChatMessages: currentChat)
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on current chat messages.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Requesting next 10 messages (which are of history).
        let expectationNotToBeCalled = XCTestExpectation()
        expectationNotToBeCalled.isInverted = true
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            expectationNotToBeCalled.fulfill()
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should not be called. It was cached and will be called after history is received.
        wait(for: [expectationNotToBeCalled],
             timeout: 1.0)
        
        // MARK: Test 3
        // When: History is received.
        messageHolder.receiveHistoryUpdateWith(messages: history2,
                                               deleted: Set<String>(), completion: {
                                                // No need to do anything when testing.
        })
        // Then: Cached completion should be called on history2.
        XCTAssertEqual(completionHandlerMessages!, history2)
        
        // MARK: Test 4
        // When: Requesting next 10 messages (which are of received history).
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history1.
        XCTAssertEqual(completionHandlerMessages!, history1)
    }
    
    func testRemoteHistoryProviderStopsRequesting() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let history2 = generateHistory(ofCount: 10)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        
        // MARK: Test 1
        // When: Request all messages.
        messageHolder.receiveHistoryUpdateWith(messages: history2,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 100) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: 10 previously received messages should be received and no history requests should be performed.
        XCTAssertEqual(completionHandlerMessages!, history2)
        XCTAssertEqual((messageHolder.getRemoteHistoryProvider() as! RemoteHistoryProviderForTests).numberOfCalls, 0)
        
        // MARK: Test 2
        // When: Requesting all messages.
        try messageTracker.getNextMessages(byLimit: 100) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Next 10 messages should be received and history request for more should be performed.
        XCTAssertEqual(completionHandlerMessages!, history1)
        XCTAssertEqual((messageHolder.getRemoteHistoryProvider() as! RemoteHistoryProviderForTests).numberOfCalls, 1)
        
        // MARK: Test 3
        // When: Requesting more messages.
        try messageTracker.getNextMessages(byLimit: 100) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: after emptying the history will be made a one more request.
        XCTAssertEqual(completionHandlerMessages!, [MessageImpl]())
        XCTAssertEqual((messageHolder.getRemoteHistoryProvider() as! RemoteHistoryProviderForTests).numberOfCalls, 2)
        
        // MARK: Test 4
        // When: Resetting 15 messages back and requesting for all messages.
        try messageTracker.resetTo(message: history2[5])
        try messageTracker.getNextMessages(byLimit: 100) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: 15 messages should be received and no history requests should be preformed.
        XCTAssertEqual(completionHandlerMessages!, (history1 + Array(history2[0 ... 4])))
        XCTAssertEqual((messageHolder.getRemoteHistoryProvider() as! RemoteHistoryProviderForTests).numberOfCalls, 2)
    }
    
    func testInsertMessagesBetweenOlderHistoryAndCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let history2 = generateHistory(ofCount: 2)
        let currentChat = generateCurrentChat(ofCount: 10)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history1,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting 10 messages (which are of current chat).
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on this 10 messages.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Requesting 10 messages (which are history).
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on this 10 messages.
        XCTAssertEqual(completionHandlerMessages!, history1)
        
        // MARK: Test 3
        // When: Receiving history between current chat and receiver older history.
        messageHolder.receiveHistoryUpdateWith(messages: history2,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: First history message should be inserted before first current chat message.
        XCTAssertEqual(lastAddedMessage, history2[1])
        XCTAssertEqual(lastMessageBeforeAdded, currentChat.last!)
    }
    
    func testReceiveHistoryPartOfCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history1,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting current chat.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Receiving current chat completion should be called.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Requesting history part.
        var numberOfCalls = 0
        try messageTracker.getNextMessages(byLimit: 5) { messages in
            numberOfCalls = numberOfCalls + 1
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Receiving history completion handler should be called.
        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertEqual(completionHandlerMessages!, Array(history1[5 ... 9]))
        
        // MARK: Test 3
        // When: Receiving history part of current chat.
        messageHolder.receiveHistoryUpdateWith(messages: Array(history2[0 ..< 5]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: No completion handlers should be called.
        XCTAssertEqual(numberOfCalls, 1)
        
        // MARK: Test 4
        // When: Requesting remaining history.
        try messageTracker.getNextMessages(byLimit: 5) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Receiving remaining history completion handler should be called.
        XCTAssertEqual(completionHandlerMessages!, Array(history1[0 ... 4]))
    }
    
    func testReceiveFullHistoryOfCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history1,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting next 10 messages.
        var numberOfCalls = 0
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            numberOfCalls = numberOfCalls + 1
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Receiving current chat completion handler should be called.
        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Receiving history part of current chat.
        messageHolder.receiveHistoryUpdateWith(messages: Array(history2[0 ... 5]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Completion handler should not be called and receiving method too.
        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Requesting for more messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            numberOfCalls = numberOfCalls + 1
        }
        // Then: History part before current chat completion handler should be called.
        XCTAssertEqual(numberOfCalls, 2)
    }
    
    func testReceiveLastHistoryPartOfCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: Array(history2[5 ... 9]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting 10 messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Current chat receiving completion handler should be called.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Requesting next 10 messages.
        let expectationToBeCalled2 = XCTestExpectation()
        try messageTracker.getNextMessages(byLimit: 10) { _ in
            expectationToBeCalled2.fulfill()
        }
        // Then: History part before current chat receiving completion handler should be called.
        wait(for: [expectationToBeCalled2],
             timeout: 1.0)
        
        // MARK: Test 3
        // When: Resetting current chat and requesting next messages.
        messageTracker.set(messagesLoading: false)
        try messageTracker.resetTo(message: currentChat[9])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handlers should be called on next 9 current chat messages.
        XCTAssertEqual(completionHandlerMessages!, Array(currentChat[0 ... 8]))
        
        // MARK: Test 4
        try messageTracker.getNextMessages(byLimit: 5) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handlers should be called first on received history messages.
        XCTAssertEqual(completionHandlerMessages!, Array(history1[5 ... 9]))
    }
    
    func testRequestAsManyMessagesAsReceivedWithHistoryForCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history1,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: Array(currentChat[0 ... 5]))
        
        // MARK: Test 1
        // When: Requesting 10 messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: First 5 messages of current chat receiving completion should be called.
        XCTAssertEqual(completionHandlerMessages!, Array(currentChat[0 ... 5]))
        
        // MARK: Test 2
        // When: Received 5 messaged of history (which is part of current chat).
        messageHolder.receiveHistoryUpdateWith(messages: Array(history2[0 ... 5]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Receiving history which is not a part of current chat.
        messageHolder.receiveHistoryUpdateWith(messages: [history2[6]],
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 4
        // When: Receiving current chat message (which is part of history).
        messageHolder.receive(newMessage: currentChat[6])
        // Then: Message should be inserted in the end.
        XCTAssertEqual(lastAddedMessage, currentChat[6])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 5
        // When: Requesting more messages.
        let expectationToBeCalled = XCTestExpectation()
        try messageTracker.getNextMessages(byLimit: 5) { messages in
            expectationToBeCalled.fulfill()
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history part before current chat.
        wait(for: [expectationToBeCalled],
             timeout: 1.0)
    }
    
    func testReceiveCurrentChatWhenHistoryFullyTracked() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: (history1 + history2),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting 10 messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Receiving completion handler should be called on history part of current chat.
        XCTAssertEqual(completionHandlerMessages!, history2)
        
        // MARK: Test 2
        // When: Receiving chat of 7/10 messages.
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: Array(currentChat[0 ..< 8]))
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Receiving next current chat message.
        messageHolder.receive(newMessage: currentChat[9])
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 4
        // When: Requesting more messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on the older history.
        XCTAssertEqual(completionHandlerMessages!, history1)
    }
    
    func testReceiveLocalHistoryRemoteHistoryCurrentChat() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2),
                                             localHistory: (history1 + Array(history2[0 ... 7])))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        
        // MARK: Test 1
        // When: Requesting next 8 messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 8) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on 8 history messages of current chat.
        XCTAssertEqual(completionHandlerMessages!, Array(history2[0 ... 7]))
        
        // MARK: Test 2
        // When: Receiving history and 1 message of current chat history.
        messageHolder.receiveHistoryUpdateWith(messages: (history1 + [history2[8]]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Receiving method should be called on that message.
        XCTAssertEqual(lastAddedMessage, history2[8])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Receiving current chat.
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        // Then: Current chat messages should be added in the end.
        XCTAssertEqual(lastAddedMessage, currentChat[9])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 4
        // When: Requesting more messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on the older history.
        XCTAssertEqual(completionHandlerMessages!, history1)
    }
    
    func testReceiveCurrentChatWhenHistoryLastPartTracked() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        let history = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: Array(history[1 ... 9]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on received history.
        XCTAssertEqual(completionHandlerMessages!, Array(history[1 ... 9]))
        
        // MARK: Test 2
        // When: Receiving chat.
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Requesting more messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on last history part message.
        XCTAssertEqual(completionHandlerMessages!, [currentChat[0]])
    }
    
    func testMergeChat() throws {
        // MARK: Model set up
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        let messages = generateCurrentChat(ofCount: 10)
        
        // MARK: Test 1
        // When: Requesting some messages
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should not be called because there's no messages received.
        XCTAssertNil(completionHandlerMessages)
        
        // MARK: Test 2
        // When: Receiving chat with 2 messages.
        messageHolder.receiving(newChat: nil,
                                previousChat: chat,
                                newMessages: Array(messages[0 ... 1]))
        // Then: Completion should be called on this messages. Receiving method should not be called.
        XCTAssertEqual(completionHandlerMessages!, Array(messages[0 ... 1]))
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Receiving chat with the same messages.
        messageHolder.receiving(newChat: chat,
                                previousChat: chat,
                                newMessages: Array(messages[0 ... 1]))
        // Then: Receiving method should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 4
        // When: Receiving chat with more messages.
        messageHolder.receiving(newChat: chat,
                                previousChat: chat,
                                newMessages: Array(messages[0 ... 3]))
        // Then: New message should be inserted in the end. Changing or removing messages methods should not be called.
        XCTAssertEqual(lastAddedMessage, messages[3])
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 5
        // When: Receiving some non-running messages.
        messageHolder.receiving(newChat: chat,
                                previousChat: chat,
                                newMessages: (Array(messages[0 ... 1]) + Array(messages[3 ... 4])))
        // Then: Message out of range should be removed, new messages should be added in the end.
        XCTAssertEqual(lastRemovedMessage, messages[2])
        XCTAssertEqual(lastAddedMessage, messages[4])
        XCTAssertNil(lastMessageBeforeAdded)
    }
    
    func testReplaceCurrentChat() throws {
        // MARK: Model set up
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let firstChat = ChatItem(id: "1")
        let secondChat = ChatItem(id: "2")
        let messages = generateCurrentChat(ofCount: 10)
        
        // MARK: Test 1
        // When: Requesting some messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion shouldn't be called. It was cached and will be called after messages are received.
        XCTAssertNil(completionHandlerMessages)
        
        // MARK: Test 2
        // When: Receiving first chat with 2 messages.
        messageHolder.receiving(newChat: firstChat,
                                previousChat: nil,
                                newMessages: Array(messages[0 ... 1]))
        // Then: Completion handler should be called. Receiving method should not.
        XCTAssertEqual(completionHandlerMessages!, Array(messages[0 ... 1]))
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Receiving second chat with 3 messages.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: firstChat,
                                newMessages: Array(messages[2 ... 4]))
        // Then: This messages should be added.
        XCTAssertEqual(lastAddedMessage, messages[4])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 4
        // When: Resetting to last message, requesting messages.
        try messageTracker.resetTo(message: messages[4])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on messages [0 ... 3].
        XCTAssertEqual(completionHandlerMessages!, Array(messages[0 ... 3]))
        
        // MARK: Test 5
        // When: Receiving second chat with non-running messages.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: secondChat,
                                newMessages: ([messages[2]] + Array(messages[4 ... 5])))
        // Then: One message should be deleted. One message should be added.
        XCTAssertEqual(lastRemovedMessage, messages[3])
        XCTAssertEqual(lastAddedMessage, messages[5])
        
        // MARK: Test 6
        // When: Resetting to the last messages and requesting messages.
        try messageTracker.resetTo(message: messages[5])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on messages except the last one.
        XCTAssertEqual(completionHandlerMessages!, (Array(messages[0 ... 2]) + [messages[4]]))
    }
    
    func testReplaceCurrentChatWhenPreviousHistoryReceived() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let messages = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: messages)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let firstChat = ChatItem(id: "1")
        let secondChat = ChatItem(id: "2")
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion shouldn't be called. It was cached and will be called after messages are received.
        XCTAssertNil(completionHandlerMessages)
        
        // MARK: Test 2
        // When: Receiving first chat with 2 messages.
        messageHolder.receiving(newChat: firstChat,
                                previousChat: nil,
                                newMessages: Array(messages[0 ... 1]))
        // Then: Completion handler should be called on this messages. Message listener methods should not be called.
        XCTAssertEqual(completionHandlerMessages!, Array(messages[0 ... 1]))
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Receiving history part of current chat.
        messageHolder.receiveHistoryUpdateWith(messages: Array(history2[0 ... 1]),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 4
        // When: Requesting all messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on full history.
        XCTAssertEqual(completionHandlerMessages!, history1)
        
        // MARK: Test 5
        // When: Receiving second chat with next 3 messages.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: firstChat,
                                newMessages: Array(messages[2 ... 4]))
        // Then: Receiving method should be called on all this messages. All current chat messages should be historified.
        XCTAssertEqual(lastAddedMessage, messages[4])
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertEqual(messageHolder.getLastChatMessageIndex(), 0)
        
        // MARK: Test 6
        // When: Resetting to the last message. Requesting latest messages.
        try messageTracker.resetTo(message: messages[4])
        try messageTracker.getNextMessages(byLimit: 20) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on previous two messages.
        XCTAssertEqual(completionHandlerMessages!, Array(messages[2 ... 3]))
        
        // MARK: Test 7
        // When: Requesting all messages.
        try messageTracker.getNextMessages(byLimit: 20) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on full history.
        XCTAssertEqual(completionHandlerMessages!, (history1 + Array(history2[0 ... 1])))
        
        // MARK: Test 8
        // When: Receiving second chat with one message deleted and one added.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: secondChat,
                                newMessages: ([messages[2]] + Array(messages[4 ... 5])))
        // Then: One message deleted. One message added.
        XCTAssertEqual(lastRemovedMessage, messages[3])
        XCTAssertEqual(lastAddedMessage, messages[5])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 9
        // When: Resetting to last message. Requesting more messages.
        try messageTracker.resetTo(message: messages[5])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion should be called on missing messages.
        XCTAssertEqual(completionHandlerMessages!, ([messages[2], messages[4]]))
    }
    
    func testReplaceCurrentChatWhenPreviousHistoryStoredLocally() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let messages = generateCurrentChat(ofCount: 10)
        let history2 = generateHistoryFrom(currentChat: messages)
        let messageHolder = newMessageHolder(withHistory: (history1 + history2),
                                             localHistory: Array(history2[0 ... 1]))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let firstChat = ChatItem(id: "1")
        let secondChat = ChatItem(id: "2")
        
        // MARK: Test 1
        // When: Requesting messages.
        var numberOfCalls = 0
        var completionHandlerMessages: [MessageImpl]?
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            numberOfCalls = numberOfCalls + 1
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on stored locally history.
        XCTAssertEqual(completionHandlerMessages!, Array(history2[0 ... 1]))
        
        // MARK: Test 2
        // When: Receiving first chat with 2 messages.
        messageHolder.receiving(newChat: firstChat,
                                previousChat: nil,
                                newMessages: Array(messages[0 ... 1]))
        // Then: Completion handler should not be called. Message listener methods should not be called.
        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Requesting all messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on full history.
        XCTAssertEqual(completionHandlerMessages!, history1)
        
        // MARK: Test 4
        // When: Receiving second chat with next 3 messages. All current chat messages should be historified.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: firstChat,
                                newMessages: Array(messages[2 ... 4]))
        // Then: This messages should be added.
        XCTAssertEqual(lastAddedMessage, messages[4])
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertEqual(messageHolder.getLastChatMessageIndex(), 0)
        
        // MARK: Test 5
        // When: Resetting to the last message. Requesting latest messages.
        try messageTracker.resetTo(message: messages[4])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on missing messages.
        XCTAssertEqual(completionHandlerMessages!, Array(messages[2 ... 3]))
        
        // MARK: Test 6
        // When: Requesting all messages.
        try messageTracker.getNextMessages(byLimit: 20) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on full history.
        XCTAssertEqual(completionHandlerMessages!, (history1 + Array(history2[0 ... 1])))
        
        // MARK: Test 7
        // When: Receiving second chat again with one message deleted and one added.
        messageHolder.receiving(newChat: secondChat,
                                previousChat: secondChat,
                                newMessages: ([messages[2]] + Array(messages[4 ... 5])))
        // Then: One message deleted. One message added.
        XCTAssertEqual(lastRemovedMessage, messages[3])
        XCTAssertEqual(lastAddedMessage, messages[5])
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 8
        // When: Resetting to the last messages. Requesting missing messages.
        try messageTracker.resetTo(message: messages[5])
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on missing messages.
        XCTAssertEqual(completionHandlerMessages!, ([messages[2], messages[4]]))
    }
    
    func testResetMixedCurrentChatAndHistory() throws {
        // MARK: Model set up
        let history1 = generateHistory(ofCount: 10)
        let history2 = generateHistory(ofCount: 10)
        let currentChat = generateCurrentChat(ofCount: 10)
        let nextCurrentChat = newCurrentChat()
        let messageHolder = newMessageHolder(withHistory: (history1 + history2))
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history2,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting next 10 messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Requesting next 10 messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history2.
        XCTAssertEqual(completionHandlerMessages!, history2)
        
        // MARK: Test 3
        // When: Requesting next 10 messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history1.
        XCTAssertEqual(completionHandlerMessages!, history1)
        
        // MARK: Test 4
        // When: Receiving next current chat message.
        messageHolder.receive(newMessage: nextCurrentChat)
        // Then: This message should be added in the end.
        XCTAssertEqual(lastAddedMessage, nextCurrentChat)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 5
        // When: Resetting to the last message. Requesting next 10 messages
        try messageTracker.resetTo(message: nextCurrentChat)
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 6
        // When: Requesting next 10 messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history2.
        XCTAssertEqual(completionHandlerMessages!, history2)
        
        // MARK: Test 7
        // When: Requesting next 10 messages.
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history1.
        XCTAssertEqual(completionHandlerMessages!, history1)
    }
    
    func testReceiveNewMessageWhenHistoryIsEmpty() throws {
        // MARK: Model set up
        let nextCurrentChat = newCurrentChat()
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: [MessageImpl](),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.set(endOfHistoryReached: true)
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on empty history.
        XCTAssertEqual(completionHandlerMessages!, [MessageImpl]())
        
        // MARK: Test 2
        // When: Receiving next current chat message.
        messageHolder.receive(newMessage: nextCurrentChat)
        // Then: This message should be added in the end.
        XCTAssertEqual(lastAddedMessage, nextCurrentChat)
        XCTAssertNil(lastMessageBeforeAdded)
    }
    
    func testEditCurrentChatMessage() throws {
        // MARK: Model set up
        let nextCurrentChat = newCurrentChat()
        let editedCurrentChat = newEdited(currentChatMessage: nextCurrentChat)
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: [MessageImpl](),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.set(reachedEndOfLocalHistory: true)
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on empty history.
        XCTAssertEqual(completionHandlerMessages!, [MessageImpl]())
        
        // MARK: Test 2
        // When: Receiving next current chat message.
        messageHolder.receive(newMessage: nextCurrentChat)
        // Then: This message should be added in the end.
        XCTAssertEqual(lastAddedMessage, nextCurrentChat)
        XCTAssertNil(lastMessageBeforeAdded)
        
        // MARK: Test 3
        // When: Changing message.
        messageHolder.changed(message: editedCurrentChat)
        // Then: Changing message listener method should be called on this message.
        XCTAssertEqual(lastOldVersionChangedMessage, nextCurrentChat)
        XCTAssertEqual(lastNewVersionChangedMessage, editedCurrentChat)
    }
    
    func testEditCurrentChatMessageReceivedWithFullUpdate() throws {
        // MARK: Model set up
        var currentChat = generateCurrentChat(ofCount: 10)
        let editedCurrentChat = currentChat
        currentChat[9] = newEdited(currentChatMessage: currentChat[9])
        let messageHolder = newMessageHolder()
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        messageHolder.receiveHistoryUpdateWith(messages: [MessageImpl](),
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        messageHolder.set(endOfHistoryReached: true)
        messageHolder.receiving(newChat: chat,
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Receiving new messages (one is different).
        messageHolder.receiving(newChat: chat,
                                previousChat: chat,
                                newMessages: editedCurrentChat)
        // Then: That message should be changed. Other message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertEqual(lastOldVersionChangedMessage, currentChat[9])
        XCTAssertEqual(lastNewVersionChangedMessage, editedCurrentChat[9])
    }
    
    func testEditHistoryMessage() throws {
        // MARK: Model set up
        let history = generateHistory(ofCount: 10)
        let editedHistoryMessage = newEdited(historyMessage: history[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history.
        XCTAssertEqual(completionHandlerMessages!, history)
        
        // MARK: Test 2
        // When: Receiving changed history message.
        messageHolder.receiveHistoryUpdateWith(messages: [editedHistoryMessage],
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: This message should be changed.
        XCTAssertEqual(lastOldVersionChangedMessage, history[9])
        XCTAssertEqual(lastNewVersionChangedMessage, editedHistoryMessage)
    }
    
    func testReplaceHistoryMessageWithEditedCurrentChatMessage() throws {
        // MARK: Model set up
        var currentChat = generateCurrentChat(ofCount: 10)
        let history = generateHistoryFrom(currentChat: currentChat)
        currentChat[9] = newEdited(currentChatMessage: currentChat[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history.
        XCTAssertEqual(completionHandlerMessages!, history)
        
        // MARK: Test 2
        // When: Receiving current chat with one changed message.
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        // Then: This message should be changed.
        XCTAssertEqual(lastOldVersionChangedMessage, history[9])
        XCTAssertEqual(lastNewVersionChangedMessage, currentChat[9])
    }
    
    func testReplaceCurrentChatMessageWithEditedHistoryMessageInClosedChat() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        let history = generateHistoryFrom(currentChat: currentChat)
        let editedHistoryMessage = newEdited(historyMessage: history[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        messageHolder.receiving(newChat: chat,
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting next messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Receiving chat without messages and history messages.
        messageHolder.receiving(newChat: nil,
                                previousChat: chat,
                                newMessages: [MessageImpl]())
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Receiving changed history message.
        messageHolder.receiveHistoryUpdateWith(messages: [editedHistoryMessage],
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: This message should be changed.
        XCTAssertEqual(lastOldVersionChangedMessage, currentChat[9])
        XCTAssertEqual(lastNewVersionChangedMessage, editedHistoryMessage)
    }
    
    func testReplaceCurrentChatMessageWithEditedHistoryMessageInOpenChat() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        let history = generateHistoryFrom(currentChat: currentChat)
        let editedHistoryMessage = newEdited(historyMessage: history[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiving(newChat: ChatItem(),
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Receiving history.
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Receiving edited history message.
        messageHolder.receiveHistoryUpdateWith(messages: [editedHistoryMessage],
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: While current chat exists changes in history should not have an effect..
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
    }
    
    func testReceiveEditedHistoryInClosedChat() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        var history = generateHistoryFrom(currentChat: currentChat)
        history[9] = newEdited(historyMessage: history[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        messageHolder.receiving(newChat: chat,
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: Receiving empty chat.
        messageHolder.receiving(newChat: nil,
                                previousChat: chat,
                                newMessages: [MessageImpl]())
        // Then: Message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Receiving history.
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Edited message should be changed.
        XCTAssertEqual(lastOldVersionChangedMessage, currentChat[9])
        XCTAssertEqual(lastNewVersionChangedMessage, history[9])
    }
    
    func testReceiveEditedHistoryAndCloseChat() throws {
        // MARK: Set up
        let currentChat = generateCurrentChat(ofCount: 10)
        var history = generateHistoryFrom(currentChat: currentChat)
        history[9] = newEdited(historyMessage: history[9])
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        messageHolder.receiving(newChat: chat,
                                previousChat: nil,
                                newMessages: currentChat)
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on current chat.
        XCTAssertEqual(completionHandlerMessages!, currentChat)
        
        // MARK: Test 2
        // When: receiving history.
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        // Then: Message listener methods should not be called.
        XCTAssertNil(lastAddedMessage)
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertNil(lastRemovedMessage)
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Receiving empty chat.
        messageHolder.receiving(newChat: nil,
                                previousChat: chat,
                                newMessages: [MessageImpl]())
        // Then: Edited message should be changed.
        XCTAssertEqual(lastOldVersionChangedMessage, currentChat[9])
        XCTAssertEqual(lastNewVersionChangedMessage, history[9])
    }
    
    func testReceiveCurrentChatWhenItHoldedAsHistory() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 10)
        let history = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        var numberOfCalls = 0
        try messageTracker.getNextMessages(byLimit: 10) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
            numberOfCalls = numberOfCalls + 1
        }
        // Then: Completion handler should be called on history.
        XCTAssertEqual(completionHandlerMessages!, history)
        XCTAssertEqual(numberOfCalls, 1)
        
        // MARK: Test 2
        // When: Received current chat message twice which is holded as local history.
        messageHolder.receive(newMessage: currentChat[9])
        messageHolder.receive(newMessage: currentChat[9])
        // Then: Message shouldn't be received as new.
        XCTAssertEqual(numberOfCalls, 1)
    }
    
    func testReplacingHistoryWithCurrentChat() throws {
        // MARK: Model set up
        let currentChat = generateCurrentChat(ofCount: 1)
        let history = generateHistoryFrom(currentChat: currentChat)
        let messageHolder = newMessageHolder(withHistory: history)
        let messageTracker = try messageHolder.newMessageTracker(withMessageListener: self)
        let chat = ChatItem()
        messageHolder.receiveHistoryUpdateWith(messages: history,
                                               deleted: Set<String>()) {
                                                // No need to do anything when testing.
        }
        
        // MARK: Test 1
        // When: Requesting messages.
        var completionHandlerMessages: [MessageImpl]? = nil
        try messageTracker.getNextMessages(byLimit: 1) { messages in
            completionHandlerMessages = messages as? [MessageImpl]
        }
        // Then: Completion handler should be called on history.
        XCTAssertEqual(completionHandlerMessages!, history)
        
        // MARK: Test 2
        // When: Receiving chat with history.
        messageHolder.receiving(newChat: nil,
                                previousChat: chat,
                                newMessages: currentChat)
        // Then: No messages should be changed.
        XCTAssertNil(lastOldVersionChangedMessage)
        XCTAssertNil(lastNewVersionChangedMessage)
        
        // MARK: Test 3
        // When: Deleting current chat message.
        messageHolder.deletedMessageWith(id: currentChat[0].getCurrentChatID()!)
        // Then: Message should be deleted.
        XCTAssertEqual(lastRemovedMessage, currentChat[0])
        
        // MARK: Test 4
        // When: Receiving chat again.
        messageHolder.receiving(newChat: chat,
                                previousChat: chat,
                                newMessages: currentChat)
        // Then: Message should be added.
        XCTAssertNil(lastMessageBeforeAdded)
        XCTAssertEqual(lastAddedMessage, currentChat[0])
    }
    
    func testSetMessagesToSend() {
        let messageToSend = MessageToSend(serverURLString: "http://demo.webim.ru",
                                          id: "1",
                                          senderName: "Sender",
                                          type: .operatorMessage,
                                          text: "Text",
                                          timeInMicrosecond: 1)
        let messageHolder = newMessageHolder()
        messageHolder.set(messagesToSend: [messageToSend])
        
        XCTAssertEqual([messageToSend],
                       messageHolder.getMessagesToSend())
    }
    
    func testSendingMessage() {
        let messageToSend = MessageToSend(serverURLString: "http://demo.webim.ru",
                                          id: "1",
                                          senderName: "Sender",
                                          type: .operatorMessage,
                                          text: "Text",
                                          timeInMicrosecond: 1)
        let messageHolder = newMessageHolder()
        messageHolder.sending(message: messageToSend)
        
        XCTAssertEqual([messageToSend],
                       messageHolder.getMessagesToSend())
    }
    
    func testSendingCancelled() {
        let messageID = "1"
        let messageToSend = MessageToSend(serverURLString: "http://demo.webim.ru",
                                          id: messageID,
                                          senderName: "Sender",
                                          type: .operatorMessage,
                                          text: "Text",
                                          timeInMicrosecond: 1)
        let messageHolder = newMessageHolder()
        messageHolder.sending(message: messageToSend)
        messageHolder.sendingCancelledWith(messageID: messageID)
        
        XCTAssertTrue(messageHolder.getMessagesToSend().isEmpty)
    }
    
    // MARK: - Mocking RemoteHistoryProvider
    final class RemoteHistoryProviderForTests: RemoteHistoryProvider {
        
        // MARK: - Properties
        var history: [MessageImpl]
        var numberOfCalls = 0
        
        // MARK: - Initialization
        init(withWebimActions webimActions: WebimActions,
             historyMessageMapper: MessageMapper,
             historyMetaInformation: HistoryMetaInformationStorage,
             history: [MessageImpl] = [MessageImpl]()) {
            self.history = history
            
            super.init(webimActions: webimActions,
                       historyMessageMapper: historyMessageMapper,
                       historyMetaInformationStorage: historyMetaInformation)
        }
        
        // MARK: - Methods
        override func requestHistory(beforeTimestamp: Int64,
                                     completion: @escaping ([MessageImpl], Bool) -> ()) {
            var beforeIndex = 0
            for (messageIndex, message) in history.enumerated() {
                if message.getTimeInMicrosecond() <= beforeTimestamp {
                    beforeIndex = messageIndex
                    
                    continue
                } else {
                    break
                }
            }
            
            let afterIndex = max(0, (beforeIndex - 100))
            
            numberOfCalls = numberOfCalls + 1
            
            completion((beforeIndex <= 0) ? [MessageImpl]() : Array(history[afterIndex ..< beforeIndex]), (afterIndex != 0))
        }
        
    }
    
}

// MARK: - MessageListener
extension MessageHolderTests: MessageListener {
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        lastAddedMessage = newMessage as? MessageImpl
        lastMessageBeforeAdded = previousMessage as? MessageImpl
    }
    
    func removed(message: Message) {
        lastRemovedMessage = message as? MessageImpl
    }
    
    func removedAllMessages() {
        // No need to do anything when testing.
    }
    
    func changed(message oldVersion: Message, to newVersion: Message) {
        lastOldVersionChangedMessage = oldVersion as? MessageImpl
        lastNewVersionChangedMessage = newVersion as? MessageImpl
    }
    
}


// MARK: -
extension MessageImpl {
    
    func getPrimaryID() -> String! {
        return (getSource().isHistoryMessage() ? getHistoryID()!.getDBid() : getCurrentChatID())
    }
 
}
