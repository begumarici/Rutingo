//
//  DayCircleView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class DayCircleView: UIView {
    
    // MARK: - Constants
    private enum ProgressThreshold {
        static let low: Double = 0.34
        static let medium: Double = 0.67
        static let high: Double = 1.0
    }
    
    // MARK: - UI Components
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(14)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(20)
        label.textColor = UIColor.black
        label.textAlignment = .center
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
        backgroundColor = AppColors.progressEmpty
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
    func configure(with date: Date, progress: Double, isToday: Bool) {
        setDateLabels(for: date)
        setProgressColor(progress)
        setTodayBorder(isToday)
    }
    
    // MARK: - Helpers
    private func setDateLabels(for date: Date) {
        dayLabel.text = DateHelper.shared.dayOfWeekShort(date)
        dateLabel.text = DateHelper.shared.dayOfMonth(date)
    }
    
    private func setProgressColor(_ progress: Double) {
        switch progress {
        case 0.0:
            backgroundColor = AppColors.progressEmpty
        case 0.0..<ProgressThreshold.low:
            backgroundColor = AppColors.progressLow
        case ProgressThreshold.low..<ProgressThreshold.medium:
            backgroundColor = AppColors.progressMedium
        case ProgressThreshold.medium..<ProgressThreshold.high:
            backgroundColor = AppColors.progressHigh
        default:
            backgroundColor = AppColors.progressComplete
        }
    }
    
    private func setTodayBorder(_ isToday: Bool) {
        if isToday {
            layer.borderWidth = 1
            layer.borderColor = AppColors.accent.cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
