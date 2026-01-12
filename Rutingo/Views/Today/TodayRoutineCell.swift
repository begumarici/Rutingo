//
//  TodayRoutineCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class TodayRoutineCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "TodayRoutineCell"
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryCardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(12)
        label.textColor = AppColors.secondary
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        streakLabel.setContentHuggingPriority(.required, for: .horizontal)
        streakLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(cardView)
        cardView.addSubview(checkmarkView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(streakLabel)
        cardView.addSubview(frequencyLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.smallPadding),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.smallPadding),
            cardView.heightAnchor.constraint(equalToConstant: 60),
            
            streakLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.padding),
            streakLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            checkmarkView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            checkmarkView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: checkmarkView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -Layout.smallPadding),

            frequencyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            frequencyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor), 
            frequencyLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -Layout.smallPadding)
        ])
    }
    
    // MARK: - Configuration
    func configure(with routine: Routine) {
        nameLabel.text = routine.name
        frequencyLabel.text = routine.frequency.displayText
        
        updateCompletionState(isCompleted: routine.isCompletedToday)
        
        let streak = routine.currentStreak
        streakLabel.attributedText = createStreakText(streak)
    }
    
    // MARK: - Helpers
    private func updateCompletionState(isCompleted: Bool) {
        if isCompleted {
            cardView.alpha = 1.0
            checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkView.tintColor = AppColors.primary
        } else {
            cardView.alpha = 1.0
            checkmarkView.image = UIImage(systemName: "circle")
            checkmarkView.tintColor = AppColors.secondary
        }
    }
    
    private func createStreakText(_ streak: Int) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let iconSize: CGFloat = 16
        
        attachment.image = UIImage(systemName: "link")?
            .withTintColor(AppColors.secondary, renderingMode: .alwaysOriginal)
        
        attachment.bounds = CGRect(x: 0, y: -1, width: iconSize, height: iconSize)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " \(streak)"))
        
        return attributedString
    }
        
}
