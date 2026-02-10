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
        table.register(CompletedSectionHeaderCell.self, forCellReuseIdentifier: CompletedSectionHeaderCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    private let emptyStateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    private let emptyStateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "moon.zzz")?.withConfiguration(
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
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupWeekCalendar()
        setupNotifications()
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(routineAdded),
            name: NSNotification.Name("RoutineAdded"),
            object: nil
        )
    }

    @objc private func routineAdded() {
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        view.addSubview(emptyStateStackView)
        
        emptyStateStackView.addArrangedSubview(emptyStateIcon)
        emptyStateStackView.addArrangedSubview(emptyStateLabel)
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
            
            emptyStateIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyStateIcon.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateStackView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
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
        let isEmpty = viewModel.notCompletedRoutines.isEmpty && viewModel.completedRoutines.isEmpty
        tableView.isHidden = isEmpty
        emptyStateStackView.isHidden = !isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    private func isCompletedSectionHeader(at indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row == 0
    }
    
    private func routine(at indexPath: IndexPath) -> Routine? {
        if indexPath.section == 0 {
            return viewModel.notCompletedRoutines[indexPath.row]
        } else if indexPath.row == 0 {
            return nil // header cell
        } else {
            return viewModel.completedRoutines[indexPath.row - 1]
        }
    }
    
    private func isPastOrFutureDay() -> Bool {
        let today = DateHelper.shared.startOfDay()
        return viewModel.selectedDate != today
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func triggerWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isPastOrFutureDay() ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.notCompletedRoutines.count
        case 1:
            if viewModel.isCompletedSectionExpanded {
                return 1 + viewModel.completedRoutines.count
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // completed section header
        if isCompletedSectionHeader(at: indexPath) {
            guard let headerCell = tableView.dequeueReusableCell(
                withIdentifier: CompletedSectionHeaderCell.identifier,
                for: indexPath
            ) as? CompletedSectionHeaderCell else {
                return UITableViewCell()
            }
            
            headerCell.configure(
                count: viewModel.completedRoutines.count,
                isExpanded: viewModel.isCompletedSectionExpanded
            )
            return headerCell
        }
        
        // routine cell (not completed or completed)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodayRoutineCell.identifier,
            for: indexPath
        ) as? TodayRoutineCell,
              let routine = routine(at: indexPath) else {
            return UITableViewCell()
        }
        
        cell.configure(with: routine, isNotToday: isPastOrFutureDay())
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // completed section header tapped - toggle expand/collapse
        if isCompletedSectionHeader(at: indexPath) {
            triggerHaptic(.light)
            
            viewModel.toggleCompletedSection()
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            return
        }
        
        // past or future day - show warning and don't allow toggle
        guard !isPastOrFutureDay() else {
            triggerWarningHaptic()
            return
        }
        
        // toggle routine completion
        guard let routine = routine(at: indexPath) else { return }
        
        triggerHaptic(.medium)
        
        viewModel.toggleRoutine(routine) { [weak self] in
            self?.updateUIWithViewModel()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // no swipe on completed section header
        guard !isCompletedSectionHeader(at: indexPath),
              let routine = routine(at: indexPath) else {
            return nil
        }
        
        let viewAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.triggerHaptic(.light)
            
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
        
        // only allow swipe on current day, not on header
        guard !isPastOrFutureDay(),
              !isCompletedSectionHeader(at: indexPath),
              let routine = routine(at: indexPath) else {
            return nil
        }
        
        let isCompleted = routine.isCompletedToday
        
        let toggleAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.triggerHaptic(.medium)
            
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
