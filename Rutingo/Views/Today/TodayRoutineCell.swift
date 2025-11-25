//
//  TodayRoutineCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class TodayRoutineCell: UITableViewCell {
    static let identifier = "TodayRoutineCell"
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFonts.bold(24)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(18)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.accent
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AppColors.background
        selectionStyle = .none
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(streakLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 32),
            checkboxButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: Layout.smallPadding),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: streakLabel.leadingAnchor, constant: -Layout.smallPadding),
            
            streakLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            streakLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            streakLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            contentView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
        
    func configure(with routine: Routine) {
        nameLabel.text = routine.name
        
        let isCompleted = routine.isCompletedToday
        checkboxButton.setTitle(isCompleted ? "✅" : "⬜️", for: .normal)
        
        let streak = routine.currentStreak
        streakLabel.text = "🔥 \(streak)"
    }
}
