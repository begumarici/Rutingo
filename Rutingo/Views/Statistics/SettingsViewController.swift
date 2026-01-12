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
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = AppColors.background
        table.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        return table
    }()
    
    // MARK: - Lifecycle
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
        title = "settings".localized
        
        configureNavigationBarAppearance()
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
    
    // MARK: - Actions
    private func openNotificationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    private func sendFeedback() {
        if let url = URL(string: "mailto:aricibegum@gmail.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showClearDataAlert() {
        let alert = UIAlertController(
            title: "clear_data_title".localized,
            message: "clear_data_message".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            CoreDataManager.shared.clearAllData()
            
            let successAlert = UIAlertController(
                title: "data_cleared".localized,
                message: "data_cleared_message".localized,
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "ok".localized, style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Notifications
        case 1: return 1 // Clear All Data
        case 2: return 2 // Send Feedback, Version
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0: // General
            cell.configure(icon: "bell", title: "notifications".localized)
            
        case 1: // Data
            cell.configure(icon: "trash", title: "clear_all_data".localized, isDestructive: true)
            
        case 2: // About
            if indexPath.row == 0 {
                cell.configure(icon: "envelope", title: "send_feedback".localized)
            } else {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                cell.configure(icon: "info.circle", title: "version".localized, detail: version)
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "general".localized
        case 1: return "data".localized
        case 2: return "about".localized
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Notifications
            openNotificationSettings()
            
        case 1: // Clear All Data
            showClearDataAlert()
            
        case 2: // About
            if indexPath.row == 0 {
                sendFeedback()
            }
            // Version - no action
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = AppColors.secondary
        header.textLabel?.font = AppFonts.semibold(18)
    }
}
