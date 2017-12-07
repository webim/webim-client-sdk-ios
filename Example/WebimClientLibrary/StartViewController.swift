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

/**
 Information view controller which is shown when tha app is started.
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2017 Webim
 */
class StartViewController: UIViewController {
    
    // MARK: - Properties
    // MARK: Outlets
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        setupStartChatButton()
        setupSettingstButton()
    }
    
    @IBAction func unwindFromSettings(_: UIStoryboardSegue) {
        // No need to do anything.
    }
    
    // MARK: Private methods
    
    /**
     Sets up navigation item.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupNavigationItem() {
        let navigationItemImageView = UIImageView(image: #imageLiteral(resourceName: "LogoWebimNavigationBar"))
        navigationItemImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationItemImageView
    }
    
    /**
     Sets up Start Chat button.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupStartChatButton() {
        startChatButton.layer.cornerRadius = CORNER_RADIOUS
    }
    
    /**
     Sets up Settings button.
     - returns:
     No return value.
     - Author:
     Nikita Lazarev-Zubov
     - Copyright:
     2017 Webim
     */
    private func setupSettingstButton() {
        settingsButton.layer.cornerRadius = CORNER_RADIOUS
        settingsButton.layer.borderWidth = BORDER_WIDTH
        settingsButton.layer.borderColor = GREY_COLOR.cgColor
    }
    
}
