//
//  CombinedStatsCardView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 31.12.2025.
//

import UIKit

class CombinedStatsCardView: UIView {
    
    // MARK: - UI Components
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    private let leftStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private let rateTitle: UILabel = {
        let label = UILabel()
        label.text = "completion_rate".localized
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.tertiary
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let progressRing: ProgressRingView = {
        let ring = ProgressRingView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        return ring
    }()
    
    private let rateValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondary
        return view
    }()
    
    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()
    
    private let streakStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let streakTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "current_perfect_streak".localized
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.tertiary
        return label
    }()
    
    private let streakValueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bold(20)
        label.textColor = .black
        return label
    }()
    
    private let totalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let totalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "total_completed".localized
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.tertiary
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bold(20)
        label.textColor = .black
        return label
    }()
    
    private let activeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let activeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "active_routines".localized
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.tertiary
        return label
    }()
    
    private let activeValueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bold(20)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.cardBackground
        layer.cornerRadius = Layout.cornerRadius
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        leftStack.addArrangedSubview(rateTitle)
        leftStack.addArrangedSubview(progressRing)
        progressRing.addSubview(rateValue)
        
        streakStack.addArrangedSubview(streakTitleLabel)
        streakStack.addArrangedSubview(streakValueLabel)
        
        totalStack.addArrangedSubview(totalTitleLabel)
        totalStack.addArrangedSubview(totalValueLabel)
        
        activeStack.addArrangedSubview(activeTitleLabel)
        activeStack.addArrangedSubview(activeValueLabel)
        
        rightStack.addArrangedSubview(streakStack)
        rightStack.addArrangedSubview(totalStack)
        rightStack.addArrangedSubview(activeStack)
        
        mainStack.addArrangedSubview(leftStack)
        mainStack.addArrangedSubview(divider)
        mainStack.addArrangedSubview(rightStack)
        
        addSubview(mainStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            leftStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.35),
            
            progressRing.widthAnchor.constraint(equalToConstant: 100),
            progressRing.heightAnchor.constraint(equalToConstant: 100),
            
            rateValue.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
            rateValue.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
            
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalTo: mainStack.heightAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(rate: Int, streak: Int, total: Int, active: Int) {
        rateValue.text = String(format: "percent_format".localized, rate)
        progressRing.setProgress(CGFloat(rate) / 100.0, animated: true)
        
        streakValueLabel.text = "\(streak) \("days_suffix".localized)"
        totalValueLabel.text = "\(total)"
        activeValueLabel.text = "\(active)"
    }
}
