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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(32)
        label.textColor = AppColors.primary
        label.numberOfLines = 0
        return label
    }()
    
    private let mainStatsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }()
    
    private let streakContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currentStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = .black
        return label
    }()
    
    private let currentStreakTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Current Streak"
        label.font = AppFonts.regular(13)
        label.textColor = AppColors.tertiary
        return label
    }()
    
    private let bestStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.tertiary
        label.textAlignment = .right
        return label
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        return view
    }()

    private let completionRateValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(56)
        label.textColor = AppColors.accent
        label.textAlignment = .center
        return label
    }()
    
    private let completionRateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Overall Completion"
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.tertiary
        label.textAlignment = .center
        return label
    }()
    
    private let completionRateDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(13)
        label.textColor = AppColors.tertiary
        label.textAlignment = .center
        return label
    }()

    private let frequencyValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(15)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Last 7 Days"
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
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
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
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
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(mainStatsCard)
        contentView.addSubview(calendarTitleLabel)
        contentView.addSubview(calendarView)

        mainStatsCard.addSubview(streakContainerView)
        mainStatsCard.addSubview(separatorLine)
        mainStatsCard.addSubview(completionRateValueLabel)
        mainStatsCard.addSubview(completionRateTitleLabel)
        mainStatsCard.addSubview(completionRateDetailLabel)
        mainStatsCard.addSubview(frequencyValueLabel)
 
        streakContainerView.addSubview(currentStreakLabel)
        streakContainerView.addSubview(currentStreakTitleLabel)
        streakContainerView.addSubview(bestStreakLabel)
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
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            
            mainStatsCard.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            mainStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            mainStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            
            streakContainerView.topAnchor.constraint(equalTo: mainStatsCard.topAnchor, constant: 20),
            streakContainerView.leadingAnchor.constraint(equalTo: mainStatsCard.leadingAnchor, constant: 20),
            streakContainerView.trailingAnchor.constraint(equalTo: mainStatsCard.trailingAnchor, constant: -20),
            
            currentStreakLabel.topAnchor.constraint(equalTo: streakContainerView.topAnchor),
            currentStreakLabel.leadingAnchor.constraint(equalTo: streakContainerView.leadingAnchor),
            
            currentStreakTitleLabel.topAnchor.constraint(equalTo: currentStreakLabel.bottomAnchor, constant: 2),
            currentStreakTitleLabel.leadingAnchor.constraint(equalTo: streakContainerView.leadingAnchor),
            currentStreakTitleLabel.bottomAnchor.constraint(equalTo: streakContainerView.bottomAnchor),
            
            bestStreakLabel.centerYAnchor.constraint(equalTo: currentStreakLabel.centerYAnchor),
            bestStreakLabel.trailingAnchor.constraint(equalTo: streakContainerView.trailingAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: streakContainerView.bottomAnchor, constant: 20),
            separatorLine.leadingAnchor.constraint(equalTo: mainStatsCard.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: mainStatsCard.trailingAnchor, constant: -20),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            completionRateValueLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 24),
            completionRateValueLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            
            completionRateTitleLabel.topAnchor.constraint(equalTo: completionRateValueLabel.bottomAnchor, constant: 4),
            completionRateTitleLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            
            completionRateDetailLabel.topAnchor.constraint(equalTo: completionRateTitleLabel.bottomAnchor, constant: 2),
            completionRateDetailLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            
            frequencyValueLabel.topAnchor.constraint(equalTo: completionRateDetailLabel.bottomAnchor, constant: 24),
            frequencyValueLabel.centerXAnchor.constraint(equalTo: mainStatsCard.centerXAnchor),
            frequencyValueLabel.bottomAnchor.constraint(equalTo: mainStatsCard.bottomAnchor, constant: -20),
            
            calendarTitleLabel.topAnchor.constraint(equalTo: mainStatsCard.bottomAnchor, constant: 24),
            calendarTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            
            calendarView.topAnchor.constraint(equalTo: calendarTitleLabel.bottomAnchor, constant: 8),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            calendarView.heightAnchor.constraint(equalToConstant: 80),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
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
        let streakAttachment = NSTextAttachment()
        let streakIconSize: CGFloat = 24
        
        if currentStreak == 0 {
            streakAttachment.image = UIImage(systemName: "link")?
                .withTintColor(AppColors.tertiary, renderingMode: .alwaysOriginal)
            streakAttachment.bounds = CGRect(x: 0, y: -4, width: streakIconSize, height: streakIconSize)
            
            let streakAttributedString = NSMutableAttributedString(attachment: streakAttachment)
            streakAttributedString.append(NSAttributedString(
                string: " No Streak",
                attributes: [.foregroundColor: AppColors.tertiary]
            ))
            currentStreakLabel.attributedText = streakAttributedString
        } else {
            streakAttachment.image = UIImage(systemName: "link")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            streakAttachment.bounds = CGRect(x: 0, y: -4, width: streakIconSize, height: streakIconSize)
            
            let streakAttributedString = NSMutableAttributedString(attachment: streakAttachment)
            streakAttributedString.append(NSAttributedString(string: " \(currentStreak) Days"))
            currentStreakLabel.attributedText = streakAttributedString
        }
        
        // Best Streak
        let bestStreak = viewModel.getBestStreak(for: routine)
        let attachment = NSTextAttachment()
        let iconSize: CGFloat = 16
        attachment.image = UIImage(systemName: "trophy.fill")?
            .withTintColor(AppColors.tertiary, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: iconSize, height: iconSize)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " Best: \(bestStreak)"))
        bestStreakLabel.attributedText = attributedString
    }
    
    private func configureCompletionRate() {
        let completionRate = viewModel.getCompletionRate(for: routine)
        let totalCompletions = routine.completionDates.count
        
        completionRateValueLabel.text = "\(completionRate)%"
        completionRateDetailLabel.text = "\(totalCompletions) total completions"
    }
    
    private func configureFrequency() {
        let frequencyAttachment = NSTextAttachment()
        let frequencyIconSize: CGFloat = 15
        frequencyAttachment.image = UIImage(systemName: "calendar")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        frequencyAttachment.bounds = CGRect(x: 0, y: -2, width: frequencyIconSize, height: frequencyIconSize)

        let frequencyAttributedString = NSMutableAttributedString(attachment: frequencyAttachment)

        switch routine.frequency {
        case .daily:
            frequencyAttributedString.append(NSAttributedString(string: " Daily"))
        case .specificDays(let days):
            let dayNames = days.map { DateHelper.getDayName(for: $0) }
            frequencyAttributedString.append(NSAttributedString(string: " " + dayNames.joined(separator: ", ")))
        }

        frequencyValueLabel.attributedText = frequencyAttributedString
    }
    
    private func configureCalendar() {
        let dates = DateHelper.shared.lastSevenDays()
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
                                         reminderTime: reminderTime)
            
            self.routine = routine
            self.configureWithRoutine()
        }
        
        addVC.onDelete = { [weak self] in
            guard let self = self else { return }
            self.viewModel.deleteRoutine(self.routine)
            self.navigationController?.popViewController(animated: true)
        }
        
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

