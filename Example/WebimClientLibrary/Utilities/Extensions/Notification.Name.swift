//
//  Notification.Name.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 16/09/2019.
//  Copyright © 2019 Webim. All rights reserved.
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

extension Notification.Name {
    static let shouldShowQuoteEditBar = Notification.Name("shouldShowQuoteEditBar")
    static let shouldHideQuoteEditBar = Notification.Name("shouldHideQuoteEditBar")
    
    static let shouldCopyMessage = Notification.Name("shouldCopyMessage")
    static let shouldDeleteMessage = Notification.Name("shouldDeleteMessage")
    
    static let shouldSetVisitorTypingDraft = Notification.Name("shouldSetVisitorTypingDraft")
    
    static let shouldShowScrollButton = Notification.Name("shouldAddScrollButton")
    static let shouldHideScrollButton = Notification.Name("shouldHideScrollButton")
    
    static let shouldShowRatingDialog = Notification.Name("shouldShowRatingDialog")
    static let shouldRateOperator = Notification.Name("shouldRateOperator")
    
    static let shouldShowFile = Notification.Name("shouldShowFile")
    
    static let shouldChangeOperatorStatus = Notification.Name("shouldChangeOperatorStatus")
    static let shouldUpdateOperatorInfo = Notification.Name("shouldUpdateOperatorInfo")
    
    static let shouldHidePopupActionsViewController = Notification.Name("shouldHidePopupActionsViewController")
    static let shouldHideOverlayWindow = Notification.Name("shouldHideOverlayWindow")
    
    static let shouldHideRatingDialogViewController = Notification.Name("shouldHideRatingDialogViewController")
    
    static let shouldSendKeyboardRequest = Notification.Name("shouldSendKeyboardRequest")
}
