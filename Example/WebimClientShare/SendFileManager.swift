//
//  SendFileManager.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 11.03.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import Foundation
import WebimMobileSDK
import UIKit

struct SendingFile {
    var fileName: String
    var fileID: String
    var totalBytes: Int64
    var totalBytesSent: Int64
    var state: MessageSendStatus

    var progress: Float {
        Float(totalBytesSent) / Float(totalBytes)
    }

    init(
        fileName: String,
        fileID: String,
        totalBytes: Int64 = -1,
        totalBytesSent: Int64 = -1,
        state: MessageSendStatus = .sending,
        id: String = ""
    ) {
        self.fileName = fileName
        self.fileID = fileID
        self.totalBytesSent = totalBytesSent
        self.totalBytes = totalBytes
        self.state = state
    }

}
