//
//  MessageImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
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


class MessageImpl: Message {
    
    // MARK: - Properties
    private let attachment: MessageAttachment?
    private let serverURLString: String
    fileprivate let id: String
    fileprivate let operatorID: String?
    fileprivate let rawText: String?
    fileprivate let senderAvatarURLString: String?
    fileprivate let senderName: String
    fileprivate let text: String
    fileprivate let timeInMicrosecond: Int64
    fileprivate let type: MessageType
    private var currentChatID: String?
    private var data: [String : Any?]?
    private var historyID: HistoryID?
    private var historyMessage: Bool
    
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String,
         id: String,
         operatorID: String?,
         senderAvatarURLString: String?,
         senderName: String,
         type: MessageType,
         data: [String : Any?]?,
         text: String,
         timeInMicrosecond: Int64,
         attachment: MessageAttachment?,
         historyMessage: Bool,
         internalID: String?,
         rawText: String?) {
        self.attachment = attachment
        self.data = data
        self.id = id
        self.operatorID = operatorID
        self.rawText = rawText
        self.senderAvatarURLString = senderAvatarURLString
        self.senderName = senderName
        self.serverURLString = serverURLString
        self.text = text
        self.timeInMicrosecond = timeInMicrosecond
        self.type = type
        
        self.historyMessage = historyMessage
        if historyMessage {
            historyID = HistoryID(withDBid: internalID!,
                                  timeInMicrosecond: timeInMicrosecond)
        } else {
            currentChatID = internalID
        }
    }
    
    
    // MARK: - Methods
    
    func getRawText() -> String? {
        return rawText
    }
    
    func getSenderAvatarURLString() -> String? {
        return senderAvatarURLString
    }
    
    func hasHistoryComponent() -> Bool {
        return (historyID != nil)
    }
    
    func getHistoryID() -> HistoryID? {
        guard historyID != nil else {
            print("Message \(self.toString()) do not have history component.")
            
            return nil
        }
        
        return historyID!
    }
    
    func getCurrentChatID() -> String? {
        guard currentChatID != nil else {
            print("Message \(self.toString()) do not have an ID in current chat or do not exist in current chat or chat exists itself not.")
            
            return nil
        }
        
        return currentChatID
    }
    
    func getSource() -> MessageSource {
        return historyMessage ? MessageSource.HISTORY : MessageSource.CURRENT_CHAT
    }
    
    func transferToCurrentChat(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryHistory(historyEquivalentMessage: self)
            
            return message
        }
        
        setSecondaryCurrentChat(currentChatEquivalentMessage: message)
        
        invertHistoryStatus()
        
        return self
    }
    
    func transferToHistory(message: MessageImpl) -> MessageImpl {
        if self != message {
            message.setSecondaryCurrentChat(currentChatEquivalentMessage: self)
            
            return message
        }
        
        setSecondaryHistory(historyEquivalentMessage: message)
        
        invertHistoryStatus()
        
        return self
    }
    
    func invertHistoryStatus() {
        guard (historyID != nil)
            && (currentChatID != nil) else {
                print("Message \(self.toString()) has not history component or does not belong to current chat.")
                
                return
        }
        
        historyMessage = !historyMessage
    }
    
    func setSecondaryHistory(historyEquivalentMessage: MessageImpl) {
        guard (!getSource().isHistoryMessage())
            && (historyEquivalentMessage.getSource().isHistoryMessage()) else {
                print("Message \(self.toString()) is already has history component.")
                
                return
        }
        
        historyID = historyEquivalentMessage.getHistoryID()
    }
    
    func setSecondaryCurrentChat(currentChatEquivalentMessage: MessageImpl) {
        guard getSource().isHistoryMessage()
            && !currentChatEquivalentMessage.getSource().isHistoryMessage() else {
                print("Current chat equivalent of the message \(self.toString()) is already has history component.")
                
                return
        }
        
        currentChatID = currentChatEquivalentMessage.getCurrentChatID()
    }
    
    func toString() -> String {
        return "MessageImpl { \n" +
            "serverURLString = \(serverURLString),\n" +
            "ID = \(id),\n" +
            "operatorID = \((operatorID != nil) ? operatorID! : "nil"),\n" +
            "senderAvatarURLString = \((senderAvatarURLString != nil) ? senderAvatarURLString! : "nil"),\n" +
            "senderName = \(senderName),\n" +
            "type = \(type),\n" +
            "text = \(text),\n" +
            "timeInMicrosecond = \(timeInMicrosecond),\n" +
            "attachment = \((attachment != nil) ? (attachment!.getURLString() != nil ? attachment!.getURLString()! : "nil") : "nil"),\n" +
            "historyMessage = \(historyMessage),\n" +
            "currentChatID = \((currentChatID != nil) ? currentChatID! : "nil"),\n" +
            "historyID = \((historyID != nil) ? historyID!.getDBid() : "nil"),\n" +
            "rawText = \((rawText != nil) ? rawText! : "nil")\n" +
        "}"
    }
    
    
    // MARK: Message protocol methods
    
    func getAttachment() -> MessageAttachment? {
        return attachment
    }
    
    func getData() -> [String : Any?]? {
        return data
    }
    
    func getID() -> String {
        return id
    }
    
    func getOperatorID() -> String? {
        return operatorID
    }
    
    func getSenderAvatarFullURLString() -> String? {
        return (senderAvatarURLString == nil) ? nil : (serverURLString + senderAvatarURLString!)
    }
    
    func getSendStatus() -> MessageSendStatus {
        return MessageSendStatus.SENT
    }
    
    func getSenderName() -> String {
        return senderName
    }
    
    func getText() -> String {
        return text
    }
    
    func getTime() -> Int64 {
        return timeInMicrosecond / 1000
    }
    
    func getType() -> MessageType {
        return type
    }
    
    
    // MARK: -
    enum MessageSource {
        
        case HISTORY
        case CURRENT_CHAT
        
        
        // MARK: - Methods
        
        func assertIsCurrentChat() throws {
            guard isCurrentChatMessage() else {
                throw MessageError.invalidState("Current message is not a part of current chat.")
            }
        }
        
        func assertIsHistory() throws {
            guard isHistoryMessage() else {
                throw MessageError.invalidState("Current message is not a part of the history.")
            }
        }
        
        func isHistoryMessage() -> Bool {
            return self == .HISTORY
        }
        
        func isCurrentChatMessage() -> Bool {
            return self == .CURRENT_CHAT
        }
        
    }
    
    // MARK: -
    enum MessageError: Error {
        case invalidState(String)
    }
    
}

