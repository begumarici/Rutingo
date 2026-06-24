//
//  CalendarViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 16.01.2026.
//

import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CalendarViewModel()
    
    // MARK: - UI Components
    private let routinesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .always
        return tableView
    }()

    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.background
        return view
    }()
    
    private let calendarCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        return view
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(24)
        label.textColor = AppColors.primary
        label.textAlignment = .center
        label.text = " "
        return label
    }()

    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = AppColors.primary
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = AppColors.primary
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        return collectionView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondary.withAlphaComponent(0.3)
        return view
    }()

    private let dayDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(17)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let emptyStateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    private let emptyStateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "calendar")?.withConfiguration(
            UIImage.SymbolConfiguration(weight: .thin)
        )
        imageView.tintColor = AppColors.secondary.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "no_routines_today".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWeekdayHeaders()
        setupTableView()
        setupGestures()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        routinesTableView.delegate = self
        routinesTableView.dataSource = self
        
        refreshData()
    }

    // statsVC manages navbar as parent
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeaderView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        view.addSubview(routinesTableView)
        
        NSLayoutConstraint.activate([
            routinesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            routinesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routinesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routinesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupHeaderView()
    }
    
    private func setupTableView() {
        routinesTableView.register(DayRoutineCell.self, forCellReuseIdentifier: DayRoutineCell.identifier)
    }
    
    private func setupHeaderView() {
        headerContainerView.addSubview(calendarCard)
        calendarCard.addSubview(monthLabel)
        calendarCard.addSubview(previousButton)
        calendarCard.addSubview(nextButton)
        calendarCard.addSubview(weekdayStackView)
        calendarCard.addSubview(calendarCollectionView)
        headerContainerView.addSubview(dividerView)
        headerContainerView.addSubview(dayDetailLabel)
        
        NSLayoutConstraint.activate([
            calendarCard.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 16),
            calendarCard.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            calendarCard.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),

            monthLabel.topAnchor.constraint(equalTo: calendarCard.topAnchor, constant: 16),
            monthLabel.centerXAnchor.constraint(equalTo: calendarCard.centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            previousButton.widthAnchor.constraint(equalToConstant: 44),
            previousButton.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 12),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30),
            
            calendarCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 4),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 240),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: -12),

            dividerView.topAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: 12),
            dividerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            dayDetailLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            dayDetailLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            dayDetailLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),
            dayDetailLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -12)
        ])
        
        layoutTableHeaderView()
    }
    
    private func layoutTableHeaderView() {
        let width = routinesTableView.bounds.width
        let size = headerContainerView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )
        
        if headerContainerView.frame.size.height != size.height {
            headerContainerView.frame.size.height = size.height
            routinesTableView.tableHeaderView = headerContainerView
        }
    }
    
    private func setupWeekdayHeaders() {
        let weekdays = [
            "day_mon".localized, "day_tue".localized, "day_wed".localized,
            "day_thu".localized, "day_fri".localized, "day_sat".localized, "day_sun".localized
        ]
        
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = AppFonts.bold(12)
            label.textColor = AppColors.secondary
            label.textAlignment = .center
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextMonthTapped))
        swipeLeft.direction = .left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(previousMonthTapped))
        swipeRight.direction = .right
        
        calendarCollectionView.addGestureRecognizer(swipeLeft)
        calendarCollectionView.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Data Loading
    private func refreshData() {
        viewModel.loadData { [weak self] in
            self?.updateUI()
        }
    }

    private func updateUI() {
        monthLabel.text = viewModel.getMonthTitle()
        
        calendarCollectionView.collectionViewLayout.invalidateLayout()
        calendarCollectionView.reloadData()
        calendarCollectionView.layoutIfNeeded()
        
        updateDayDetail()
        layoutTableHeaderView()
    }
    
    private func updateDayDetail() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = .current
        dayDetailLabel.text = formatter.string(from: viewModel.selectedDate)
        
        let routines = viewModel.getRoutinesForSelectedDate()
        
        if routines.isEmpty {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
            footer.addSubview(emptyStateStackView)
            
            emptyStateStackView.addArrangedSubview(emptyStateIcon)
            emptyStateStackView.addArrangedSubview(emptyStateLabel)
            
            NSLayoutConstraint.activate([
                emptyStateIcon.widthAnchor.constraint(equalToConstant: 80),
                emptyStateIcon.heightAnchor.constraint(equalToConstant: 80),
                
                emptyStateStackView.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                emptyStateStackView.topAnchor.constraint(equalTo: footer.topAnchor, constant: 40)
            ])
            routinesTableView.tableFooterView = footer
        } else {
            routinesTableView.tableFooterView = nil
        }
        
        routinesTableView.reloadData()
    }
    
    private func animateCalendarTransition(subtype: CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = subtype
        
        calendarCollectionView.layer.add(transition, forKey: nil)
        monthLabel.layer.add(transition, forKey: nil)
    }
    
    // MARK: - Actions
    @objc private func previousMonthTapped() {
        animateCalendarTransition(subtype: .fromLeft)
        viewModel.changeMonth(by: -1) { [weak self] in
            self?.updateUI()
        }
    }

    @objc private func nextMonthTapped() {
        animateCalendarTransition(subtype: .fromRight)
        viewModel.changeMonth(by: 1) { [weak self] in
            self?.updateUI()
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.uiModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.identifier, for: indexPath
        ) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.uiModels[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectDate(at: indexPath.item) { [weak self] in
            self?.updateUI()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = floor(collectionView.bounds.width / 7)
        return CGSize(width: width, height: 40)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRoutinesForSelectedDate().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DayRoutineCell.identifier, for: indexPath
        ) as? DayRoutineCell else {
            return UITableViewCell()
        }
        
        let routines = viewModel.getRoutinesForSelectedDate()
        cell.configure(with: routines[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let routine = viewModel.getRoutinesForSelectedDate()[indexPath.row].routine
        navigationController?.pushViewController(RoutineDetailViewController(routine: routine), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
