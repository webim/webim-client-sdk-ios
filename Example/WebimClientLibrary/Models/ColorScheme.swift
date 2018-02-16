//
//  ColorScheme.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 07.02.18.
//  Copyright © 2018 Webim. All rights reserved.
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

final class ColorScheme {
    
    // MARK: - Properties
    static let shared = ColorScheme()
    var option: Option
    
    // MARK: - Initialization
    private init() {
        if let settings = UserDefaults.standard.object(forKey: USER_DEFAULTS_NAME) as? [String : String] {
            if let rawValue = settings[UserDefaultsKey.COLOR_SCHEME.rawValue],
                let option = Option(rawValue: rawValue) {
                self.option = option
            } else {
                self.option = .CLASSIC
            }
        } else {
            self.option = .CLASSIC
        }
    }
    
    // MARK: - Methods
    
    func navigationItemImage() -> UIImage {
        switch option {
        case .CLASSIC:
            return #imageLiteral(resourceName: "LogoWebimNavigationBar")
        case .DARK:
            return #imageLiteral(resourceName: "LogoWebimNavigationBar_dark")
        }
    }
    
    func backButtonImage() -> UIImage {
        switch option {
        case .CLASSIC:
            return #imageLiteral(resourceName: "Back")
        case .DARK:
            return #imageLiteral(resourceName: "Back_dark")
        }
    }
    
    func closeChatButtonImage() -> UIImage {
        switch option {
        case .CLASSIC:
            return #imageLiteral(resourceName: "Close")
        case .DARK:
            return #imageLiteral(resourceName: "Close_dark")
        }
    }
    
    func scrollToBottomButtonImage() -> UIImage {
        switch option {
        case .CLASSIC:
            return #imageLiteral(resourceName: "ScrollToBottom")
        case .DARK:
            return #imageLiteral(resourceName: "ScrollToBottom_dark")
        }
    }
    
    func keyboardAppearance() -> UIKeyboardAppearance {
        switch option {
        case .CLASSIC:
            return .light
        case .DARK:
            return .dark
        }
    }
    
    // MARK: -
    enum Option: String {
        case CLASSIC = "classic"
        case DARK = "dark"
    }
    
}

// MARK: -
struct SchemeColor {
    
    // MARK: - Properties
    private let classic: UIColor
    private let dark: UIColor
    
    // MARK: - Initialization
    init(classic: UIColor,
         dark: UIColor) {
        self.classic = classic
        self.dark = dark
    }
    
    // MARK: - Methods
    
    func color() -> UIColor {
        return colorWith(scheme: ColorScheme.shared.option)
    }
    
    // MARK: Private methods
    private func colorWith(scheme: ColorScheme.Option) -> UIColor {
        switch scheme {
        case .CLASSIC:
            return classic
        case .DARK:
            return dark
        }
    }
    
}
