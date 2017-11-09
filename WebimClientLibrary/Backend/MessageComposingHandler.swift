//
//  MessageComposingHandlerImpl.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 14.08.17.
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
 Class that is responsible for sending drafts of visitor typed messages to an operator side chat.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
final class MessageComposingHandler {
    
    // MARK: - Constants
    private enum Deadline: Int {
        case DRAFT_SENDING_INTERVAL = 1 // Second
        case RESET_STATUS_DELAY = 5 // Second
    }
    
    
    // MARK: - Properties
    private let queue: DispatchQueue
    private let webimActions: WebimActions
    private var latestDraft: String?
    private var resetTimer: Timer?
    private var updateDraftScheduled: Bool?
    
    
    // MARK: - Initialization
    init(withWebimActions webimActions: WebimActions,
         queue: DispatchQueue) {
        self.webimActions = webimActions
        self.queue = queue
    }
    
    
    // MARK: - Methods
    
    func setComposing(draft: String?) {
        latestDraft = draft
        
        if updateDraftScheduled != true {
            send(draft: draft)
            updateDraftScheduled = true
            
            queue.asyncAfter(deadline: (DispatchTime.now() + .seconds(Deadline.DRAFT_SENDING_INTERVAL.rawValue)),
                             execute: {
                                self.updateDraftScheduled = false
                                
                                if self.latestDraft != draft {
                                    self.send(draft: self.latestDraft)
                                }
            })
        }
        
        resetTimer?.invalidate()
        
        if draft != nil {
            let resetTime = Date().addingTimeInterval(Double(Deadline.RESET_STATUS_DELAY.rawValue))
            resetTimer = Timer(fireAt: resetTime,
                               interval: 0.0,
                               target: self,
                               selector: #selector(resetTypingStatus),
                               userInfo: nil,
                               repeats: false)
            RunLoop.main.add(resetTimer!,
                             forMode: .commonModes)
        }
    }
    
    // MARK: Private methods
    @objc private func resetTypingStatus() {
        queue.async {
            self.webimActions.set(visitorTyping: false,
                                  draft: nil,
                                  deleteDraft: false)
        }
    }
    
    private func send(draft: String?) {
        let visitorTyping = (draft == nil) ? false : (draft!.isEmpty ? false : true)
        let deleteDraft = (draft == nil) ? true : (draft!.isEmpty ? true : false)
        webimActions.set(visitorTyping: visitorTyping,
                         draft: draft,
                         deleteDraft: deleteDraft)
    }
    
}
