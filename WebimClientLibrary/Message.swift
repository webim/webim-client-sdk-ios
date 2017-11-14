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
 A message is an immutable object. It means that changing some of the message fields creates a new object. Messages can be compared by using `isEqual(to:)` method for searching messages with the same set of fields or by ID (`message1.getID() == message2.getID()`) for searching logically identical messages. ID is formed on the client side when sending a message (`MessageStream.send(message:,isHintQuestion:)` or `MessageStream.sendFile(atPath:mimeType:completion:)).
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol Message {
    
    /**
     Messages of the types `MessageType.FILE_FROM_OPERATOR` and `MessageType.FILE_FROM_VISITOR` can contain attachments.
     - important:
     Notice that this method may return nil even in the case of previously listed types of messages. E.g. if a file is being sent.
     - returns:
     The attachment of the message.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getAttachment() -> MessageAttachment?
    
    /**
     Messages of type `MessageType.ACTION_REQUEST` contain custom dictionary.
     - returns:
     Dictionary which contains custom fields or nil if there's no such custom fields.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getData() -> [String : Any?]?
    
    /**
     Every message can be uniquefied by its ID. Messages also can be lined up by its IDs.
     - important:
     ID doesn’t change while changing the content of a message.
     - returns:
     Unique ID of the message.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     ID of a message sender, if the sender is an operator.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getOperatorID() -> String?
    
    /**
     - returns:
     URL of a sender's avatar.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getSenderAvatarFullURLString() -> String?
    
    /**
     - returns:
     Name of a message sender.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getSenderName() -> String
    
    /**
     - returns:
     `MessageSendStatus.SENT` if a message had been sent to the server, was received by the server and was delivered to all the clients; `MessageSendStatus.SENDING` if not.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getSendStatus() -> MessageSendStatus
    
    /**
     - returns:
     Text of the message.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getText() -> String
    
    /**
     - returns:
     Epoch time (in ms) the message was processed by the server.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getTime() -> Int64
    
    /**
     - returns:
     Type of a message.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getType() -> MessageType
    
    /**
     Method which can be used to compare if two Message objects have identical contents.
     - parameter message:
     Second `Message` object.
     - returns:
     True if two `Message` objects are identical and false otherwise.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func isEqual(to message: Message) -> Bool
    
}

/**
 Contains information about an attachment file.
 - SeeAlso:
 `Message.getAttachment()`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol MessageAttachment {
    
    /**
     - returns:
     MIME-type of an attachment file.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getContentType() -> String?
    
    /**
     - returns:
     Name of an attachment file.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getFileName() -> String?
    
    /**
     - returns:
     If a file is an image, returns information about an image; in other cases returns nil.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getImageInfo() -> ImageInfo?
    
    /**
     - returns:
     Attachment file size in bytes.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getSize() -> Int64?
    
    /**
     A URL String of a file.
     - important:
     Notice that this URL is short-living and is tied to a session.
     - returns:
     URL String of the file.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getURLString() -> String?
    
}

/**
 Contains information about an image.
 - SeeAlso:
 `MessageAttachment.getImageInfo()`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
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
     URL String of reduced image.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getThumbURLString() -> String
    
    /**
     - returns:
     Height of an image in pixels.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getHeight() -> Int?
    
    /**
     - returns:
     Width of an image in pixels.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getWidth() -> Int?
}


// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum MessageType: String {
    
    /**
     A message from operator which requests some actions from a visitor.
     E.g. choose an operator group by clicking on a button in this message.
     - SeeAlso:
     `Message.getData()`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case ACTION_REQUEST = "action_request"
    
    /**
     A message sent by an operator which contains an attachment.
     - important:
     Notice that the method `Message.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - SeeAlso:
     `Message.getAttachment()`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case FILE_FROM_OPERATOR = "file_from_operator"
    
    /**
     A message sent by a visitor which contains an attachment.
     - important:
     Notice that the method `Message.getAttachment()` may return nil even for messages of this type. E.g. if a file is being sent.
     - SeeAlso:
     `Message.getAttachment()`
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case FILE_FROM_VISITOR = "file_from_visitor"
    
    /**
     A system information message.
     Messages of this type are automatically sent at specific events. E.g. when starting a chat, closing a chat or when an operator joins a chat.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case INFO = "info"
    
    /**
     A text message sent by an operator.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OPERATOR = "operator"
    
    /**
     A system information message which indicates that an operator is busy and can't reply to a visitor at the moment.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case OPERATOR_BUSY = "operator_busy"
    
    /**
     A text message sent by a visitor.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case VISITOR = "visitor"

}

/**
 Until a message is sent to the server, is received by the server and is spreaded among clients, message can be seen as "being send"; at the same time `Message.getSendStatus()` will return `SENDING`. In other cases - `SENT`.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public enum MessageSendStatus {
    
    /**
     A message is being sent.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case SENDING
    
    /**
     A message had been sent to the server, received by the server and was spreaded among clients.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    case SENT
    
}
