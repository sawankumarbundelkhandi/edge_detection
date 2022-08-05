//
//  ShutterButton.swift
//  WeScan
//
//  Created by Boris Emorine on 2/26/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// A simple button used for the shutter.
final class ShutterButton: UIControl {
    
    private let outterRingLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    
    private let outterRingRatio: CGFloat = 0.80
    private let innerRingRatio: CGFloat = 0.75
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateInnerCircleLayer(forHighlightedState: isHighlighted)
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(outterRingLayer)
        layer.addSublayer(innerCircleLayer)
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        impactFeedbackGenerator.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        outterRingLayer.frame = rect
        outterRingLayer.path = pathForOutterRing(inRect: rect).cgPath
        outterRingLayer.fillColor = UIColor.white.cgColor
        outterRingLayer.rasterizationScale = UIScreen.main.scale
        outterRingLayer.shouldRasterize = true
        
        innerCircleLayer.frame = rect
        innerCircleLayer.path = pathForInnerCircle(inRect: rect).cgPath
        innerCircleLayer.fillColor = UIColor.white.cgColor
        innerCircleLayer.rasterizationScale = UIScreen.main.scale
        innerCircleLayer.shouldRasterize = true
    }
    
    // MARK: - Animation
    
    private func animateInnerCircleLayer(forHighlightedState isHighlighted: Bool) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        var values = [CATransform3DMakeScale(1.0, 1.0, 1.0), CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(0.93, 0.93, 0.93), CATransform3DMakeScale(0.9, 0.9, 0.9)]
        if isHighlighted == false {
            values = [CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(1.0, 1.0, 1.0)]
        }
        animation.values = values
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = isHighlighted ? 0.35 : 0.10
        
        innerCircleLayer.add(animation, forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }
    
    // MARK: - Paths
    
    private func pathForOutterRing(inRect rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: rect)
        
        let innerRect = scaleAndCenter(rect: rect, ratio: outterRingRatio)
        let innerPath = UIBezierPath(ovalIn: innerRect).reversing()
        
        path.append(innerPath)
        
        return path
    }
    
    private func pathForInnerCircle(inRect rect: CGRect) -> UIBezierPath {
        let rect = scaleAndCenter(rect: rect, ratio: innerRingRatio)
        let path = UIBezierPath(ovalIn: rect)
        
        return path
    }
    
    private func scaleAndCenter(rect: CGRect, ratio: CGFloat) -> CGRect {
        let scaleTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaledRect = rect.applying(scaleTransform)
        
        let translateTransform = CGAffineTransform(translationX: rect.minX * (1 - ratio) + (rect.width - scaledRect.width) / 2.0, y: rect.minY * (1 - ratio) + (rect.height - scaledRect.height) / 2.0)
        let translatedRect = scaledRect.applying(translateTransform)
        
        return translatedRect
    }
    
}
