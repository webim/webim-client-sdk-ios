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
    private weak var fileUrlCreator: FileUrlCreator?
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    
    static func convert(messageKind: MessageItem.MessageKind) -> MessageType? {
        switch messageKind {
        case .actionRequest:
            return .actionRequest
        case .contactInformationRequest:
            return .contactInformationRequest
        case .fileFromOperator:
            return .fileFromOperator
        case .fileFromVisitor:
            return .fileFromVisitor
        case .info:
            return .info
        case .keyboard:
            return .keyboard
        case .keyboardResponse:
            return .keyboardResponse
        case .operatorMessage:
            return .operatorMessage
        case .operatorBusy:
            return .operatorBusy
        case .visitorMessage:
            return .visitorMessage
        default:
            WebimInternalLogger.shared.log(entry: "Invalid message type received: \(messageKind.rawValue)",
                verbosityLevel: .warning)
            
            return nil
        }
    }
    
    func convert(messageItem: MessageItem,
                 historyMessage: Bool) -> MessageImpl? {
        guard let kind = messageItem.getKind() else {
            return nil
        }
        if kind == .contactInformation || kind == .forOperator {
            return nil
        }
        guard let type = MessageMapper.convert(messageKind: kind) else {
            return nil
        }
        
        var attachment: FileInfoImpl?
        var attachments: [FileInfoImpl]
        var keyboard: Keyboard?
        var keyboardRequest: KeyboardRequest?
        var text: String?
        var rawText: String?
        var data: MessageData?
        var sticker: Sticker?
        
        guard let messageItemText = messageItem.getText() else {
            WebimInternalLogger.shared.log(entry: "Message Item Text is nil in MessageFactories.\(#function)")
            return nil
        }
        if (kind == .fileFromVisitor)
            || (kind == .fileFromOperator) {
            
            if let fileUrlCreator = fileUrlCreator {
                attachments = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator,
                                                          text: messageItemText)
                if attachments.isEmpty {
                    attachment = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator,
                                                            text: messageItemText)
                    if let attachment = attachment {
                        attachments.append(attachment)
                    }
                } else {
                    attachment = attachments.first
                }
                if let attachment = attachment {
                    data = MessageDataImpl(
                        attachment: MessageAttachmentImpl(fileInfo: attachment,
                                                          filesInfo: attachments,
                                                          state: .ready)
                    )
                } else {
                    if let rawData = messageItem.getRawData(),
                       let file = MessageDataItem(jsonDictionary: rawData).getFile() {
                        let fileInfoImpl = FileInfoImpl(urlString: nil,
                                                        size: file.getProperties()?.getSize() ?? 0,
                                                        filename: file.getProperties()?.getFilename() ?? "",
                                                        contentType: file.getProperties()?.getContentType() ?? "",
                                                        guid: file.getProperties()?.getGUID() ?? "",
                                                        fileUrlCreator: nil)
                        attachment = fileInfoImpl
                        attachments.append(fileInfoImpl)
                        data = MessageDataImpl(
                            attachment: MessageAttachmentImpl(fileInfo: fileInfoImpl,
                                                              filesInfo: attachments,
                                                              state: .upload))
                    }
                }
            }
            guard let attachment = attachment else {
                return nil
            }
            
            text = attachment.getFileName()
            rawText = messageItemText
        } else {
            text = messageItemText
        }
        
        if kind == .keyboard, let data = messageItem.getRawData() {
            keyboard = KeyboardImpl.getKeyboard(jsonDictionary: data)
        }
        
        if kind == .keyboardResponse, let data = messageItem.getRawData() {
            keyboardRequest = KeyboardRequestImpl.getKeyboardRequest(jsonDictionary: data)
        }
        
        if kind == .stickerVisitor, let data = messageItem.getRawData() {
            sticker = StickerImpl.getSticker(jsonDictionary: data)
        }
        
        let quote = messageItem.getQuote()
        var messageAttachmentFromQuote: FileInfo? = nil
        if let kind = quote?.getMessageKind(), kind == .fileFromVisitor || kind == .fileFromOperator {
            if let fileUrlCreator = fileUrlCreator {
                guard let quoteText = quote?.getText() else {
                    WebimInternalLogger.shared.log(entry: "Quote Text is nil in MessageFactories.\(#function)")
                    return nil
                }
                messageAttachmentFromQuote = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator,
                                                                        text: quoteText)
                if messageAttachmentFromQuote == nil {
                    let attachments = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator,
                                                                  text: quoteText)
                    if !attachments.isEmpty {
                        messageAttachmentFromQuote = attachments[0]
                    }
                }
            }
        }
        
        
        guard let clientSideID = messageItem.getClientSideID() else {
            WebimInternalLogger.shared.log(entry: "Message Item has not Client Side ID in MessageFactories.\(#function)")
            return nil
        }
        guard let senderName = messageItem.getSenderName() else {
            WebimInternalLogger.shared.log(entry: "Message Item has not Sender Name in MessageFactories.\(#function)")
            return nil
        }
        guard let messageText = text else {
            WebimInternalLogger.shared.log(entry: "Message has not Text in MessageFactories.\(#function)")
            return nil
        }
        guard let timeInMicrosecond = messageItem.getTimeInMicrosecond() else {
            WebimInternalLogger.shared.log(entry: "Message Item has not Time In Microsecond in MessageFactories.\(#function)")
            return nil
        }
        
        return MessageImpl(serverURLString: serverURLString,
                           id: clientSideID,
                           keyboard: keyboard,
                           keyboardRequest: keyboardRequest,
                           operatorID: messageItem.getSenderID(),
                           quote: QuoteImpl.getQuote(quoteItem: quote, messageAttachment: messageAttachmentFromQuote),
                           senderAvatarURLString: messageItem.getSenderAvatarURLString(),
                           senderName: senderName,
                           sticker: sticker,
                           type: type,
                           rawData: messageItem.getRawData(),
                           data: data,
                           text: messageText,
                           timeInMicrosecond: timeInMicrosecond,
                           historyMessage: historyMessage,
                           internalID: messageItem.getID(),
                           rawText: rawText,
                           read: messageItem.getRead() ?? true,
                           messageCanBeEdited: messageItem.getCanBeEdited(),
                           messageCanBeReplied: messageItem.getCanBeReplied(),
                           messageIsEdited: messageItem.getIsEdited())
    }
    
    func set(fileUrlCreator: FileUrlCreator) {
        self.fileUrlCreator = fileUrlCreator
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
                             type: .visitorMessage,
                             text: text,
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond())
    }
    
    func createTextMessageToSendWithQuoteWith(id: String,
                                              text: String,
                                              repliedMessage: Message) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: .visitorMessage,
                             text: text,
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond(),
                             quote: QuoteImpl(state: QuoteState.pending,
                                              authorID: nil,
                                              messageAttachment: repliedMessage.getData()?.getAttachment()?.getFileInfo(),
                                              messageID: repliedMessage.getCurrentChatID(),
                                              messageType: repliedMessage.getType(),
                                              senderName: repliedMessage.getSenderName(),
                                              text: repliedMessage.getText(),
                                              timestamp: Int64(repliedMessage.getTime().timeIntervalSince1970 * 1000)))
    }

    
    func createFileMessageToSendWith(id: String) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: .fileFromVisitor,
                             text: "",
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond())
    }
    
    func createStickerMessageToSendWith(id: String, stickerId: Int) -> MessageToSend {
        return MessageToSend(serverURLString: serverURLString,
                             id: id,
                             senderName: "",
                             type: .stickerVisitor,
                             text: "",
                             timeInMicrosecond: InternalUtils.getCurrentTimeInMicrosecond(),
                             sticker: StickerImpl(stickerId: stickerId))
    }
    
}
