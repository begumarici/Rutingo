//
//  ProfileViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.12.2025.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = StatisticsViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let cardsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let trendCardView: TrendCardView = {
        let view = TrendCardView()
        return view
    }()
    
    private let combinedStatsCard: CombinedStatsCardView = {
        let view = CombinedStatsCardView()
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(cardsStack)
        cardsStack.addArrangedSubview(trendCardView)
        cardsStack.addArrangedSubview(combinedStatsCard)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
           scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           
           cardsStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
           cardsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
           cardsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
           cardsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
           cardsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
           
           combinedStatsCard.heightAnchor.constraint(equalToConstant: 180)
       ])
    }

    private func loadData() {
        viewModel.loadData { [weak self] in
            guard let self = self else { return }
            
            self.trendCardView.configure(
                weeklyRate: self.viewModel.weeklyCompletionRate,
                lastWeekRate: self.viewModel.lastWeekCompletionRate,
                dailyRates: self.viewModel.dailyCompletionRates
            )
            
            self.combinedStatsCard.configure(
                rate: self.viewModel.completionRate,
                streak: self.viewModel.overallStreak,
                total: self.viewModel.totalCompletions,
                active: self.viewModel.activeRoutines
            )
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "tab_profile".localized
        
        configureNavigationBarAppearance()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
    }
    
    private func configureNavigationBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.largeTitleTextAttributes = [
            .font: AppFonts.bold(34),
            .foregroundColor: AppColors.navbarTitle
        ]
        navigationBar.titleTextAttributes = [
            .font: AppFonts.semibold(17),
            .foregroundColor: AppColors.navbarTitle
        ]
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()

        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
