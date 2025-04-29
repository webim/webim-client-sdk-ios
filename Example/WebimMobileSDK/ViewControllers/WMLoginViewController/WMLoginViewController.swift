//
//  WMLoginViewControlle.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 13.01.2025.
//  Copyright © 2025 Webim. All rights reserved.
//

import UIKit

final class WMLoginViewController: UIViewController {
    
    @IBOutlet weak var webimLogo: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var logoConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOrientation()
        setupStartChatButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        welcomeTextView.sizeToFit()
        setupColorScheme()
        welcomeTextView.textContainer.lineFragmentPadding = 5
    }
    
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
    
    @IBAction func startWork(_ sender: Any) {
        let vc = WMSelectAccountViewController.loadViewControllerFromXib()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func checkOrientation() {
        DispatchQueue.main.async {
            let orientation = UIWindow.isLandscape
            self.logoConstraint.constant = orientation ? 0 : 108
            self.welcomeConstraint.constant = orientation ? 10 : 48
        }
    }

    private func setupStartChatButton() {
        startButton.layer.cornerRadius = 8.0
    }

    private func setupColorScheme() {
        view.backgroundColor = startViewBackgroundColour

        welcomeLabel.textColor = welcomeLabelTextColour

        welcomeTextView.textColor = welcomeTextViewTextColour
        welcomeTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: welcomeTextViewForegroundColour
        ]

        startButton.backgroundColor = startChatButtonBackgroundColour
        startButton.setTitleColor(startChatTitleColour, for: .normal)

        startButton.setTitleColor(settingsButtonTitleColour, for: .normal)

        startButton.layer.borderColor = settingButtonBorderColour.cgColor
    }
    
}
    