// MARK: - MicrosecondsTimeHolder
extension MessageImpl: MicrosecondsTimeHolder {
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
}

// MARK: - Equatable
extension MessageImpl: Equatable {
    
    static func == (lhs: MessageImpl,
                    rhs: MessageImpl) -> Bool {
        return (((((((lhs.id == rhs.id)
            && (lhs.operatorID == rhs.operatorID))
            && (lhs.rawText == rhs.rawText))
            && (lhs.senderAvatarURLString == rhs.senderAvatarURLString))
            && (lhs.senderName == rhs.senderName))
            && (lhs.text == rhs.text))
            && (lhs.timeInMicrosecond == rhs.timeInMicrosecond))
            && (lhs.type == rhs.type)
    }
    
}


// MARK: -
final class MessageAttachmentImpl: MessageAttachment {
    
    // MARK: - Properties
    private let urlString: String?
    private let size: Int64?
    private let filename: String?
    private let contentType: String?
    private let imageInfo: ImageInfo?
    
    
    // MARK: - Initialization
    init(withURLString urlString: String?,
         size: Int64?,
         filename: String?,
         contentType: String?,
         imageInfo: ImageInfo? = nil) {
        self.urlString = urlString
        self.size = size
        self.filename = filename
        self.contentType = contentType
        self.imageInfo = imageInfo
    }
    
    
    // MARK: - Methods
    static func getAttachment(byServerURL serverURLString: String,
                              text: String) -> MessageAttachment? {
        let textData = text.data(using: .utf8)
        guard let textDictionary = try? JSONSerialization.jsonObject(with: textData!,
                                                                     options: []) as? [String : Any?] else {
                                                                        print("Message attachment parameters parsing failed.")
                                                                        return nil
        }
        
        let fileParameters = FileParametersItem(withJSONDictionary: textDictionary!)
        guard let filename = fileParameters.getFilename() else {
            return nil
        }
        guard let guid = fileParameters.getGUID() else {
            return nil
        }
        guard let contentType = fileParameters.getContentType() else {
            return nil
        }
        let fileURLString = serverURLString +
            WebimActions.ServerPathSuffix.DOWNLOAD_FILE.rawValue +
            "/" +
            guid +
            "/" +
            filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        return MessageAttachmentImpl(withURLString: fileURLString,
                                     size: fileParameters.getSize(),
                                     filename: filename,
                                     contentType: contentType,
                                     imageInfo: extractImageInfoOf(fileParameters: fileParameters,
                                                                   with: fileURLString))
    }
    
    
    // MARK: MessageAttachment protocol methods
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getFileName() -> String? {
        return filename
    }
    
    func getImageInfo() -> ImageInfo? {
        return imageInfo
    }
    
    func getSize() -> Int64? {
        return size
    }
    
    func getURLString() -> String? {
        return urlString
    }
    
    
    // MARK: Private methods
    private static func extractImageInfoOf(fileParameters: FileParametersItem?,
                                           with fileURLString: String?) -> ImageInfo? {
        guard (fileParameters != nil)
            && (fileURLString != nil) else {
            return nil
        }
        
        let imageSize = (fileParameters?.getImageParameters() == nil) ? nil : fileParameters?.getImageParameters()?.getSize()
        guard imageSize != nil else {
            return nil
        }
        
        let thumbURLString = (fileURLString == nil) ? nil : (fileURLString! + "?thumb=ios")
        guard thumbURLString != nil else {
            return nil
        }
        
        return ImageInfoImpl(withThumbURLString: thumbURLString!,
                             width: imageSize?.getWidth(),
                             height: imageSize?.getHeight())
    }
    
}


// MARK: -
final class ImageInfoImpl: ImageInfo {
    
    // MARK: - Properties
    private let thumbURLString: String
    private let width: Int?
    private let height: Int?
    
    
    // MARK: - Initialization
    init(withThumbURLString thumbURLString: String,
         width: Int?,
         height: Int?) {
        self.thumbURLString = thumbURLString
        self.width = width
        self.height = height
    }
    
    
    // MARK: - ImageInfo protocol methods
    
    func getThumbURLString() -> String {
        return thumbURLString
    }
    
    func getHeight() -> Int? {
        return height
    }
    
    func getWidth() -> Int? {
        return width
    }
    
}
