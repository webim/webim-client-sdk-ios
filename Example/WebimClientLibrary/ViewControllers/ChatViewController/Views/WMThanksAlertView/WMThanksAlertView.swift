//
//  WMThanksAlertView.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 19.04.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

class WMThanksAlertView: UIView {

    private let showAlertTime = DispatchTimeInterval.seconds(2)
    private let moveAlertAnimationTime = 0.4
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCancelGesture()
        self.alpha = 0
    }
    
    func showAlert() {
        
        DispatchQueue.main.async {
            self.present()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + showAlertTime) {
            self.hide()
        }
    }
    
    func present() {
        self.alpha = 1
        UIView.animate(withDuration: moveAlertAnimationTime) {
            self.frame = self.showRect()
        }
    }
    
    func hide() {
        UIView.animate(withDuration: moveAlertAnimationTime) {
            self.frame = self.hideRect()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + moveAlertAnimationTime) {
            self.alpha = 0
        }
        
    }
    
    func showRect() -> CGRect {
        let width = self.superview?.frame.width ?? self.frame.width
        return CGRect(x: 0, y: 0, width: width, height: self.frame.height)
    }
    
    func hideRect() -> CGRect {
        let width = self.superview?.frame.width ?? self.frame.width
        return CGRect(x: 0, y: -self.frame.height, width: width, height: self.frame.height)
    }
    
    @objc
    func hideWithoutAnimation() {
        self.frame = self.hideRect()
        self.alpha = 0
    }
    
    private func setupCancelGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideWithoutAnimation)
        )
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}
