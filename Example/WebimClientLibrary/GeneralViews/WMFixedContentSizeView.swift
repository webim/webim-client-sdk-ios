//
//  FixedContentSizeView.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 20.04.2021.
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

protocol WMFixedWidthViewDelegate: AnyObject {
    func viewWillResize(_ view: UIView)
}

class WMFixedWidthView: UIView {
    weak var delegate: WMFixedWidthViewDelegate?
    var widthConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixViewSize()
    }
    
    func fixViewSize() {
        if let superview = self.superview {
            
            if self.frame.width != superview.frame.width {
                self.widthConstraint?.constant = superview.frame.width
                self.delegate?.viewWillResize(self)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        self.widthConstraint = widthConstraint
        NSLayoutConstraint.activate([widthConstraint])
        fixViewSize()
    }
}

class WMFixedContentSizeView: UIView {

    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixViewSize()
    }
    
    func fixViewSize() {
        if let subview = self.subviews.first {
            
            if self.frame.height != subview.frame.height {
                self.heightConstraint?.constant = subview.frame.height
            }
                
            if self.frame.width != subview.frame.width {
                self.widthConstraint?.constant = subview.frame.width
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        fixViewSize()
    }
}
