//
//  ObservableView.swift
//  Webim.Ru
//
//  Created by Anna Frolova on 16.02.2022.
//  Copyright © 2021 _webim_. All rights reserved.
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
import WebimClientLibrary

extension UIView {
    var globalPoint: CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }

    func pointInView(view: UIView) -> CGPoint {
        return self.convert(self.frame.origin, to: view)
    }
}

@objc protocol WMToolbarBackgroundViewDelegate: AnyObject {
    func showToolbarWithHeight(_ height: CGFloat)
}

class WMToolbarBackgroundView: UIView {
    @IBOutlet weak var delegate: WMToolbarBackgroundViewDelegate?
    override func layoutSubviews() {
        super.layoutSubviews()
        if let window = self.window {
            let height = window.frame.height - self.convert(self.frame.origin, to: window).y
            if height > 0 {
                self.delegate?.showToolbarWithHeight(height)
            } else {
                self.delegate?.showToolbarWithHeight(self.frame.height)
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
}
