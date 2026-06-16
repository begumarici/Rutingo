//
//  CalendarDayCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 16.01.2026.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    
    static let identifier = "CalendarDayCell"
    
    // MARK: - UI Components
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let routineIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = 2
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = min(bounds.width, bounds.height)
        contentView.layer.cornerRadius = size / 2.5
        contentView.layer.masksToBounds = true
    }
    
    private func setupUI() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 40),
            contentView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(routineIndicator)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            routineIndicator.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            routineIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            routineIndicator.widthAnchor.constraint(equalToConstant: 4),
            routineIndicator.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        dayLabel.textColor = AppColors.secondary
        dayLabel.font = AppFonts.bold(16)
        contentView.backgroundColor = .clear
        routineIndicator.isHidden = true
        routineIndicator.backgroundColor = AppColors.primary
    }
    
    // MARK: - Configuration
    func configure(with item: CalendarDayItem) {
        dayLabel.text = item.text
        routineIndicator.isHidden = !item.hasRoutine
        
        if item.date == nil {
            contentView.backgroundColor = .clear
            return
        }

        dayLabel.font = AppFonts.bold(16)
        
        if item.isSelected {
            if item.isToday {
                contentView.backgroundColor = AppColors.accentOrange
                dayLabel.textColor = AppColors.background
                dayLabel.font = AppFonts.bold(16)
                routineIndicator.backgroundColor = AppColors.background
            } else {
                contentView.backgroundColor = AppColors.accentOrange
                dayLabel.textColor = AppColors.background
                dayLabel.font = AppFonts.bold(16)
                routineIndicator.backgroundColor = AppColors.background
            }
            
        } else {
            contentView.backgroundColor = .clear
            routineIndicator.backgroundColor = AppColors.primary
            
            if item.isToday {
                contentView.backgroundColor = AppColors.accentOrange.withAlphaComponent(0.12)
                dayLabel.textColor = AppColors.primary
                dayLabel.font = AppFonts.regular(16)
            } else {
                contentView.backgroundColor = .clear
                dayLabel.textColor = AppColors.primary
                dayLabel.font = AppFonts.regular(16)
            }
        }
    }
}
