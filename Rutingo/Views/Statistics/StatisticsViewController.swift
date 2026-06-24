//
//  StatisticsViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.12.2025.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = StatisticsViewModel()
    private var currentChild: UIViewController?
    
    // MARK: - UI Components
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["calendar".localized, "tab_statistics".localized]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return sc
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Statistics
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
    
    private let trendCardView = TrendCardView()
    private let combinedStatsCard = CombinedStatsCardView()
    
    // Calendar child VC
    private lazy var calendarViewController = CalendarViewController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatisticsData()
        configureNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Statistics scroll view
        scrollView.addSubview(cardsStack)
        cardsStack.addArrangedSubview(trendCardView)
        cardsStack.addArrangedSubview(combinedStatsCard)
        
        NSLayoutConstraint.activate([
            cardsStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            cardsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            cardsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            cardsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            combinedStatsCard.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    // MARK: - Child VC Management
    private func showStatistics() {
        transition(to: makeStatisticsContainer())
        loadStatisticsData()
    }
    
    private func showCalendar() {
        transition(to: calendarViewController)
    }
    
    /// remove the current child and add new one
    private func transition(to newChild: UIViewController) {
        if currentChild == newChild { return }
        
        currentChild?.willMove(toParent: nil)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()
        
        addChild(newChild)
        newChild.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newChild.view)
        
        NSLayoutConstraint.activate([
            newChild.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newChild.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newChild.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newChild.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        newChild.didMove(toParent: self)
        currentChild = newChild
    }
    
    private func makeStatisticsContainer() -> UIViewController {
        if let existing = children.first(where: { $0 is StatisticsContentViewController }) {
            return existing
        }
        let vc = StatisticsContentViewController(scrollView: scrollView)
        return vc
    }
    
    // MARK: - Data
    private func loadStatisticsData() {
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
    
    // MARK: - Navigation Bar
    private func configureNavigationBar() {
        title = "calendar".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        
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
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: showCalendar()
        case 1: showStatistics()
        default: break
        }
    }
    
    @objc private func settingsTapped() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
}

// MARK: - StatisticsContentViewController
private class StatisticsContentViewController: UIViewController {
    
    private let wrappedScrollView: UIScrollView
    
    init(scrollView: UIScrollView) {
        self.wrappedScrollView = scrollView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        view.addSubview(wrappedScrollView)
        
        NSLayoutConstraint.activate([
            wrappedScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            wrappedScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrappedScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wrappedScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
