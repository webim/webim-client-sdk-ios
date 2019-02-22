//
//  FAQClient.swift
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
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class FAQClientBuilder {
    
    // MARK: - Properties
    private var baseURL: String?
    private var completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor?
    
    // MARK: - Builder methods
    
    func set(baseURL: String) -> FAQClientBuilder {
        self.baseURL = baseURL
        
        return self
    }
    
    func set(completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor?) -> FAQClientBuilder {
        self.completionHandlerExecutor = completionHandlerExecutor
        
        return self
    }
    
    func build() -> FAQClient {
        let faqRequestLoop = FAQRequestLoop(completionHandlerExecutor: completionHandlerExecutor!)
        
        return FAQClient(withFAQRequestLoop: faqRequestLoop,
                        faqActions: FAQActions(baseURL: baseURL!, faqRequestLoop: faqRequestLoop))
    }
    
}

// MARK: -
/**
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class FAQClient {
    
    // MARK: - Properties
    private let faqRequestLoop: FAQRequestLoop
    private let faqActions: FAQActions
    
    // MARK: - Initialization
    init(withFAQRequestLoop faqRequestLoop: FAQRequestLoop,
         faqActions: FAQActions) {
        self.faqRequestLoop = faqRequestLoop
        self.faqActions = faqActions
    }
    
    // MARK: - Methods
    
    func start() {
        faqRequestLoop.start()
    }
    
    func pause() {
        faqRequestLoop.pause()
    }
    
    func resume() {
        faqRequestLoop.resume()
    }
    
    func stop() {
        faqRequestLoop.stop()
    }
    
    func getActions() -> FAQActions {
        return faqActions
    }
    
}
