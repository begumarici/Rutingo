//
//  Untitled.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import UIKit

final class TasksViewController: UIViewController {

    // MARK: - Section
    private enum Section: Int, CaseIterable {
        case active
        case completed
    }

    // MARK: - Properties
    private let viewModel = TasksViewModel()

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "tasks_title".localized
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "tasks_add_placeholder".localized
        textField.borderStyle = .none
        textField.returnKeyType = .done
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = """
        \("tasks_empty_title".localized)
        \("tasks_empty_message".localized)
        """
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchAndReload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndReload()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        textField.delegate = self
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews(){
        view.addSubview(titleLabel)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            inputContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputContainerView.heightAnchor.constraint(equalToConstant: 52),

            textField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.separatorStyle = .none
    }

    // MARK: - Data
    private func fetchAndReload() {
        viewModel.fetchTasks()
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = viewModel.activeTasks.isEmpty && viewModel.completedTasks.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func addTaskFromInput() {
        guard let text = textField.text else { return }
        viewModel.addTask(title: text)
        textField.text = nil
        fetchAndReload()
    }

    private func task(at indexPath: IndexPath) -> Task {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .active:
            return viewModel.activeTasks[indexPath.row]
        case .completed:
            return viewModel.completedTasks[indexPath.row]
        }
    }
}

// MARK: - UITextFieldDelegate
extension TasksViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTaskFromInput()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension TasksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .active:
            return viewModel.activeTasks.count
        case .completed:
            return viewModel.completedTasks.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .active:
            return nil
        case .completed:
            return viewModel.completedTasks.isEmpty ? nil : "tasks_completed".localized
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let task = task(at: indexPath)

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCell.identifier,
            for: indexPath
        ) as? TaskCell else {
            return UITableViewCell()
        }

        cell.configure(with: task)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = task(at: indexPath)
        viewModel.toggleTask(selectedTask)
        fetchAndReload()
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] _, _, completion in
            guard let self else { return }

            let task = self.task(at: indexPath)
            self.viewModel.deleteTask(task)
            self.fetchAndReload()
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
