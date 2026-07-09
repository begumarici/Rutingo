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
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.accentPurple
        return button
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        addSubviews()
        setupConstraints()
        setupSwipeGestures()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupWeekCalendar() {
        weekCalendarView.onDateSelected = { [weak self] date in
            self?.handleDateSelection(date)
        }
        
        weekCalendarView.onSwipeLeft = { [weak self] in
            self?.animateTransition(direction: .left, includeWeek: true)
            self?.viewModel.goToNextWeek { [weak self] in
                self?.updateUIWithViewModel()
            }
        }

        weekCalendarView.onSwipeRight = { [weak self] in
            self?.animateTransition(direction: .right, includeWeek: true)
            self?.viewModel.goToPreviousWeek { [weak self] in
                self?.updateUIWithViewModel()
            }
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
    
    private func addSubviews() {
        view.addSubview(greetingLabel)
        view.addSubview(dateLabel)
        view.addSubview(weekCalendarView)
        view.addSubview(focusLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(emptyStateStackView)
        
        emptyStateStackView.addArrangedSubview(emptyStateIcon)
        emptyStateStackView.addArrangedSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
            focusLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -8),
            focusLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            addButton.centerYAnchor.constraint(equalTo: focusLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            
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
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(tableSwipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(tableSwipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let addRoutineVC = AddRoutineViewController()
        let routinesViewModel = RoutinesViewModel()
        addRoutineVC.onSave = { form in
            routinesViewModel.addRoutine(form) {
                NotificationCenter.default.post(name: NSNotification.Name("RoutineAdded"), object: nil)
            }
        }
        let navVC = UINavigationController(rootViewController: addRoutineVC)
        present(navVC, animated: true)
    }
    
    @objc private func tableSwipedLeft() {
        let weekBefore = Calendar.current.component(.weekOfYear, from: viewModel.selectedDate)
        animateTransition(direction: .left, includeWeek: false)
        viewModel.goToNextDay { [weak self] in
            guard let self else { return }
            if Calendar.current.component(.weekOfYear, from: self.viewModel.selectedDate) != weekBefore {
                self.animateTransition(direction: .left, includeWeek: true)
            }
            self.updateUIWithViewModel()
        }
    }
    
    @objc private func tableSwipedRight() {
        let weekBefore = Calendar.current.component(.weekOfYear, from: viewModel.selectedDate)
        animateTransition(direction: .right, includeWeek: false)
        viewModel.goToPreviousDay { [weak self] in
            guard let self else { return }
            if Calendar.current.component(.weekOfYear, from: self.viewModel.selectedDate) != weekBefore {
                self.animateTransition(direction: .right, includeWeek: true)
            }
            self.updateUIWithViewModel()
        }
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
        let isEmpty = viewModel.notCompletedRoutines.isEmpty && viewModel.completedRoutines.isEmpty && viewModel.skippedRoutines.isEmpty
        tableView.isHidden = isEmpty
        emptyStateStackView.isHidden = !isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    private func openDetail(for routine: Routine) {
        let detailVC = RoutineDetailViewController(routine: routine)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func openEdit(for routine: Routine) {
        let addVC = AddRoutineViewController()
        addVC.mode = .edit(routine)
        let routinesViewModel = RoutinesViewModel()
        addVC.onUpdate = { [weak self] routine, form in
            routinesViewModel.updateRoutine(routine: routine, form: form) { [weak self] in
                self?.loadData()
            }
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
    
    // MARK: - Helpers
    private func isCompletedSectionHeader(at indexPath: IndexPath) -> Bool {
        indexPath.section == 1 && indexPath.row == 0
    }
    
    private func isSkippedSectionHeader(at indexPath: IndexPath) -> Bool {
        indexPath.section == 2 && indexPath.row == 0
    }
    
    private func routine(at indexPath: IndexPath) -> Routine? {
        switch indexPath.section {
        case 0: return viewModel.notCompletedRoutines[indexPath.row]
        case 1: return indexPath.row == 0 ? nil : viewModel.completedRoutines[indexPath.row - 1]
        case 2: return indexPath.row == 0 ? nil : viewModel.skippedRoutines[indexPath.row - 1]
        default: return nil
        }
    }
    
    private func isPastOrFutureDay() -> Bool {
        viewModel.selectedDate != DateHelper.shared.startOfDay()
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private func triggerWarningHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    private func animateTransition(direction: UIRectEdge, includeWeek: Bool = false) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .push
        transition.subtype = direction == .right ? .fromLeft : .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        tableView.layer.add(transition, forKey: nil)
        if includeWeek {
            weekCalendarView.layer.add(transition, forKey: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        isPastOrFutureDay() ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.notCompletedRoutines.count
        case 1: return viewModel.isCompletedSectionExpanded ? 1 + viewModel.completedRoutines.count : 1
        case 2: return viewModel.isSkippedSectionExpanded  ? 1 + viewModel.skippedRoutines.count  : 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // completed section header
        if isCompletedSectionHeader(at: indexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompletedSectionHeaderCell.identifier,
                                                           for: indexPath) as? CompletedSectionHeaderCell else { return UITableViewCell() }
            cell.configure(count: viewModel.completedRoutines.count, isExpanded: viewModel.isCompletedSectionExpanded)
            return cell
        }
        
        if isSkippedSectionHeader(at: indexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompletedSectionHeaderCell.identifier,
                                                           for: indexPath) as? CompletedSectionHeaderCell else { return UITableViewCell() }
            cell.configure(count: viewModel.skippedRoutines.count, isExpanded: viewModel.isSkippedSectionExpanded,
                           title: "skipped".localized)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier,
                                                       for: indexPath) as? TodayRoutineCell,
              let routine = routine(at: indexPath) else { return UITableViewCell() }
        
        cell.configure(with: routine, isNotToday: isPastOrFutureDay(), isSkipped: indexPath.section == 2)
        
        cell.onCheckmarkTapped = { [weak self] in
            guard let self, !self.isPastOrFutureDay() else {
                self?.triggerWarningHaptic()
                return
            }
            
            if indexPath.section == 2 {
                self.triggerHaptic(.light)
                self.viewModel.unskipRoutine(routine) { [weak self] in
                    self?.updateUIWithViewModel()
                }
            } else {
                self.triggerHaptic(.medium)
                self.viewModel.toggleRoutine(routine) { [weak self] in self?.updateUIWithViewModel()
                }
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    
    // MARK: Row tap → Detail
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // completed section header tapped - toggle expand/collapse
        if isCompletedSectionHeader(at: indexPath) {
            triggerHaptic(.light)
            
            viewModel.toggleCompletedSection()
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            return
        }
        
        if isSkippedSectionHeader(at: indexPath) {
            triggerHaptic(.light)
            viewModel.isSkippedSectionExpanded.toggle()
            tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            return
        }
        
        // toggle routine completion
        guard let routine = routine(at: indexPath) else { return }
        openDetail(for: routine)
    }
    
    // MARK: Long press → Context menu (peek preview + actions)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
   
        guard !isCompletedSectionHeader(at: indexPath),
              !isSkippedSectionHeader(at: indexPath),
              let routine = routine(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: {
                RoutineDetailViewController(routine: routine)
            },
            actionProvider: { [weak self] _ in
                guard let self else { return nil }
                return self.makeContextMenu(for: routine, at: indexPath)
            }
        )
    }
    
    /// tap to peek -> push to detail
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath,
              let routine = routine(at: indexPath) else { return }
        animator.addCompletion { [weak self] in
            self?.openDetail(for: routine)
        }
    }
    
    // MARK: Swipe actions
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isCompletedSectionHeader(at: indexPath),
              !isSkippedSectionHeader(at: indexPath),
              !isPastOrFutureDay(),
              let routine = routine(at: indexPath) else { return nil }
        
        if indexPath.section == 2 {
            let unskip = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
                self?.triggerHaptic(.light)
                self?.viewModel.unskipRoutine(routine) { [weak self] in
                    self?.updateUIWithViewModel(); done(true)
                }
            }
            unskip.image = UIImage(systemName: "arrow.uturn.backward")?
                .withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
            unskip.backgroundColor = AppColors.secondary
            return UISwipeActionsConfiguration(actions: [unskip])
        }
        
        let skip = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
            self?.triggerHaptic(.medium)
            self?.viewModel.skipRoutine(routine) { [weak self] in
                self?.updateUIWithViewModel(); done(true)
            }
        }
        skip.image = UIImage(systemName: "forward.fill")?
            .withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
        skip.backgroundColor = AppColors.accentOrange
        
        let config = UISwipeActionsConfiguration(actions: [skip])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isPastOrFutureDay(),
              !isCompletedSectionHeader(at: indexPath),
              !isSkippedSectionHeader(at: indexPath),
              let routine = routine(at: indexPath) else {
            return nil
        }
        
        // skipped
        if indexPath.section == 2 {
            let complete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
                self?.triggerHaptic(.medium)
                self?.viewModel.toggleRoutine(routine) { [weak self] in
                    self?.updateUIWithViewModel()
                    done(true)
                }
            }
            
            complete.image = UIImage(systemName: "checkmark")?

                .withTintColor(AppColors.background, renderingMode: .alwaysOriginal)

            complete.backgroundColor = AppColors.accentGreen

            let config = UISwipeActionsConfiguration(actions: [complete])

            config.performsFirstActionWithFullSwipe = true

            return config
        }
        
        // normal
        if routine.isCountBased {
            guard routine.canQuickComplete else { return nil }

            let complete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
                self?.triggerHaptic(.medium)
                self?.viewModel.toggleRoutine(routine) { [weak self] in
                    self?.updateUIWithViewModel(); done(true)
                }
            }
            complete.image = UIImage(systemName: "checkmark")?
                .withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
            complete.backgroundColor = AppColors.accentGreen

            let config = UISwipeActionsConfiguration(actions: [complete])
            config.performsFirstActionWithFullSwipe = true
            return config
        }

        let isCompleted = routine.isCompletedToday
        let toggle = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, done in
            self?.triggerHaptic(.medium)
            
            self?.viewModel.toggleRoutine(routine) { [weak self] in
                self?.updateUIWithViewModel(); done(true)
            }
        }
        toggle.image = UIImage(systemName: isCompleted ? "arrow.uturn.backward" : "checkmark")?
            .withTintColor(AppColors.background, renderingMode: .alwaysOriginal)
        toggle.backgroundColor = isCompleted ? AppColors.secondary : AppColors.accentGreen
        
        let config = UISwipeActionsConfiguration(actions: [toggle])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - Context Menu Builder
private extension TodayViewController {
    
    func makeContextMenu(for routine: Routine, at indexPath: IndexPath) -> UIMenu {
        let isCompleted = routine.isCompletedToday
        let isSkipped   = indexPath.section == 2
        let isToday     = !isPastOrFutureDay()
        let menuTitle   = routine.name ?? ""
        
        // Edit
        let edit = UIAction(
            title: "edit".localized,
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.openEdit(for: routine)
        }
        
        // View Detail
        let detail = UIAction(
            title: "view_detail".localized,
            image: UIImage(systemName: "info.circle")
        ) { [weak self] _ in
            self?.openDetail(for: routine)
        }

        guard isToday else {
            return UIMenu(title: menuTitle, children: [detail, edit])
        }

        if isSkipped {
            let unskip = UIAction(
                title: "unskip".localized,
                image: UIImage(systemName: "arrow.uturn.backward")
            ) { [weak self] _ in
                self?.triggerHaptic(.light)
                self?.viewModel.unskipRoutine(routine) { [weak self] in self?.updateUIWithViewModel() }
            }

            let complete = UIAction(
                title: "complete".localized,
                image: UIImage(systemName: "checkmark.circle")
            ) { [weak self] _ in
                self?.triggerHaptic(.medium)
                self?.viewModel.toggleRoutine(routine) { [weak self] in self?.updateUIWithViewModel() }
            }
            return UIMenu(title: menuTitle, children: [complete, unskip, edit, detail])
        }

        let skip = UIAction(
            title: "skip".localized,
            image: UIImage(systemName: "forward.circle")
        ) { [weak self] _ in
            self?.triggerHaptic(.medium)
            self?.viewModel.skipRoutine(routine) { [weak self] in self?.updateUIWithViewModel() }
        }

        if routine.isCountBased {
            guard routine.canQuickComplete else {
                return UIMenu(title: menuTitle, children: [skip, edit, detail])
            }
            let complete = UIAction(
                title: "complete".localized,
                image: UIImage(systemName: "checkmark.circle")
            ) { [weak self] _ in
                self?.triggerHaptic(.medium)
                self?.viewModel.toggleRoutine(routine) { [weak self] in self?.updateUIWithViewModel() }
            }
            return UIMenu(title: menuTitle, children: [complete, skip, edit, detail])
        }

        let toggleTitle = isCompleted ? "uncomplete".localized : "complete".localized
        let toggleIcon  = isCompleted ? "arrow.uturn.backward" : "checkmark.circle"
        let toggle = UIAction(
            title: toggleTitle,
            image: UIImage(systemName: toggleIcon)
        ) { [weak self] _ in
            self?.triggerHaptic(.medium)
            self?.viewModel.toggleRoutine(routine) { [weak self] in self?.updateUIWithViewModel() }
        }

        return UIMenu(title: menuTitle, children: [toggle, skip, edit, detail])
    }
}
