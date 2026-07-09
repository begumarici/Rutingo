//
//  RoutineDetailViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.11.2025.
//

import UIKit

class RoutineDetailViewController: UIViewController {
    
    // MARK: - Properties
    var routine: Routine! // !!!!
    private let viewModel: RoutinesViewModel
    private let calendarViewModel = CalendarViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    // MARK: - Stats Card
    private let statsCard: UIView = makeCard()

    private let statsInner: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.primary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let statsRowStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()

    private let streakMiniCard: UIView = makeMiniCard()
    private let bestStreakMiniCard: UIView = makeMiniCard()
    private let completionMiniCard: UIView = makeMiniCard()

    private let streakValueLabel: UILabel = makeMiniLabel()
    private let bestStreakValueLabel: UILabel = makeMiniLabel()
    private let completionValueLabel: UILabel = makeMiniLabel()

    // MARK: - Calendar Card
    private let calendarCard: UIView = makeCard()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(17)
        label.textColor = AppColors.primary
        label.textAlignment = .center
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
        return stack
    }()

    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        return cv
    }()

    private let legendStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    // MARK: - Dynamic Info Cards
    private var dynamicCards: [UIView] = []

    // MARK: - Init
    init(routine: Routine, viewModel: RoutinesViewModel = RoutinesViewModel()) {
        self.routine = routine
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
        setupCalendarCard()
        configureWithRoutine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
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
    }
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        statsCard.addSubview(statsInner)
        statsInner.addArrangedSubview(nameLabel)
        statsInner.addArrangedSubview(statsRowStack)

        // Mini cards
        embedInMiniCard(streakValueLabel, labelText: "streak".localized, into: streakMiniCard)
        embedInMiniCard(bestStreakValueLabel, labelText: "best".localized, into: bestStreakMiniCard)
        embedInMiniCard(completionValueLabel, labelText: "completion".localized, into: completionMiniCard)

        statsRowStack.addArrangedSubview(streakMiniCard)
        statsRowStack.addArrangedSubview(bestStreakMiniCard)
        statsRowStack.addArrangedSubview(completionMiniCard)

        mainStackView.addArrangedSubview(statsCard)
    }
    
    private func setupConstraints() {
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

            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            statsInner.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 24),
            statsInner.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 20),
            statsInner.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -20),
            statsInner.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -24),

            statsRowStack.leadingAnchor.constraint(equalTo: statsInner.leadingAnchor),
            statsRowStack.trailingAnchor.constraint(equalTo: statsInner.trailingAnchor),

            streakMiniCard.heightAnchor.constraint(equalToConstant: 72),
            bestStreakMiniCard.heightAnchor.constraint(equalToConstant: 72),
            completionMiniCard.heightAnchor.constraint(equalToConstant: 72),
        ])
    }

    // MARK: - Calendar Card Setup
    private func setupCalendarCard() {
        let weekdays = ["day_mon".localized, "day_tue".localized, "day_wed".localized,
                        "day_thu".localized, "day_fri".localized, "day_sat".localized, "day_sun".localized]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = AppFonts.bold(11)
            label.textColor = AppColors.secondary
            label.textAlignment = .center
            weekdayStackView.addArrangedSubview(label)
        }

        // Legend
        let legendItems: [(UIColor, String)] = [
            (AppColors.accentGreen, "legend_done".localized),
            (AppColors.accentOrange, "legend_skipped".localized),
            (UIColor.dynamic(light: "D93025", dark: "FF3B30"), "legend_missed".localized),
        ]
        for (color, text) in legendItems {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = color
            dot.layer.cornerRadius = 5
            let lbl = UILabel()
            lbl.font = AppFonts.regular(11)
            lbl.textColor = AppColors.secondary
            lbl.text = text
            let row = UIStackView(arrangedSubviews: [dot, lbl])
            row.axis = .horizontal
            row.spacing = 5
            row.alignment = .center
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 10),
                dot.heightAnchor.constraint(equalToConstant: 10),
            ])
            legendStack.addArrangedSubview(row)
        }

        calendarCard.addSubview(monthLabel)
        calendarCard.addSubview(previousButton)
        calendarCard.addSubview(nextButton)
        calendarCard.addSubview(weekdayStackView)
        calendarCard.addSubview(calendarCollectionView)
        calendarCard.addSubview(legendStack)

        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: calendarCard.topAnchor, constant: 16),
            monthLabel.centerXAnchor.constraint(equalTo: calendarCard.centerXAnchor),

            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            previousButton.widthAnchor.constraint(equalToConstant: 36),
            previousButton.heightAnchor.constraint(equalToConstant: 36),

            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36),

            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 12),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 24),

            calendarCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 4),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 240),

            legendStack.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 12),
            legendStack.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 12),
            legendStack.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -12),
            legendStack.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: -16),
        ])

        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self

        mainStackView.addArrangedSubview(calendarCard)
    }
    
    // MARK: - Configuration
    private func configureWithRoutine() {
        dynamicCards.forEach { $0.removeFromSuperview() }
        dynamicCards.removeAll()
        
        nameLabel.text = routine.name
        
        // stat mini cards
        let streak = routine.currentStreak
        streakValueLabel.attributedText = makeIconText(
            icon: "flame.fill",
            text: " \(streak)",
            iconColor: streak > 0 ? AppColors.accentOrange : AppColors.secondary
        )

        // Best streak
        let best = viewModel.getBestStreak(for: routine)
        bestStreakValueLabel.attributedText = makeIconText(
            icon: "trophy.fill",
            text: " \(best)",
            iconColor: AppColors.secondary
        )

        // Completion
        let rate = viewModel.getCompletionRate(for: routine)
        completionValueLabel.attributedText = makeIconText(
            icon: "checkmark.seal.fill",
            text: " \(rate)%",
            iconColor: AppColors.primary
        )

        // update calendar
        calendarViewModel.filteredRoutine = routine
        calendarViewModel.loadData { [weak self] in
            self?.monthLabel.text = self?.calendarViewModel.getMonthTitle()
            self?.calendarCollectionView.reloadData()
        }

        // completion / goal progress
        let progressCard = routine.isCountBased ? makeGoalCard() : makeCompletionCard()
        dynamicCards.append(progressCard)
        let insertIndex = mainStackView.arrangedSubviews.firstIndex(of: calendarCard) ?? mainStackView.arrangedSubviews.count
        mainStackView.insertArrangedSubview(progressCard, at: insertIndex)

        // time info
        var scheduleItems: [(icon: String, iconColor: UIColor, iconBg: UIColor,
                             title: String, value: String, multiline: Bool)] = []

        scheduleItems.append((
            icon: "repeat",
            iconColor: UIColor(hex: "#185FA5"),
            iconBg: UIColor(hex: "#E6F1FB"),
            title: "frequency".localized,
            value: routine.frequency.displayText,
            multiline: false
        ))
        
        if routine.startHour >= 0, routine.endHour >= 0 {
            let start = String(format: "%02d:%02d", routine.startHour, routine.startMinute)
            let end   = String(format: "%02d:%02d", routine.endHour, routine.endMinute)
            scheduleItems.append((
                icon: "clock",
                iconColor: AppColors.secondary,
                iconBg: AppColors.secondaryCardBackground,
                title: "time_range".localized,
                value: "\(start) – \(end)",
                multiline: false
            ))
        }

        // Reminder
        if routine.hasReminder, let time = routine.reminderTime {
            let fmt = DateFormatter()
            fmt.timeStyle = .short
            scheduleItems.append((
                icon: "bell.fill",
                iconColor: UIColor(hex: "#854F0B"),
                iconBg: UIColor(hex: "#FAEEDA"),
                title: "reminder".localized,
                value: fmt.string(from: time),
                multiline: false
            ))
        }

        let scheduleCard = makeGroupedCard(items: scheduleItems)
        dynamicCards.append(scheduleCard)
        mainStackView.addArrangedSubview(scheduleCard)

        // personal info
        var personalItems: [(icon: String, iconColor: UIColor, iconBg: UIColor,
                              title: String, value: String, multiline: Bool)] = []
        
        if let feelingDisplay = routine.feelingType?.displayText {
            personalItems.append((
                icon: "heart.fill",
                iconColor: UIColor(hex: "#A32D2D"),
                iconBg: UIColor(hex: "#FCEBEB"),
                title: "feeling".localized,
                value: feelingDisplay,
                multiline: false
            ))
        }

        // Motivation
        if let motivation = routine.motivation, !motivation.isEmpty {
            personalItems.append((
                icon: "lightbulb.fill",
                iconColor: UIColor(hex: "#534AB7"),
                iconBg: UIColor(hex: "#EEEDFE"),
                title: "motivation".localized,
                value: motivation,
                multiline: true
            ))
        }
        
        if !personalItems.isEmpty {
            let personalCard = makeGroupedCard(items: personalItems)
            dynamicCards.append(personalCard)
            mainStackView.addArrangedSubview(personalCard)
        }
    }

    // MARK: - Goal Card
    // MARK: - Completion Card (binary routines)
    private func makeCompletionCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.cardBackground
        card.layer.cornerRadius = Layout.cardCornerRadius

        let isCompleted = routine.isCompletedToday

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = isCompleted ? "uncomplete".localized : "complete".localized
        config.image = UIImage(systemName: isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = isCompleted ? AppColors.secondaryCardBackground : AppColors.accentGreen
        config.baseForegroundColor = isCompleted ? AppColors.primary : AppColors.onAccent
        button.configuration = config
        button.addTarget(self, action: #selector(completionToggleTapped), for: .touchUpInside)

        card.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])

        return card
    }

    @objc private func completionToggleTapped() {
        viewModel.toggleCompletion(routine) { [weak self] in
            self?.configureWithRoutine()
        }
    }

    // MARK: - Goal Card
    private func makeGoalCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.cardBackground
        card.layer.cornerRadius = Layout.cardCornerRadius

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFonts.semibold(16)
        titleLabel.textColor = AppColors.primary
        titleLabel.text = "today_progress".localized

        let minusButton = UIButton(type: .system)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        minusButton.tintColor = routine.todayValue > 0 ? AppColors.tertiary : AppColors.tertiary.withAlphaComponent(0.4)
        minusButton.isEnabled = routine.todayValue > 0
        minusButton.addTarget(self, action: #selector(goalDecrementTapped), for: .touchUpInside)

        let plusButton = UIButton(type: .system)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = AppColors.accentGreen
        plusButton.addTarget(self, action: #selector(goalIncrementTapped), for: .touchUpInside)

        let isCompleted = routine.isCompletedToday
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AppFonts.bold(24)
        valueLabel.textColor = isCompleted ? AppColors.accentGreen : AppColors.primary
        valueLabel.textAlignment = .center
        valueLabel.text = "\(Routine.formattedGoalValue(routine.todayValue))/\(Routine.formattedGoalValue(routine.targetValue))\(routine.routineUnit.shortSuffix)"
        valueLabel.isUserInteractionEnabled = true
        valueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalValueTapped)))

        let resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("reset".localized, for: .normal)
        resetButton.titleLabel?.font = AppFonts.medium(13)
        resetButton.setTitleColor(AppColors.secondary, for: .normal)
        resetButton.addTarget(self, action: #selector(goalResetTapped), for: .touchUpInside)

        let controlsRow = UIStackView(arrangedSubviews: [minusButton, valueLabel, plusButton])
        controlsRow.translatesAutoresizingMaskIntoConstraints = false
        controlsRow.axis = .horizontal
        controlsRow.alignment = .center
        controlsRow.distribution = .equalSpacing

        let mainStack = UIStackView(arrangedSubviews: [titleLabel, controlsRow, resetButton])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 14
        mainStack.alignment = .center

        card.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),

            controlsRow.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            controlsRow.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),

            minusButton.widthAnchor.constraint(equalToConstant: 36),
            minusButton.heightAnchor.constraint(equalToConstant: 36),
            plusButton.widthAnchor.constraint(equalToConstant: 36),
            plusButton.heightAnchor.constraint(equalToConstant: 36),
        ])

        return card
    }

    @objc private func goalIncrementTapped() {
        viewModel.incrementGoal(routine) { [weak self] in
            self?.configureWithRoutine()
        }
    }

    @objc private func goalDecrementTapped() {
        viewModel.decrementGoal(routine) { [weak self] in
            self?.configureWithRoutine()
        }
    }

    @objc private func goalResetTapped() {
        let alert = UIAlertController(
            title: "reset_progress_title".localized,
            message: "reset_progress_message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "reset".localized, style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.resetGoal(self.routine) { [weak self] in
                self?.configureWithRoutine()
            }
        })
        present(alert, animated: true)
    }

    @objc private func goalValueTapped() {
        let alert = UIAlertController(title: "enter_value_title".localized, message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] field in
            field.keyboardType = .decimalPad
            field.text = self.map { Routine.formattedGoalValue($0.routine.todayValue) }
        }
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "save".localized, style: .default) { [weak self, weak alert] _ in
            guard let self, let text = alert?.textFields?.first?.text else { return }
            let normalized = text.replacingOccurrences(of: ",", with: ".")
            guard let value = Double(normalized) else { return }
            self.viewModel.setGoalValue(self.routine, value: value) { [weak self] in
                self?.configureWithRoutine()
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Grouped card builder
    private func makeGroupedCard(items: [(icon: String, iconColor: UIColor, iconBg: UIColor,
                                          title: String, value: String, multiline: Bool)]) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.cardBackground
        card.layer.cornerRadius = Layout.cardCornerRadius
        card.clipsToBounds = true

        var previousAnchor = card.topAnchor

        for (index, item) in items.enumerated() {
            let row = makeInfoRow(icon: item.icon, iconColor: item.iconColor,
                                  iconBg: item.iconBg, title: item.title,
                                  value: item.value, multiline: item.multiline)
            card.addSubview(row)

            if index > 0 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = AppColors.separator
                card.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.topAnchor.constraint(equalTo: previousAnchor),
                    separator.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                    separator.heightAnchor.constraint(equalToConstant: 0.5),
                ])
                NSLayoutConstraint.activate([
                    row.topAnchor.constraint(equalTo: separator.bottomAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    row.topAnchor.constraint(equalTo: card.topAnchor),
                ])
            }

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            ])

            previousAnchor = row.bottomAnchor

            if index == items.count - 1 {
                row.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
            }
        }

        return card
    }

    private func makeInfoRow(icon: String, iconColor: UIColor, iconBg: UIColor,
                             title: String, value: String, multiline: Bool) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let iconBox = UIView()
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.backgroundColor = iconBg
        iconBox.layer.cornerRadius = 8

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFonts.regular(12)
        titleLabel.textColor = AppColors.secondary
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AppFonts.semibold(15)
        valueLabel.textColor = AppColors.primary
        valueLabel.text = value
        valueLabel.numberOfLines = multiline ? 0 : 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2

        iconBox.addSubview(iconView)
        row.addSubview(iconBox)
        row.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconBox.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            iconBox.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconBox.widthAnchor.constraint(equalToConstant: 32),
            iconBox.heightAnchor.constraint(equalToConstant: 32),

            iconView.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            textStack.leadingAnchor.constraint(equalTo: iconBox.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -14),
        ])

        return row
    }

    // MARK: - Calendar Actions
    @objc private func previousMonthTapped() {
        calendarViewModel.changeMonth(by: -1) { [weak self] in
            self?.monthLabel.text = self?.calendarViewModel.getMonthTitle()
            self?.calendarCollectionView.reloadData()
        }
    }

    @objc private func nextMonthTapped() {
        calendarViewModel.changeMonth(by: 1) { [weak self] in
            self?.monthLabel.text = self?.calendarViewModel.getMonthTitle()
            self?.calendarCollectionView.reloadData()
        }
    }

    // MARK: - Actions
    @objc private func editTapped() {
        let addVC = AddRoutineViewController()
        addVC.mode = .edit(routine)
        
        addVC.onUpdate = { [weak self] routine, form in
            guard let self = self else { return }

            self.viewModel.updateRoutine(routine: routine, form: form) {
                self.routine = routine
                self.configureWithRoutine()
            }
        }
        
        addVC.onDelete = { [weak self] in
            guard let self = self else { return }
            self.viewModel.deleteRoutine(self.routine) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

// MARK: - CollectionView (Calendar)
extension RoutineDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarViewModel.uiModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.identifier, for: indexPath
        ) as? CalendarDayCell else { return UICollectionViewCell() }
        cell.configure(with: calendarViewModel.uiModels[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.bounds.width / 7)
        return CGSize(width: width, height: 40)
    }
}

// MARK: - Builder Helpers
private extension RoutineDetailViewController {

    static func makeCard() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cardCornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.07
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        return view
    }

    static func makeMiniCard() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryCardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }

    static func makeMiniLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(20)
        label.textColor = AppColors.primary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textAlignment = .center
        return label
    }

    func embedInMiniCard(_ valueLabel: UILabel, labelText: String, into card: UIView) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(11)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        label.text = labelText
        
        card.addSubview(valueLabel)
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -8),

            label.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
    }

    func makeIconText(icon: String, text: String, iconColor: UIColor) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -3, width: 20, height: 20)
        let result = NSMutableAttributedString(attachment: attachment)
        result.append(NSAttributedString(string: text, attributes: [.foregroundColor: AppColors.primary]))
        return result
    }
}
