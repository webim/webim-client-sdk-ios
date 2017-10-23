//
//  StringID.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 09.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class ClientSideID {
    
    // MARK: - Constants
    enum StringSize: Int {
        case CLIENT_SIDE_ID = 32
    }
    
    // MARK: - Methods
    static func generateClientSideID() -> String {
        return generateClientSideString(ofCharactersNumber: StringSize.CLIENT_SIDE_ID.rawValue)
    }
    
    // MARK: - Private methods
    static func generateClientSideString(ofCharactersNumber numberOfCharacters: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< numberOfCharacters {
            let random = arc4random_uniform(length)
            var nextChar = letters.character(at: Int(random))
            randomString = randomString + (NSString(characters: &nextChar, length: 1) as String)
        }
        
        return randomString
    }
    
}
