//
//  SettingsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 28.11.17.
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

import PopupDialog
import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private var popupDialogHandler: PopupDialogHandler?
    private var settingsTableViewController: SettingsTableViewController?
    
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIButton!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupDialogHandler = PopupDialogHandler(delegate: self)
        
        setupNavigationItem()
        setupSaveButton()
        
        hideKeyboardOnTap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupColorScheme()
    }
    
    func setupColorScheme() {
        view.backgroundColor = backgroundMainColor.color()
        
        navigationController?.navigationBar.barTintColor = backgroundSecondaryColor.color()
        setupVisibleNavigationItemsElements()
        
        saveButton.backgroundColor = buttonColor.color()
        saveButton.setTitleColor(textButtonColor.color(),
                                 for: .normal)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if let viewController = segue.destination as? SettingsTableViewController,
            segue.identifier == "EmbedSettingsTable" {
            settingsTableViewController = viewController
            
            viewController.delegate = self
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        if identifier != "EmbedSettingsTable",
            !settingsValidated() {
            return false
        }
        
        return true
    }
    
    // MARK: Private methods
    
    private func setupNavigationItem() {
        setupVisibleNavigationItemsElements()
        
        // Need for title view to be centered.
        let emptyBarButton = UIButton(type: .custom)
        emptyBarButton.setImage(#imageLiteral(resourceName: "Empty"),
                                for: .normal)
        emptyBarButton.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyBarButton)
    }
    
    private func setupVisibleNavigationItemsElements() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(ColorScheme.shared.backButtonImage(),
                            for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = BackButton.ACCESSIBILITY_LABEL.rawValue.localized
        backButton.accessibilityHint = BackButton.ACCESSIBILITY_HINT.rawValue.localized
        backButton.addTarget(self,
                             action: #selector(onBackButtonClick(sender:)),
                             for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let navigationItemImageView = UIImageView(image: ColorScheme.shared.navigationItemImage())
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
    }
    
    @objc
    private func onBackButtonClick(sender: UIButton) {
        if settingsValidated() {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func settingsValidated() -> Bool {
        guard let accountName = settingsTableViewController?.accountNameTextField.text,
            !accountName.isEmpty else {
                popupDialogHandler?.showSettingsAlertDialog(withMessage: SettingsErrorDialog.WRONG_ACCOUNT_NAME_MESSAGE.rawValue.localized)
                
                return false
        }
        guard let location = settingsTableViewController?.locationTextField.text,
            !location.isEmpty else {
                popupDialogHandler?.showSettingsAlertDialog(withMessage: SettingsErrorDialog.WRONG_LOCATION_MESSAGE.rawValue.localized)
                
                return false
        }
        
        set(accountName: accountName,
            location: location,
            pageTitle: settingsTableViewController?.pageTitleTextField.text)
        
        return true
    }
    
    private func set(accountName: String,
                     location: String,
                     pageTitle: String?) {
        Settings.shared.accountName = accountName
        Settings.shared.location = location
        if let pageTitle = pageTitle,
            !pageTitle.isEmpty {
            Settings.shared.pageTitle = pageTitle
        }
        
        Settings.shared.save()
    }
    
    private func setupSaveButton() {
        saveButton.layer.borderWidth = LIGHT_BORDER_WIDTH
        saveButton.layer.borderColor = buttonBorderColor.color().cgColor
        saveButton.layer.cornerRadius = CORNER_RADIUS
    }
    
}
