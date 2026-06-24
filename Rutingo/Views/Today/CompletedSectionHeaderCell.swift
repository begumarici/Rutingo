//
//  CompletedSectionHeaderCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 8.02.2026.
//

import UIKit

class CompletedSectionHeaderCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "CompletedSectionHeaderCell"
    
    // MARK: - UI Components
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.primary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
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
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(chevronIcon)
        contentView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            chevronIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding + 4),
            chevronIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 16),
            chevronIcon.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: chevronIcon.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(count: Int, isExpanded: Bool, title: String? = nil) {
        titleLabel.text = (title ?? "completed".localized) + " (\(count))"
        let chevronName = isExpanded ? "chevron.down" : "chevron.right"
        chevronIcon.image = UIImage(systemName: chevronName)
    }
}
