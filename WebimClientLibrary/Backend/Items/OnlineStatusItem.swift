//
//  OnlineStatusItem.swift
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
 Raw values equal to field names received in responses from server (except `unknown` case which is custom).
 * `BUSY_OFFLINE` - user can't send messages at all;
 * `BUSY_ONLINE` - user send offline messages, but server can return an error;
 * `OFFLINE` - user can send offline messages;
 * `ONLINE` - user can send online and offline messages;
 * `UNKNOWN` - session has not received data from server.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
enum OnlineStatusItem: String {
    case busyOffline = "busy_offline"
    case busyOnline = "busy_online"
    case offline = "offline"
    case online = "online"
    case unknown = "unknown"
}
