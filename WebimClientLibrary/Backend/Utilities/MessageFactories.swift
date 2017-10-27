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


protocol MessageFactoriesMapper {
    
    func map(message: MessageItem) throws -> MessageImpl?
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl]
    
}

// MARK: -
class AbstractMapper: MessageFactoriesMapper {
    
    // MARK: - Constants
    private enum MapError: Error {
        case INVALID_MESSAGE_TYPE(String)
    }
    
    
    // MARK: - Properties
    private let serverURLString: String
    
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    
    // MARK: - Methods
    
    func convert(messageItem: MessageItem,
                 historyMessage: Bool) throws -> MessageImpl? {
        let kind = messageItem.getKind()
        if (kind == nil)
            || (kind == .CONTACT_REQUEST)
            || (kind == .CONTACTS)
            || (kind == .FOR_OPERATOR) {
            return nil
        }
        
        var attachment: MessageAttachment? = nil
        var text: String? = nil
        var rawText: String? = nil
        
        let messageItemText = messageItem.getText()
        if (kind == .FILE_FROM_VISITOR) || (kind == .FILE_FROM_OPERATOR) {
            attachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURLString,
                                                             text: messageItemText!)
            if attachment == nil {
                return nil
            }
            
            text = attachment?.getFileName()
            rawText = messageItemText!
        } else {
            text = (messageItemText == nil) ? "" : messageItemText!
        }
        
        return MessageImpl(withServerURLString: serverURLString,
                           id: messageItem.getClientSideID()!,
                           operatorID: messageItem.getSenderId(),
                           senderAvatarURLString: messageItem.getSenderAvatarURLString(),
                           senderName: messageItem.getSenderName()!,
                           type: try convert(messageKind: kind!),
                           data: messageItem.getData(),
                           text: text!,
                           timeInMicrosecond: messageItem.getTimeInMicrosecond()!,
                           attachment: attachment,
                           historyMessage: historyMessage,
                           internalID: messageItem.getID(),
                           rawText: rawText)
    }
    
    
    // MARK: MessageFactoriesMapper protocol methods
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl] {
        var mappedList = [MessageImpl]()
        
        for message in messages {
            if let mappedMessage = try? map(message: message) {
                if let mappedMessage = mappedMessage {
                    mappedList.append(mappedMessage)
                }
            }
        }
        
        return mappedList
    }
    
    func map(message: MessageItem) throws -> MessageImpl? {
        preconditionFailure("This method must be overridden!")
    }
    
    
    // MARK: Private methods
    private func convert(messageKind: MessageItem.MessageKind) throws -> MessageType {
        switch messageKind {
        case MessageItem.MessageKind.ACTION_REQUEST:
            return MessageType.ACTION_REQUEST
        case MessageItem.MessageKind.FILE_FROM_OPERATOR:
            return MessageType.FILE_FROM_OPERATOR
        case MessageItem.MessageKind.FILE_FROM_VISITOR:
            return MessageType.FILE_FROM_VISITOR
        case MessageItem.MessageKind.INFO:
            return MessageType.INFO
        case MessageItem.MessageKind.OPERATOR:
            return MessageType.OPERATOR
        case MessageItem.MessageKind.OPERATOR_BUSY:
            return MessageType.OPERATOR_BUSY
        case MessageItem.MessageKind.VISITOR:
            return MessageType.VISITOR
        default:
            throw MapError.INVALID_MESSAGE_TYPE("Invalid message type received: \(messageKind.rawValue)")
        }
    }
    
}

// MARK: -
final class CurrentChatMapper: AbstractMapper {
    
    
    // MARK: - Initialization
    override init(withServerURLString serverURLString: String) {
        super.init(withServerURLString: serverURLString)
    }
    
    // MARK: - Methods
    override func map(message: MessageItem) throws -> MessageImpl? {
        return try convert(messageItem: message,
                           historyMessage: false)
    }
    
}

// MARK: -
final class HistoryMapper: AbstractMapper {
    
    // MARK: - Initialization
    override init(withServerURLString serverURLString: String) {
        super.init(withServerURLString: serverURLString)
    }
    
    // MARK: - Methods
    override func map(message: MessageItem) throws -> MessageImpl? {
        return try convert(messageItem: message,
                           historyMessage: true)
    }
    
}


// MARK: -
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
        return MessageToSend(withServerURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: MessageType.VISITOR,
                             text: text,
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
    func createFileMessageToSendWith(id: String) -> MessageToSend {
        return MessageToSend(withServerURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: MessageType.FILE_FROM_VISITOR,
                             text: "",
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
}

// MARK: -
final class OperatorFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    func createOperatorFrom(operatorItem: OperatorItem?) -> OperatorImpl? {
        return (operatorItem == nil) ? nil : OperatorImpl(withID: operatorItem!.getID(),
                                                          name: operatorItem!.getFullName(),
                                                          avatarURLString: (operatorItem!.getAvatarURLString() == nil) ? nil : (serverURLString + operatorItem!.getAvatarURLString()!))
    }

}
