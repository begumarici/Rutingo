//
//  RoutinesViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 15.11.2025.
//

import UIKit

class RoutinesViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = RoutinesViewModel()
    
    // MARK: - UI Components
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
    
    private let emptyStateStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    private let emptyStateIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "plus.circle")?.withConfiguration(
            UIImage.SymbolConfiguration(weight: .thin)
        )
        imageView.tintColor = AppColors.secondary.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "no_routines_message".localized
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        setupNavigationBar()
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "routines".localized
        
        configureNavigationBarAppearance()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoutineTapped)
        )
    }
    
    private func configureNavigationBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.largeTitleTextAttributes = [
            .font: AppFonts.bold(34),
            .foregroundColor: AppColors.navbarTitle
        ]
        navigationBar.titleTextAttributes = [
            .font: AppFonts.semibold(17),
            .foregroundColor: AppColors.navbarTitle
        ]
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        
        emptyStateView.addSubview(emptyStateStackView)
        emptyStateStackView.addArrangedSubview(emptyStateIconView)
        emptyStateStackView.addArrangedSubview(emptyStateLabel)
        
        view.addSubview(emptyStateView)
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
            
            emptyStateStackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            
            emptyStateIconView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateIconView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Data Loading
    private func loadData() {
        viewModel.loadData { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            
            let isEmpty = self.viewModel.allRoutines.isEmpty
            self.emptyStateView.isHidden = !isEmpty
            if isEmpty {
                self.view.bringSubviewToFront(self.emptyStateView)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addRoutineTapped() {
        let addVC = AddRoutineViewController()
        addVC.onSave = { [weak self] name, frequency, hasReminder, reminderTime in
            self?.viewModel.addRoutine(name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime) {
                self?.loadData()
            }
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension RoutinesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = viewModel.allRoutines[indexPath.row]
        let detailVC = RoutineDetailViewController(routine: routine, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let routine = viewModel.allRoutines[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            let alert = UIAlertController(
                title: "delete_routine".localized,
                message: "delete_routine_message".localized,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel) { _ in
                completionHandler(false)
            })
            
            alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { _ in
                self.viewModel.deleteRoutine(routine) {
                    self.loadData()
                    completionHandler(true)
                }
            })
            
            self.present(alert, animated: true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
