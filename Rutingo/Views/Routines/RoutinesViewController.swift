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
        title = "Routines"
        
        setupNavigationBar()
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoutineTapped)
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData() {
        viewModel.loadData()
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
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let routine = viewModel.allRoutines[indexPath.row]
            viewModel.deleteRoutine(routine)
            tableView.reloadData()
        }
    }
}
