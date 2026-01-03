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
    private let ovalProgressView: OvalProgressView = {
        let view = OvalProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.secondary
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
        label.text = "No routines scheduled for today"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(greetingLabel)
        view.addSubview(dateLabel)
        view.addSubview(ovalProgressView)
        ovalProgressView.contentView.addSubview(tableView)
        ovalProgressView.contentView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.padding),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            ovalProgressView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8 ),
            ovalProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            ovalProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            ovalProgressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: ovalProgressView.contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: ovalProgressView.contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: ovalProgressView.contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: ovalProgressView.contentView.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: ovalProgressView.contentView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: ovalProgressView.contentView.centerYAnchor)
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
        
        // Progress
        let completed = viewModel.todayRoutines.filter { $0.isCompletedToday }.count
        let total = viewModel.todayRoutines.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0.0
        
        if progress == 1.0 && total > 0 {
            ovalProgressView.setCompleted()
        } else {
            ovalProgressView.setProgress(progress)
        }
        
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
        cell.configure(with: routine)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = viewModel.todayRoutines[indexPath.row]
        viewModel.toggleRoutine(routine) { [weak self] in
            self?.updateUIWithViewModel()
        }
    }
}
