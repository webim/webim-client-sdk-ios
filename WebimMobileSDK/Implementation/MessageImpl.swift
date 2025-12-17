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
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
class MessageImpl {
    
    // MARK: - Properties
    private let clientSideID: String
    private let serverSideID: String?
    private let keyboard: Keyboard?
    private let keyboardRequest: KeyboardRequest?
    private let operatorID: String?
    private let quote: Quote?
    private let rawText: String?
    private let senderAvatarURLString: String?
    private let senderName: String
    private let sendStatus: MessageSendStatus
    private let serverURLString: String
    private let sticker: Sticker?
    private let text: String
    private let timeInMicrosecond: Int64
    private let type: MessageType
    private var currentChatID: String?
    private var rawData: [String: Any?]?
    private var data: MessageData?
    private var historyID: HistoryID?
    private var historyMessage: Bool
    private var read: Bool
    private var messageCanBeEdited: Bool
    private var messageCanBeReplied: Bool
    private var messageIsEdited: Bool
    private var visitorReactionInfo: String?
    private var visitorCanReact: Bool?
    private var visitorChangeReaction: Bool?
    private var group: Group?
    private var deleted: Bool?
    
    // MARK: - Initialization
    init(serverURLString: String,
         clientSideID: String,
         serverSideID: String?,
         keyboard: Keyboard?,
         keyboardRequest: KeyboardRequest?,
         operatorID: String?,
         quote: Quote?,
         senderAvatarURLString: String?,
         senderName: String,
         sendStatus: MessageSendStatus = .sent,
         sticker: Sticker?,
         type: MessageType,
         rawData: [String: Any?]?,
         data: MessageData?,
         text: String,
         timeInMicrosecond: Int64,
         historyMessage: Bool,
         internalID: String?,
         rawText: String?,
         read: Bool,
         messageCanBeEdited: Bool,
         messageCanBeReplied: Bool,
         messageIsEdited: Bool,
         visitorReactionInfo: String?,
         visitorCanReact: Bool?,
         visitorChangeReaction: Bool?,
         group: Group?,
         deleted: Bool?) {
        self.data = data
        self.clientSideID = clientSideID
        self.serverSideID = serverSideID
        self.keyboard = keyboard
        self.keyboardRequest = keyboardRequest
        self.quote = quote
        self.operatorID = operatorID
        self.rawText = rawText
        self.rawData = rawData
        self.senderAvatarURLString = senderAvatarURLString
        self.senderName = senderName
        self.sendStatus = sendStatus
        self.sticker = sticker
        self.serverURLString = serverURLString
        self.text = text
        self.timeInMicrosecond = timeInMicrosecond
        self.type = type
        self.read = read
        self.messageCanBeEdited = messageCanBeEdited
        self.messageCanBeReplied = messageCanBeReplied
        self.messageIsEdited = messageIsEdited
        self.visitorReactionInfo = visitorReactionInfo
        self.visitorCanReact = visitorCanReact
        self.visitorChangeReaction = visitorChangeReaction
        self.group = group
        self.deleted = deleted
        self.historyMessage = historyMessage
        if historyMessage {
            guard let internalID = internalID else {
                WebimInternalLogger.shared.log(entry: "Message has not Internal ID in MessageImpl.\(#function)")
                fatalError("Message has not Internal ID in MessageImpl.\(#function)")
            }
            historyID = HistoryID(dbID: internalID,
                                  timeInMicrosecond: timeInMicrosecond)
        }
        currentChatID = internalID
    }
    
