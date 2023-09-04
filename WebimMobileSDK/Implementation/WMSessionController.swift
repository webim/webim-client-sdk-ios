//
//  WMSessionController.swift
//  WebimClientLibrary
//
//  Created by Аслан Кутумбаев on 11.07.2023.
//  
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

// MARK: - Constants
fileprivate enum WMKeychainWrapperName: String {
    case main = "ru.webim.WebimClientSDKiOS.visitor."
}
fileprivate enum WMKeychainWrapperMainPrefix: String {
    case sessionID = "session_id"
}

class WMSessionController {
    
    static var shared: WMSessionController = WMSessionController()
    
    private var sessions: [WeakRefference<WebimSessionImpl>] = []
    
    func add(session: WebimSessionImpl) {
        sessions.append(WeakRefference(session))
    }
    
    func remove(session: WebimSessionImpl) {
        sessions.removeAll { $0.value === session }
    }
    
    func session(visitorName: String, accountName: String, location: String, mobileChatInstance: String) -> WebimSessionImpl? {
        let userDefaultsKey = WMKeychainWrapperName.main.rawValue + visitorName + "." + mobileChatInstance
        let userDefaults = WMKeychainWrapper.standard.dictionary(forKey: userDefaultsKey)
        
        guard let sessionID = userDefaults?[WMKeychainWrapperMainPrefix.sessionID.rawValue] as? String else {
            return nil
        }
        
        if let _ = sessions.filter({ $0.value?.getSessionID() == sessionID }).first?.value {
            WebimInternalLogger.shared.log(entry: "New session initialization prevented. Current session already exist")
        } else {
            WebimInternalLogger.shared.log(entry: "Session dosen't exist. New session initialization required")
        }
        
        return sessions
            .filter { $0.value?.getSessionID() == sessionID }
            .first?
            .value
    }
}

