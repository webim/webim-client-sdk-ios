//
//  UIImage.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 14.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func roundImage(size: CGSize? = nil) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge,
                          height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
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
