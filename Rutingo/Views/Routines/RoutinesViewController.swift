//
//  RoutinesViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 15.11.2025.
//

import UIKit

class RoutinesViewController: UIViewController {
    private let viewModel = RoutinesViewModel()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(RoutineCell.self, forCellReuseIdentifier: RoutineCell.identifier)
        table.backgroundColor = AppColors.background
        table.separatorStyle = .none
        return table
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
        label.text = "No routines yet\nTap + to add your first routine"
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
        
        setupNavigationBar()
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Routines"
        
        if let navigationBar = navigationController?.navigationBar {
                navigationBar.largeTitleTextAttributes = [
                    .font: AppFonts.bold(34),
                    .foregroundColor: AppColors.primary
                ]
            navigationBar.titleTextAttributes = [
                        .font: AppFonts.semibold(17),
                        .foregroundColor: AppColors.primary
                    ]
                }
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoutineTapped)
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: Layout.padding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -Layout.padding)
        ])
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData() {
        viewModel.loadData()
        let isEmpty = viewModel.allRoutines.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty

        tableView.reloadData()
    }
    
    @objc private func addRoutineTapped() {
        let addVC = AddRoutineViewController()
        addVC.onSave = { [weak self] name, frequency in
            self?.viewModel.addRoutine(name: name, frequency: frequency)
            self?.loadData()
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

extension RoutinesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.allRoutines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutineCell.identifier, for: indexPath) as? RoutineCell else {
            return UITableViewCell()
        }
        
        let routine = viewModel.allRoutines[indexPath.row]
        cell.configure(with: routine)
        
        return cell
    }
}

extension RoutinesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = viewModel.allRoutines[indexPath.row]
        let detailVC = RoutineDetailViewController(routine: routine, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
