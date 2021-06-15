//
//  SpinningIndicator.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 14.10.2019.
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

import Foundation
import UIKit

class SpinningIndicator: UIView {
    
    // MARK: - Properties
    var animating: Bool = true {
        didSet {
            updateAnimation()
        }
    }
    var lineWidth: CGFloat = 2 {
        didSet {
            circleLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    var strokeColor: CGColor = UIColor.red.cgColor {
        didSet {
            circleLayer.strokeColor = strokeColor
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    private let circleLayer = CAShapeLayer()
    private let strokeEndAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = 2.5
        group.repeatCount = .infinity
        group.animations = [animation]

        return group
    }()
    private let strokeStartAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let group = CAAnimationGroup()
        group.duration = 2.5
        group.repeatCount = .infinity
        group.animations = [animation]

        return group
    }()
    private let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 4
        animation.repeatCount = .infinity
        
        return animation
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - circleLayer.lineWidth / 2
        
        let startAngle = CGFloat(-Double.pi / 2) // -90°
        let endAngle = startAngle + CGFloat(Double.pi * 2)
        let path = UIBezierPath(
            arcCenter: CGPoint.zero,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        circleLayer.position = center
        circleLayer.path = path.cgPath
    }
    
    // MARK: - Private methods
    private func setup() {
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = nil
        circleLayer.strokeColor = strokeColor
        layer.addSublayer(circleLayer)
        updateAnimation()
    }
    
    private func updateAnimation() {
        if animating {
            circleLayer.isHidden = false
            circleLayer.add(strokeEndAnimation, forKey: "strokeEnd")
            circleLayer.add(strokeStartAnimation, forKey: "strokeStart")
            circleLayer.add(rotationAnimation, forKey: "rotation")
        } else {
            circleLayer.isHidden = true
            circleLayer.removeAnimation(forKey: "strokeEnd")
            circleLayer.removeAnimation(forKey: "strokeStart")
            circleLayer.removeAnimation(forKey: "rotation")
        }
    }
}
