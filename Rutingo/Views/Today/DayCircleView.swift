//
//  DayCircleView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class DayCircleView: UIView {
    
    // MARK: - Properties
    private var isCurrentlyToday: Bool = false
    private var isCurrentlySelected: Bool = false
    
    // MARK: - UI Components
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(20)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.updateBorderColor()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 14
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        addSubview(dayLabel)
        addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            dayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 0),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with date: Date, progress: Double, isToday: Bool, isSelected: Bool = false) {
        isCurrentlyToday = isToday
        isCurrentlySelected = isSelected
        setDateLabels(for: date)
        setAppearance(progress: progress, isToday: isToday, isSelected: isSelected)
    }
    
    // MARK: - Helpers
    private func setDateLabels(for date: Date) {
        dayLabel.text = DateHelper.shared.dayOfWeekShort(date)
        dateLabel.text = DateHelper.shared.dayOfMonth(date)
    }
    
    private func setAppearance(progress: Double, isToday: Bool, isSelected: Bool) {
        if isToday {
            backgroundColor = AppColors.accentOrange
            dayLabel.textColor = AppColors.onAccent
            dateLabel.textColor = AppColors.onAccent
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        } else if isSelected {
            backgroundColor = AppColors.accentPurple.withAlphaComponent(0.15)
            dayLabel.textColor = AppColors.accentPurple
            dateLabel.textColor = AppColors.accentPurple
            layer.borderWidth = 1.5
            layer.borderColor = AppColors.accentPurple.cgColor
        } else {
            backgroundColor = .clear
            dayLabel.textColor = AppColors.secondary
            dateLabel.textColor = AppColors.secondary
            layer.borderWidth = 1
            layer.borderColor = AppColors.secondary.withAlphaComponent(0.3).cgColor
        }
    }

    private func updateBorderColor() {
        if isCurrentlyToday {
            layer.borderColor = UIColor.clear.cgColor
        } else if isCurrentlySelected {
            layer.borderColor = AppColors.accentPurple.cgColor
        } else {
            layer.borderColor = AppColors.secondary.withAlphaComponent(0.3).cgColor
        }
    }
}
