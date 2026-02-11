//
//  ThemeSelectionViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 10.02.2026.
//

import UIKit

class ThemeSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private let themes: [Theme] = [.system, .light, .dark]
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = AppColors.background
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell")
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
        title = "theme".localized
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ThemeSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme.displayName
        cell.textLabel?.font = AppFonts.regular(17)
        cell.textLabel?.textColor = AppColors.primary
        cell.backgroundColor = AppColors.cardBackground
        
        if theme == ThemeManager.shared.currentTheme {
            cell.accessoryType = .checkmark
            cell.tintColor = AppColors.primary
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTheme = themes[indexPath.row]
        ThemeManager.shared.currentTheme = selectedTheme
        
        tableView.reloadData()
    }
}
