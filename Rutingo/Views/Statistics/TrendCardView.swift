//
//  StatCardView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.12.2025.
//

import UIKit

class StatCardView: UIView {
    
    // MARK: - UI Components
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(36)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(12)
        label.textColor = AppColors.secondary
        label.numberOfLines = 2
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
        
        addSubview(valueLabel)
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Value (sol üstte)
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Title (sağ altta)
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
}