    func disableBotButtons() -> Bool {
        if self.type == .keyboard {
            if let keyboard = self.keyboard as? KeyboardImpl {
                if keyboard.getState() == .pending {
                    keyboard.keyboardItem.state = .canceled
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Methods
    func getRawText() -> String? {
        return rawText
    }
    
    func getSenderAvatarURLString() -> String? {
        return senderAvatarURLString
    }
    
    func getTimeInMicrosecond() -> Int64 {
        return timeInMicrosecond
    }
    
    func hasHistoryComponent() -> Bool {
        return (historyID != nil)
    }
    
    func getHistoryID() -> HistoryID? {
        guard let historyID = historyID else {
            WebimInternalLogger.shared.log(
                entry: "Message \(self.toString()) do not have history component.",
                verbosityLevel: .debug,
                logType: .messageHistory)
            
            return nil
        }
        
        return historyID
    }
    
    func getServerUrlString() -> String {
        return serverURLString
    }
    
    func getSource() -> MessageSource {
        return (historyMessage ? MessageSource.history : MessageSource.currentChat)
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
                WebimInternalLogger.shared.log(
                    entry: "Message \(self.toString()) has not history component or does not belong to current chat.",
                    verbosityLevel: .debug,
                    logType: .messageHistory)
                
                return
        }
        
        historyMessage = !historyMessage
    }
    
    func setSecondaryHistory(historyEquivalentMessage: MessageImpl) {
        guard !getSource().isHistoryMessage(),
            historyEquivalentMessage.getSource().isHistoryMessage() else {
                WebimInternalLogger.shared.log(
                    entry: "Message \(self.toString()) is already has history component.",
                    verbosityLevel: .debug,
                    logType: .messageHistory)
                
                return
        }
        
        historyID = historyEquivalentMessage.getHistoryID()
    }
    
    func setSecondaryCurrentChat(currentChatEquivalentMessage: MessageImpl) {
        guard getSource().isHistoryMessage(),
            !currentChatEquivalentMessage.getSource().isHistoryMessage() else {
                WebimInternalLogger.shared.log(entry: "Current chat equivalent of the message \(self.toString()) is already has history component.",
                    verbosityLevel: .debug)
                
                return
        }
        
        currentChatID = currentChatEquivalentMessage.getCurrentChatID()
    }
    
    func setRead(isRead: Bool) {
        read = isRead
    }
    
    func getRead() -> Bool {
        return read
    }
    
    func setMessageCanBeEdited(messageCanBeEdited: Bool) {
        self.messageCanBeEdited = messageCanBeEdited
    }
    
    func toString() -> String {
        return """
MessageImpl {
    serverURLString = \(serverURLString),
    ID = \(clientSideID),
    operatorID = \(operatorID ?? "nil"),
    senderAvatarURLString = \(senderAvatarURLString ?? "nil"),
    senderName = \(senderName),
    type = \(type),
    text = \(text),
    timeInMicrosecond = \(timeInMicrosecond),
    attachment = \(data?.getAttachment()?.getFileInfo().getURL()?.absoluteString ?? "nil"),
    historyMessage = \(historyMessage),
    currentChatID = \(currentChatID ?? "nil"),
    historyID = \(historyID?.getDBid() ?? "nil"),
    rawText = \(rawText ?? "nil"),
    read = \(read)
    status = \(sendStatus)
    deleted = \(deleted)
}
"""
    }
    
    // MARK: -
    enum MessageSource {
        case history
        case currentChat
        
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
            return (self == .history)
        }
        
        func isCurrentChatMessage() -> Bool {
            return (self == .currentChat)
        }
        
    }
    
    // MARK: -
    enum MessageError: Error {
        case invalidState(String)
    }
    
}

// MARK: - Message
extension MessageImpl: Message {
    func getQuote() -> Quote? {
        return quote
    }
    
    func getRawData() -> [String : Any?]? {
        return rawData
    }
    
    func getData() -> MessageData? {
        return data
    }
    
    func getID() -> String {
        return clientSideID
    }
    
    func getServerSideID() -> String? {
        return serverSideID
    }
    
    func getCurrentChatID() -> String? {
        guard let currentChatID = currentChatID else {
            WebimInternalLogger.shared.log(entry: "Message \(self.toString()) do not have an ID in current chat or do not exist in current chat or chat exists itself not.",
                verbosityLevel: .debug)
            
            return nil
        }
        
        return currentChatID
    }
    
    func getKeyboard() -> Keyboard? {
        return keyboard
    }
    
    func getKeyboardRequest() -> KeyboardRequest? {
        return keyboardRequest
    }
    
    func getOperatorID() -> String? {
        return operatorID
    }
    
    func getSenderAvatarFullURL() -> URL? {
        guard let senderAvatarURLString = senderAvatarURLString else {
            return nil
        }
        
        return URL(string: (serverURLString + senderAvatarURLString))
    }
    
    func getSendStatus() -> MessageSendStatus {
        return sendStatus
    }
    
    func getSenderName() -> String {
        return senderName
    }
    
    func getSticker() -> Sticker? {
        return sticker
    }
    
    func getText() -> String {
        return text
    }
    
    func getTime() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timeInMicrosecond / 1_000_000))
    }
    
    func getType() -> MessageType {
        return type
    }
    
    func isEqual(to message: Message) -> Bool {
        guard let message = message as? MessageImpl else {
            return false
        }
        return (self == message)
    }
    
    func isReadByOperator() -> Bool {
        return getRead() //todo: maybe returns old value
    }
    
    func canBeEdited() -> Bool {
        return messageCanBeEdited
    }
    
    func canBeReplied() -> Bool {
        return messageCanBeReplied
    }
    
    func isEdited() -> Bool {
        return messageIsEdited
    }
    
    func getVisitorReaction() -> String? {
        return visitorReactionInfo
    }
    
    func canVisitorReact() -> Bool {
        return visitorCanReact ?? false
    }

    func canVisitorChangeReaction() -> Bool {
        return visitorChangeReaction ?? false
    }
    
    func getGroup() -> Group? {
        return group
    }
    
    func isDeleted() -> Bool? {
        return deleted
    }
}

// MARK: - Equatable
extension MessageImpl: Equatable {
    
