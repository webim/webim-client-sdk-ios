//
//  MessageToSend.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
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
 Message subtype which is used when message is sending by visitor at the moment.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class MessageToSend: MessageImpl {
    
    // MARK: - Initialization
    init(serverURLString: String,
         id: String,
         senderName: String,
         type: MessageType,
         text: String,
         timeInMicrosecond: Int64,
         quote: Quote? = nil,
         sticker: Sticker? = nil) {
        super.init(serverURLString: serverURLString,
                   id: id,
                   keyboard: nil,
                   keyboardRequest: nil,
                   operatorID: nil,
                   quote: quote,
                   senderAvatarURLString: nil,
                   senderName: senderName,
                   sendStatus: .sending,
                   sticker: sticker,
                   type: type,
                   rawData: nil,
                   data: nil,
                   text: text,
                   timeInMicrosecond: timeInMicrosecond,
                   historyMessage: false,
                   internalID: nil,
                   rawText: nil,
                   read: false,
                   messageCanBeEdited: false,
                   messageCanBeReplied: false,
                   messageIsEdited: false)
    }
    
}
