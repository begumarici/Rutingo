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
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TodayCell")
        table.backgroundColor = AppColors.background
        return table
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
        title = "Today"
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(greetingLabel)
        view.addSubview(dateLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.padding),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: Layout.smallPadding),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            tableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Layout.padding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        tableView.reloadData()
    }
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todayRoutines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCell", for: indexPath)
        let routine = viewModel.todayRoutines[indexPath.row]
        
        let isCompleted = routine.isCompletedToday
        let checkmark = isCompleted ? "✅" : "⬜️"
        cell.textLabel?.text = "\(checkmark) \(routine.emoji ?? "") \(routine.name ?? "Unnamed")"
        
        return cell
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = viewModel.todayRoutines[indexPath.row]
        viewModel.toggleRoutine(routine)
        tableView.reloadData()
    }
}