    static func == (lhs: MessageImpl,
                    rhs: MessageImpl) -> Bool {
        return lhs.clientSideID == rhs.clientSideID
            && lhs.serverSideID == rhs.serverSideID
            && lhs.operatorID == rhs.operatorID
            && lhs.rawText == rhs.rawText
            && lhs.senderAvatarURLString == rhs.senderAvatarURLString
            && lhs.senderName == rhs.senderName
            && lhs.text == rhs.text
            && lhs.timeInMicrosecond == rhs.timeInMicrosecond
            && lhs.type == rhs.type
            && lhs.isReadByOperator() == rhs.isReadByOperator()
            && lhs.canBeEdited() == rhs.canBeEdited()
            && lhs.isEdited() == rhs.isEdited()
            && lhs.visitorCanReact == rhs.visitorCanReact
            && lhs.canVisitorReact() == rhs.canVisitorReact()
            && lhs.canVisitorChangeReaction() == rhs.canVisitorChangeReaction()
            && areEqualQuotes(lhs: lhs.quote, rhs: rhs.quote)
            && areEqualKeyboard(lhs: lhs.getKeyboard(), rhs: rhs.getKeyboard())
            && areEqualKeyboardRequest(lhs: lhs.getKeyboardRequest(), rhs: rhs.getKeyboardRequest())
            && lhs.sendStatus == rhs.sendStatus
            && lhs.serverURLString == rhs.serverURLString
            && areEqualSticker(lhs: lhs.sticker, rhs: rhs.sticker)
            && lhs.currentChatID == rhs.currentChatID
            //&& lhs.rawData == rhs.rawData
            && areEqualMessageAttachment(lhs: lhs.data?.getAttachment(), rhs: rhs.data?.getAttachment())
            && lhs.historyID == rhs.historyID
            && lhs.historyMessage == rhs.historyMessage
            && lhs.read == rhs.read
            && lhs.canBeReplied() == rhs.canBeReplied()
            && lhs.visitorReactionInfo == rhs.visitorReactionInfo
    }
    
