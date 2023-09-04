//
//  WMSettingsViewController+SelectUser.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 24.04.2023.
//  Copyright © 2023 Webim. All rights reserved.
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
import WebimMobileSDK

extension WMSettingsViewController: SelectUserDelegate {
    func showUserList() {
        let vc = SelectVisitorViewController.loadViewControllerFromXib()
        vc.initialSetup()
        vc.set(delegate: self)
        vc.set(sourceView: selectVisitorCell.accessoryImageView)
        vc.setArrowDirection(arrowDirection: .up)
        rotateArrow()
        present(vc, animated: true)
    }
    
    private func rotateArrow() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            let rotateTransform = CGAffineTransformRotate(.identity, .pi)
            self.selectVisitorCell.accessoryImageView.transform = rotateTransform
        }
    }
}


extension WMSettingsViewController: SelectVisitorDelegate {
    func didSelect(visitor: SelectVisitorViewController.VisitorRows) {
        var demoVisitor: DemoVisitor?
        switch visitor {
        case .unauthorized:
            demoVisitor = nil
        case .fedor:
            demoVisitor = .fedor
        case .semion:
            demoVisitor = .semion
        }
        
        visitorFieldsManager.set(selectedVisitor: demoVisitor)
        selectVisitorCell.usernameLabel.text = visitor.rawValue.localized
    }
    
    func controllerWillDisappear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.selectVisitorCell.accessoryImageView.transform = .identity
        }
    }
}
