//
//  CountProgressRingView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 07.07.2026.
//

import UIKit

/// A small ring showing progress toward a count-based routine's daily target (e.g. "2/4").
final class CountProgressRingView: UIView {

    private let lineWidth: CGFloat = 3
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.isUserInteractionEnabled = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        addSubview(countLabel)

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -4)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * .pi
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func configure(current: Int16, target: Int16, progressColor: UIColor, trackColor: UIColor, textColor: UIColor) {
        let safeTarget = max(target, 1)
        let progress = min(CGFloat(current) / CGFloat(safeTarget), 1.0)
        trackLayer.strokeColor = trackColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.strokeEnd = progress
        countLabel.text = "\(current)/\(safeTarget)"
        countLabel.textColor = textColor
    }
}
