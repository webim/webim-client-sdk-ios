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

final class StartViewController: UIViewController {
    
    // MARK: - Properties
    // MARK: Outlets
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var welcomeTextView: UITextView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStartChatButton()
        setupSettingsButton()
        
        // Xcode does not localize UITextView text automatically.
        welcomeTextView.text = NSLocalizedString(StartView.WELCOME_TEXT.rawValue,
                                                 tableName: "Main",
                                                 bundle: .main,
                                                 value: "",
                                                 comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupColorScheme()
        setupNavigationItem()
    }
    
    @IBAction func unwindFromSettings(_: UIStoryboardSegue) {
        // No need to do anything.
    }
    
    // MARK: Private methods
    
    private func setupStartChatButton() {
        startChatButton.layer.cornerRadius = CORNER_RADIUS
        startChatButton.layer.borderWidth = LIGHT_BORDER_WIDTH
        startChatButton.layer.borderColor = buttonBorderColor.color().cgColor
    }
    
    private func setupSettingsButton() {
        settingsButton.layer.cornerRadius = CORNER_RADIUS
        settingsButton.layer.borderWidth = BORDER_WIDTH
    }
    
    private func setupColorScheme() {
        view.backgroundColor = backgroundMainColor.color()
        navigationController?.navigationBar.barTintColor = backgroundSecondaryColor.color()
        
        welcomeTextView.backgroundColor = backgroundMainColor.color()
        welcomeTextView.textColor = textMainColor.color()
        welcomeTextView.tintColor = textTintColor.color()
        
        startChatButton.backgroundColor = buttonColor.color()
        startChatButton.setTitleColor(textButtonColor.color(),
                                      for: .normal)
        
        settingsButton.setTitleColor(textButtonTransparentColor.color(),
                                     for: .normal)
        settingsButton.setTitleColor(textButtonTransparentHighlightedColor.color(),
                                     for: .highlighted)
        settingsButton.layer.borderColor = textButtonTransparentColor.color().cgColor
    }
    
    private func setupNavigationItem() {
        let navigationItemImageView = UIImageView(image: ColorScheme.shared.navigationItemImage())
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
    }
    
}
