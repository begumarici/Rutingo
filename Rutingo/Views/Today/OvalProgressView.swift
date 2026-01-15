//
//  OvalProgressView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 1.01.2026.
//

import UIKit

class OvalProgressView: UIView {
    
    // MARK: - Properties
    private var backgroundLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(64)
        label.textColor = AppColors.primary
        label.textAlignment = .center
        return label
    }()

    private let dailyFocusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(18)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        label.text = "daily_focus".localized
        return label
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayers() {
        backgroundLayer.fillColor = AppColors.cardBackground.cgColor
        backgroundLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = AppColors.secondary.withAlphaComponent(0.5).cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round
        trackLayer.zPosition = 10
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = AppColors.primary.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        progressLayer.zPosition = 10
        layer.addSublayer(progressLayer)
    }
    
    private func setupUI() {
        addSubview(percentageLabel)
        addSubview(dailyFocusLabel)
        addSubview(contentView)
        
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            percentageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            dailyFocusLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 4),
            dailyFocusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            contentView.topAnchor.constraint(equalTo: dailyFocusLabel.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = bounds.insetBy(dx: 16, dy: 16)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 40)
        
        backgroundLayer.path = path.cgPath
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: Double) {
        let percentage = Int(progress * 100)
        percentageLabel.text = String(format: "percent_format".localized, percentage)
        
        let clampedProgress = min(max(progress, 0), 1)
        progressLayer.strokeEnd = CGFloat(clampedProgress)
    }
    
    func setCompleted() {
        percentageLabel.text = String(format: "percent_format".localized, 100)
        progressLayer.strokeEnd = 1.0
        progressLayer.strokeColor = AppColors.primary.cgColor
    }
}
