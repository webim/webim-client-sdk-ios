//
//  SessionDestroyer.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.09.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class SessionDestroyer {
    
    // MARK: - Properties
    var actions: [() -> ()]?
    var destroyed: Bool?
    
    
    // MARK: - Methods
    
    func add(action: @escaping () -> ()) {
        self.actions?.append(action)
    }
    
    func destroy() {
        if !isDestroyed() {
            destroyed = true
            
            if let actions = actions {
                for action in actions {
                    action()
                }
            }
        }
    }
    
    func isDestroyed() -> Bool {
        return destroyed == true
    }
    
}