    private static func areEqualQuotes(lhs: Quote?, rhs: Quote?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualKeyboard(lhs: Keyboard?, rhs: Keyboard?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualKeyboardRequest(lhs: KeyboardRequest?, rhs: KeyboardRequest?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualSticker(lhs: Sticker?, rhs: Sticker?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualMessageAttachment(lhs: MessageAttachment?, rhs: MessageAttachment?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func checkNil<T>(lhs: T?, rhs: T?) -> Bool? {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return nil
    }
    
}

// MARK: -
/**
 Internal messages' data representation.
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
final class MessageDataImpl: MessageData {
    
    // MARK: - Properties
    private let attachment: MessageAttachment?
    private let translationInfo: TranslationInfo?
    
    // MARK: - Initialization
    init(attachment: MessageAttachment?,
         translationInfo: TranslationInfo?) {
        self.attachment = attachment
        self.translationInfo = translationInfo
    }
    
    // MARK: - Methods
    func getAttachment() -> MessageAttachment? {
        return attachment
    }
    
    func getTranslationInfo() -> TranslationInfo? {
        return translationInfo
    }
    
    func isEqual(to messageData: MessageData) -> Bool {
        guard let messageData = messageData as? MessageDataImpl else {
            return false
        }
        return self == messageData
    }
    
    static private func convert(messageData: MessageDataItem?) -> MessageData {
        let translationInfo = messageData?.getTranslationInfo()
        return MessageDataImpl(attachment: nil,
                               translationInfo: TranslationInfoImpl(translatedText: translationInfo?.getTranslatedText(),
                                                                    sourceLang: translationInfo?.getSourceLang(),
                                                                    targetLang: translationInfo?.getTargetLang(),
                                                                    error: translationInfo?.getError()))
    }
}

extension MessageDataImpl: Equatable {
    static func == (lhs: MessageDataImpl, rhs: MessageDataImpl) -> Bool {
        return areEqualMessageAttachment(lhs: lhs.getAttachment(), rhs: rhs.getAttachment())
                && areEqualTranslationInfo(lhs: lhs.getTranslationInfo(), rhs: rhs.getTranslationInfo())
    }
    
    private static func areEqualMessageAttachment(lhs: MessageAttachment?, rhs: MessageAttachment?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualTranslationInfo(lhs: TranslationInfo?, rhs: TranslationInfo?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func checkNil<T>(lhs: T?, rhs: T?) -> Bool? {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return nil
    }
}

// MARK: -
/**
 Internal messages' attachments representation.
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
final class MessageAttachmentImpl: MessageAttachment {
    
    // MARK: - Properties
    private let fileInfo: FileInfo
    private let filesInfo: [FileInfo]
    private let state: AttachmentState
    private var downloadProgress: Int64?
    private var errorType: String?
    private var errorMessage: String?
    private var visitorErrorMessage: String?
    
    // MARK: - Initialization
    init(fileInfo: FileInfo,
         filesInfo: [FileInfo],
         state: AttachmentState,
         downloadProgress: Int64? = nil,
         errorType: String? = nil,
         errorMessage: String? = nil,
         visitorErrorMessage: String? = nil) {
        self.fileInfo = fileInfo
        self.filesInfo = filesInfo
        self.state = state
        self.downloadProgress = downloadProgress
        self.errorType = errorType
        self.errorMessage = errorMessage
        self.visitorErrorMessage = visitorErrorMessage
    }
    
    // MARK: - Methods
    func getFileInfo() -> FileInfo {
        return fileInfo
    }
    
    
    func getFilesInfo() -> [FileInfo] {
        return filesInfo
    }
    
    func getState() -> AttachmentState {
        return state
    }
    
    func getDownloadProgress() -> Int64? {
        return downloadProgress
    }
    
    func getErrorType() -> String? {
        return errorType
    }
    
    func getErrorMessage() -> String? {
        return errorMessage
    }
    
    func getVisitorErrorMessage() -> String? {
        return visitorErrorMessage
    }
    
    func isEqual(to messageAttachment: MessageAttachment) -> Bool {
        guard let messageAttachment = messageAttachment as? MessageAttachmentImpl else {
            return false
        }
        return self == messageAttachment
    }
}

extension MessageAttachmentImpl: Equatable {
    static func == (lhs: MessageAttachmentImpl, rhs: MessageAttachmentImpl) -> Bool {
        return lhs.fileInfo.isEqual(to: rhs.fileInfo)
            && areEqualFilesInfo(lhs: lhs.filesInfo, rhs: rhs.filesInfo)
            && lhs.state == rhs.state
            && lhs.getDownloadProgress() == rhs.getDownloadProgress()
            && lhs.getErrorType() == rhs.getErrorType()
            && lhs.getErrorMessage() == rhs.getErrorMessage()
            && lhs.getVisitorErrorMessage() == rhs.getVisitorErrorMessage()
    }
    
    private static func areEqualFilesInfo(lhs: [FileInfo], rhs: [FileInfo]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        for (index, item) in lhs.enumerated() {
            if !item.isEqual(to: rhs[index]) {
                return false
            }
        }
        return true
    }
}

// MARK: -
/**
 Internal fileinfo representation.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class FileInfoImpl {
    
    // MARK: - Constants
    private enum Period: Int64 {
        case attachmentURLExpires = 300 // (seconds) = 5 (minutes).
    }
    
    
    // MARK: - Properties
    private let urlString: String?
    private let size: Int64?
    private let filename: String
    private let contentType: String?
    private let imageInfo: ImageInfo?
    private let guid: String?
    private weak var fileUrlCreator: FileUrlCreator?
    
    
    // MARK: - Initialization
    init(urlString: String?,
         size: Int64?,
         filename: String,
         contentType: String?,
         imageInfo: ImageInfo? = nil,
         guid: String?,
         fileUrlCreator: FileUrlCreator?) {
        self.urlString = urlString
        self.size = size
        self.filename = filename
        self.contentType = contentType
        self.imageInfo = imageInfo
        self.guid = guid
        self.fileUrlCreator = fileUrlCreator
    }
    
    // MARK: - Methods
    static func getAttachment(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                              text: String) -> FileInfoImpl? {
        guard let textData = text.data(using: .utf8) else {
            WebimInternalLogger.shared.log(entry: "Convert Text to Data failure in MessageImpl.\(#function)")
            return nil
        }
        
        guard let optionaltextDictionary = (
            (try? JSONSerialization.jsonObject(with: textData, options: [])
                as? [String: Any?])
                as [String : Any?]??),
            let textDictionary = optionaltextDictionary else {
            WebimInternalLogger.shared.log(
                entry: "Message attachment parameters parsing failed: \(text).",
                verbosityLevel: .warning
            )
            return nil
        }
        
        return getAttachment(byFileUrlCreator: fileUrlCreator,
                             textDictionary: textDictionary)
    }
    
    static func getErrorAttachment(byFileUrlCreator fileUrlCreator: FileUrlCreator, text: String, data: [String:Any?]) -> FileInfoImpl? {
        guard let textData = text.data(using: .utf8) else { return nil }
        let textDictionary = (try? JSONSerialization.jsonObject(with: textData) as? [String: Any?]) ?? [:]
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary)
        
        let filename = fileParameters.getFilename() ?? "Unknown filename"
        let fileSize = fileParameters.getSize() ?? -1
        
        return FileInfoImpl(
            urlString: nil,
            size: fileSize,
            filename: filename,
            contentType: nil,
            imageInfo: nil,
            guid: nil,
            fileUrlCreator: fileUrlCreator
        )
    }
    
    static func getAttachments(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                               text: String) -> [FileInfoImpl] {
        var attachments = [FileInfoImpl]()
        guard let textData = text.data(using: .utf8) else {
            WebimInternalLogger.shared.log(entry: "Convert Text to Data failure in MessageImpl.\(#function)")
            return []
        }
        guard let optionaltextDictionaryArray = (
            (try? JSONSerialization.jsonObject(with: textData, options: [])
                as? [Any])
                as [Any]??),
            let textDictionaryArray = optionaltextDictionaryArray else {
            return []
        }
        for textDictionary in textDictionaryArray {
            if let textDictionary = textDictionary as? [String: Any?],
               let fileInfoImpl = getAttachment(byFileUrlCreator: fileUrlCreator,
                                                textDictionary: textDictionary) {
                attachments.append(fileInfoImpl)
            }
        }
        return attachments
    }
    
    // MARK: Private methods
    private static func getAttachment(byFileUrlCreator fileUrlCreator: FileUrlCreator,
                                      textDictionary: [String: Any?]) -> FileInfoImpl? {
        let fileParameters = FileParametersItem(jsonDictionary: textDictionary)
        guard let filename = fileParameters.getFilename(),
            let guid = fileParameters.getGUID(),
            let contentType = fileParameters.getContentType() else {
            return nil
        }
        
        let fileURLString = fileUrlCreator.createFileURL(byFilename: filename, guid: guid, isThumb: true)
            
        return FileInfoImpl(urlString: fileURLString,
                            size: fileParameters.getSize(),
                            filename: filename,
                            contentType: contentType,
                            imageInfo: extractImageInfoOf(fileParameters: fileParameters,
                                                          fileUrlCreator: fileUrlCreator),
                            guid: guid,
                            fileUrlCreator: fileUrlCreator)
    }
    
    private static func extractImageInfoOf(fileParameters: FileParametersItem?,
                                           fileUrlCreator: FileUrlCreator) -> ImageInfo? {
        guard let fileParameters = fileParameters,
              let filename = fileParameters.getFilename(),
              let guid = fileParameters.getGUID(),
              let thumbURLString = fileUrlCreator.createFileURL(byFilename: filename, guid: guid, isThumb: true),
            let imageSize = fileParameters.getImageParameters()?.getSize() else {
            return nil
        }
        
        return ImageInfoImpl(withThumbURLString: thumbURLString,
                             fileUrlCreator: fileUrlCreator,
                             filename: filename,
                             guid: guid,
                             width: imageSize.getWidth(),
                             height: imageSize.getHeight())
    }
    
}

// MARK: - MessageAttachment
extension FileInfoImpl: FileInfo {
    
    func getContentType() -> String? {
        return contentType
    }
    
    func getFileName() -> String {
        return filename
    }
    
    func getImageInfo() -> ImageInfo? {
        return imageInfo
    }
    
    func getSize() -> Int64? {
        return size
    }
    
    func getGuid() -> String? {
        return guid
    }
    
    func getURL() -> URL? {
        guard let urlString = self.urlString else {
            WebimInternalLogger.shared.log(entry: "Getting URL from String failure because URL String is nil in MessageImpl.\(#function)")
            return nil
        }
        if let guid = guid,
           let currentURLString = fileUrlCreator?.createFileURL(byFilename: filename, guid: guid) {
            return URL(string: currentURLString)
        }
        return URL(string: urlString)
    }
    
    func isEqual(to fileInfo: FileInfo) -> Bool {
        guard let fileInfo = fileInfo as? FileInfoImpl else {
            return false
        }
        return (self == fileInfo)
    }
    
}

extension FileInfoImpl: Equatable {
    
    static func == (lhs: FileInfoImpl,
                    rhs: FileInfoImpl) -> Bool {
        return lhs.urlString == rhs.urlString
            && lhs.size == rhs.size
            && lhs.filename == rhs.filename
            && lhs.contentType == rhs.contentType
            && areEqualImageInfos(lhs: lhs.imageInfo, rhs: rhs.imageInfo)
            && lhs.guid == rhs.guid
    }
    
    private static func areEqualImageInfos(lhs: ImageInfo?, rhs: ImageInfo?) -> Bool {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return lhs!.isEqual(to: rhs!)
    }
}

// MARK: -
/**
 Internal image information representation.
 - seealso:
 `MessageAttachment`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class ImageInfoImpl: ImageInfo {
    
    // MARK: - Properties
    private let thumbURLString: String
    private let width: Int?
    private let height: Int?
    private weak var fileUrlCreator: FileUrlCreator?
    private let filename: String
    private let guid: String?
    
    // MARK: - Initialization
    init(withThumbURLString thumbURLString: String,
         fileUrlCreator: FileUrlCreator?,
         filename: String,
         guid: String?,
         width: Int?,
         height: Int?) {
        self.thumbURLString = thumbURLString
        self.fileUrlCreator = fileUrlCreator
        self.filename = filename
        self.guid = guid
        self.width = width
        self.height = height
    }
    
    // MARK: - Methods
    // MARK: ImageInfo protocol methods
    
    func getThumbURL() -> URL? {
        guard let guid = guid,
              let currentURLString = fileUrlCreator?.createFileURL(byFilename: filename, guid: guid, isThumb: true),
              let thumbURL = URL(string: currentURLString) else {
            WebimInternalLogger.shared.log(entry: "Getting Thumb URL from String failure in MessageImpl.\(#function)")
            return nil
        }
        return thumbURL
    }
    
    func getHeight() -> Int? {
        return height
    }
    
    func getWidth() -> Int? {
        return width
    }
    
    func isEqual(to imageInfo: ImageInfo) -> Bool {
        guard let imageInfo = imageInfo as? ImageInfoImpl else {
            return false
        }
        return (self == imageInfo)
    }
}

extension ImageInfoImpl: Equatable {
    
    static func == (lhs: ImageInfoImpl,
                    rhs: ImageInfoImpl) -> Bool {
        return lhs.thumbURLString == rhs.thumbURLString
        && lhs.filename == rhs.filename
        && lhs.guid == rhs.guid
        && lhs.width == rhs.width
        && lhs.height == rhs.height
    }
}

// MARK: -
/**
 - seealso:
 `Keyboard`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardImpl: Keyboard {
    
    fileprivate var keyboardItem: KeyboardItem
    
    init?(data: [String: Any?]) {
        if let keyboard = KeyboardItem(jsonDictionary: data) {
            self.keyboardItem = keyboard
        } else {
            return nil
        }
    }
    
    static func getKeyboard(jsonDictionary: [String : Any?]) -> Keyboard? {
        return KeyboardImpl(data: jsonDictionary)
    }
    
    func getButtons() -> [[KeyboardButton]] {
        var buttonArrayArray = [[KeyboardButton]]()
        for buttonArray in keyboardItem.getButtons() {
            var newButtonArray = [KeyboardButton]()
            for button in buttonArray {
                guard let buttonImpl = KeyboardButtonImpl(data: button) else {
                    WebimInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardImpl.\(#function)")
                    return []
                }
                newButtonArray.append(buttonImpl)
            }
            buttonArrayArray.append(newButtonArray)
        }
        return buttonArrayArray
    }
    
    func getState() -> KeyboardState {
        return keyboardItem.getState()
    }
    
    func getResponse() -> KeyboardResponse? {
        return KeyboardResponseImpl(data: keyboardItem.getResponse())
    }
    
    func isEqual(to keyboard: Keyboard) -> Bool {
        guard let keyboard = keyboard as? KeyboardImpl else {
            return false
        }
        return self == keyboard
    }
}

extension KeyboardImpl: Equatable {
    static func == (lhs: KeyboardImpl, rhs: KeyboardImpl) -> Bool {
        return lhs.getState() == rhs.getState()
            && areEqualButtons(lhs: lhs.getButtons(), rhs: rhs.getButtons())
            && areEqualResponses(lhs: lhs.getResponse(), rhs: rhs.getResponse())
    }
    
    private static func areEqualButtons(lhs: [[KeyboardButton]], rhs: [[KeyboardButton]]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        if lhs.isEmpty && rhs.isEmpty {
            return true
        }
        for (index, array) in lhs.enumerated() {
            if array.count != rhs[index].count {
                return false
            }
            for (indexButton, button) in array.enumerated() {
                if !button.isEqual(to: rhs[index][indexButton]) {
                    return false
                }
            }
        }
        return true
    }
    
    private static func areEqualResponses(lhs: KeyboardResponse?, rhs: KeyboardResponse?) -> Bool {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return lhs!.isEqual(to: rhs!)
    }
}

/**
 - seealso:
 `Sticker`
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
final class StickerImpl: Sticker {
    private let stickerItem: StickerItem
    
    init?(data: [String: Any?]) {
        if let sticker = StickerItem(jsonDictionary: data) {
            self.stickerItem = sticker
        } else {
            return nil
        }
    }
    
    init(stickerId: Int) {
        self.stickerItem = StickerItem(stickerId: stickerId)
    }
    
    static func getSticker(jsonDictionary: [String : Any?]) -> Sticker? {
        return StickerImpl(data: jsonDictionary)
    }
    
    func getStickerId() -> Int {
        return stickerItem.getStickerId()
    }
    
    func isEqual(to sticker: Sticker) -> Bool {
        guard let sticker = sticker as? StickerImpl else {
            return false
        }
        return self.getStickerId() == sticker.getStickerId()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardButton`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardButtonImpl: KeyboardButton {
    
    private let buttonItem: KeyboardButtonItem
    
    init?(data: KeyboardButtonItem?) {
        if let buttonItem = data {
            self.buttonItem = buttonItem
        } else {
            return nil
        }
    }
    
    func getID() -> String {
        return buttonItem.getId()
    }
    
    func getText() -> String {
        return buttonItem.getText()
    }
    
    func getConfiguration() -> Configuration? {
        return ConfigurationImpl(data: buttonItem.getConfiguration())
    }
    
    func getParams() -> Params? {
        return ParamsImpl(data: buttonItem.getParams())
    }
    
    func isEqual(to keyboardButton: KeyboardButton) -> Bool {
        guard let keyboardButton = keyboardButton as? KeyboardButtonImpl else {
            return false
        }
        return self == keyboardButton
    }
}

extension KeyboardButtonImpl: Equatable {
    static func == (lhs: KeyboardButtonImpl, rhs: KeyboardButtonImpl) -> Bool {
        return lhs.getID() == rhs.getID()
        && lhs.getText() == rhs.getText()
        && areEqualConfigurations(lhs: lhs.getConfiguration(), rhs: rhs.getConfiguration())
        && areEqualParams(lhs: lhs.getParams(), rhs: rhs.getParams())
    }
    
    private static func checkNil<T>(lhs: T?, rhs: T?) -> Bool? {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return nil
    }
    
    private static func areEqualConfigurations(lhs: Configuration?, rhs: Configuration?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
    
    private static func areEqualParams(lhs: Params?, rhs: Params?) -> Bool {
        if let checkNil = checkNil(lhs: lhs, rhs: rhs) {
            return checkNil
        }
        return lhs!.isEqual(to: rhs!)
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardResponse`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardResponseImpl: KeyboardResponse {
    
    private let keyboardResponseItem: KeyboardResponseItem
    
    init?(data: KeyboardResponseItem?) {
        if let keyboardResponse = data {
            self.keyboardResponseItem = keyboardResponse
        } else {
            return nil
        }
    }
    
    func getButtonID() -> String {
        return keyboardResponseItem.getButtonId()
    }
    
    func getMessageID() -> String {
        return keyboardResponseItem.getMessageId()
    }
    
    func isEqual(to keyboardResponse: KeyboardResponse) -> Bool {
        guard let keyboardResponse = keyboardResponse as? KeyboardResponseImpl else {
            return false
        }
        return self == keyboardResponse
    }
}

extension KeyboardResponseImpl: Equatable {
    static func == (lhs: KeyboardResponseImpl, rhs: KeyboardResponseImpl) -> Bool {
        return lhs.getButtonID() == rhs.getButtonID()
        && lhs.getMessageID() == rhs.getMessageID()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardResponse`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class KeyboardRequestImpl: KeyboardRequest {
    
    private let keyboardRequestItem: KeyboardRequestItem
    
    init?(data: [String: Any?]) {
        if let keyboardRequest = KeyboardRequestItem(jsonDictionary: data) {
            self.keyboardRequestItem = keyboardRequest
        } else {
            return nil
        }
    }
    
    static func getKeyboardRequest(jsonDictionary: [String : Any?]) -> KeyboardRequest? {
        return KeyboardRequestImpl(data: jsonDictionary)
    }
    
    func getButton() -> KeyboardButton {
        guard let buttonImpl = KeyboardButtonImpl(data: keyboardRequestItem.getButton()) else {
            WebimInternalLogger.shared.log(entry: "Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
            fatalError("Getting KeyboardButtonImpl from data failure in KeyboardRequestImpl.\(#function)")
        }
        return buttonImpl
    }
    
    func getMessageID() -> String {
        return keyboardRequestItem.getMessageId()
    }
    
    func isEqual(to keyboardRequest: KeyboardRequest) -> Bool {
        guard let keyboardRequest = keyboardRequest as? KeyboardRequestImpl else {
            return false
        }
        return self == keyboardRequest
    }
}

extension KeyboardRequestImpl: Equatable {
    static func == (lhs: KeyboardRequestImpl, rhs: KeyboardRequestImpl) -> Bool {
        return lhs.getButton().isEqual(to: rhs.getButton())
            && lhs.getMessageID() == rhs.getMessageID()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardButton`
 - author:
 Anna Frolova
 - copyright:
 2021 Webim
 */
final class ConfigurationImpl: Configuration {
    
    private let configurationItem: ConfigurationItem
    
    init?(data: ConfigurationItem?) {
        if let configurationItem = data {
            self.configurationItem = configurationItem
        } else {
            return nil
        }
    }
    
    func isActive() -> Bool? {
        return configurationItem.isActive()
    }
    
    func getButtonType() -> ButtonType? {
        return configurationItem.getButtonType()
    }
    
    func getData() -> String? {
        return configurationItem.getData()
    }
    
    func getState() -> ButtonState? {
        return configurationItem.getState()
    }
    
    func getHideAfter() -> Bool? {
        return configurationItem.getHideAfter()
    }
 
    func isEqual(to configuration: Configuration) -> Bool {
        guard let configuration = configuration as? ConfigurationImpl else {
            return false
        }
        return self == configuration
    }
}

extension ConfigurationImpl: Equatable {
    static func == (lhs: ConfigurationImpl, rhs: ConfigurationImpl) -> Bool {
        return lhs.isActive() == rhs.isActive()
        && lhs.getButtonType() == rhs.getButtonType()
        && lhs.getData() == rhs.getData()
        && lhs.getState() == rhs.getState()
    }
}

// MARK: -
/**
 - seealso:
 `KeyboardButton`
 - author:
 Anna Frolova
 - copyright:
 2023 Webim
 */
final class ParamsImpl: Params {
    
    private let paramsItem: ParamsItem?
    
    init(data: ParamsItem?) {
        self.paramsItem = data
    }
    
    func getType() -> ParamsButtonType? {
        return paramsItem?.getType()
    }
    
    func getAction() -> String? {
        return paramsItem?.getAction()
    }
    
    func getColor() -> String? {
        return paramsItem?.getColor()
    }
 
    func isEqual(to params: Params) -> Bool {
        guard let params = params as? ParamsImpl else {
            return false
        }
        return (self == params)
    }
}

extension ParamsImpl: Equatable {
    static func == (lhs: ParamsImpl,
                    rhs: ParamsImpl) -> Bool {
        return lhs.getType() == rhs.getType()
            && lhs.getAction() == rhs.getAction()
            && lhs.getColor() == rhs.getColor()
    }
}


// MARK: -
/**
 - seealso:
 `Message.getQuote()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class QuoteImpl: Quote {
    
    private let state: QuoteState
    private let authorID: String?
    private let messageAttachment: FileInfo?
    private let messageID: String?
    private let messageType: MessageType?
    private let senderName: String?
    private let text: String?
    private let rawText: String?
    private let timestamp: Int64?
    private let translationInfo: TranslationInfo?
    
    init(state: QuoteState,
         authorID: String?,
         messageAttachment: FileInfo?,
         messageID: String?,
         messageType: MessageType?,
         senderName: String?,
         text: String?,
         rawText: String?,
         timestamp: Int64?,
         translationInfo: TranslationInfo?) {
        self.state = state
        self.authorID = authorID
        self.messageAttachment = messageAttachment
        self.messageID = messageID
        self.messageType = messageType
        self.senderName = senderName
        self.text = text
        self.rawText = rawText
        self.timestamp = timestamp
        self.translationInfo = translationInfo
    }
    
    // MARK: - Methods
    static func getQuote(quoteItem: QuoteItem?,
                         messageAttachment: FileInfo?,
                         fileUrlCreator: FileUrlCreator? = nil) -> Quote? {
        guard let quoteItem = quoteItem else {
            return nil
        }
        var text = quoteItem.getText()
        let rawText = quoteItem.getText()
        var messageType: MessageType? = nil
        if let messageKind = quoteItem.getMessageKind() {
            messageType = MessageMapper.convert(messageKind: messageKind)
        }
        var quoteMessageAttachment = messageAttachment
        if let messageAttachment = messageAttachment {
            text = messageAttachment.getFileName()
        } else if messageType == .fileFromOperator || messageType == .fileFromVisitor,
           let fileUrlCreator = fileUrlCreator,
           let rawText = text {
            quoteMessageAttachment = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator, text: rawText)
            if let quoteMessageAttachment = quoteMessageAttachment {
                text = quoteMessageAttachment.getFileName()
            }
        }
        guard let quoteState = quoteItem.getState() else {
            WebimInternalLogger.shared.log(entry: "Quote Item has not State in KeyboardRequestImpl.\(#function)")
            return nil
        }
        let translationInfo = convert(messageData: quoteItem.getData()?.getTranslationInfo())
        
        return QuoteImpl(state: convert(quoteState: quoteState),
                         authorID: quoteItem.getAuthorID(),
                         messageAttachment: quoteMessageAttachment,
                         messageID: quoteItem.getID(),
                         messageType: messageType,
                         senderName: quoteItem.getSenderName(),
                         text: text,
                         rawText: rawText,
                         timestamp: quoteItem.getTimeInMicrosecond(),
                         translationInfo: translationInfo)
    }
    
    func getRawText() -> String? {
        return rawText
    }
    
    func getAuthorID() -> String? {
        return authorID
    }
    
    func getMessageAttachment() -> FileInfo? {
        return messageAttachment
    }
    
    func getMessageTimestamp() -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp / 1_000_000))
        
    }
    
    func getMessageID() -> String? {
        return messageID
    }
    
    func getMessageText() -> String? {
        return text
    }
    
    func getMessageType() -> MessageType? {
        return messageType
    }
    
    func getSenderName() -> String? {
        return senderName
    }
    
    func getState() -> QuoteState {
        return state
    }
    
    func getTranslationInfo() -> TranslationInfo? {
        return translationInfo
    }
    
    func isEqual(to quote: Quote) -> Bool {
        guard let quote = quote as? QuoteImpl else {
            return false
        }
        return (self == quote)
    }
    
    static private func convert(messageData: TranslationInfoItem?) -> TranslationInfo {
        
        return TranslationInfoImpl(translatedText: messageData?.getTranslatedText(),
                                   sourceLang: messageData?.getSourceLang(),
                                   targetLang: messageData?.getTargetLang(),
                                   error: messageData?.getError())
    }
    
    static private func convert(quoteState: QuoteItem.QuoteStateItem) -> QuoteState {
        switch quoteState {
        case .pending:
            return .pending
        case .filled:
            return .filled
        case .notFound:
            return .notFound
        }
    }
}

extension QuoteImpl: Equatable {
    
    static func == (lhs: QuoteImpl,
                    rhs: QuoteImpl) -> Bool {
        return lhs.state == rhs.state
            && lhs.authorID == rhs.authorID
            && areEqualMessageAttachments(lhs: lhs.messageAttachment, rhs: rhs.messageAttachment)
            && lhs.messageID == rhs.messageID
            && lhs.messageType == rhs.messageType
            && lhs.senderName == rhs.senderName
            && lhs.text == rhs.text
            && lhs.rawText == rhs.rawText
            && lhs.timestamp == rhs.timestamp
    }
    
    private static func areEqualMessageAttachments(lhs: FileInfo?, rhs: FileInfo?) -> Bool {
        if lhs == nil && rhs != nil || lhs != nil && rhs == nil {
            return false
        }
        if lhs == nil && rhs == nil {
            return true
        }
        return lhs!.isEqual(to: rhs!)
    }
}

class GroupImpl {
    private let id: String
    private let messageCount: Int
    private let messageNumber: Int
    
    init(id: String, messageCount: Int, messageNumber: Int) {
        self.id = id
        self.messageCount = messageCount
        self.messageNumber = messageNumber
    }
}

extension GroupImpl: Group {
    func getID() -> String {
        return id
    }
    
    func getMessageCount() -> Int {
        return messageCount
    }
    
    func getMessageNumber() -> Int {
        return messageNumber
    }
}

class TranslationInfoImpl: TranslationInfo {
    
    private let translatedText: String?
    private let sourceLang: String?
    private let targetLang: String?
    private let error: String?
    
    init(translatedText: String?,
         sourceLang: String?,
         targetLang: String?,
         error: String?) {
        self.translatedText = translatedText
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.error = error
    }
    
    func getTranslatedText() -> String? {
        return translatedText
    }
    
    func getSourceLang() -> String? {
        return sourceLang
    }
    
    func getTargetLang() -> String? {
        return targetLang
    }
    
    func getError() -> String? {
        return error
    }
    
    func isEqual(to translationInfo: TranslationInfo) -> Bool {
        guard let translationInfo = translationInfo as? TranslationInfoImpl else {
            return false
        }
        return (self == translationInfo)
    }
}

extension TranslationInfoImpl: Equatable {
    
    static func == (lhs: TranslationInfoImpl,
                    rhs: TranslationInfoImpl) -> Bool {
        return lhs.getTranslatedText() == rhs.getTranslatedText()
            && lhs.getSourceLang() == rhs.getSourceLang()
            && lhs.getTargetLang() == rhs.getTargetLang()
            && lhs.getError() == rhs.getError()
    }
}
