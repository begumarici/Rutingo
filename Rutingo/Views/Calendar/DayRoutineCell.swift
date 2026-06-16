//
//  DayRoutineCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 16.01.2026.
//

import UIKit

class DayRoutineCell: UITableViewCell {
    
    static let identifier = "DayRoutineCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cardCornerRadius
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(17)
        label.textColor = AppColors.primary
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
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusIcon)
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            statusIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: RoutineWithStatus) {
        if item.isSkipped {
            containerView.alpha = 0.7
            nameLabel.textColor = AppColors.secondary
            statusIcon.image = UIImage(systemName: "forward.circle.fill")
            statusIcon.tintColor = AppColors.accentOrange
        } else if item.isCompleted {
            containerView.alpha = 1.0
            nameLabel.textColor = AppColors.primary
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = AppColors.accentGreen
        } else {
            containerView.alpha = 1.0
            nameLabel.textColor = AppColors.primary
            statusIcon.image = UIImage(systemName: "circle")
            statusIcon.tintColor = AppColors.secondary
        }
        
        nameLabel.text = item.routine.name
    }
}
