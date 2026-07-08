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
    
    var onCheckmarkTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.layer.masksToBounds = false
        return view
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private let ringView: CountProgressRingView = {
        let view = CountProgressRingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(17)
        label.textColor = AppColors.primary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(15)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(13)
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
        
        checkmarkButton.addTarget(self, action: #selector(checkmarkButtonTapped), for: .touchUpInside)
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(cardView)
        cardView.addSubview(checkmarkButton)
        checkmarkButton.addSubview(checkmarkView)
        checkmarkButton.addSubview(ringView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(streakLabel)
        cardView.addSubview(frequencyLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.heightAnchor.constraint(equalToConstant: 72),
            
            checkmarkButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            checkmarkButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 60),
            checkmarkButton.heightAnchor.constraint(equalTo: cardView.heightAnchor),
            
            checkmarkView.centerXAnchor.constraint(equalTo: checkmarkButton.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: checkmarkButton.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 28),
            checkmarkView.heightAnchor.constraint(equalToConstant: 28),

            ringView.centerXAnchor.constraint(equalTo: checkmarkButton.centerXAnchor),
            ringView.centerYAnchor.constraint(equalTo: checkmarkButton.centerYAnchor),
            ringView.widthAnchor.constraint(equalToConstant: 40),
            ringView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 4),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -12),

            frequencyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            frequencyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            frequencyLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -12),
            
            streakLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            streakLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func checkmarkButtonTapped() {
        onCheckmarkTapped?()
    }

    // MARK: - Configuration
    func configure(with routine: Routine, isNotToday: Bool = false, isSkipped: Bool = false) {
        // reset
        nameLabel.attributedText = nil
        nameLabel.textColor = AppColors.primary
        frequencyLabel.textColor = AppColors.secondary
        streakLabel.isHidden = false
        checkmarkButton.isHidden = false
        checkmarkButton.isUserInteractionEnabled = true
        checkmarkView.isHidden = false
        ringView.isHidden = true
        cardView.alpha = 1.0

        nameLabel.text = routine.name
        frequencyLabel.text = routine.frequency.displayText

        if isSkipped {
            cardView.alpha = 0.7
            checkmarkButton.isUserInteractionEnabled = false
            checkmarkView.image = UIImage(systemName: "forward.circle.fill")
            checkmarkView.tintColor = AppColors.accentOrange
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: AppColors.secondary
            ]
            nameLabel.attributedText = NSAttributedString(string: routine.name ?? "", attributes: attributes)
            frequencyLabel.textColor = AppColors.secondary.withAlphaComponent(0.6)
            streakLabel.attributedText = createStreakText(routine.currentStreak)

        } else if isNotToday {
            cardView.alpha = 0.7
            checkmarkButton.isHidden = true
            streakLabel.isHidden = true
            nameLabel.textColor = AppColors.secondary
            frequencyLabel.textColor = AppColors.secondary

        } else {
            updateCompletionState(for: routine)
            streakLabel.attributedText = createStreakText(routine.currentStreak)
        }
    }

    // MARK: - Helpers
    private func updateCompletionState(for routine: Routine) {
        let isCompleted = routine.isCompletedToday

        if routine.isCountBased {
            checkmarkView.isHidden = true
            ringView.isHidden = false
            ringView.configure(
                current: routine.todayCount,
                target: routine.targetCount,
                progressColor: isCompleted ? AppColors.accentGreen : AppColors.accentPurple,
                trackColor: AppColors.secondaryCardBackground,
                textColor: isCompleted ? AppColors.accentGreen : AppColors.primary
            )

            if isCompleted {
                cardView.alpha = 0.75
                nameLabel.textColor = AppColors.secondary
                frequencyLabel.textColor = AppColors.tertiary
            } else {
                cardView.alpha = 1.0
                nameLabel.textColor = AppColors.primary
                frequencyLabel.textColor = AppColors.secondary
            }

        } else if isCompleted {
            cardView.alpha = 0.75
            checkmarkView.isHidden = false
            checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkView.tintColor = AppColors.accentGreen
            nameLabel.textColor = AppColors.secondary
            frequencyLabel.textColor = AppColors.tertiary
        } else {
            cardView.alpha = 1.0
            checkmarkView.isHidden = false
            checkmarkView.image = UIImage(systemName: "circle")
            checkmarkView.tintColor = AppColors.tertiary
            nameLabel.textColor = AppColors.primary
            frequencyLabel.textColor = AppColors.secondary
        }
    }
    
    private func createStreakText(_ streak: Int) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let iconSize: CGFloat = 18
        
        attachment.image = UIImage(systemName: "flame.fill")?
            .withTintColor(
                streak > 0 ? AppColors.accentOrange : AppColors.tertiary,
                renderingMode: .alwaysOriginal
            )
        attachment.bounds = CGRect(x: 0, y: -2, width: iconSize, height: iconSize)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(
            string: " \(streak)",
            attributes: [.foregroundColor: streak > 0 ? AppColors.accentOrange : AppColors.tertiary]
        ))
        
        return attributedString
    }
        
}
