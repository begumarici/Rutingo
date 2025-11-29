//
//  TodayViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.11.2025.
//

import UIKit

class TodayViewController: UIViewController {
    
    private let viewModel = TodayViewModel()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let dateLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let dailyFocusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(22)
        label.textColor = AppColors.primary
        label.text = "Your daily focus"
        return label
    }()
    
    private let progressInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TodayRoutineCell.self, forCellReuseIdentifier: TodayRoutineCell.identifier)
        table.backgroundColor = AppColors.background
        table.separatorStyle = .none
        return table
    }()
    
    private let weekCalendarView: WeekCalendarView = {
        let view = WeekCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No routines scheduled for today"
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(greetingLabel)
        view.addSubview(dateLabel)
        view.addSubview(weekCalendarView)
        view.addSubview(dailyFocusLabel)
        view.addSubview(progressInfoLabel)
        view.addSubview(tableView)
        
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.padding),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: Layout.smallPadding),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            weekCalendarView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Layout.padding),
            weekCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            weekCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            dailyFocusLabel.topAnchor.constraint(equalTo: weekCalendarView.bottomAnchor, constant: Layout.padding),
            dailyFocusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dailyFocusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            progressInfoLabel.topAnchor.constraint(equalTo: dailyFocusLabel.bottomAnchor, constant: 4),
            progressInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            progressInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
          
            tableView.topAnchor.constraint(equalTo: progressInfoLabel.bottomAnchor, constant: Layout.smallPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: progressInfoLabel.bottomAnchor, constant: 40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            emptyStateView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: Layout.padding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -Layout.padding)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData() {
        viewModel.loadData()
        greetingLabel.text = viewModel.greeting
        dateLabel.text = viewModel.dateText
        
        let dates = viewModel.lastSevenDays
        let progressMap = viewModel.getCompletionProgress()
        weekCalendarView.configure(with: dates, progressMap: progressMap)
        
        let completed = viewModel.todayRoutines.filter { $0.isCompletedToday }.count
        let total = viewModel.todayRoutines.count
        progressInfoLabel.text = "\(completed) of \(total) completed"
        
        let isEmpty = viewModel.todayRoutines.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.reloadData()
    }
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todayRoutines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier, for: indexPath) as? TodayRoutineCell else {
            return UITableViewCell()
        }
        
        let routine = viewModel.todayRoutines[indexPath.row]
        cell.configure(with: routine)
        
        return cell
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = viewModel.todayRoutines[indexPath.row]
        viewModel.toggleRoutine(routine)
        loadData()
    }
}
