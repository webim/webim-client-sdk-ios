//
//  File.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 11.03.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressIndicator: UIView {
    
    // MARK: - Properties
    
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
    
    private var startValue: Float = 0
    private let backgrondCircleLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
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
        
        backgrondCircleLayer.position = center
        backgrondCircleLayer.path = path.cgPath
        
        circleLayer.position = center
        circleLayer.path = path.cgPath
    }
    
    func enableRotationAnimation() {
        circleLayer.add(rotationAnimation, forKey: "rotation")
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = startValue
        startValue = value
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        circleLayer.strokeEnd = CGFloat(value)
        
        circleLayer.add(animation, forKey: "strokeEnd")
    }
    
    func updateImageDownloadProgress(_ progress: Float) {
        if self.isHidden {
            self.isHidden = false
            self.enableRotationAnimation()
        }
        self.setProgressWithAnimation(
            duration: 0.1,
            value: progress
        )
    }
    
    func setDefaultSetup() {
        self.lineWidth = 1
        self.strokeColor = WMCircleProgressIndicatorCyan.cgColor
        self.isUserInteractionEnabled = false
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Private methods
    
    private func setup() {
        backgrondCircleLayer.lineWidth = lineWidth
        backgrondCircleLayer.fillColor = nil
        backgrondCircleLayer.strokeColor = WMCircleProgressIndicatorLightGrey.cgColor
        layer.addSublayer(backgrondCircleLayer)
        
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = nil
        circleLayer.strokeColor = strokeColor
        layer.addSublayer(circleLayer)
    }
    
}
