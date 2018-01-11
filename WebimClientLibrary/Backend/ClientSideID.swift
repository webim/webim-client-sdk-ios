//
//  StringID.swift
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
 Class which is responsible for generating random IDs (e.g. for sending messages).
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
struct ClientSideID {
    
    // MARK: - Constants
    enum StringSize: Int {
        case CLIENT_SIDE_ID = 32
    }
    
    // MARK: - Methods
    static func generateClientSideID() -> String {
        return generateRandomString(ofCharactersNumber: StringSize.CLIENT_SIDE_ID.rawValue)
    }
    
    // MARK: - Private methods
    static func generateRandomString(ofCharactersNumber numberOfCharacters: Int) -> String {
        let letters: NSString = "abcdef0123456789"
        let length = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< numberOfCharacters {
            let random = arc4random_uniform(length)
            var nextChar = letters.character(at: Int(random))
            randomString = randomString + (NSString(characters: &nextChar,
                                                    length: 1) as String)
        }
        
        return randomString
    }
    
}
