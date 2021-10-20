//
//  Operator.swift
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
 Abstracts a chat operator.
 - seealso:
 `MessageStream.getCurrentOperator()`
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
public protocol Operator {
    
    /**
     - returns:
     Unique ID of the operator.
     - seealso:
     `MessageStream.rateOperatorWith(id:byRate:completionHandler:)`
     `MessageStream.getLastRatingOfOperatorWith(id:)`
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Display name of the operator.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getName() -> String
    
    /**
     - returns:
     URL of the operator’s avatar or `nil` if does not exist.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2017 Webim
     */
    func getAvatarURL() -> URL?
    
    /**
     - returns:
     Display operator title.
     - author:
     Anna Frolova
     - copyright:
     2021 Webim
     */
    func getTitle() -> String?
    
    /**
     - returns:
     Display operator additional Information.
     - author:
     Anna Frolova
     - copyright:
     2021 Webim
     */
    func getInfo() -> String?
}
