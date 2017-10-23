//
//  WebimSession.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 02.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

public protocol WebimSession {
    
    /**
     Resumes session networking.
     - important:
     Session is created as paused. To start using it firstly you should call this method.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func resume() throws
    
    /**
     Pauses session networking.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func pause() throws
    
    /**
     Destroys session. After that any session methods are not available.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func destroy() throws
    
    /**
     - returns:
     A `MessageStream` object attached to this session. Each invocation of this method returns the same object.
     */
    func getStream() -> MessageStream
    
}
