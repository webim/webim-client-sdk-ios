//
//  NavigationBarUpdater.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 01.07.2022.
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

class NavigationControllerManager {

    private var isBarVisible: Bool?
    private var additionalView: UIView?
    private var navigationController: UINavigationController?

    init() {
        navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }

    func update(with style: NavigationBarStyle, removeOriginBorder: Bool = false) {

        let isEnabled: Bool = false
        let isTranslucent: Bool = false
        let barTintColor: UIColor = navigationBarTintColour
        var backgroundColor: UIColor

        switch style {
        case .connected:
            backgroundColor = navigationBarBarTintColour
        case .disconnected:
            backgroundColor = navigationBarNoConnectionColour
        case .clear:
            backgroundColor = navigationBarClearColour
        case .defaultStyle:
            backgroundColor = navigationBarBarTintColour
        }

        navigationController?.setTopBar(
            isEnabled: isEnabled,
            isTranslucent: isTranslucent,
            barTintColor: barTintColor,
            backgroundColor: backgroundColor)

        additionalView?.backgroundColor = backgroundColor

        guard removeOriginBorder else { return }
        self.removeOriginBorder()
    }

    func setAdditionalHeight(_ height: CGFloat = 22, with color: UIColor = navigationBarBarTintColour) {
        additionalView = produceAdditionalView(color: color)
        navigationController?.topViewController?.view.addSubview(additionalView ?? UIView())
        if #available(iOS 11.0, *) {
            navigationController?.topViewController?.additionalSafeAreaInsets.top = height
        }
        setupAdditionalViewConstraints(with: height)
        additionalView?.layer.zPosition = 0
    }

    func getAdditionalView() -> UIView {
        return additionalView ?? UIView()
    }

    func removeAdditionalView() {
        additionalView?.removeFromSuperview()
        additionalView = nil
    }

    func removeOriginBorder() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = navigationController?.navigationBar.standardAppearance
            navBarAppearance?.shadowColor = .clear

            navigationController?.navigationBar.standardAppearance = navBarAppearance ?? UINavigationBarAppearance()
            navigationController?.navigationBar.compactAppearance = navBarAppearance ?? UINavigationBarAppearance()
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance ?? UINavigationBarAppearance()
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        navigationController?.navigationBar.layoutIfNeeded()
    }

    func restoreOriginBorder() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = navigationController?.navigationBar.standardAppearance
            navBarAppearance?.shadowColor = nil

            navigationController?.navigationBar.standardAppearance = navBarAppearance ?? UINavigationBarAppearance()
            navigationController?.navigationBar.compactAppearance = navBarAppearance ?? UINavigationBarAppearance()
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance ?? UINavigationBarAppearance()
        } else {
            navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
            navigationController?.navigationBar.shadowImage = nil
        }
        navigationController?.navigationBar.layoutIfNeeded()
    }

    func reset() {
        restoreOriginBorder()
        removeAdditionalView()
    }

    func set(isNavigationBarVisible: Bool) {
        isBarVisible = isNavigationBarVisible
        navigationController?.setNavigationBarHidden(!isNavigationBarVisible, animated: true)
    }

    private func produceAdditionalView(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }

    private func setupAdditionalViewConstraints(with height: CGFloat) {
        additionalView?.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(height)
        }
    }

    enum NavigationBarStyle {
        case connected
        case disconnected
        case clear
        case defaultStyle
    }
}
