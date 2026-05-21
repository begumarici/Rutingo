//
//  BlocksDetailViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.04.2026.
//

import UIKit

class BlocksDetailViewController: UIViewController {

    // MARK: - Properties
    var block: TimeBlock
    var onDelete: (() -> Void)?
    var onUpdate: ((String, Int, Int, Int, Int) -> Void)?
    private let viewModel: BlocksViewModel
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = 16
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.bold(24)
        l.textColor = AppColors.primary
        l.numberOfLines = 1
        return l
    }()
    
    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(15)
        l.textColor = AppColors.secondary
        return l
    }()
    
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("delete_block".localized, for: .normal)
        b.titleLabel?.font = AppFonts.semibold(16)
        b.setTitleColor(.systemRed, for: .normal)
        return b
    }()
    
    // MARK: - Init
    init(block: TimeBlock, viewModel: BlocksViewModel) {
        self.block = block
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupUI()
        configure()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "edit".localized,
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = AppColors.primary
    }
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(infoCard)
        infoCard.addSubview(titleLabel)
        infoCard.addSubview(timeLabel)
        
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        let p: CGFloat  = 20
        let cp: CGFloat = 16

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            infoCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            titleLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: cp),
            titleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cp),
            titleLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cp),

            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            timeLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cp),
            timeLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cp),
            timeLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -cp),

            deleteButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 12),
            deleteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        title = block.title
        titleLabel.text = block.title
        timeLabel.text = block.timeRangeText
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        let addVC = AddBlockViewController()
        addVC.title = "edit_block".localized
        
        addVC.configure(title: block.title ?? "",
                        startHour: Int(block.startHour),
                        startMinute: Int(block.startMinute),
                        endHour: Int(block.endHour),
                        endMinute: Int(block.endMinute)
        )
        
        addVC.onSave = { [weak self] title, startHour, startMinute, endHour, endMinute in
            guard let self else { return }
            self.viewModel.updateBlock(self.block, title: title, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute) {
                self.configure()
            }
            self.onUpdate?(title, startHour, startMinute, endHour, endMinute)
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "delete_block".localized,
            message: "delete_block_message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deleteBlock(self.block) {
                self.onDelete?()
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: true)
    }
}
