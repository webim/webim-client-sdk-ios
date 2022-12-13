//
//  DeltaCallbackTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 18.08.2022.
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

class DeltaCallbackTests: XCTestCase {

    var deltaCallback: DeltaCallback?
    var actionRequestLoop: ActionRequestLoopForTests!
    var webimActions: WebimActionsImpl!
    var messageHolder: MessageHolder!
    var messageStream: MessageStreamImpl!
    var historyPoller: HistoryPoller!

    let defaultMessageMapper = MessageMapperForTests(withServerURLString: "Some value")
    let userDefaults = "DeltaCallbackTests"
    let serverURLString = "DeltaCallbackTestsServerURLString"
    let locationSettingsHolderUserDefaultsKey = "DeltaCallbackTestslocationSettingsHolder"

    override func setUp() {
        super.setUp()
        deltaCallback = DeltaCallback(
            currentChatMessageMapper: defaultMessageMapper,
            historyMessageMapper: defaultMessageMapper,
            userDefaultsKey: "Some")

        let sessionDestroyer = SessionDestroyer(userDefaultsKey: userDefaults)
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

        historyPoller = HistoryPoller(withSessionDestroyer: sessionDestroyer,
                                      queue: queue,
                                      historyMessageMapper: defaultMessageMapper,
                                      webimActions: webimActions,
                                      messageHolder: messageHolder,
                                      historyMetaInformationStorage: MemoryHistoryMetaInformationStorage())

        deltaCallback?.set(messageStream: messageStream,
                           messageHolder: messageHolder,
                           historyPoller: historyPoller)
    }

    override func tearDown() {
        deltaCallback = nil
        super.tearDown()
    }

    func test_Process_Chat() {
        let listener = ChatStateListenerMock()
        let deltaItemUpdate = buildDeltaItem(data: getChatItem(state: .closed),
                                             event: .update,
                                             objectType: .chat)
        let deltaItemAdd = buildDeltaItem(data: getChatItem(state: .queue),
                                          event: .add,
                                          objectType: .chat)

        messageStream.set(chatStateListener: listener)
        deltaCallback?.process(deltaList: [deltaItemAdd!, deltaItemUpdate!])

        XCTAssertTrue(listener.chatStateChanged)
        XCTAssertEqual(listener.newChatState, .closed)
    }

    func test_Process_ChatMessage() throws {
        let listener = MessageListenerMock()
        let id = "72b6946234214a24b8d067a406ffcd53_2"
        let chatMessageString = """
        {
            "id" : "4eabdef5d5774c16b991c25581e3c217",
            "authorId" : null,
            "clientSideId" : "c04c4caf000441f97eafe765ad6d2193",
            "edited" : false,
            "read" : false,
            "avatar" : null,
            "channelSideId" : null,
            "text" : "Awfajhwgdjawdaw",
            "sessionId" : "e0bbb10932104c2b84d6965cc876f556",
            "modifiedTs" : 1660833655.0889719,
            "canBeReplied" : true,
            "kind" : "visitor",
            "ts" : 1660833655.0889719,
            "name" : "Посетитель",
            "canBeEdited" : true
        }
        """
        let deltaItemUpdateChat = buildDeltaItem(
            id: id,
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemAddChatMessage = buildDeltaItem(
            id: id,
            data: chatMessageString,
            event: .add,
            objectType: .chatMessage)
        let deltaItemUpdateChatMessage = buildDeltaItem(
            id: id,
            data: chatMessageString,
            event: .update,
            objectType: .chatMessage)
        let deltaItemDeleteChatMessage = buildDeltaItem(
            id: id,
            data: chatMessageString,
            event: .delete,
            objectType: .chatMessage)

        let _ = try messageStream.newMessageTracker(messageListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemAddChatMessage!,
            deltaItemUpdateChatMessage!,
            deltaItemDeleteChatMessage!]
        )

        XCTAssertEqual(listener.changed, true)
        XCTAssertEqual(listener.added, true)
    }



