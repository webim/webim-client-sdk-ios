//
//  StartViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 01.00.2017.
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

import UIKit
import WebimMobileWidget
import WebimMobileSDK

final class WMStartViewController: UIViewController {

    // MARK: - Private Properties
    private var unreadMessageCounter: Int = 0

    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var visitorFieldsManager = WMVisitorFieldsManager()

    // MARK: - Outlets
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var appVersion: UILabel!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var welcomeTextView: UITextView!
    @IBOutlet var startChatButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var unreadMessageCounterView: UIView!
    @IBOutlet var unreadMessageCounterLabel: UILabel!
    @IBOutlet var unreadMessageCounterActivity: UIActivityIndicatorView!

    @IBOutlet var startConstraint: NSLayoutConstraint!
    @IBOutlet var logoConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOrientation()
        setupStartChatButton()
        setupSettingsButton()
        setupLogoTapGestureRecognizer()
        setupNavigationBarUpdater()
        updateNavigationBar()
        self.unreadMessageCounterLabel.layer.masksToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Workaround for displaying correctly the position of the text inside weclomeTextView
        welcomeTextView.text = NSLocalizedString("xS6-J8-Sm9.text", tableName: "WMStartViewController", comment: "")
        welcomeTextView.sizeToFit()
        setupColorScheme()
        welcomeTextView.textContainer.lineFragmentPadding = 5
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.17
        let stringAttributes = [NSAttributedString.Key.paragraphStyle: style]
        welcomeLabel.attributedText = NSAttributedString(string: "Welcome to the WebimClientLibrary app!".localized, attributes: stringAttributes)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.appVersion.text = "v. " + version
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startWebimSession()
        updateMessageCounter()
    }

    @IBAction func startChat(_ sender: Any? = nil) {
        presentChatViewController(
            openFromNotification: sender == nil,
            visitorData: visitorFieldsManager.getVisitorData(for: .currentVisitor)
        )
    }

    @IBAction func openSettings() {
        let settingsVc = WMSettingsViewController.loadViewControllerFromXib()
        navigationController?.pushViewController(settingsVc, animated: true)
    }

    // MARK: - Private methods
    @objc private func presentWMLogsViewController(_ gesture: UIGestureRecognizer) {
        if WMTestManager.testModeEnabled() {
            let logsViewController = WMLogsViewController.loadViewControllerFromXib()
            navigationController?.pushViewController(logsViewController, animated: true)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.checkOrientation()
    }

    private func checkOrientation() {
        DispatchQueue.main.async {
            let orientation = UIApplication.shared.statusBarOrientation.isLandscape
            self.startConstraint.constant = orientation ? 20 : 50
            self.logoConstraint.constant = orientation ? -10 : 30
        }
    }

    private func setupStartChatButton() {
        startChatButton.layer.cornerRadius = 8.0
        startChatButton.layer.borderWidth = 1.0
        startChatButton.layer.borderColor = startChatButtonBorderColour
    }

    private func setupSettingsButton() {
        settingsButton.layer.cornerRadius = 8.0
        settingsButton.layer.borderWidth = 1.0
    }

    private func setupLogoTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(presentWMLogsViewController(_:)))
        logoImageView.addGestureRecognizer(gesture)
        logoImageView.isUserInteractionEnabled = true
    }

    private func setupColorScheme() {
        view.backgroundColor = startViewBackgroundColour

        welcomeLabel.textColor = welcomeLabelTextColour

        welcomeTextView.textColor = welcomeTextViewTextColour
        welcomeTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: welcomeTextViewForegroundColour
        ]

        startChatButton.backgroundColor = startChatButtonBackgroundColour
        startChatButton.setTitleColor(startChatTitleColour, for: .normal)

        settingsButton.setTitleColor(settingsButtonTitleColour, for: .normal)

        settingsButton.layer.borderColor = settingButtonBorderColour
    }

    private func updateMessageCounter() {
        DispatchQueue.main.async {
            if self.unreadMessageCounter > 0 {
                self.unreadMessageCounterView.alpha = 1
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
                self.unreadMessageCounterActivity.stopAnimating()
                self.unreadMessageCounterLabel.text = "\(self.unreadMessageCounter)"
            } else {
                self.unreadMessageCounterView.alpha = 0
            }
        }
    }

    private func setupNavigationBarUpdater() {
        NavigationBarUpdater.shared.set(navigationController: navigationController)
    }

    private func updateNavigationBar() {
        NavigationBarUpdater.shared.update(with: .defaultStyle)
        NavigationBarUpdater.shared.set(isNavigationBarVisible: true)
    }

    private func presentChatViewController(openFromNotification: Bool, visitorData: Data? = nil) {
        WebimServiceController.currentSession.stopSession()
        
        let widget = ExternalWidgetBuilder().buildDefaultWidget(
            remoteNotificationSystem: .apns,
            visitorFieldsData: visitorData,
            webimLogger: WidgetLogManager.shared,
            webimLoggerVerbosityLevel: .debug,
            availableLogTypes: [.manualCall,.messageHistory,.networkRequest,.undefined],
            openFromNotification: openFromNotification
        )
        
        self.navigationController?.pushViewController(widget, animated: true)
    }

    private func startWebimSession() {
        WebimServiceController.shared.stopSession()
        let currentVisitorFieldsData = visitorFieldsManager.getVisitorData(for: .currentVisitor)
        _ = WebimServiceController.shared.createSession(jsonData: currentVisitorFieldsData)
        WebimServiceController.currentSession.set(unreadByVisitorMessageCountChangeListener: self)
        WebimServiceController.shared.fatalErrorHandlerDelegate = self
        unreadMessageCounter = WebimServiceController.currentSession.getUnreadMessagesByVisitor()
    }

}

// MARK: - WEBIM: MessageListener
extension WMStartViewController: UnreadByVisitorMessageCountChangeListener {

    // MARK: - Methods
    func changedUnreadByVisitorMessageCountTo(newValue: Int) {
        if unreadMessageCounter == 0 {
            DispatchQueue.main.async {
                self.unreadMessageCounterActivity.stopAnimating()
            }
        }
        unreadMessageCounter = newValue
        updateMessageCounter()
    }
}



// MARK: - FatalErrorHandler
extension WMStartViewController: FatalErrorHandlerDelegate {

    // MARK: - Methods
    func showErrorDialog(withMessage message: String) {
        alertDialogHandler.showCreatingSessionFailureDialog(withMessage: message)
        startChatButton.isHidden = true
        unreadMessageCounterView.isHidden = true
    }

}
