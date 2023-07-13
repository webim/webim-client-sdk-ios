//
//  WMTestManager.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 06.09.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

import UIKit
import WebimMobileSDK

enum WMTestDialogAction {
    case sendMessage
    case editMessage
    case deleteMessage
    case replyToMessage
    case sendTyping
    case sendRandomImage
    case sendRandomFile
    case reactToMessage
    case noActinon
}

class WMTestManager: NSObject {
    static let testDialogActionsArray = createTestDialogActionsArray()
    private static let userDefaultsTestModeEnabledKey = WMKeychainWrapper.webimKeyPrefix + "userDefaultsTestModeEnabledKey"
    
    static func toogleTestMode() -> Bool {
        let boolValue = !UserDefaults.standard.bool(forKey: userDefaultsTestModeEnabledKey)
        UserDefaults.standard.set(boolValue, forKey: userDefaultsTestModeEnabledKey)
        return boolValue
    }
    
    static func testModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsTestModeEnabledKey)
    }
    
    private static func createTestDialogActionsArray() -> [WMTestDialogAction] {
        var testDialogActionsArray = [WMTestDialogAction]()
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.editMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.deleteMessage, count: 5)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.replyToMessage, count: 10)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendTyping, count: 2)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendRandomImage, count: 3)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.sendRandomFile, count: 3)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.reactToMessage, count: 2)
        testDialogActionsArray += Array(repeating: WMTestDialogAction.noActinon, count: 10)
        return testDialogActionsArray
    }
    
    static var testDialogModeEnabled = false
    static var testTimer: Timer?
}

//extension ChatViewController {
//    func runRandomAction() {
//        if WMTestManager.testDialogModeEnabled {
//            DispatchQueue.main.async {
//                guard let message = self.randomMessage() else { return }
//
//                switch WMTestManager.testDialogActionsArray.randomElement() {
//                case .sendMessage:
//                    self.sendMessage(self.randomMessageText())
//                case .editMessage:
//                    WebimServiceController.currentSession.edit(
//                        message: message,
//                        text: "edit" + self.randomMessageText(),
//                        completionHandler: self
//                    )
//                case .deleteMessage:
//                    WebimServiceController.currentSession.delete(
//                        message: message,
//                        completionHandler: self
//                    )
//                case .replyToMessage:
//                    WebimServiceController.currentSession.reply(
//                        message: self.randomMessageText(),
//                        repliedMessage: message,
//                        completion: { }
//                    )
//                case .sendTyping:
//                    WebimServiceController.currentSession.setVisitorTyping(draft: "setVisitorTyping text")
//                case .sendRandomImage:
//                    self.sendRandomImage()
//                case .sendRandomFile:
//                    self.sendRandomFile()
//                case .reactToMessage:
//                    break
//                case .noActinon:
//                    break
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//    @objc func fireTestTimer() {
//        runRandomAction()
//    }
//
//    func stopDialogTest() {
//        WMTestManager.testTimer?.invalidate()
//    }
//
//    func sendRandomFile() {
//        guard let file = "test file text".data(using: .utf8) else { return }
//        WebimServiceController.currentSession.send(
//            file: file,
//            fileName: "testFile.txt",
//            mimeType: "text/plain",
//            completionHandler: self
//        )
//    }
//
//    func replyToMessage() {
//        guard let messageToReact = self.randomMessage() else { return }
//        guard let reaction = [ReactionString.dislike, ReactionString.like].randomElement() else { return }
//
//        WebimServiceController.currentSession.react(
//            reaction: reaction,
//            message: messageToReact,
//            completionHandler: self
//        )
//    }
//
//    private func sendRandomImage() {
//        let image = UIImage(named: "AppIcon")
//        let data = image!.jpegData(compressionQuality: 1.0)
//
//        WebimServiceController.currentSession.send(
//            file: data!,
//            fileName: "testImage.jpg",
//            mimeType: "image/jpeg",
//            completionHandler: self
//        )
//    }
//
//    func toggleAutotest() -> Bool {
//        WMTestManager.testDialogModeEnabled.toggle()
//        updateTestModeState()
//        return WMTestManager.testDialogModeEnabled
//    }
//
//    func updateTestModeState() {
//        if WMTestManager.testDialogModeEnabled {
//            WMTestManager.testTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(fireTestTimer), userInfo: nil, repeats: true)
//        } else {
//            WMTestManager.testTimer?.invalidate()
//        }
//    }
//
//    private func randomMessageText() -> String {
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd.MM.yyyy hh.mm.ss"
//        return "test ios visitor " + formatter.string(from: date)
//    }
//
//    private func randomMessage() -> Message? {
//        return self.messages().randomElement()
//    }
//}
