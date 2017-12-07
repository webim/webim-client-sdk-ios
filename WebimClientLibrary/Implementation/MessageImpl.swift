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


/**
 Internal messages representasion.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class MessageImpl {
    
    // MARK: - Properties
    private let attachment: MessageAttachment?
    private let id: String
    private let operatorID: String?
    private let rawText: String?
    private let senderAvatarURLString: String?
    private let senderName: String
    private let serverURLString: String
    private let text: String
    private let timeInMicrosecond: Int64
    private let type: MessageType
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
            historyID = HistoryID(dbID: internalID!,
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
        
        return historyID
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
        guard historyID != nil,
            currentChatID != nil else {
                print("Message \(self.toString()) has not history component or does not belong to current chat.")
                
                return
        }
        
        historyMessage = !historyMessage
    }
    
    func setSecondaryHistory(historyEquivalentMessage: MessageImpl) {
        guard !getSource().isHistoryMessage(),
            historyEquivalentMessage.getSource().isHistoryMessage() else {
                print("Message \(self.toString()) is already has history component.")
                
                return
        }
        
        historyID = historyEquivalentMessage.getHistoryID()
    }
    
    func setSecondaryCurrentChat(currentChatEquivalentMessage: MessageImpl) {
        guard getSource().isHistoryMessage(),
            !currentChatEquivalentMessage.getSource().isHistoryMessage() else {
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

// MARK: - Message
extension MessageImpl: Message {
    
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
    
    func getSenderAvatarFullURL() -> URL? {
        guard let senderAvatarURLString = senderAvatarURLString else {
            return nil
        }
        
        let fullSenderAvatarURLString = serverURLString + senderAvatarURLString
        
        return URL(string: fullSenderAvatarURLString)
    }
    
    func getSendStatus() -> MessageSendStatus {
        return .SENT
    }
    
    func getSenderName() -> String {
        return senderName
    }
    
    func getText() -> String {
        return text
    }
    
    func getTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timeInMicrosecond / 1000000))
    }
    
    func getType() -> MessageType {
        return type
    }
    
    func isEqual(to message: Message) -> Bool {
        return self == message as! MessageImpl
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
/**
 Internal messages' attachments representation.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class MessageAttachmentImpl {
    
    // MARK: - Constants
    private enum Period: Int64 {
        case ATTACHMENT_URL_EXPIRES_PERIOD = 300 // (seconds) = 5 (minutes).
    }
    
    
    // MARK: - Properties
    private let urlString: String?
    private let size: Int64?
    private let filename: String?
    private let contentType: String?
    private let imageInfo: ImageInfo?
    
    
    // MARK: - Initialization
    init(urlString: String?,
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
                              webimClient: WebimClient,
                              text: String) -> MessageAttachment? {
        let textData = text.data(using: .utf8)
        guard let textDictionary = try? JSONSerialization.jsonObject(with: textData!,
                                                                     options: []) as? [String : Any?] else {
                                                                        print("Message attachment parameters parsing failed.")
                                                                        
                                                                        return nil
        }
        
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary!)
        guard let filename = fileParameters.getFilename(),
            let guid = fileParameters.getGUID(),
            let contentType = fileParameters.getContentType() else {
            return nil
        }
        
        guard let pageID = webimClient.getDeltaRequestLoop().getAuthorizationData()?.getPageID(),
            let authorizationToken = webimClient.getDeltaRequestLoop().getAuthorizationData()?.getAuthorizationToken() else {
            print("Tried to access to message attachment without authorization data.")
            
            return nil
        }
        
        let expires = Int64(Date().timeIntervalSince1970) + Period.ATTACHMENT_URL_EXPIRES_PERIOD.rawValue
        let data: String = guid + String(expires)
        if let hash = data.hmacSHA256(withKey: authorizationToken) {
            let fileURLString = serverURLString + WebimActions.ServerPathSuffix.DOWNLOAD_FILE.rawValue + "/"
                + guid + "/"
                + filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "?"
                + "page-id" + "=" + pageID + "&"
                + "expires" + "=" + String(expires) + "&"
                + "hash" + "=" + hash
            
            return MessageAttachmentImpl(urlString: fileURLString,
                                         size: fileParameters.getSize(),
                                         filename: filename,
                                         contentType: contentType,
                                         imageInfo: extractImageInfoOf(fileParameters: fileParameters,
                                                                       with: fileURLString))
        } else {
            print("Error creating message attachment link due to HMAC SHA256 encoding error.")
            
            return nil
        }
    }
    
    
    // MARK: Private methods
    private static func extractImageInfoOf(fileParameters: FileParametersItem?,
                                           with fileURLString: String?) -> ImageInfo? {
        guard fileParameters != nil,
            fileURLString != nil else {
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
                             width: imageSize!.getWidth(),
                             height: imageSize!.getHeight())
    }
    
}

// MARK: - MessageAttachment
extension MessageAttachmentImpl: MessageAttachment {
    
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
    
}


// MARK: -
/**
 Internal image information representation.
 - SeeAlso:
 `MessageAttachment`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
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
    
    
    // MARK: - Methods
    // MARK: ImageInfo protocol methods
    
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
