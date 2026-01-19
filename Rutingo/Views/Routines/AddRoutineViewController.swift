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
    
    // MARK: - UI Containers
    private let nameContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let frequencyContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let reminderContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Name
    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "routine_name".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = AppColors.secondaryCardBackground
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        textField.leftViewMode = .always
        textField.font = AppFonts.regular(16)
        textField.textColor = AppColors.secondary
        textField.attributedPlaceholder = NSAttributedString(
            string: "routine_name_placeholder".localized,
            attributes: [.foregroundColor: AppColors.secondary]
        )
        return textField
    }()
    
    // Frequency
    private let frequencyStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "frequency".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let frequencyControl: UISegmentedControl = {
        let items = ["daily".localized, "specific_days".localized]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = AppColors.primary
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: AppFonts.semibold(14)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: AppColors.secondary,
            .font: AppFonts.regular(14)
        ], for: .normal)
        return control
    }()
    
    private let dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.isHidden = true
        return stackView
    }()
    
    // Reminder
    private let reminderStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private let reminderHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let reminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "reminder".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.secondary
        return label
    }()

    private let reminderSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = AppColors.secondary
        toggle.isOn = false
        return toggle
    }()

    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.isHidden = true
        picker.tintColor = AppColors.primary
        return picker
    }()
    
    // Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("save".localized, for: .normal)
        button.titleLabel?.font = AppFonts.bold(18)
        button.backgroundColor = AppColors.primary
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("delete_routine".localized, for: .normal)
        button.titleLabel?.font = AppFonts.semibold(16)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .clear
        button.isHidden = true
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameContainer)
        contentView.addSubview(frequencyContainer)
        contentView.addSubview(reminderContainer)
        contentView.addSubview(deleteButton) 
        contentView.addSubview(saveButton)
     
        nameContainer.addSubview(nameStack)
        nameStack.addArrangedSubview(nameLabel)
        nameStack.addArrangedSubview(nameTextField)
        
        frequencyContainer.addSubview(frequencyStackView)
        frequencyStackView.addArrangedSubview(frequencyLabel)
        frequencyStackView.addArrangedSubview(frequencyControl)
        frequencyStackView.addArrangedSubview(dayStackView)
        
        reminderContainer.addSubview(reminderStackView)
        reminderHeaderView.addSubview(reminderLabel)
        reminderHeaderView.addSubview(reminderSwitch)
        reminderStackView.addArrangedSubview(reminderHeaderView)
        reminderStackView.addArrangedSubview(timePicker)
        
        setupConstraints()
        setupActions()
        createDayButtons()
    }
    
    private func configureModeUI() {
        switch mode {
        case .add:
            title = "add_routine".localized
            saveButton.setTitle("save".localized, for: .normal)
            deleteButton.isHidden = true
        case .edit:
            title = "edit_routine".localized
            saveButton.setTitle("update".localized, for: .normal)
            deleteButton.isHidden = false
        }
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppColors.navbarTitle]
    }
    
    private func setupNavigationBar() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        closeButton.tintColor = AppColors.primary
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let cardPadding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // name container
            nameContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            nameContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            nameStack.topAnchor.constraint(equalTo: nameContainer.topAnchor, constant: cardPadding),
            nameStack.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: cardPadding),
            nameStack.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -cardPadding),
            nameStack.bottomAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: -cardPadding),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // frequency container
            frequencyContainer.topAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: padding),
            frequencyContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            frequencyContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            frequencyStackView.topAnchor.constraint(equalTo: frequencyContainer.topAnchor, constant: cardPadding),
            frequencyStackView.leadingAnchor.constraint(equalTo: frequencyContainer.leadingAnchor, constant: cardPadding),
            frequencyStackView.trailingAnchor.constraint(equalTo: frequencyContainer.trailingAnchor, constant: -cardPadding),
            frequencyStackView.bottomAnchor.constraint(equalTo: frequencyContainer.bottomAnchor, constant: -cardPadding),
            dayStackView.heightAnchor.constraint(equalToConstant: 40),

            // reminder container
            reminderContainer.topAnchor.constraint(equalTo: frequencyContainer.bottomAnchor, constant: padding),
            reminderContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            reminderContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            reminderStackView.topAnchor.constraint(equalTo: reminderContainer.topAnchor, constant: cardPadding),
            reminderStackView.leadingAnchor.constraint(equalTo: reminderContainer.leadingAnchor, constant: cardPadding),
            reminderStackView.trailingAnchor.constraint(equalTo: reminderContainer.trailingAnchor, constant: -cardPadding),
            reminderStackView.bottomAnchor.constraint(equalTo: reminderContainer.bottomAnchor, constant: -cardPadding),
            reminderHeaderView.heightAnchor.constraint(equalToConstant: 31),
            
            reminderLabel.centerYAnchor.constraint(equalTo: reminderHeaderView.centerYAnchor),
            reminderLabel.leadingAnchor.constraint(equalTo: reminderHeaderView.leadingAnchor),
            reminderSwitch.centerYAnchor.constraint(equalTo: reminderHeaderView.centerYAnchor),
            reminderSwitch.trailingAnchor.constraint(equalTo: reminderHeaderView.trailingAnchor),
            
            // buttons
            deleteButton.topAnchor.constraint(equalTo: reminderContainer.bottomAnchor, constant: 10),
            deleteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            
            contentView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: padding)
        ])
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        frequencyControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func createDayButtons() {
        for i in 1...7 {
            let button = UIButton(type: .custom)
            
            let dayName = DateHelper.getDayName(for: i)
            button.setTitle(String(dayName.prefix(3)), for: .normal)
            
            let calendarTag = (i % 7) + 1
            button.tag = calendarTag
            
            button.titleLabel?.font = AppFonts.bold(14)
            button.backgroundColor = AppColors.secondary
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 20
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true

            
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
        UIView.animate(withDuration: 0.3) {
            let isSpecific = self.frequencyControl.selectedSegmentIndex == 1
            
            self.dayStackView.isHidden = !isSpecific
            self.dayStackView.alpha = isSpecific ? 1.0 : 0.0
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func reminderSwitchChanged() {
        hasReminder = reminderSwitch.isOn
        if reminderSwitch.isOn {
            reminderTime = timePicker.date
        }
        
        UIView.animate(withDuration: 0.3) {
            self.timePicker.isHidden = !self.reminderSwitch.isOn
            self.timePicker.alpha = self.reminderSwitch.isOn ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.tag
        
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
            sender.backgroundColor = AppColors.secondary
        } else {
            selectedDays.append(day)
            sender.backgroundColor = AppColors.primary
        }
    }
    
    @objc private func saveButtonTapped() {
        guard validate() else { return }
        
        if reminderSwitch.isOn {
            NotificationManager.shared.checkPermission { [weak self] hasPermission in
                if hasPermission {
                    self?.completeSaving()
                } else {
                    self?.showPermissionAlert()
                }
            }
        } else {
            completeSaving()
        }
    }

    private func completeSaving() {
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

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "notifications_disabled".localized,
            message: "notifications_disabled_message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "settings".localized, style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "delete_routine".localized,
            message: "delete_routine_message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    private func populateFields(with routine: Routine) {
        nameTextField.text = routine.name
        
        switch routine.frequency {
        case .daily:
            frequencyControl.selectedSegmentIndex = 0
            dayStackView.isHidden = true
            
        case .specificDays(let days):
            frequencyControl.selectedSegmentIndex = 1
            selectedDays = days
            dayStackView.isHidden = false
            dayStackView.alpha = 1.0
            
            for day in days {
                for case let button as UIButton in dayStackView.arrangedSubviews {
                    if button.tag == day {
                        button.backgroundColor = AppColors.primary
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
        
        timePicker.isHidden = !routine.hasReminder
    }
    
    private func validate() -> Bool {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "validation_name_empty".localized)
            return false
        }
        
        if frequencyControl.selectedSegmentIndex == 1 && selectedDays.isEmpty {
            showAlert(message: "validation_select_day".localized)
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}
