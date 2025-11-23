//
//  DayCircleView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class DayCircleView: UIView {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(12)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        label.textAlignment = .center
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(20)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AppColors.background
        layer.cornerRadius = 8
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        addSubview(dayLabel)
        addSubview(dateLabel)
        addSubview(statusLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            dayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2),
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with date: Date, isCompleted: Bool, isToday: Bool) {
        dayLabel.text = DateHelper.shared.dayOfWeekShort(date)
        dateLabel.text = DateHelper.shared.dayOfMonth(date)
        
        if isToday && !isCompleted {
            statusLabel.text = "🔵"
            backgroundColor = AppColors.accent.withAlphaComponent(0.2)
        } else if isCompleted {
            statusLabel.text = "✅"
            backgroundColor = AppColors.cardBackground
        } else {
            statusLabel.text = "⬜️"
            backgroundColor = AppColors.cardBackground
        }
    }
}