    func test_Process_ChatOperator() {
        let listener = CurrentOperatorChangeListenerMock()
        let chatOperatorData = """
      {
        "avatar" : "/images/avatar/wmtest6_223630.png?1650797909569812",
        "id" : 223630,
        "departmentKeys" : [
          "oflain_otdel",
          "onebot",
          "highload_selenium",
          "bugztasks_t656",
          "petrodepartment",
          "testovyi_otdel",
          "isaev_dep",
          "lenin_otdel",
          "test_otdel",
          "telegram",
          "bugztasks_t858",
          "alexander_dep",
          "test_boiko",
          "magic_dep",
          "la_squadra_di_esecuzione",
          "kir_dep",
          "otdel_dlia_testa",
          "test_regress",
          "bot",
          "bot_dep"
        ],
        "robotType" : null,
        "fullname" : "Василий Админович",
        "langToFullname" : {

        }
      }
"""
        let deltaItemUpdateChat = buildDeltaItem(
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemUpdateChatMessage = buildDeltaItem(
            data: chatOperatorData,
            event: .update,
            objectType: .chatOperator)
        let deltaItemAddChatMessage = buildDeltaItem(
            data: chatOperatorData,
            event: .add,
            objectType: .chatOperator)
        let deltaItemDeleteChatMessage = buildDeltaItem(
            data: chatOperatorData,
            event: .delete,
            objectType: .chatOperator)

        messageStream.set(currentOperatorChangeListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemAddChatMessage!,
            deltaItemDeleteChatMessage!,
            deltaItemUpdateChat!,
            deltaItemUpdateChatMessage!]
        )

        XCTAssertTrue(listener.operatorChanged)
        XCTAssertEqual(listener.newOperator?.getID(), "223630")
    }

