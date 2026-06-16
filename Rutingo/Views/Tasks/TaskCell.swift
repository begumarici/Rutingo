//
//  TaskCell.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.05.2026.
//

import UIKit

final class TaskCell: UITableViewCell {

    // MARK: - Identifier
    static let identifier = "TaskCell"

    // MARK: - UI
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.primary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.primary
        label.numberOfLines = 1
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(checkImageView)
        stackView.addArrangedSubview(titleLabel)
        

        NSLayoutConstraint.activate([
            checkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkImageView.heightAnchor.constraint(equalToConstant: 24),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Configure
    func configure(with task: Task) {
        if task.isCompleted {
            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            checkImageView.tintColor = AppColors.accentGreen
            titleLabel.attributedText = NSAttributedString(
                string: task.title ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: AppColors.secondary
                ]
            )
        } else {
            checkImageView.image = UIImage(systemName: "circle")

            titleLabel.attributedText = nil
            titleLabel.text = task.title
            titleLabel.textColor = AppColors.primary
        }
    }
}
