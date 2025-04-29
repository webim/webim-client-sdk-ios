//
//  UIWindow.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 29.01.2025.
//  Copyright © 2025 Webim. All rights reserved.
//

import UIKit

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