    func test_Process_ChatOperatorTyping() {
        let operatorTypingData = true
        let listener = OperatorTypingListenerMock()
        let deltaItemUpdateChat = buildDeltaItem(
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemAddChatOperatorTyping = buildDeltaItem(
            data: operatorTypingData,
            event: .add,
            objectType: .chatOperatorTyping)
        let deltaItemAddChatOperatorNotTyping = buildDeltaItem(
            data: !operatorTypingData,
            event: .add,
            objectType: .chatOperatorTyping)
        let deltaItemUpdateChatOperatorTyping = buildDeltaItem(
            data: operatorTypingData,
            event: .update,
            objectType: .chatOperatorTyping)
        let deltaItemUpdateChatOperatorNotTyping = buildDeltaItem(
            data: !operatorTypingData,
            event: .update,
            objectType: .chatOperatorTyping)
        let deltaItemDeleteChatOperatorTyping = buildDeltaItem(
            data: operatorTypingData,
            event: .delete,
            objectType: .chatOperatorTyping)
        let deltaItemDeleteChatOperatorNotTyping = buildDeltaItem(
            data: !operatorTypingData,
            event: .delete,
            objectType: .chatOperatorTyping)

        messageStream.set(operatorTypingListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemAddChatOperatorTyping!,
            deltaItemUpdateChat!,
            deltaItemDeleteChatOperatorTyping!,
            deltaItemUpdateChat!,
            deltaItemAddChatOperatorNotTyping!,
            deltaItemUpdateChat!,
            deltaItemUpdateChatOperatorNotTyping!,
            deltaItemUpdateChat!,
            deltaItemDeleteChatOperatorNotTyping!,
            deltaItemUpdateChat!,
            deltaItemUpdateChatOperatorTyping!]
        )
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemUpdateChatOperatorTyping!]
        )

        XCTAssertTrue(listener.typingStateChanged)
        XCTAssertEqual(listener.isTyping, operatorTypingData)
    }

    func test_Process_ChatReadByVisitor() {
        let chatReadByVisitorData = true
        let listener = UnreadByVisitorTimestampChangeListenerMock()

        let deltaItemUpdateChat = buildDeltaItem(
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemAddChatReadByVisitor = buildDeltaItem(
            data: chatReadByVisitorData,
            event: .add,
            objectType: .chatReadByVisitor)
        let deltaItemAddChatNotReadByVisitor = buildDeltaItem(
            data: !chatReadByVisitorData,
            event: .add,
            objectType: .chatReadByVisitor)
        let deltaItemUpdateChatReadByVisitor = buildDeltaItem(
            data: chatReadByVisitorData,
            event: .update,
            objectType: .chatReadByVisitor)
        let deltaItemUpdateChatNotReadByVisitor = buildDeltaItem(
            data: !chatReadByVisitorData,
            event: .update,
            objectType: .chatReadByVisitor)
        let deltaItemDeleteChatReadByVisitor = buildDeltaItem(
            data: chatReadByVisitorData,
            event: .delete,
            objectType: .chatReadByVisitor)
        let deltaItemDeleteChatNotReadByVisitor = buildDeltaItem(
            data: !chatReadByVisitorData,
            event: .delete,
            objectType: .chatReadByVisitor)

        messageStream.set(unreadByVisitorTimestampChangeListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemAddChatReadByVisitor!,
            deltaItemAddChatNotReadByVisitor!,
            deltaItemUpdateChatReadByVisitor!,
            deltaItemUpdateChatNotReadByVisitor!,
            deltaItemDeleteChatReadByVisitor!,
            deltaItemDeleteChatNotReadByVisitor!]
        )

        XCTAssertTrue(listener.timestampChanged)
        XCTAssertNil(listener.newValue)
    }

    func test_Process_ChatState() {
        let listener = ChatStateListenerMock()
        let deltaItemUpdateChat = buildDeltaItem(
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemAddChatState = buildDeltaItem(
            data: "\"\(ChatItem.ChatItemState.closed.rawValue)\"",
            event: .add,
            objectType: .chatState)
        let deltaItemUpdateChatState = buildDeltaItem(
            data: "\"\(ChatItem.ChatItemState.unknown.rawValue)\"",
            event: .update,
            objectType: .chatState)
        let deltaItemDeleteChatState = buildDeltaItem(
            data: "\"\(ChatItem.ChatItemState.chatting.rawValue)\"",
            event: .delete,
            objectType: .chatState)

        messageStream.set(chatStateListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemUpdateChatState!]
        )
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemAddChatState!]
        )
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemDeleteChatState!]
        )

        XCTAssertTrue(listener.chatStateChanged)
        XCTAssertEqual(listener.newChatState, .chatting)
    }

    func test_Process_ChatUnreadByOperatorTimestamp() {
        let listener = UnreadByOperatorTimestampChangeListenerMock()
        let expectedTimeInterval = TimeInterval(1234.51231)
        let deltaItemUpdateChat = buildDeltaItem(
            data: getChatItem(),
            event: .update,
            objectType: .chat)
        let deltaItemAddChatUnreadByOperatorTS = buildDeltaItem(
            data: Double(1234.51231),
            event: .add,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemUpdateChatUnreadByOperatorTS = buildDeltaItem(
            data: Double(1234.51231),
            event: .update,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemDeleteChatUnreadByOperatorTS = buildDeltaItem(
            data: Double(1234.51231),
            event: .delete,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemAddChatUnreadByOperatorTSNegative = buildDeltaItem(
            data: Double(-1234.51231),
            event: .add,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemUpdateChatUnreadByOperatorTSNegative = buildDeltaItem(
            data: Double(-1234.51231),
            event: .update,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemDeleteChatUnreadByOperatorTSNegative = buildDeltaItem(
            data: Double(-1234.51231),
            event: .delete,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemAddChatUnreadByOperatorTSNull = buildDeltaItem(
            data: "null",
            event: .add,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemUpdateChatUnreadByOperatorTSNull = buildDeltaItem(
            data: "null",
            event: .update,
            objectType: .chatUnreadByOperatorTimestamp)
        let deltaItemDeleteChatUnreadByOperatorTSNull = buildDeltaItem(
            data: "null",
            event: .delete,
            objectType: .chatUnreadByOperatorTimestamp)

        messageStream.set(unreadByOperatorTimestampChangeListener: listener)
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemAddChatUnreadByOperatorTS!,
            deltaItemUpdateChatUnreadByOperatorTS!,
            deltaItemDeleteChatUnreadByOperatorTS!,
            deltaItemAddChatUnreadByOperatorTSNegative!,
            deltaItemUpdateChatUnreadByOperatorTSNegative!,
            deltaItemDeleteChatUnreadByOperatorTSNegative!,
            deltaItemAddChatUnreadByOperatorTSNull!,
            deltaItemUpdateChatUnreadByOperatorTSNull!,
            deltaItemDeleteChatUnreadByOperatorTSNull!]
        )
        deltaCallback?.process(deltaList: [
            deltaItemUpdateChat!,
            deltaItemUpdateChatUnreadByOperatorTS!]
        )

        XCTAssertTrue(listener.timestampChanged)
        XCTAssertEqual(listener.newValue!, expectedTimeInterval, accuracy: 1)
    }

    func test_Process_DepartmentList() {
        let listener = DepartmentListChangeListenerMock()
        let departmentJson = """
        [
            {
                "localeToName" : {
                    "ru" : "Mobile Test 1"
                },
                "key" : "mobile_test_1",
                "online" : "offline",
                "name" : "Mobile Test 1",
                "order" : 100,
                "logo" : "/webim/images/department_logo/wmtest2_1.png"
            }
        ]
        """

        let deltaItem = buildDeltaItem(data: departmentJson,
                                       event: .update,
                                       objectType: .departmentList)

        messageStream.set(departmentListChangeListener: listener)
        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(listener.received)
        XCTAssertEqual(listener.departmentList.count, 1)
    }

    func test_Process_HistoryRevision() {
        historyPoller.resume()
        actionRequestLoop.enqueueCalled = false
        actionRequestLoop.webimRequest = nil
        let revisionJson = """
         {
            "revision":231
         }
         """

        let deltaItem = buildDeltaItem(data: revisionJson,
                                       event: .update,
                                       objectType: .historyRevision)

        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(actionRequestLoop.enqueueCalled)
        XCTAssertNotNil(actionRequestLoop.webimRequest)
    }

    func test_Process_Survey() {
        let listener = SurveyListenerMock()
        messageStream.set(surveyListener: listener)
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
        let deltaItem = buildDeltaItem(data: surveyJson,
                                       event: .update,
                                       objectType: .survey)

        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(listener.onSurveyCalled)
    }

    func test_Process_SurveyCancelled() {
        let listener = SurveyListenerMock()
        let surveyJson = "null"
        let deltaItem = buildDeltaItem(data: surveyJson,
                                       event: .update,
                                       objectType: .survey)

        messageStream.set(surveyListener: listener)
        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(listener.onSurveyCancelledCalled)
    }

    func test_Process_UnreadByVisitor() {
        let listener = UnreadByVisitorMessageCountChangeListenerMock()
        let unreadByVisitorJson = """
        {
            "msgCnt" : 5,
            "sinceTs" : 12412671
        }
        """
        let deltaItem = buildDeltaItem(data: unreadByVisitorJson,
                                       event: .update,
                                       objectType: .unreadByVisitor)

        messageStream.set(unreadByVisitorMessageCountChangeListener: listener)
        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(listener.unreadValueChanged)
        XCTAssertEqual(listener.newValue, 5)
    }

    func test_Process_VisitSessionState() {
        let listener = VisitSessionStateListenerMock()
        let sessionStateJson = "\"offline-message\""
        let deltaItem = buildDeltaItem(data: sessionStateJson,
                                       event: .update,
                                       objectType: .visitSessionState)

        messageStream.set(visitSessionStateListener: listener)
        deltaCallback?.process(deltaList: [deltaItem!])

        XCTAssertTrue(listener.called)
        XCTAssertEqual(listener.state, .offlineMessage)
    }

    func test_Process_FullUpdate() {
        let visitSessionStateListener = VisitSessionStateListenerMock()
        let departmentListChangeListener = DepartmentListChangeListenerMock()
        let surveyListener = SurveyListenerMock()
        let chatStateListener = ChatStateListenerMock()
        let locationSettingsChangeListener = LocationSettingsChangeListenerMock()
        let helloMessageListener = HelloMessageListenerMock()
        let fullUpdate = FullUpdate(jsonDictionary: convertToDict(FullUpdateTests.defaultFullUpdateJson))

        messageStream.set(visitSessionStateListener: visitSessionStateListener)
        messageStream.set(departmentListChangeListener: departmentListChangeListener)
        messageStream.set(surveyListener: surveyListener)
        messageStream.set(chatStateListener: chatStateListener)
        messageStream.set(locationSettingsChangeListener: locationSettingsChangeListener)
        messageStream.set(helloMessageListener: helloMessageListener)

        deltaCallback?.process(fullUpdate: fullUpdate)

        XCTAssertTrue(visitSessionStateListener.called)
        XCTAssertEqual(visitSessionStateListener.state, .chat)

        XCTAssertTrue(departmentListChangeListener.received)
        XCTAssertEqual(departmentListChangeListener.departmentList.count, 2)

        XCTAssertTrue(chatStateListener.chatStateChanged)
        XCTAssertEqual(chatStateListener.newChatState, .closedByOperator)

        XCTAssertTrue(surveyListener.onSurveyCalled)

        XCTAssertFalse(locationSettingsChangeListener.called)

        XCTAssertFalse(helloMessageListener.helloMessageCalled)
    }
}

class MessageMapperForTests: MessageMapper {

    override func map(message: MessageItem) -> MessageImpl? {
        return MessageImpl(serverURLString: "Some",
                                  id: "Some",
                                  serverSideID: nil,
                                  keyboard: nil,
                                  keyboardRequest: nil,
                                  operatorID: nil,
                                  quote: nil,
                                  senderAvatarURLString: "Some",
                                  senderName: "Some",
                                  sendStatus: .sent,
                                  sticker: nil,
                                  type: .visitorMessage,
                                  rawData: nil,
                                  data: nil,
                                  text: "Some",
                                  timeInMicrosecond: 12,
                                  historyMessage: false,
                                  internalID: nil,
                                  rawText: nil,
                                  read: false,
                                  messageCanBeEdited: false,
                                  messageCanBeReplied: false,
                                  messageIsEdited: false,
                                  visitorReactionInfo: nil,
                                  visitorCanReact: nil,
                                  visitorChangeReaction: nil)
    }
}

fileprivate func getChatItem(state: ChatItem.ChatItemState = .chatting) -> String {
     """
{
"readByVisitor" : true,
"category" : null,
"subject" : null,
"operatorTyping" : false,
"clientSideId" : "95f308d22be1a388c66e875fd71e466c",
"state" : "\(state.rawValue)",
"needToBeClosed" : false,
"visitorTyping" : null,
"messages" : [
    {
        "avatar" : null,
        "authorId" : null,
        "ts" : 1518713140.778348,
        "sessionId" : "72b6946234214a24b8d067a406ffcd53",
        "id" : "72b6946234214a24b8d067a406ffcd53_2",
        "text" : "Текст",
        "kind" : "info",
        "name" : ""
    }
],
"offline" : false,
"unreadByVisitorMsgCnt" : 5,
"visitorMessageDraft" : null,
"id" : 2530,
"unreadByVisitorSinceTs" : 1518713140.778348,
"operatorIdToRate" : { },
"creationTs" : 1518713140.777204,
"subcategory" : null,
"requestedForm" : null,
"unreadByOperatorSinceTs" : 1518713140.77720,
"operator" : {
    "avatar" : "/webim/images/avatar/demo_33201.png",
    "fullname" : "Administrator",
    "id" : 33201,
    "robotType" : null,
    "departmentKeys" : [
        "telegram",
        "test3",
        "test2"
    ],
    "langToFullname" : { },
    "sip" : "10002715000033201"
}
}
"""
}

fileprivate func buildDeltaItem(
    id: String = "Some value",
    data: Any = "Some value",
    event: DeltaItem.Event = .update,
    objectType: DeltaItem.DeltaType) -> DeltaItem? {

        let deltaItemString = """
        {
          "id" : "\(id)",
          "data" : \(data),
          "event" : "\(event.rawValue)",
          "objectType" : "\(objectType.rawValue)"
        }
    """

        return DeltaItem(jsonDictionary: convertToDict(deltaItemString))
}

fileprivate func convertToDict(_ json: String) -> [String: Any?] {
    return try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any?]
}
