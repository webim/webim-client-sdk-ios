//
//  ChatTestView.swift
//  WebimClientLibrary_Example
//
//  Created by Anna Frolova on 04.08.2021.
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

import Foundation
import UIKit
import WebimClientLibrary

protocol ChatTestViewDelegate: UIViewController {
    func getSearchMessageText() -> String
    func showSearchResult(searcMessages: [Message]?)
    func toogleAutotest() -> Bool
    func clearHistory()
}

class ChatTestView: UIView {
    @IBOutlet var autotestButton: UIButton!
    @IBOutlet var clearHistory: UIButton!
    @IBOutlet var operatorInfo: UIButton!
    private weak var delegate: ChatTestViewDelegate!
    private var titleViewOperatorTitle: String?
    private var titleViewOperatorInfo: String?
    
    override func loadXibViewSetup() {
        clearHistory.setImage(deleteImage, for: .normal)
    }
    
    func setupView(delegate: ChatTestViewDelegate) {
        self.delegate = delegate
    }
    
    func setupOperatorInfo(titleViewOperatorTitle: String?, titleViewOperatorInfo: String?) {
        self.titleViewOperatorInfo = titleViewOperatorInfo
        self.titleViewOperatorTitle = titleViewOperatorTitle
    }
    
    @IBAction func runAutotestClicked() {
        let autotestRunning = self.delegate.toogleAutotest()
        self.autotestButton.setTitle(autotestRunning ? "Stop autotest" : "Run autotest", for: .normal)
    }
    
    @IBAction func hideTap() {
        self.alpha = 0
    }
    
    @IBAction func searchTap() {
        let searchText = self.delegate.getSearchMessageText()
        if searchText.isEmpty {
            self.delegate.showSearchResult(searcMessages: nil)
        } else {
            WebimServiceController.shared.currentSession().searchMessagesBy(query: searchText, completionHandler: self)
        }
    }
    
    @IBAction func clearHistoryTap(_ sender: Any) {
        let alert = UIAlertController(title: "Очистить историю",
                                      message: "Очистка истории",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "ОК",
            style: .default,
            handler: { _ in
                WebimServiceController.currentSession.clearHistory()
                self.delegate.clearHistory()
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )
        let actions = [okAction, cancelAction]
        actions.forEach({ alert.addAction($0) })
        self.delegate.present(alert, animated: true)
    }
    
    @IBAction func operatorInfotap(_ sender: Any) {
        let alertDialogHandler = UIAlertHandler(delegate: delegate)
        let operatorTitle = titleViewOperatorTitle ?? ""
        let operatorInfo = titleViewOperatorInfo ?? ""
        alertDialogHandler.showOperatorInfo(
            withMessage: "\("Agent title".localized): \(operatorTitle.description) \n \("Additional information".localized): \(operatorInfo.description) "
        )
    }
    
}

extension ChatTestView: SearchMessagesCompletionHandler {
    
    func onSearchMessageSuccess(query: String, messages: [Message]) {
        self.delegate.showSearchResult(searcMessages: messages)
        print(messages)
    }
    
    func onSearchMessageFailure(query: String) {
        self.delegate.showSearchResult(searcMessages: [])
        print("onSearchMessageFailure")
    }
    
}
