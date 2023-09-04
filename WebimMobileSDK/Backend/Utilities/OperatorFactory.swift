//
//  OperatorFactory.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 19.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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
 Mapper class that is responsible for converting internal operator model objects to public ones.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class OperatorFactory {
    
    // MARK: - Properties
    var serverURLString: String
    
    // MARK: - Initialization
    init(withServerURLString serverURLString: String) {
        self.serverURLString = serverURLString
    }
    
    // MARK: - Methods
    func createOperatorFrom(operatorItem: OperatorItem?) -> OperatorImpl? {
        guard let operatorItem = operatorItem else { return nil }
        var avatarURL: String? = nil
        if let url = operatorItem.getAvatarURLString(),
            !url.isEmpty {
            avatarURL = serverURLString + url
        }
        return OperatorImpl(id: operatorItem.getID(),
                            name: operatorItem.getFullName(),
                            avatarURLString: avatarURL,
                            title: operatorItem.getTitle(),
                            info: operatorItem.getInfo())
    }
    
}
