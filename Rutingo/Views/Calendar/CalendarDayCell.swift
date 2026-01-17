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
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        return label
    }()
    
    private let routineIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.primary
        view.isHidden = true
        return view
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
        backgroundColor = .clear
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(routineIndicator)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            routineIndicator.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            routineIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            routineIndicator.widthAnchor.constraint(equalToConstant: 20),
            routineIndicator.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    // MARK: - Configuration
    func configure(day: Int, isToday: Bool, isSelected: Bool, hasRoutines: Bool) {
        dayLabel.text = "\(day)"
        routineIndicator.isHidden = !hasRoutines
        
        if isToday {
            dayLabel.font = AppFonts.bold(16)
            dayLabel.textColor = AppColors.primary
        } else {
            dayLabel.font = AppFonts.regular(16)
            dayLabel.textColor = AppColors.secondary
        }
        
        if isSelected {
            contentView.backgroundColor = AppColors.cardBackground
            contentView.layer.cornerRadius = 8
            dayLabel.textColor = AppColors.primary 
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
    func configureEmpty() {
        dayLabel.text = ""
        contentView.backgroundColor = .clear
        routineIndicator.isHidden = true
    }
}
