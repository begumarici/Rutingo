//
//  RoutineDetailViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.11.2025.
//

import UIKit

class RoutineDetailViewController: UIViewController {
    
    // MARK: - Properties
    var routine: Routine!
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
        embedInMiniCard(streakValueLabel, into: streakMiniCard)
        embedInMiniCard(bestStreakValueLabel, into: bestStreakMiniCard)
        embedInMiniCard(completionValueLabel, into: completionMiniCard)

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
        
        // Streak
        let streak = routine.currentStreak
        streakValueLabel.attributedText = makeIconText(
            icon: "flame.fill",
            text: " \(streak)",
            iconColor: streak > 0 ? AppColors.accentOrange : AppColors.secondary
        )
        addTooltip(to: streakMiniCard, text: "current_streak".localized)

        // Best streak
        let best = viewModel.getBestStreak(for: routine)
        bestStreakValueLabel.attributedText = makeIconText(
            icon: "trophy.fill",
            text: " \(best)",
            iconColor: AppColors.secondary
        )
        addTooltip(to: bestStreakMiniCard, text: "best".localized)

        // Completion
        let rate = viewModel.getCompletionRate(for: routine)
        completionValueLabel.attributedText = makeIconText(
            icon: "checkmark.seal.fill",
            text: " \(rate)%",
            iconColor: AppColors.primary
        )
        addTooltip(to: completionMiniCard, text: "overall_completion".localized)

        // update calendar
        calendarViewModel.filteredRoutine = routine
        calendarViewModel.loadData { [weak self] in
            self?.monthLabel.text = self?.calendarViewModel.getMonthTitle()
            self?.calendarCollectionView.reloadData()
        }

        // Frequency
        addInfoCard(icon: "repeat", title: "frequency".localized, value: routine.frequency.displayText)

        // Time range
        if routine.startHour >= 0, routine.endHour >= 0 {
            let start = String(format: "%02d:%02d", routine.startHour, routine.startMinute)
            let end   = String(format: "%02d:%02d", routine.endHour,   routine.endMinute)
            addInfoCard(icon: "clock", title: "time_range".localized, value: "\(start) – \(end)")
        }

        // Reminder
        if routine.hasReminder, let time = routine.reminderTime {
            let fmt = DateFormatter()
            fmt.timeStyle = .short
            addInfoCard(icon: "bell.fill", title: "reminder".localized, value: fmt.string(from: time))
        }

        // Feeling
        if let feelingDisplay = routine.feelingType?.displayText {
            addInfoCard(icon: "heart.fill", title: "feeling".localized, value: feelingDisplay)
        }

        // Motivation
        if let motivation = routine.motivation, !motivation.isEmpty {
            addInfoCard(icon: "lightbulb.fill", title: "motivation".localized, value: motivation, multiline: true)
        }
    }

    private func addInfoCard(icon: String, title: String, value: String, multiline: Bool = false) {
        let card = makeInfoCard(icon: icon, title: title, value: value, multiline: multiline)
        dynamicCards.append(card)
        mainStackView.addArrangedSubview(card)
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
        
        addVC.onUpdate = { [weak self] routine, name, frequency, feeling, motivation, blockType, hasReminder, reminderTime, startHour, startMinute, endHour, endMinute in
            guard let self = self else { return }
            
            self.viewModel.updateRoutine(routine: routine,
                                         name: name,
                                         frequency: frequency,
                                         feeling: feeling,
                                         motivation: motivation,
                                         blockType: blockType,
                                         hasReminder: hasReminder,
                                         reminderTime: reminderTime,
                                         startHour: startHour,
                                         startMinute: startMinute,
                                         endHour: endHour,
                                         endMinute: endMinute
            ) {
                
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
    
    // MARK: - Tooltip
    private func addTooltip(to view: UIView, text: String) {
        view.gestureRecognizers?.removeAll()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gestureRecognizer.minimumPressDuration = 0.4
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
        view.accessibilityHint = text
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let source = gesture.view else { return }

        self.view.viewWithTag(9999)?.removeFromSuperview()

        let tooltip = UILabel()
        tooltip.tag = 9999
        tooltip.text = "  \(source.accessibilityHint ?? "")  "
        tooltip.font = AppFonts.medium(13)
        tooltip.textColor = AppColors.background
        tooltip.backgroundColor = AppColors.primary
        tooltip.layer.cornerRadius = 8
        tooltip.clipsToBounds = true
        tooltip.textAlignment = .center
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        tooltip.alpha = 0
        self.view.addSubview(tooltip)

        let frame = source.convert(source.bounds, to: self.view)
        NSLayoutConstraint.activate([
            tooltip.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: frame.midX),
            tooltip.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: frame.minY - 6),
            tooltip.heightAnchor.constraint(equalToConstant: 32),
        ])

        UIView.animate(withDuration: 0.7) { tooltip.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.2, animations: { tooltip.alpha = 0 }) { _ in
                tooltip.removeFromSuperview()
            }
        }
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

    func embedInMiniCard(_ label: UILabel, into card: UIView) {
        card.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -8),
        ])
    }

    func makeInfoCard(icon: String, title: String, value: String, multiline: Bool = false) -> UIView {
        let card = RoutineDetailViewController.makeCard()

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = AppColors.secondary
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

        card.addSubview(iconView)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        return card
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
