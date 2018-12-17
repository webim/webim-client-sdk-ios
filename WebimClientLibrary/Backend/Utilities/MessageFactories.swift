//
//  MessageFactories.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 10.08.17.
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

import Foundation

// MARK: -
/**
 Abstract class that supposed to be parent of mapper classes that are responsible for converting internal message model objects to public one.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class MessageMapper {
    
    // MARK: - Constants
    private enum MapError: Error {
        case invalidMessageType(String)
    }
    
    // MARK: - Properties
    private let serverURLString: String
    private weak var webimClient: WebimClient?
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    
    static func convert(messageKind: MessageItem.MessageKind) -> MessageType? {
        switch messageKind {
        case .actionRequest:
            return .ACTION_REQUEST
        case .contactInformationRequest:
            return .CONTACTS_REQUEST
        case .fileFromOperator:
            return .FILE_FROM_OPERATOR
        case .fileFromVisitor:
            return .FILE_FROM_VISITOR
        case .info:
            return .INFO
        case .operatorMessage:
            return .OPERATOR
        case .operatorBusy:
            return .OPERATOR_BUSY
        case .visitorMessage:
            return .VISITOR
        default:
            WebimInternalLogger.shared.log(entry: "Invalid message type received: \(messageKind.rawValue)",
                verbosityLevel: .WARNING)
            
            return nil
        }
    }
    
    func convert(messageItem: MessageItem,
                 historyMessage: Bool) -> MessageImpl? {
        let kind = messageItem.getKind()
        if (kind == nil)
            || (kind == .contactInformation)
            || (kind == .forOperator) {
            return nil
        }
        let type = MessageMapper.convert(messageKind: kind!)
        if type == nil {
            return nil
        }
        
        var attachment: MessageAttachment? = nil
        var text: String? = nil
        var rawText: String? = nil
        
        let messageItemText = messageItem.getText()
        if (kind == .fileFromVisitor)
            || (kind == .fileFromOperator) {
            attachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURLString,
                                                             webimClient: webimClient!,
                                                             text: messageItemText!)
            if attachment == nil {
                return nil
            }
            
            text = attachment?.getFileName()
            rawText = messageItemText!
        } else {
            text = messageItemText ?? ""
        }
        
        return MessageImpl(serverURLString: serverURLString,
                           id: messageItem.getClientSideID()!,
                           operatorID: messageItem.getSenderID(),
                           senderAvatarURLString: messageItem.getSenderAvatarURLString(),
                           senderName: messageItem.getSenderName()!,
                           type: type!,
                           data: messageItem.getData(),
                           text: text!,
                           timeInMicrosecond: messageItem.getTimeInMicrosecond()!,
                           attachment: attachment,
                           historyMessage: historyMessage,
                           internalID: messageItem.getID(),
                           rawText: rawText,
                           read: messageItem.getRead() ?? true,
                           messageCanBeEdited: messageItem.getCanBeEdited())
    }
    
    func set(webimClient: WebimClient) {
        self.webimClient = webimClient
    }
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl] {
        return messages.map { map(message: $0) }.compactMap { $0 }
    }
    
    func map(message: MessageItem) -> MessageImpl? {
        preconditionFailure("This method must be overridden!")
    }
    
}

// MARK: -
/**
 Concrete mapper class that is responsible for converting internal message model objects to public message model objects of current chat.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class CurrentChatMessageMapper: MessageMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: false)
    }
    
}

// MARK: -
/**
 Concrete mapper class that is responsible for converting internal message model objects to public message model objects of previous chats.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class HistoryMessageMapper: MessageMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: true)
    }
    
}

// MARK: -
/**
 Class that responsible for creating child class objects for public message model objects of messages that are to be sent by visitor.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class SendingFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    
    // MARK: - Methods
    
    func createTextMessageToSendWith(id: String,
                                     text: String) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: .VISITOR,
                             text: text,
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
    func createFileMessageToSendWith(id: String) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: .FILE_FROM_VISITOR,
                             text: "",
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
}
