//
//  TodayViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.11.2025.
//

import UIKit

class TodayViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = TodayViewModel()
    
    // MARK: - UI Components
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.navbarTitle
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let weekCalendarView: WeekCalendarView = {
        let view = WeekCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let focusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "daily_focus".localized
        label.font = AppFonts.semibold(22)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TodayRoutineCell.self, forCellReuseIdentifier: TodayRoutineCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "no_routines_today".localized
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupWeekCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupWeekCalendar() {
        weekCalendarView.onDateSelected = { [weak self] date in
            self?.handleDateSelection(date)
        }
    }
    
    private func handleDateSelection(_ date: Date) {
        viewModel.setSelectedDate(date) { [weak self] in
            self?.updateUIWithViewModel()
        }
    }

    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(greetingLabel)
        view.addSubview(dateLabel)
        view.addSubview(weekCalendarView)
        view.addSubview(focusLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            weekCalendarView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Layout.smallPadding),
            weekCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            weekCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            focusLabel.topAnchor.constraint(equalTo: weekCalendarView.bottomAnchor, constant: Layout.smallPadding),
            focusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            focusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            tableView.topAnchor.constraint(equalTo: focusLabel.bottomAnchor, constant: Layout.smallPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Data Loading
    private func loadData() {
        viewModel.loadData { [weak self] in
            self?.updateUIWithViewModel()
        }
    }
    
    private func updateUIWithViewModel() {
        // Header
        greetingLabel.text = viewModel.greeting
        dateLabel.text = viewModel.dateText
        
        // Week Calendar
        let weekDates = viewModel.getCurrentWeekDates()
        let progressMap = viewModel.getWeekProgressMap(for: weekDates)
        weekCalendarView.configure(with: weekDates, progressMap: progressMap, selectedDate: viewModel.selectedDate)
        
        // Empty State
        let isEmpty = viewModel.todayRoutines.isEmpty
        tableView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todayRoutines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier, for: indexPath) as? TodayRoutineCell else {
            return UITableViewCell()
        }
        
        let routine = viewModel.todayRoutines[indexPath.row]
        let today = DateHelper.shared.startOfDay()
        let isNotToday = viewModel.selectedDate != today
        
        cell.configure(with: routine, isNotToday: isNotToday)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let today = DateHelper.shared.startOfDay()
        guard viewModel.selectedDate == today else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let routine = viewModel.todayRoutines[indexPath.row]
        viewModel.toggleRoutine(routine) { [weak self] in
            self?.updateUIWithViewModel()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let routine = viewModel.todayRoutines[indexPath.row]
        
        let viewAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            let detailVC = RoutineDetailViewController(routine: routine)
            self?.navigationController?.pushViewController(detailVC, animated: true)
            completionHandler(true)
        }
        
        viewAction.image = UIImage(systemName: "info.circle")?.withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
        viewAction.backgroundColor = AppColors.secondary
        
        let configuration = UISwipeActionsConfiguration(actions: [viewAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let today = DateHelper.shared.startOfDay()
        guard viewModel.selectedDate == today else {
            return nil
        }
        
        let routine = viewModel.todayRoutines[indexPath.row]
        let isCompleted = routine.isCompletedToday
        
        let toggleAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            self?.viewModel.toggleRoutine(routine) { [weak self] in
                self?.updateUIWithViewModel()
                completionHandler(true)
            }
        }
        
        if isCompleted {
            toggleAction.image = UIImage(systemName: "arrow.uturn.backward")?.withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
            toggleAction.backgroundColor = AppColors.secondary
        } else {
            toggleAction.image = UIImage(systemName: "checkmark")?.withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
            toggleAction.backgroundColor = AppColors.primary
        }

        let configuration = UISwipeActionsConfiguration(actions: [toggleAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
