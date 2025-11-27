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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func configure(with date: Date, progress: Double, isToday: Bool) {
        dayLabel.text = DateHelper.shared.dayOfWeekShort(date)
        dateLabel.text = DateHelper.shared.dayOfMonth(date)
        
        if progress == 0.0 {
           backgroundColor = AppColors.progressEmpty
        } else if progress < 0.34 {
           backgroundColor = AppColors.progressLow
        } else if progress < 0.67 {
           backgroundColor = AppColors.progressMedium
        } else if progress < 1.0 {
           backgroundColor = AppColors.progressHigh
        } else {
           backgroundColor = AppColors.progressComplete
        }
        
        if isToday {
            layer.borderWidth = 1
            layer.borderColor = AppColors.accent.cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
