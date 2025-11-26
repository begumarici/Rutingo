//
//  RoutineCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class RoutineCell: UITableViewCell {
    static let identifier = "RoutineCell"
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(18)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(24)
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
        cardView.addSubview(nameLabel)
        cardView.addSubview(frequencyLabel)
        cardView.addSubview(streakLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.smallPadding),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.smallPadding),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
  
            streakLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.padding),
            streakLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.smallPadding + 4),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.padding),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -Layout.padding),

            frequencyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            frequencyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.padding),
            frequencyLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakLabel.leadingAnchor, constant: -Layout.padding),
            frequencyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.smallPadding - 4)
        ])
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.3) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            self.cardView.alpha = highlighted ? 0.8 : 1.0
        }
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
        frequencyLabel.text = routine.frequency.displayText
        let streak = routine.currentStreak
        streakLabel.attributedText = createStreakText(streak)
    }
}
