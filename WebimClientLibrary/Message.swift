//
//  Message.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
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
 Abstracts a single message in the message history.
 A message is an immutable object. It means that changing some of the message fields creates a new object. Messages can be compared by using `isEqual(to:)` method for searching messages with the same set of fields or by ID (`message1.getID() == message2.getID()`) for searching logically identical messages. ID is formed on the client side when sending a message (`MessageStream.send(message:isHintQuestion:)` or `MessageStream.sendFile(atPath:mimeType:completion:)).
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol Message {
    
    /**
     Messages of type `MessageType.actionRequest` contain custom dictionary.
     - returns:
     Dictionary which contains custom fields or `nil` if there's no such custom fields.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getRawData() -> [String: Any?]?
    
    /**
    Messages of types `MessageType.FILE_FROM_OPERATOR` and `MessageType.FILE_FROM_VISITOR` can contain file.
    - returns:
    The file of the message.
    - author:
    Yury Vozleev
    - copyright:
    2020 Webim
    */
    func getData() -> MessageData?
    
    /**
     Every message can be uniquefied by its ID. Messages also can be lined up by its IDs.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique ID of the message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getID() -> String
    
    /**
     Current chat id of the message.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique ID of the message.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getCurrentChatID() -> String?
    
    /**
     Messages of type `MessageType.keyboard` contain keyboard from script bot.
     - returns:
     Keyboard with buttons.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getKeyboard() -> Keyboard?
    
    /**
     Messages of type `MessageType.keyboardResponse` contain keyboard request from script bot.
     - returns:
     Keyboard request.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getKeyboardRequest() -> KeyboardRequest?
    
    /**
     - returns:
     ID of a message sender, if the sender is an operator.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getOperatorID() -> String?
    
    
    /**
     - returns:
     Quote message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getQuote() -> Quote?
    
    /**
     - returns:
     The sticker item that was sent to the server.
     - attention:
     This method can't be used as is. It requires that client server to support this mechanism.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    func getSticker() -> Sticker?
    
    /**
     - returns:
     URL of a sender's avatar or `nil` if one does not exist.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getSenderAvatarFullURL() -> URL?
    
    /**
     - returns:
     Name of a message sender.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getSenderName() -> String
    
    /**
     - returns:
     `MessageSendStatus.sent` if a message had been sent to the server, was received by the server and was delivered to all the clients; `MessageSendStatus.sending` if not.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getSendStatus() -> MessageSendStatus
    
    /**
     - returns:
     Text of the message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getText() -> String
    
    /**
     - returns:
     Timestamp of the moment the message was processed by the server.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getTime() -> Date
    
    /**
     - seealso:
     `MessageType` enum.
     - returns:
     Type of a message.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getType() -> MessageType
    
    /**
     Method which can be used to compare if two Message objects have identical contents.
     - parameter message:
     Second `Message` object.
     - returns:
     True if two `Message` objects are identical and false otherwise.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func isEqual(to message: Message) -> Bool
    
    /**
     - returns:
     True if visitor message read by operator or this message is not by visitor and false otherwise.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func isReadByOperator() -> Bool
    
    /**
     - returns:
     True if this message can be edited or deleted.
     - author:
     Nikita Kaberov
     - copyright:
     2018 Webim
     */
    func canBeEdited() -> Bool
    
    /**
     - returns:
     True if this message can be replied.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func canBeReplied() -> Bool
    
    /**
     - returns:
     True if this message is edited.
     - author:
     Eugene Ilyin
     - copyright:
     2019 Webim
     */
    func isEdited() -> Bool
}

/**
Contains a file attached to the message.
- seealso:
`Message.getData()`
- author:
Yury Vozleev
- copyright:
2020 Webim
*/
public protocol MessageData {
    
    /**
     Messages of the types `MessageType.FILE_FROM_OPERATOR` and `MessageType.FILE_FROM_VISITOR` can contain attachments.
     - important:
     Notice that this method may return nil even in the case of previously listed types of messages. E.g. if a file is being sent.
     - seealso:
     `MessageAttachment` protocol.
     - returns:
     Information about the file that is attached to the message.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    func getAttachment() -> MessageAttachment?
    
}

/**
 Contains an attachment file.
 - seealso:
 `MessageData.getAttachment()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
public protocol MessageAttachment {
    /**
     - returns:
     The file info of the attachment.
     - author:
     Vozleev Yury
     - copyright:
     2020 Webim
     */
    func getFileInfo() -> FileInfo
    
    /**
     - returns:
     The files info of the attachment.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getFilesInfo() -> [FileInfo]
    
    /**
     - returns:
     Attachment state.
     - author:
     Vozleev Yury
     - copyright:
     2020 Webim
     */
    func getState() -> AttachmentState
    
    /**
     - returns:
     Attachment upload progress as a percentage.
     - author:
     Vozleev Yury
     - copyright:
     2020 Webim
     */
    func getDownloadProgress() -> Int64?
    
    /**
     - returns:
     Type of error in case of problems during attachment upload.
     - author:
     Vozleev Yury
     - copyright:
     2020 Webim
     */
    func getErrorType() -> String?
    
    /**
     - returns:
     A message with the reason for the error during loading.
     - author:
     Vozleev Yury
     - copyright:
     2020 Webim
     */
    func getErrorMessage() -> String?
    
}

/**
 Shows the state of the attachment.
 - seealso:
 `MessageAttachment.getState()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
public enum AttachmentState {
    
    /**
     Some error occurred during loading.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case error
    
    /**
     File is available for download.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case ready
    
    /**
     The file is uploaded to the server.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case upload
}

/**
Contains information about attachment properties.
- seealso:
`MessageAttachment.getFileInfo()`
- author:
Nikita Lazarev-Zubov
- copyright:
2017 Webim
*/
public protocol FileInfo {
    
    /**
     - returns:
     MIME-type of an attachment file.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getContentType() -> String?
    
    /**
     - returns:
     Name of an attachment file.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getFileName() -> String
    
    /**
     - seealso:
     `ImageInfo` protocol.
     - returns:
     If a file is an image, returns information about an image; in other cases returns nil.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getImageInfo() -> ImageInfo?
    
    /**
     - returns:
     Attachment file size in bytes.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getSize() -> Int64?
    
    /**
     - important:
     Notice that this URL is short-living and is tied to a session.
     - returns:
     URL of attached file.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getURL() -> URL?
    
}

/**
 Provides information about an image.
 - seealso:
 `FileInfo.getImageInfo()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol ImageInfo {
    
    /**
     Returns a URL String of an image thumbnail.
     The maximum width and height is usually 300 px but it can be adjusted at server settings.
     To get an actual preview size before file uploading is completed, use the following code:
     ````
        let THUMB_SIZE = 300
        var width = imageInfo.getWidth()
        var height = imageInfo.getHeight()
        if (height > width) {
            width = (THUMB_SIZE * width) / height
            height = THUMB_SIZE
        } else {
            height = (THUMB_SIZE * height) / width
            width = THUMB_SIZE
        }
        ````
     - important:
     Notice that this URL is short-living and is tied to a session.
     - returns:
     URL of reduced image.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getThumbURL() -> URL
    
    /**
     - returns:
     Height of an image in pixels.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getHeight() -> Int?
    
    /**
     - returns:
     Width of an image in pixels.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getWidth() -> Int?
}

/**
 Provides information about a keyboard from script board.
 - seealso:
 `Message.getKeyboard()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol Keyboard {
    
    /**
     - returns:
     Keyboard buttons.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getButtons() -> [[KeyboardButton]]
    
    /**
     - returns:
     Kayboard state.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getState() -> KeyboardState
    
    /**
     - returns:
     Keyboard response.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getResponse() -> KeyboardResponse?
}

/**
 Supported keyboard States.
 - seealso:
 `Keyboard.getState()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum KeyboardState {
    
    /**
     A keyboard is waiting for answer.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case pending
    
    @available(*, unavailable, renamed: "pending")
    case PENDING
    
    /**
     A keyboard has response.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case completed
    
    @available(*, unavailable, renamed: "completed")
    case COMPLETED
    
    /**
     A keyboard cancelled without response.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case canceled
    
    @available(*, unavailable, renamed: "canceled")
    case CANCELLED
}

/**
 Provides information about a keyboard response to script board.
 - seealso:
 `Message.getKeyboard()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol KeyboardResponse {
    
    /**
     - returns:
     ID of a button.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getButtonID() -> String
    
    /**
     - returns:
     ID of a message.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageID() -> String
}

/**
 Keyboard button.
 - seealso:
 `Keyboard.getButtons()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol KeyboardButton {
    
    /**
     - returns:
     ID of a button.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Text of a button.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getText() -> String
}

/**
 Keyboard request.
 - seealso:
 `Message.getRequest()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol KeyboardRequest {
    
    /**
     - returns:
     Request button.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getButton() -> KeyboardButton
    
    /**
     - returns:
     Request message ID.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageID() -> String
}

/**
 Qoute.
 - seealso:
 `Message.getQuote()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol Quote {
    /**
     - returns:
     Author ID.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getAuthorID() -> String?
    
    /**
     - returns:
     Author ID.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageAttachment() -> FileInfo?
 
    /**
     - returns:
     Author ID.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageTimestamp() -> Date?
    
    /**
     - returns:
     Message ID.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageID() -> String?
    
    /**
     - returns:
     Message text.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageText() -> String?
    
    /**
     - returns:
     Message type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getMessageType() -> MessageType?
    
    /**
     - returns:
     Sender name.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getSenderName() -> String?
    
    /**
     - returns:
     Quote type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getState() -> QuoteState
}

/**
 Contains information about sticker.
 - seealso:
 `Message.getSticker()`
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
public protocol Sticker {
    
    /**
     - returns:
     Sticker ID.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    func getStickerId() -> Int
}

// MARK: -
/**
 Supported quote states.
 - seealso:
 `Quote.getType()`
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum QuoteState {
    
    /**
     Quoute is loading.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case pending
    
    @available(*, unavailable, renamed: "pending")
    case PENDING
    
    /**
     Quoute loaded.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case filled
    
    @available(*, unavailable, renamed: "filled")
    case FILLED
    
    /**
     Quote message is not found on server.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case notFound
    
    @available(*, unavailable, renamed: "notFound")
    case NOT_FOUND
}

// MARK: -
/**
 Supported file states.
 - seealso:
 `File`
 - author:
 Yury Vozleev
 - copyright:
 2020 Webim
 */
public enum FileState {
    
    /**
     File uploading error.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case error
    
    /**
     File uploaded.
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case ready
    
    /**
     File is uploading
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case upload
}

// MARK: -
/**
 Supported message types.
 - seealso:
 `Message.getType()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum MessageType {
    
    /**
     A message from operator which requests some actions from a visitor.
     E.g. choose an operator group by clicking on a button in this message.
     - seealso:
     `Message.getData()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case actionRequest
    
    @available(*, unavailable, renamed: "actionRequest")
    case ACTION_REQUEST
    
    /**
     Message type that is received after operator clicked contacts request button.
     - important:
     There's no this functionality automatic support yet. All payload is transfered inside standard text field.
     - seealso:
     `Message.getText()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case contactInformationRequest
    
    @available(*, unavailable, renamed: "contactInformationRequest")
    case CONTACTS_REQUEST
    
    /**
     A message sent by an operator which contains an attachment.
     - important:
     Notice that the method `MessageData.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - seealso:
     `MessageData.getAttachment()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case fileFromOperator
    
    @available(*, unavailable, renamed: "fileFromOperator")
    case FILE_FROM_OPERATOR
    
    /**
     A message sent by a visitor which contains an attachment.
     - important:
     Notice that the method `MessageData.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - seealso:
     `MessageData.getAttachment()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case fileFromVisitor
    
    @available(*, unavailable, renamed: "fileFromVisitor")
    case FILE_FROM_VISITOR
    
    /**
     A system information message.
     Messages of this type are automatically sent at specific events. E.g. when starting a chat, closing a chat or when an operator joins a chat.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case info
    
    @available(*, unavailable, renamed: "info")
    case INFO
    
    /**
     Message with buttons for visitor choise.
     Messages of this type are sent by script robot.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case keyboard
    
    @available(*, unavailable, renamed: "keyboard")
    case KEYBOARD
    
    /**
     Response to messages of `keyboard` type.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case keyboardResponse
    
    @available(*, unavailable, renamed: "keyboardResponse")
    case KEYBOARD_RESPONSE
    
    /**
     A text message sent by an operator.
     - seealso:
     `Message.getText()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case operatorMessage
    
    @available(*, unavailable, renamed: "operatorMessage")
    case OPERATOR
    
    /**
     A system information message which indicates that an operator is busy and can't reply to a visitor at the moment.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case operatorBusy
    
    @available(*, unavailable, renamed: "operatorBusy")
    case OPERATOR_BUSY
    
    /**
     A text message sent by a visitor.
     - seealso:
     `Message.getText()`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case visitorMessage
    
    @available(*, unavailable, renamed: "visitorMessage")
    case VISITOR
    
    /**
     A sticker message sent by a visitor.
     - seealso:
     `Message.getText()`
     - author:
     Yury Vozleev
     - copyright:
     2020 Webim
     */
    case stickerVisitor
}

/**
 Until a message is sent to the server, is received by the server and is spreaded among clients, message can be seen as "being send"; at the same time `Message.getSendStatus()` will return `sending`. In other cases - `sent`.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public enum MessageSendStatus {
    
    /**
     A message is being sent.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case sending
    
    @available(*, unavailable, renamed: "sending")
    case SENDING
    
    /**
     A message had been sent to the server, received by the server and was spreaded among clients.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    case sent
    
    @available(*, unavailable, renamed: "sent")
    case SENT
    
}
