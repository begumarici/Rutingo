//
//  AddRoutineViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 22.11.2025.
//

import UIKit

class AddRoutineViewController: UIViewController {
    var onSave: ((String, Frequency) -> Void)?
    private var selectedFrequency: Frequency = .daily
    private var selectedDays: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Name"
        label.font = AppFonts.semibold(14)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter routine name"
        textField.borderStyle = .roundedRect
        textField.font = AppFonts.regular(16)
        return textField
    }()
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Frequency"
        label.font = AppFonts.semibold(14)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let frequencyControl: UISegmentedControl = {
        let items = ["Daily", "Specific Days"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Days of Week"
        label.font = AppFonts.semibold(14)
        label.textColor = AppColors.secondary
        label.isHidden = true
        return label
    }()
    
    private let dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = AppFonts.semibold(18)
        button.backgroundColor = AppColors.accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Layout.cornerRadius
        return button
    }()
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        title = "Add Routine"
        
        setupNavigationBar()
        addSubviews()
        setupConstraints()
        setupActions()
        createDayButtons()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func addSubviews() {
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(frequencyLabel)
        view.addSubview(frequencyControl)
        view.addSubview(daysLabel)
        view.addSubview(dayStackView)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
  
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            frequencyLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            frequencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            frequencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),

            frequencyControl.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 8),
            frequencyControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            frequencyControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            frequencyControl.heightAnchor.constraint(equalToConstant: 32),

            daysLabel.topAnchor.constraint(equalTo: frequencyControl.bottomAnchor, constant: 24),
            daysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            daysLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),

            dayStackView.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 8),
            dayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            dayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            dayStackView.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        frequencyControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func createDayButtons() {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        
        for (index, day) in days.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(day, for: .normal)
            button.tag = index + 1
            button.titleLabel?.font = AppFonts.semibold(16)

            button.backgroundColor = AppColors.cardBackground
            button.setTitleColor(UIColor.black, for: .normal)
            button.layer.cornerRadius = 22
            button.clipsToBounds = true
            
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            dayStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func frequencyChanged() {
        if frequencyControl.selectedSegmentIndex == 0 {
            selectedFrequency = .daily
            dayStackView.isHidden = true
            daysLabel.isHidden = true
        } else {
            dayStackView.isHidden = false
            daysLabel.isHidden = false
        }
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.tag
        
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
            sender.backgroundColor = AppColors.cardBackground
            sender.setTitleColor(UIColor.black, for: .normal)
        } else {
            selectedDays.append(day)
            sender.backgroundColor = AppColors.progressLow

            if selectedDays.count == 7 {
                switchToDaily()
            }
        }
    }
    
    private func switchToDaily() {
        frequencyControl.selectedSegmentIndex = 0
        selectedDays.removeAll()
        
        for case let button as UIButton in dayStackView.arrangedSubviews {
            button.backgroundColor = AppColors.cardBackground
        }
        
        dayStackView.isHidden = true
        daysLabel.isHidden = true
    }
    
    @objc private func saveButtonTapped() {
        guard validate() else { return }
        
        let name = nameTextField.text ?? ""
        
        if frequencyControl.selectedSegmentIndex == 1 {
            if selectedDays.count == 7 {
                selectedFrequency = .daily
            } else {
                selectedFrequency = .specificDays(selectedDays.sorted())
            }
        } else {
            selectedFrequency = .daily
        }
        
        onSave?(name, selectedFrequency)
        dismiss(animated: true)
    }
    
    private func validate() -> Bool {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter a routine name")
            return false
        }
        
        if frequencyControl.selectedSegmentIndex == 1 && selectedDays.isEmpty {
            showAlert(message: "Please select at least one day")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
