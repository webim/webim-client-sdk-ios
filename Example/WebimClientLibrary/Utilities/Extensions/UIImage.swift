//
//  UIImage.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 14.10.17.
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

extension UIImage {
    
    // MARK: - Methods
    func roundImage() -> UIImage {
        let minEdge = min(self.size.height,
                          self.size.width)
        let size = CGSize(width: minEdge,
                          height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size,
                                               false,
                                               0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        self.draw(in: CGRect(origin: CGPoint.zero,
                             size: size),
                  blendMode: .copy,
                  alpha: 1.0)
        
        context.setBlendMode(.copy)
        context.setFillColor(UIColor.clear.cgColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero,
                                                 size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero,
                                                     size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result
    }
    
}
