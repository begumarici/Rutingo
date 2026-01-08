//
//  SettingsViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 8.01.2026.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = AppColors.background
        table.separatorStyle = .none
        table.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        return table
    }()
    
    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupTableView()
        addSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Settings"
        
        configureNavigationBarAppearance()
    }
    
    private func configureNavigationBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        navigationBar.largeTitleTextAttributes = [
            .font: AppFonts.bold(34),
            .foregroundColor: AppColors.primary
        ]
        navigationBar.titleTextAttributes = [
            .font: AppFonts.semibold(17),
            .foregroundColor: AppColors.primary
        ]
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Helpers
    
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0: // General
            cell.configure(icon: "globe", title: "Language", detail: "English")
            
        case 1: // Data
            cell.configure(icon: "trash", title: "Clear All Data", isDestructive: true)
            
        case 2: // About
            cell.configure(icon: "info.circle", title: "Version", detail: "1.0.0")
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Data"
        case 2: return "About"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Language
            // TODO: - Language section will be opened
        case 1: // CLear data
            showClearDataAlert()
            // Version
        case 2:
            break
        default:
            break
        }
    }
    
    private func showClearDataAlert() {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "Are you sure you want to delete all your routines and progress? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            CoreDataManager.shared.clearAllData()
            
            let successAlert = UIAlertController(
                title: "Data Cleared",
                message: "All your routines and progress have been deleted.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}
