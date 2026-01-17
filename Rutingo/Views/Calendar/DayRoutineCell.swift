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
        view.layer.cornerRadius = 8
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
        label.font = AppFonts.medium(15)
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
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            statusIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 20),
            statusIcon.heightAnchor.constraint(equalToConstant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(routine: Routine, date: Date) {
        nameLabel.text = routine.name
        
        let isCompleted = routine.isCompleted(on: date)
        
        if isCompleted {
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = AppColors.primary
        } else {
            statusIcon.image = UIImage(systemName: "circle")
            statusIcon.tintColor = AppColors.secondary
        }
    }
}
