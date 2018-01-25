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


/**
 Protocol which is implemented by several mappers classes.
 - SeeAlso:
 `MessageItem`
 `Message`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
protocol MessageFactoriesMapper {
    
    func set(webimClient: WebimClient)
    
    func map(message: MessageItem) -> MessageImpl?
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl]
    
}


// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class AbstractMapper: MessageFactoriesMapper {
    
    // MARK: - Constants
    private enum MapError: Error {
        case INVALID_MESSAGE_TYPE(String)
    }
    
    
    // MARK: - Properties
    private let serverURLString: String
    private var webimClient: WebimClient?
    
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    
    // MARK: - Methods
    
    static func convert(messageKind: MessageItem.MessageKind) -> MessageType? {
        switch messageKind {
        case .ACTION_REQUEST:
            return .ACTION_REQUEST
        case .CONTACTS_REQUEST:
            return .CONTACTS_REQUEST
        case .FILE_FROM_OPERATOR:
            return .FILE_FROM_OPERATOR
        case .FILE_FROM_VISITOR:
            return .FILE_FROM_VISITOR
        case .INFO:
            return .INFO
        case .OPERATOR:
            return .OPERATOR
        case .OPERATOR_BUSY:
            return .OPERATOR_BUSY
        case .VISITOR:
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
            || (kind == .CONTACTS)
            || (kind == .FOR_OPERATOR) {
            return nil
        }
        let type = AbstractMapper.convert(messageKind: kind!)
        if type == nil {
            return nil
        }
        
        var attachment: MessageAttachment? = nil
        var text: String? = nil
        var rawText: String? = nil
        
        let messageItemText = messageItem.getText()
        if (kind == .FILE_FROM_VISITOR)
            || (kind == .FILE_FROM_OPERATOR) {
            attachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURLString,
                                                             webimClient: webimClient!,
                                                             text: messageItemText!)
            if attachment == nil {
                return nil
            }
            
            text = attachment?.getFileName()
            rawText = messageItemText!
        } else {
            text = ((messageItemText == nil) ? "" : messageItemText!)
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
                           rawText: rawText)
    }
    
    // MARK: MessageFactoriesMapper protocol methods
    
    func set(webimClient: WebimClient) {
        self.webimClient = webimClient
    }
    
    func mapAll(messages: [MessageItem]) -> [MessageImpl] {
        return messages.map { map(message: $0) }.flatMap { $0 }
    }
    
    func map(message: MessageItem) -> MessageImpl? {
        preconditionFailure("This method must be overridden!")
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class CurrentChatMapper: AbstractMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: false)
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class HistoryMapper: AbstractMapper {
    
    // MARK: - Methods
    override func map(message: MessageItem) -> MessageImpl? {
        return convert(messageItem: message,
                       historyMessage: true)
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
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
                             type: MessageType.VISITOR,
                             text: text,
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
    func createFileMessageToSendWith(id: String) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: MessageType.FILE_FROM_VISITOR,
                             text: "",
                             timeInMicrosecond: (InternalUtils.getCurrentTimeInMicrosecond() * 1000))
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class OperatorFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    func createOperatorFrom(operatorItem: OperatorItem?) -> OperatorImpl? {
        return (operatorItem == nil) ? nil : OperatorImpl(id: operatorItem!.getID(),
                                                          name: operatorItem!.getFullName(),
                                                          avatarURLString: (operatorItem!.getAvatarURLString() == nil) ? nil : (serverURLString + operatorItem!.getAvatarURLString()!))
    }

}
