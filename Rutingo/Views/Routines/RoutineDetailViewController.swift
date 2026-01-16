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
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // Stats Card
    private let mainStatsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }()

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
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
    
    private let frequencyValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.medium(14)
        label.textAlignment = .center
        label.textColor = AppColors.secondary
        return label
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondary
        return view
    }()

    private let streakStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()

    private let currentStreakStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    private let currentStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.secondary
        return label
    }()

    private let currentStreakTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "current_streak".localized
        label.font = AppFonts.regular(13)
        label.textColor = AppColors.secondary
        return label
    }()

    private let bestStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()

    private let completionRateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    private let completionRateValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(56)
        label.textColor = AppColors.primary
        return label
    }()

    private let completionRateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "overall_completion".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        return label
    }()

    private let completionRateDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(13)
        label.textColor = AppColors.secondary
        return label
    }()

    // Calendar Card
    private let calendarCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }()

    private let calendarSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "completed_days_this_week".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()

    private lazy var calendarView: WeekCalendarView = {
        let view = WeekCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization
    init(routine: Routine, viewModel: RoutinesViewModel) {
        self.routine = routine
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupUI()
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
 
        mainStackView.addArrangedSubview(mainStatsCard)
        mainStackView.addArrangedSubview(calendarCardView)
        
        mainStatsCard.addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(nameLabel)
        statsStackView.addArrangedSubview(frequencyValueLabel)
        
        statsStackView.setCustomSpacing(4, after: nameLabel)
        
        statsStackView.setCustomSpacing(12, after: frequencyValueLabel)
        statsStackView.addArrangedSubview(separatorLine)
        statsStackView.setCustomSpacing(20, after: separatorLine)
        
        currentStreakStackView.addArrangedSubview(currentStreakLabel)
        currentStreakStackView.addArrangedSubview(currentStreakTitleLabel)
        
        streakStackView.addArrangedSubview(currentStreakStackView)
        streakStackView.addArrangedSubview(bestStreakLabel)
        statsStackView.addArrangedSubview(streakStackView)
        
        completionRateStackView.addArrangedSubview(completionRateValueLabel)
        completionRateStackView.addArrangedSubview(completionRateTitleLabel)
        completionRateStackView.addArrangedSubview(completionRateDetailLabel)
        statsStackView.addArrangedSubview(completionRateStackView)
        
        calendarCardView.addSubview(calendarSectionStack)
        calendarSectionStack.addArrangedSubview(calendarTitleLabel)
        calendarSectionStack.addArrangedSubview(calendarView)
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
            
            statsStackView.topAnchor.constraint(equalTo: mainStatsCard.topAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: mainStatsCard.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: mainStatsCard.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: mainStatsCard.bottomAnchor, constant: -24),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            calendarSectionStack.topAnchor.constraint(equalTo: calendarCardView.topAnchor, constant: 20),
            calendarSectionStack.leadingAnchor.constraint(equalTo: calendarCardView.leadingAnchor, constant: 20),
            calendarSectionStack.trailingAnchor.constraint(equalTo: calendarCardView.trailingAnchor, constant: -20),
            calendarSectionStack.bottomAnchor.constraint(equalTo: calendarCardView.bottomAnchor, constant: -20),
            
            calendarView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    private func configureWithRoutine() {
        nameLabel.text = routine.name
        configureStreakLabels()
        configureCompletionRate()
        configureFrequency()
        configureCalendar()
    }
    
    private func configureStreakLabels() {
        let currentStreak = routine.currentStreak
        
        let streakText = currentStreak == 0 ? " \("no_streak".localized)" : " \(currentStreak) \("days_suffix".localized)"

        currentStreakLabel.attributedText = createAttributedText(
            icon: "link",
            text: streakText,
            iconColor: AppColors.secondary,
            iconSize: 24,
            yOffset: -4
        )
        
        let bestStreak = viewModel.getBestStreak(for: routine)
        bestStreakLabel.attributedText = createAttributedText(
            icon: "trophy.fill",
            text: " \("best".localized): \(bestStreak)",
            iconColor: AppColors.secondary,
            iconSize: 16,
            yOffset: -2
        )
    }

    private func createAttributedText(
        icon: String,
        text: String,
        iconColor: UIColor,
        iconSize: CGFloat,
        yOffset: CGFloat
    ) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)?
            .withTintColor(iconColor, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: yOffset, width: iconSize, height: iconSize)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(
            string: text,
            attributes: [.foregroundColor: AppColors.secondary]
        ))
        
        return attributedString
    }
    
    private func configureCompletionRate() {
        let completionRate = viewModel.getCompletionRate(for: routine)
        let totalCompletions = routine.completionDates.count
        
        completionRateValueLabel.text = String(format: "percent_format".localized, completionRate)
        completionRateDetailLabel.text = "\(totalCompletions) \("total_completions".localized)"
    }
    
    private func configureFrequency() {
        frequencyValueLabel.text = routine.frequency.displayText
    }
    
    private func configureCalendar() {
        let dates = DateHelper.shared.currentWeekDays()
        var progressMap: [Date: Double] = [:]
        
        for date in dates {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let isCompleted = routine.isCompleted(on: normalizedDate)
            progressMap[normalizedDate] = isCompleted ? 1.0 : 0.0
        }
        
        calendarView.configure(with: dates, progressMap: progressMap)
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        let addVC = AddRoutineViewController()
        addVC.mode = .edit(routine)
        
        addVC.onUpdate = { [weak self] routine, name, frequency, hasReminder, reminderTime in
            guard let self = self else { return }
       
            self.viewModel.updateRoutine(routine: routine,
                                         name: name,
                                         frequency: frequency,
                                         hasReminder: hasReminder,
                                         reminderTime: reminderTime) {
                
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
