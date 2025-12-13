//
//  AddRoutineViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 22.11.2025.
//

import UIKit

class AddRoutineViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((String, Frequency, Bool, Date?) -> Void)?
    var onUpdate: ((Routine, String, Frequency, Bool, Date?) -> Void)?
    var onDelete: (() -> Void)?
    
    enum Mode {
        case add
        case edit(Routine)
    }
    var mode: Mode = .add
    
    private var selectedFrequency: Frequency = .daily
    private var selectedDays: [Int] = []
    private var hasReminder: Bool = false
    private var reminderTime: Date = Date()
    
    // MARK: - UI Components
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
    
    private let reminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Reminder"
        label.font = AppFonts.semibold(14)
        label.textColor = AppColors.secondary
        return label
    }()

    private let reminderSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        return toggle
    }()

    private let timePickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Routine", for: .normal)
        button.titleLabel?.font = AppFonts.semibold(16)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = Layout.cornerRadius
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.isHidden = true
        return button
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismiss()
        
        if case .edit(let routine) = mode {
            populateFields(with: routine)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        configureModeUI()
        setupNavigationBar()
        addSubviews()
        setupConstraints()
        setupActions()
        createDayButtons()
    }
    
    private func configureModeUI() {
        switch mode {
        case .add:
            title = "Add Routine"
            saveButton.setTitle("Save", for: .normal)
            deleteButton.isHidden = true
        case .edit:
            title = "Edit Routine"
            saveButton.setTitle("Update", for: .normal)
            deleteButton.isHidden = false
        }
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        view.addSubview(reminderLabel)   
        view.addSubview(reminderSwitch)
        view.addSubview(timePickerContainer)
        timePickerContainer.addSubview(timePicker)
        view.addSubview(saveButton)
        view.addSubview(deleteButton)
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
            
            reminderLabel.topAnchor.constraint(equalTo: dayStackView.bottomAnchor, constant: 24),
            reminderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            
            reminderSwitch.centerYAnchor.constraint(equalTo: reminderLabel.centerYAnchor),
            reminderSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            
            timePickerContainer.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 12),
            timePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            timePickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            timePickerContainer.heightAnchor.constraint(equalToConstant: 150),
            
            timePicker.topAnchor.constraint(equalTo: timePickerContainer.topAnchor),
            timePicker.leadingAnchor.constraint(equalTo: timePickerContainer.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: timePickerContainer.trailingAnchor),
            timePicker.bottomAnchor.constraint(equalTo: timePickerContainer.bottomAnchor),
            
            saveButton.topAnchor.constraint(equalTo: timePickerContainer.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.padding),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.padding),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        frequencyControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    
    @objc private func reminderSwitchChanged() {
        hasReminder = reminderSwitch.isOn
        timePickerContainer.isHidden = !reminderSwitch.isOn
        
        if reminderSwitch.isOn {
            reminderTime = timePicker.date
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
        
        let reminderEnabled = reminderSwitch.isOn
        let reminderDate = reminderEnabled ? timePicker.date : nil
        
        switch mode {
        case .add:
            onSave?(name, selectedFrequency, reminderEnabled, reminderDate)
        case .edit(let routine):
            onUpdate?(routine, name, selectedFrequency, reminderEnabled, reminderDate)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Routine",
            message: "Are you sure you want to delete this routine? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard case .edit(let routine) = self?.mode else { return }
            
            CoreDataManager.shared.deleteRoutine(routine)
            
            self?.onDelete?()
      
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    private func switchToDaily() {
        frequencyControl.selectedSegmentIndex = 0
        selectedDays.removeAll()
        
        for case let button as UIButton in dayStackView.arrangedSubviews {
            button.backgroundColor = AppColors.cardBackground
        }
        
        dayStackView.isHidden = true
        daysLabel.isHidden = true
    }
    
    private func populateFields(with routine: Routine) {
        nameTextField.text = routine.name
        
        switch routine.frequency {
        case .daily:
            frequencyControl.selectedSegmentIndex = 0
            dayStackView.isHidden = true
            daysLabel.isHidden = true
            
        case .specificDays(let days):
            frequencyControl.selectedSegmentIndex = 1
            selectedDays = days
            dayStackView.isHidden = false
            daysLabel.isHidden = false
            
            for day in days {
                for case let button as UIButton in dayStackView.arrangedSubviews {
                    if button.tag == day {
                        button.backgroundColor = AppColors.progressLow
                        button.setTitleColor(.black, for: .normal)
                    }
                }
            }
        }
        
        reminderSwitch.isOn = routine.hasReminder
        hasReminder = routine.hasReminder
        
        if let time = routine.reminderTime {
            timePicker.date = time
            reminderTime = time
        }
        
        timePickerContainer.isHidden = !routine.hasReminder
    }
    
    // MARK: - Validation
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
