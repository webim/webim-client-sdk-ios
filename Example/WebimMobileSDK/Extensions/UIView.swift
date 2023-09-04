//
//  UIView.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 16/09/2019.
//  Copyright © 2019 Webim. All rights reserved.
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

extension UIView {
    static func loadXibView() -> Self {
        let identifier = "\(Self.self)"
        let nib = UINib(nibName: identifier, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! Self
        view.loadXibViewSetup()
        return view
    }
    
    @objc
    func loadXibViewSetup() { }

    func loadViewFromNib(_ nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setWidth(_ width: CGFloat) {
        var newFrame = frame
        newFrame.size.width = width
        self.frame = newFrame
    }
    
    func setHeight(_ height: CGFloat) {
        var newFrame = frame
        newFrame.size.height = height
        self.frame = newFrame
    }
}
