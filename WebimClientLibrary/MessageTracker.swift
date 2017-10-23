//
//  MessageTracker.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 MessageTracker has two purposes:
 - it allows to request the messages which are above in the history;
 - it defines an interval within which message changes are transmitted to the listener (see `MessageStream.new(messageTracker messageListener:)`).
 - SeeAlso:
 `MessageStream.new(messageTracker messageListener:)`
 */
public protocol MessageTracker {
    
    /**
     Requests the messages above in history.
     Returns not more than `limit` of messages.
     If an empty list is passed, it indicated the end of the message history.
     - important:
     Notice that this method can not be called again until the callback for the previous call will be invoked.
     - parameter limit:
     A number of messages will be returned (not more than this specified number).
     - parameter completion:
     A callback.
     - throws:
     `MessageTrackerError.invalidState` if the method was called not from the thread the `WebimSession` was created in.
     `MessageTrackerError.destroyedObject` if the `MessageTracker` or the `WebimSession` was destroyed.
     `MessageTrackerError.repeatedRequest` if the previous request was not completed.
     `MessageTrackerError.invalidArgument` if `limit <= 0`.
     */
    func getNextMessages(byLimit limit: Int,
                         completion: @escaping ([Message]) -> ()) throws
    
    /**
     `MessageTracker` retains some range of messages. By using this method one can move the upper limit of this range to another message.
     - important:
     Notice that this method can not be used unless the previous call `getNextMessages(byLimit:completion:)` was finished (completion handler was invoked).
     - parameter message:
     A message reset to.
     - throws:
     `MessageTrackerError.invalidState` if the method was called not from the thread the `WebimSession` was created in.
     `MessageTrackerError.destroyedObject` if the `MessageTracker` or the `WebimSession` was destroyed.
     'MessageTrackerError.repeatedRequest` if the previous `getNextMessages(byLimit:completion:)` request was not completed.
     */
    func resetTo(message: Message) throws
    
    /**
     Destroys the `MessageTracker`.
     It is impossible to use any `MessageTracker` methods after it was destroyed.
     - throws:
     `MessageTrackerError.invalidState` if the method was called not from the thread the `WebimSession` was created in.
     */
    func destroy() throws
    
}
