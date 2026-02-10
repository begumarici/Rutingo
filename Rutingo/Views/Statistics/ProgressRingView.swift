//
//  ProgressRingView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.12.2025.
//

import UIKit

class ProgressRingView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        
        // ios 17+ trait observation
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.updateColors()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = AppColors.secondaryCardBackground.cgColor
        trackLayer.lineWidth = 8
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = AppColors.primary.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = min(max(progress, 0), 1)
        
        if animated {
            progressLayer.removeAllAnimations()
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = clampedProgress
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            progressLayer.strokeEnd = clampedProgress
            progressLayer.add(animation, forKey: "progressAnimation")
        } else {
            progressLayer.removeAllAnimations()
            progressLayer.strokeEnd = clampedProgress
        }
        
        progressLayer.strokeEnd = clampedProgress
    }
    
    // MARK: - Helpers
    private func updateColors() {
        trackLayer.strokeColor = AppColors.secondaryCardBackground.cgColor
        progressLayer.strokeColor = AppColors.primary.cgColor
    }
}
