//
//  UIImage.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 27.11.2019.
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

extension UIImage {
    public enum FlipOrientation {
        case vertically, horizontally
    }
    
    public func flipImage(_ orientation: FlipOrientation) -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: size.width / 2, y: size.height / 2)
        
        switch orientation {
        case .horizontally:
            context.scaleBy(x: -1.0, y: -1.0)
        case .vertically:
            context.scaleBy(x: -1.0, y: 1.0)
        }
        
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        let cgImage: CGImage! = self.cgImage
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    public func colour(_ colour: UIColor) -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        context.setBlendMode(.multiply)
        
        let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let cgImage: CGImage! = self.cgImage
        context.clip(to: rectangle, mask: cgImage)
        colour.setFill()
        context.fill(rectangle)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
