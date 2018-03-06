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
 MessageTracker allows to request the messages which are above in the history.
 - seealso:
 `MessageStream.newMessageTracker(messageListener:)`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol MessageTracker {
    
    /**
     Requests last messages from history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, there no messages in history yet.
     If there is any previous `MessageTracker` request that is not completed, or limit of messages is less than 1, or current `MessageTracker` has been destroyed, this method will do nothing.
     Following history request can be fulfilled by `getLastMessages(byLimit:completion:)` method.
     - important:
     Notice that this method can not be called again until the callback for the previous call will be invoked.
     When an error occurs (e.g. there's one request is still running) an empty list will be returned inside completion block.
     - seealso:
     `getLastMessages(byLimit:completion:)` method.
     `destroy()` method.
     `Message` protocol.
     - parameter limitOfMessages:
     A number of messages will be returned (not more than this specified number).
     - parameter completion:
     Completion to be called on resulting array of messages if method call succeeded. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
     - parameter result:
     Resulting array of messages if method call succeeded.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getLastMessages(byLimit limitOfMessages: Int,
                         completion: @escaping (_ result: [Message]) -> ()) throws
    
    /**
     Requests the messages above in history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, the end of the message history is reached.
     If there is any previous `MessageTracker` request that is not completed, or limit of messages is less than 1, or current `MessageTracker` has been destroyed, this method will do nothing.
     - seealso:
     `destroy()` method.
     `Message` protocol.
     - important:
     Notice that this method can not be called again until the callback for the previous call will be invoked.
     When an error occurs (e.g. there's one request is still running) an empty list will be returned inside completion block.
     - parameter limitOfMessages:
     A number of messages will be returned (not more than this specified number).
     - parameter completion:
     Completion to be called on resulting array of messages if method call succeeded. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
     - parameter result:
     Resulting array of messages if method call succeeded.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getNextMessages(byLimit limitOfMessages: Int,
                         completion: @escaping (_ result: [Message]) -> ()) throws
    
    /**
     Requests all messages from history. If an empty list is passed inside completion, there no messages in history yet.
     If there is any previous `MessageTracker` request that is not completed, or current `MessageTracker` has been destroyed, this method will do nothing.
     - important:
     This method is totally independent on `getNextMessages(byLimit:completion:)` and `getLastMessages(byLimit:completion:)` methods' calls.
     When an error occurs (e.g. `MessageTracker` object is destroyed) an empty list will be returned inside completion block.
     - seealso:
     `destroy()` method.
     `Message` protocol.
     - parameter completion:
     Completion to be called on resulting array of messages if method call succeeded. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
     - parameter result:
     Resulting array of messages if method call succeeded.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getAllMessages(completion: @escaping (_ result: [Message]) -> ()) throws
    
    /**
     `MessageTracker` retains some range of messages. By using this method one can move the upper limit of this range to another message.
     If there is any previous `MessageTracker` request that is not completed, this method will do nothing.
     - important:
     Notice that this method can not be used unless the previous call `getNextMessages(byLimit:completion:)` was finished (completion handler was invoked).
     - seealso:
     `Message` protocol.
     - parameter message:
     A message reset to.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func resetTo(message: Message) throws
    
    /**
     Destroys the `MessageTracker`.
     It is impossible to use any `MessageTracker` methods after it was destroyed.
     - seealso:
     `Message` protocol.
     - throws:
     `AccessError.INVALID_THREAD` if the method was called not from the thread the `WebimSession` was created in.
     `AccessError.INVALID_SESSION` if the method was called after `WebimSession` object was destroyed.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func destroy() throws
    
}
