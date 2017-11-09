//
//  MessageTracker.swift
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
 MessageTracker has two purposes:
 - it allows to request the messages which are above in the history;
 - it defines an interval within which message changes are transmitted to the listener (see `MessageStream.new(messageTracker messageListener:)`).
 - SeeAlso:
 `MessageStream.new(messageTracker messageListener:)`
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
public protocol MessageTracker {
    
    /**
     Requests the messages above in history. Returns not more than `limit` of messages. If an empty list is passed inside completion, the end of the message history is reached.
     If there is any previous `MessageTracker` request that is not completed of limit of messages is less than 1, this method will do nothing.
     - important:
     Notice that this method can not be called again until the callback for the previous call will be invoked.
     - parameter limit:
     A number of messages will be returned (not more than this specified number).
     - parameter completion:
     A callback.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func getNextMessages(byLimit limit: Int,
                         completion: @escaping ([Message]) -> ()) throws
    
    /**
     `MessageTracker` retains some range of messages. By using this method one can move the upper limit of this range to another message.
     If there is any previous `MessageTracker` request that is not completed, this method will do nothing.
     - important:
     Notice that this method can not be used unless the previous call `getNextMessages(byLimit:completion:)` was finished (completion handler was invoked).
     - parameter message:
     A message reset to.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func resetTo(message: Message) throws
    
    /**
     Destroys the `MessageTracker`.
     It is impossible to use any `MessageTracker` methods after it was destroyed.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    func destroy() throws
    
}
