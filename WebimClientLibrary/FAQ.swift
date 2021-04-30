//
//  FAQ.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 07.02.19.
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

/**
 - attention:
 This mechanism can't be used as is. It requires that client server to support this mechanism.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public protocol FAQ {
    
    /**
     Resumes FAQ networking.
     - important:
     FAQ is created as paused. To start using it firstly you should call this method.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func resume() throws
    
    /**
     Pauses FAQ networking.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func pause() throws
    
    /**
     Destroys FAQ. After that any FAQ methods are not available.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if FAQ was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func destroy() throws
    
    /**
     Requests category. If nil is passed inside completion, there no category with this id.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter id:
     Category ID.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getCategory(id: String, completionHandler: @escaping (_ result: Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests categories for app. If nil is passed inside completion, there no category with this id.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter application:
     Application name.
     - parameter language:
     Language.
     - parameter departmentKey:
     Department key.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getCategoriesForApplication(completionHandler: @escaping (_ result: Result<[String], FAQGetCompletionHandlerError>) -> Void)
    
     /**
     Requests category from cache. If nil is passed inside completion, there no category with this id in cache.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter id:
     Category ID.
     - parameter completionHandler:
     Completion to be called on category if method call succeeded.
     - parameter result:
     Resulting category if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getCachedCategory(id: String, completionHandler: @escaping (_ result: Result<FAQCategory, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests item. If nil is passed inside completion, there no item with this id.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter id:
     Item ID.
     - parameter openFrom:
     Item open from this source.
     - parameter completionHandler:
     Completion to be called on item if method call succeeded.
     - parameter result:
     Resulting item if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getItem(id: String, openFrom: FAQItemSource?, completionHandler: @escaping (_ result: Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
    Requests item from cache. If nil is passed inside completion, there no item with this id.
    - seealso:
    `destroy()` method.
    `FAQItem` protocol.
    - parameter id:
    Item ID.
    - parameter openFrom:
    Item open from this source.
    - parameter completionHandler:
    Completion to be called on item if method call succeeded.
    - parameter result:
    Resulting item if method call succeeded.
    - throws:
    `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
    `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
    - author:
    Nikita Kaberov
    - copyright:
    2019 Webim
    */
    func getCachedItem(id: String, openFrom: FAQItemSource?, completionHandler: @escaping (_ result: Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Requests structure. If nil is passed inside completion, there no structure with this id.
     - seealso:
     `destroy()` method.
     `FAQStructure` protocol.
     - parameter id:
     Structure ID.
     - parameter completionHandler:
     Completion to be called on structure if method call succeeded.
     - parameter result:
     Resulting structure if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func getStructure(id: String, completionHandler: @escaping (_ result: Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void)
    
    /**
    Requests structure from cache. If nil is passed inside completion, there no structure with this id.
    - seealso:
    `destroy()` method.
    `FAQStructure` protocol.
    - parameter id:
    Structure ID.
    - parameter completionHandler:
    Completion to be called on structure if method call succeeded.
    - parameter result:
    Resulting structure if method call succeeded.
    - throws:
    `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
    `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
    - author:
    Nikita Kaberov
    - copyright:
    2019 Webim
    */
    func getCachedStructure(id: String, completionHandler: @escaping (_ result: Result<FAQStructure, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Like selected FAQ item.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter item:
     FAQ item.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func like(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Dislike selected FAQ item.
     - seealso:
     `destroy()` method.
     `FAQItem` protocol.
     - parameter item:
     FAQ item.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func dislike(item: FAQItem, completionHandler: @escaping (Result<FAQItem, FAQGetCompletionHandlerError>) -> Void)
    
    /**
     Search categories by query.
     - seealso:
     `destroy()` method.
     `FAQCategory` protocol.
     - parameter query:
     Search word or phrase.
     - parameter category:
     Category for search.
     - parameter limitOfItems:
     A number of items will be returned (not more than this specified number).
     - parameter completionHandler:
     Completion to be called if method call succeeded.
     - parameter result:
     Resulting items array if method call succeeded.
     - throws:
     `FAQAccessError.invalidThread` if the method was called not from the thread the FAQ was created in.
     `FAQAccessError.invalidFaq` if the method was called after FAQ object was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    func search(query: String, category: String, limitOfItems: Int, completionHandler: @escaping (_ result: Result<[FAQSearchItem], FAQGetCompletionHandlerError>) -> Void)
}

// MARK: -
/**
 Error types that can be throwed by FAQ methods.
 - seealso:
 `FAQ` methods.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum FAQAccessError: Error {
    
    /**
     Error that is thrown if the method was called not from the thread the FAQ was created in.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case invalidThread
    
    @available(*, unavailable, renamed: "invalidThread")
    case INVALID_THREAD
    
    /**
     Error that is thrown if FAQ was destroyed.
     - author:
     Nikita Kaberov
     - copyright:
     2019 Webim
     */
    case invalidFaq
    
    @available(*, unavailable, renamed: "invalidFaq")
    case INVALID_FAQ
}

// MARK: -
/**
 Error types that can be throwed by FAQ methods.
 - seealso:
 `FAQ` methods.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum FAQGetCompletionHandlerError: Error {
    case error
    
    @available(*, unavailable, renamed: "error")
    case ERROR
}

// MARK: -
/**
 Item will be open from this source.
 - seealso:
 `FAQ` methods.
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
public enum FAQItemSource {
    /**
    Item is opened from search.
    - author:
    Nikita Kaberov
    - copyright:
    2019 Webim
    */
    case search
    
    @available(*, unavailable, renamed: "search")
    case SEARCH
    
    /**
    Item is opened from tree.
    - author:
    Nikita Kaberov
    - copyright:
    2019 Webim
    */
    case tree
    
    @available(*, unavailable, renamed: "tree")
    case TREE
}
