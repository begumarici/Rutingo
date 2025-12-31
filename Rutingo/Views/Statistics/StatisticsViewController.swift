//
//  ProfileViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.12.2025.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        addSubviews()
        setupConstraints()
        loadData()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(statsStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func loadData() {
        viewModel.loadData { [weak self] in
            self?.setupStats()
        }
    }

    private func setupStats() {
        // Stats data
        let stats = [
            ("CURRENT STREAK", "\(viewModel.overallStreak)d"),
            ("TOTAL COMPLETED", "\(viewModel.totalCompletions)"),
            ("COMPLETION RATE", "\(viewModel.completionRate)%"),
            ("ACTIVE ROUTINES", "\(viewModel.activeRoutines)")
        ]
        
        let cardWidth = (view.bounds.width - 44) / 2  // (16 + 12 + 16 = 44)
        let cardHeight = cardWidth  // KARE! Aynı boyut!
        
        // Create rows (2 cards per row)
           for i in stride(from: 0, to: stats.count, by: 2) {
               let rowStack = UIStackView()
               rowStack.axis = .horizontal
               rowStack.spacing = 20
               rowStack.distribution = .fillEqually
               
               // Left card
               let leftCard = createStatCard(title: stats[i].0, value: stats[i].1)
               rowStack.addArrangedSubview(leftCard)
               
               // Right card (if exists)
               if i + 1 < stats.count {
                   let rightCard = createStatCard(title: stats[i+1].0, value: stats[i+1].1)
                   rowStack.addArrangedSubview(rightCard)
               }
               
               // ⭐ Row height = card height (KARE)
               rowStack.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
               
               statsStackView.addArrangedSubview(rowStack)
           }
    }

    private func createStatCard(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = AppColors.cardBackground
        container.layer.cornerRadius = Layout.cornerRadius
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = AppFonts.regular(9)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = AppFonts.bold(24)
        valueLabel.textColor = AppColors.tertiary
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12)
        ])
        
        return container
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Profile"
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.largeTitleTextAttributes = [
            .font: AppFonts.bold(34),
            .foregroundColor: AppColors.primary
        ]
        navigationBar.titleTextAttributes = [
            .font: AppFonts.semibold(17),
            .foregroundColor: AppColors.primary
        ]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
    }
    
    @objc private func settingsTapped() {
        print("Settings tapped!")
    }
}
