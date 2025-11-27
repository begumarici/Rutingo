//
//  TodayRoutineCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class TodayRoutineCell: UITableViewCell {
    static let identifier = "TodayRoutineCell"
    
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

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
        label.font = AppFonts.semibold(16)
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(cardView)
        cardView.addSubview(checkboxButton)
        cardView.addSubview(nameLabel)
        cardView.addSubview(streakLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.smallPadding),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.smallPadding),
            cardView.heightAnchor.constraint(equalToConstant: 50),

            checkboxButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.padding),
            checkboxButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 32),
            checkboxButton.heightAnchor.constraint(equalToConstant: 32),
            
            streakLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.padding),
            streakLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -Layout.smallPadding)
        ])
    }
    
    private func createStreakText(_ streak: Int) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let iconSize: CGFloat = 16
        
        attachment.image = UIImage(systemName: "link")?
            .withTintColor(AppColors.secondary, renderingMode: .alwaysOriginal)
        
        attachment.bounds = CGRect(x: 0, y: -1, width: iconSize, height: iconSize)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " \(streak)", attributes: [
            .font: AppFonts.regular(16),
            .foregroundColor: AppColors.secondary
        ]))
        
        return attributedString
    }
        
    func configure(with routine: Routine) {
        nameLabel.text = routine.name
        
        let isCompleted = routine.isCompletedToday
        checkboxButton.setTitle(isCompleted ? "✅" : "⬜️", for: .normal)
        
        let streak = routine.currentStreak
        streakLabel.attributedText = createStreakText(streak)
    }
}
