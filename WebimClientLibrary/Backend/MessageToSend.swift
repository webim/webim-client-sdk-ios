//
//  MessageToSend.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class MessageToSend: MessageImpl {
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String,
         id: String,
         senderName: String,
         type: MessageType,
         text: String,
         timeInMicrosecond: Int64) {
        super.init(withServerURLString: serverURLString,
                   id: id,
                   operatorID: nil,
                   senderAvatarURLString: nil,
                   senderName: senderName,
                   type: type,
                   data: nil,
                   text: text,
                   timeInMicrosecond: timeInMicrosecond,
                   attachment: nil,
                   historyMessage: false,
                   internalID: nil,
                   rawText: nil)
    }
    
    // MARK: - Methods
    override func getSendStatus() -> MessageSendStatus {
        return MessageSendStatus.SENDING
    }
    
}
