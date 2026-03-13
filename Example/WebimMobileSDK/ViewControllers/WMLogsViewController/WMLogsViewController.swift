//
//  WMLogsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 16.06.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
import WebimMobileWidget

class WMLogsViewController: UIViewController {
    
    lazy var navigationBarUpdater = NavigationBarUpdater()
    private let queue: DispatchQueue = DispatchQueue.init(label: "WMLogsManager")

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupScrollButtonImage()
        let doneItem = UIBarButtonItem(title: "Write to file", style: .done, target: self, action: #selector(writeToFile))
        navigationItem.rightBarButtonItem = doneItem
    }

    @IBAction private func scrollToBottom() {
        if !textView.text.isEmpty {
            let location = textView.text.count - 1
            let bottom = NSRange(location: location, length: 1)
            textView.scrollRangeToVisible(bottom)
        }
    }

    private func setupTextView() {
        let logs = WidgetLogManager.shared.getLogs()
        logs.forEach { log in
            addLog(log)
        }
    }

    private func addLog(_ log: String) {
        textView.text.append("\(log) \n \n")
    }

    private func setupScrollButtonImage() {
        scrollButton.setTitle(nil, for: .normal)
        scrollButton.setBackgroundImage(scrollButtonImage, for: .normal)
    }

    private func updateNavigationBar() {
        navigationBarUpdater.set(navigationController: navigationController)
        navigationBarUpdater.set(isNavigationBarVisible: true)
        navigationBarUpdater.update(with: .defaultStyle)
    }
    
    @objc
    private func writeToFile() {
        guard let logFile = generateLogFilsUrl() else {
            return
        }
        queue.sync {
            let text: String
            if textView.text.count > 10 * 1024 * 1024 {
                text = String(textView.text.dropFirst(textView.text.count - 10 * 1024 * 1024))
            } else {
                text = textView.text
            }
            try? text.write(to: logFile, atomically: true, encoding: .utf8)
            navigationItem.rightBarButtonItem?.title = "Saved!"
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func generateLogFilsUrl() -> URL? {

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentDirectory.appendingPathComponent("WebimDemoAppLog.txt")
    }
}

extension WMLogsViewController: WidgetLogManagerObserver {
    func didGetNewLog(log: String) {
        addLog(log)
        print(log)
    }
}
