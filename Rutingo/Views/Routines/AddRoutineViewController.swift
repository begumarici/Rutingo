//
//  AddRoutineViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 22.11.2025.
//

import UIKit

class AddRoutineViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((String, Frequency, String?, String?, String?, Bool, Date?, Int16, Int16, Int16, Int16) -> Void)?
    var onUpdate: ((Routine, String, Frequency, String?, String?, String?, Bool, Date?, Int16, Int16, Int16, Int16) -> Void)?
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
    private var selectedFeeling: String?
    private var motivationText: String?
    private var selectedBlockType: String?
    private var currentStep: Int = 0
    private let totalSteps: Int = 6
    private var hasTimeRange: Bool = false
    private var startTime: Date = Date()
    private var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    
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
    
    private let feelingContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let feelingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "feeling_question".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        return label
    }()

    private let feelingStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let feelingButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let motivationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let motivationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "motivation_question".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        return label
    }()

    private let motivationStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let motivationTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = AppColors.secondaryCardBackground
        tv.layer.cornerRadius = 8
        tv.font = AppFonts.regular(15)
        tv.textColor = AppColors.secondary.withAlphaComponent(0.4)
        
        tv.text = "motivation_placeholder".localized
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return tv
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
        label.textColor = AppColors.primary
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
        label.textColor = AppColors.primary
        return label
    }()
    
    private let frequencyControl: UISegmentedControl = {
        let items = ["daily".localized, "specific_days".localized]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = AppColors.primary
        control.setTitleTextAttributes([
            .foregroundColor: AppColors.background,
            .font: AppFonts.semibold(14)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: AppColors.secondary,
            .font: AppFonts.semibold(14)
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
        label.textColor = AppColors.primary
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
    
    // Time Range
    private let timeRangeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let timeRangeStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let timeRangeHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let timeRangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "time_range".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        return label
    }()

    private let timeRangeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = AppColors.secondary
        toggle.isOn = false
        return toggle
    }()

    private let timeRangePickersStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
        stack.alpha = 0
        return stack
    }()

    // Start row
    private let startPickerRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let startHeaderRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let startPickerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "start_time".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        return label
    }()

    private let startTimeValueContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryCardBackground
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = true
        return view
    }()

    private let startTimeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(15)
        label.textColor = AppColors.primary
        return label
    }()

    private let startTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = AppColors.primary
        picker.isHidden = true
        picker.alpha = 0
        return picker
    }()

    // End row
    private let endPickerRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let endHeaderRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let endPickerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "end_time".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        return label
    }()

    private let endTimeValueContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryCardBackground
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = true
        return view
    }()

    private let endTimeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(15)
        label.textColor = AppColors.primary
        return label
    }()

    private let endTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = AppColors.primary
        picker.isHidden = true
        picker.alpha = 0
        return picker
    }()
    
    // Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("save".localized, for: .normal)
        button.titleLabel?.font = AppFonts.bold(18)
        button.backgroundColor = AppColors.primary
        button.setTitleColor(AppColors.background, for: .normal)
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
        setupKeyboardObservers()
        motivationTextView.delegate = self
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
        createFeelingButtons()
        setupActions()
        createDayButtons()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameContainer)
        contentView.addSubview(frequencyContainer)
        contentView.addSubview(reminderContainer)
        
        contentView.addSubview(feelingContainer)
        contentView.addSubview(motivationContainer)
        contentView.addSubview(timeRangeContainer)

        // iç yapı
        timeRangeContainer.addSubview(timeRangeStackView)
        timeRangeHeaderView.addSubview(timeRangeLabel)
        timeRangeHeaderView.addSubview(timeRangeSwitch)
        timeRangeStackView.addArrangedSubview(timeRangeHeaderView)
        timeRangeStackView.addArrangedSubview(timeRangePickersStack)

        // start row
        startHeaderRow.addSubview(startPickerLabel)
        startTimeValueContainer.addSubview(startTimeValueLabel)
        startHeaderRow.addSubview(startTimeValueContainer)
        startPickerRow.addArrangedSubview(startHeaderRow)
        startPickerRow.addArrangedSubview(startTimePicker)
        timeRangePickersStack.addArrangedSubview(startPickerRow)

        // end row
        endHeaderRow.addSubview(endPickerLabel)
        endTimeValueContainer.addSubview(endTimeValueLabel)
        endHeaderRow.addSubview(endTimeValueContainer)
        endPickerRow.addArrangedSubview(endHeaderRow)
        endPickerRow.addArrangedSubview(endTimePicker)
        timeRangePickersStack.addArrangedSubview(endPickerRow)
        
        feelingContainer.addSubview(feelingStackView)
        feelingStackView.addArrangedSubview(feelingLabel)
        feelingStackView.addArrangedSubview(feelingButtonsStack)

        motivationContainer.addSubview(motivationStackView)
        motivationStackView.addArrangedSubview(motivationLabel)
        motivationStackView.addArrangedSubview(motivationTextView)
        
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
            
            // time range container
            timeRangeContainer.topAnchor.constraint(equalTo: reminderContainer.bottomAnchor, constant: padding),
            timeRangeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            timeRangeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            timeRangeStackView.topAnchor.constraint(equalTo: timeRangeContainer.topAnchor, constant: cardPadding),
            timeRangeStackView.leadingAnchor.constraint(equalTo: timeRangeContainer.leadingAnchor, constant: cardPadding),
            timeRangeStackView.trailingAnchor.constraint(equalTo: timeRangeContainer.trailingAnchor, constant: -cardPadding),
            timeRangeStackView.bottomAnchor.constraint(equalTo: timeRangeContainer.bottomAnchor, constant: -cardPadding),
            timeRangeHeaderView.heightAnchor.constraint(equalToConstant: 31),

            timeRangeLabel.centerYAnchor.constraint(equalTo: timeRangeHeaderView.centerYAnchor),
            timeRangeLabel.leadingAnchor.constraint(equalTo: timeRangeHeaderView.leadingAnchor),
            timeRangeSwitch.centerYAnchor.constraint(equalTo: timeRangeHeaderView.centerYAnchor),
            timeRangeSwitch.trailingAnchor.constraint(equalTo: timeRangeHeaderView.trailingAnchor),

            // start row
            startHeaderRow.heightAnchor.constraint(equalToConstant: 32),
            startPickerLabel.centerYAnchor.constraint(equalTo: startHeaderRow.centerYAnchor),
            startPickerLabel.leadingAnchor.constraint(equalTo: startHeaderRow.leadingAnchor),
            startTimeValueContainer.centerYAnchor.constraint(equalTo: startHeaderRow.centerYAnchor),
            startTimeValueContainer.trailingAnchor.constraint(equalTo: startHeaderRow.trailingAnchor),
            startTimeValueContainer.heightAnchor.constraint(equalToConstant: 32),
            startTimeValueLabel.topAnchor.constraint(equalTo: startTimeValueContainer.topAnchor, constant: 6),
            startTimeValueLabel.bottomAnchor.constraint(equalTo: startTimeValueContainer.bottomAnchor, constant: -6),
            startTimeValueLabel.leadingAnchor.constraint(equalTo: startTimeValueContainer.leadingAnchor, constant: 12),
            startTimeValueLabel.trailingAnchor.constraint(equalTo: startTimeValueContainer.trailingAnchor, constant: -12),

            // end row
            endHeaderRow.heightAnchor.constraint(equalToConstant: 32),
            endPickerLabel.centerYAnchor.constraint(equalTo: endHeaderRow.centerYAnchor),
            endPickerLabel.leadingAnchor.constraint(equalTo: endHeaderRow.leadingAnchor),
            endTimeValueContainer.centerYAnchor.constraint(equalTo: endHeaderRow.centerYAnchor),
            endTimeValueContainer.trailingAnchor.constraint(equalTo: endHeaderRow.trailingAnchor),
            endTimeValueContainer.heightAnchor.constraint(equalToConstant: 32),
            endTimeValueLabel.topAnchor.constraint(equalTo: endTimeValueContainer.topAnchor, constant: 6),
            endTimeValueLabel.bottomAnchor.constraint(equalTo: endTimeValueContainer.bottomAnchor, constant: -6),
            endTimeValueLabel.leadingAnchor.constraint(equalTo: endTimeValueContainer.leadingAnchor, constant: 12),
            endTimeValueLabel.trailingAnchor.constraint(equalTo: endTimeValueContainer.trailingAnchor, constant: -12),
            
            // feeling container
            feelingContainer.topAnchor.constraint(equalTo: timeRangeContainer.bottomAnchor, constant: padding),
            feelingContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            feelingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            feelingStackView.topAnchor.constraint(equalTo: feelingContainer.topAnchor, constant: cardPadding),
            feelingStackView.leadingAnchor.constraint(equalTo: feelingContainer.leadingAnchor, constant: cardPadding),
            feelingStackView.trailingAnchor.constraint(equalTo: feelingContainer.trailingAnchor, constant: -cardPadding),
            feelingStackView.bottomAnchor.constraint(equalTo: feelingContainer.bottomAnchor, constant: -cardPadding),
            feelingButtonsStack.heightAnchor.constraint(equalToConstant: 56),

            // motivation container
            motivationContainer.topAnchor.constraint(equalTo: feelingContainer.bottomAnchor, constant: padding),
            motivationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            motivationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            motivationStackView.topAnchor.constraint(equalTo: motivationContainer.topAnchor, constant: cardPadding),
            motivationStackView.leadingAnchor.constraint(equalTo: motivationContainer.leadingAnchor, constant: cardPadding),
            motivationStackView.trailingAnchor.constraint(equalTo: motivationContainer.trailingAnchor, constant: -cardPadding),
            motivationStackView.bottomAnchor.constraint(equalTo: motivationContainer.bottomAnchor, constant: -cardPadding),
            motivationTextView.heightAnchor.constraint(equalToConstant: 80),
            
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
            deleteButton.topAnchor.constraint(equalTo: motivationContainer.bottomAnchor, constant: 10),
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
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let inset = keyboardFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset

        if let activeView = view.findFirstResponder() {
            let rect = activeView.convert(activeView.bounds, to: scrollView)
            let paddedRect = rect.insetBy(dx: 0, dy: -16)
            UIView.animate(withDuration: duration) {
                self.scrollView.scrollRectToVisible(paddedRect, animated: false)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    private func createFeelingButtons() {
        for feeling in Routine.FeelingType.allCases {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(feeling.displayText, for: .normal)
            button.titleLabel?.font = AppFonts.regular(12)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(AppColors.primary, for: .normal)
            button.backgroundColor = AppColors.secondaryCardBackground
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.clear.cgColor
            button.accessibilityIdentifier = feeling.rawValue
            button.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
            feelingButtonsStack.addArrangedSubview(button)
        }
    }
    
    @objc private func feelingButtonTapped(_ sender: UIButton) {
        let tapped = sender.accessibilityIdentifier

        if selectedFeeling == tapped {
            selectedFeeling = nil
        } else {
            selectedFeeling = tapped
        }

        for case let button as UIButton in feelingButtonsStack.arrangedSubviews {
            let isSelected = button.accessibilityIdentifier == selectedFeeling
            button.backgroundColor = isSelected ? AppColors.primary : AppColors.secondaryCardBackground
            button.setTitleColor(isSelected ? AppColors.background : AppColors.primary, for: .normal)
            button.layer.borderColor = isSelected ? AppColors.primary.cgColor : UIColor.clear.cgColor
        }
    }
    
    private func setupActions() {
        frequencyControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        timeRangeSwitch.addTarget(self, action: #selector(timeRangeSwitchChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)

        let startTap = UITapGestureRecognizer(target: self, action: #selector(startTimeValueTapped))
        startTimeValueContainer.addGestureRecognizer(startTap)

        let endTap = UITapGestureRecognizer(target: self, action: #selector(endTimeValueTapped))
        endTimeValueContainer.addGestureRecognizer(endTap)

        startTimeValueLabel.text = formattedTime(from: startTimePicker.date)
        endTimeValueLabel.text = formattedTime(from: endTimePicker.date)
    }
    
    private func createDayButtons() {
        for i in 1...7 {
            let button = UIButton(type: .custom)
            
            let dayName = DateHelper.getDayName(for: i)
            button.setTitle(String(dayName.prefix(3)), for: .normal)
            
            let calendarTag = (i % 7) + 1
            button.tag = calendarTag
            
            button.titleLabel?.font = AppFonts.semibold(14)
            button.backgroundColor = AppColors.background
            button.setTitleColor(AppColors.primary, for: .normal)
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
            sender.backgroundColor = AppColors.background
            sender.setTitleColor(AppColors.primary, for: .normal)
        } else {
            selectedDays.append(day)
            sender.backgroundColor = AppColors.primary
            sender.setTitleColor(AppColors.background, for: .normal)
        }
    }
    
    @objc private func timeRangeSwitchChanged() {
        hasTimeRange = timeRangeSwitch.isOn

        if !hasTimeRange {
            closeStartTimePicker()
            closeEndTimePicker()
        }

        UIView.animate(withDuration: 0.3) {
            self.timeRangePickersStack.isHidden = !self.timeRangeSwitch.isOn
            self.timeRangePickersStack.alpha = self.timeRangeSwitch.isOn ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func startTimeValueTapped() {
        let willShow = startTimePicker.isHidden
        if willShow {
            closeEndTimePicker()
        }
        UIView.animate(withDuration: 0.25) {
            self.startTimePicker.isHidden = !willShow
            self.startTimePicker.alpha = willShow ? 1.0 : 0.0
            self.startTimeValueLabel.textColor = willShow ? .systemRed : AppColors.primary
            self.endTimeValueLabel.textColor = AppColors.primary
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func endTimeValueTapped() {
        let willShow = endTimePicker.isHidden
        if willShow {
            closeStartTimePicker()
        }
        UIView.animate(withDuration: 0.25) {
            self.endTimePicker.isHidden = !willShow
            self.endTimePicker.alpha = willShow ? 1.0 : 0.0
            self.endTimeValueLabel.textColor = willShow ? .systemRed : AppColors.primary
            self.startTimeValueLabel.textColor = AppColors.primary
            self.view.layoutIfNeeded()
        }
    }
    
    private func closeStartTimePicker() {
        startTimePicker.isHidden = true
        startTimePicker.alpha = 0
        startTimeValueLabel.textColor = AppColors.primary
    }

    private func closeEndTimePicker() {
        endTimePicker.isHidden = true
        endTimePicker.alpha = 0
        endTimeValueLabel.textColor = AppColors.primary
    }

    @objc private func startTimeChanged() {
        startTimeValueLabel.text = formattedTime(from: startTimePicker.date)
    }

    @objc private func endTimeChanged() {
        endTimeValueLabel.text = formattedTime(from: endTimePicker.date)
    }

    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
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
        
        motivationText = motivationTextView.text == "motivation_placeholder".localized ? nil : motivationTextView.text
        
        let startHour: Int16 = hasTimeRange ? Int16(Calendar.current.component(.hour, from: startTimePicker.date)) : -1
        let startMinute: Int16 = hasTimeRange ? Int16(Calendar.current.component(.minute, from: startTimePicker.date)) : 0
        let endHour: Int16 = hasTimeRange ? Int16(Calendar.current.component(.hour, from: endTimePicker.date)) : -1
        let endMinute: Int16 = hasTimeRange ? Int16(Calendar.current.component(.minute, from: endTimePicker.date)) : 0
        
        switch mode {
        case .add:
            onSave?(name, selectedFrequency, selectedFeeling, motivationText, selectedBlockType, reminderEnabled, reminderDate, startHour, startMinute, endHour, endMinute)
        case .edit(let routine):
            onUpdate?(routine, name, selectedFrequency, selectedFeeling, motivationText, selectedBlockType, reminderEnabled, reminderDate, startHour, startMinute, endHour, endMinute)
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
                        button.setTitleColor(AppColors.background, for: .normal)
                    }
                }
            }
        }
        
        if routine.startHour >= 0 {
            hasTimeRange = true
            timeRangeSwitch.isOn = true
            timeRangePickersStack.isHidden = false
            timeRangePickersStack.alpha = 1.0

            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = Int(routine.startHour)
            components.minute = 0
            if let date = Calendar.current.date(from: components) {
                startTimePicker.date = date
                startTimeValueLabel.text = formattedTime(from: date)
            }

            components.hour = Int(routine.endHour)
            if let date = Calendar.current.date(from: components) {
                endTimePicker.date = date
                endTimeValueLabel.text = formattedTime(from: date)
            }
        }
        
        if let feeling = routine.feeling {
            selectedFeeling = feeling
            for case let button as UIButton in feelingButtonsStack.arrangedSubviews {
                let isSelected = button.accessibilityIdentifier == feeling
                button.backgroundColor = isSelected ? AppColors.primary : AppColors.secondaryCardBackground
                button.setTitleColor(isSelected ? AppColors.background : AppColors.primary, for: .normal)
            }
        }

        if let motivation = routine.motivation {
            motivationTextView.text = motivation
            motivationTextView.textColor = AppColors.primary
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension AddRoutineViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "motivation_placeholder".localized {
            textView.text = ""
            textView.textColor = AppColors.primary
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "motivation_placeholder".localized
            textView.textColor = AppColors.secondary.withAlphaComponent(0.4)
        }
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
