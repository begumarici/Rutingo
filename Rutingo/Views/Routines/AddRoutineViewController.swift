//
//  AddRoutineViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 22.11.2025.
//

import UIKit

class AddRoutineViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((RoutineFormData) -> Void)?
    var onUpdate: ((Routine, RoutineFormData) -> Void)?
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
    private var isCountBased: Bool = false
    /// Captured after the form is fully populated, to detect unsaved changes on cancel (edit mode only).
    private var initialFormSnapshot: RoutineFormData?
    private var targetValue: Double = 4
    private var selectedUnit: RoutineUnit = .count
    
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
    
    // Count-based
    private let countContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let countStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let countHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "count_based".localized
        label.font = AppFonts.semibold(16)
        label.textColor = AppColors.primary
        return label
    }()

    private let countSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = AppColors.secondary
        toggle.isOn = false
        return toggle
    }()

    private let countStepperRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.isHidden = true
        stack.alpha = 0
        return stack
    }()

    private let countStepperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "target_count".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        return label
    }()

    private let targetValueField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = AppFonts.semibold(15)
        field.textColor = AppColors.primary
        field.textAlignment = .center
        field.keyboardType = .decimalPad
        field.backgroundColor = AppColors.secondaryCardBackground
        field.layer.cornerRadius = 8
        field.text = "4"
        return field
    }()

    private lazy var unitButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = AppColors.primary
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = AppColors.secondaryCardBackground
        button.layer.cornerRadius = 8
        button.titleLabel?.font = AppFonts.semibold(15)
        button.showsMenuAsPrimaryAction = true
        return button
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

    // Different time per day
    private let differentTimesHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let differentTimesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "different_times_per_day".localized
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.secondary
        return label
    }()

    private let differentTimesSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = AppColors.secondary
        toggle.isOn = false
        return toggle
    }()

    private let perDayTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
        stack.alpha = 0
        return stack
    }()

    private var dayTimeRows: [DayTimeRangeRow] = []
    
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
        initialFormSnapshot = buildFormData()
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
        contentView.addSubview(countContainer)

        countContainer.addSubview(countStackView)
        countHeaderView.addSubview(countLabel)
        countHeaderView.addSubview(countSwitch)
        countStackView.addArrangedSubview(countHeaderView)
        countStackView.addArrangedSubview(countStepperRow)
        countStepperRow.addArrangedSubview(countStepperLabel)
        countStepperRow.addArrangedSubview(targetValueField)
        countStepperRow.addArrangedSubview(unitButton)

        // iç yapı
        timeRangeContainer.addSubview(timeRangeStackView)
        timeRangeHeaderView.addSubview(timeRangeLabel)
        timeRangeHeaderView.addSubview(timeRangeSwitch)
        timeRangeStackView.addArrangedSubview(timeRangeHeaderView)

        differentTimesHeaderView.addSubview(differentTimesLabel)
        differentTimesHeaderView.addSubview(differentTimesSwitch)
        timeRangeStackView.addArrangedSubview(differentTimesHeaderView)

        timeRangeStackView.addArrangedSubview(timeRangePickersStack)
        timeRangeStackView.addArrangedSubview(perDayTimeStack)

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

            differentTimesHeaderView.heightAnchor.constraint(equalToConstant: 31),
            differentTimesLabel.centerYAnchor.constraint(equalTo: differentTimesHeaderView.centerYAnchor),
            differentTimesLabel.leadingAnchor.constraint(equalTo: differentTimesHeaderView.leadingAnchor),
            differentTimesSwitch.centerYAnchor.constraint(equalTo: differentTimesHeaderView.centerYAnchor),
            differentTimesSwitch.trailingAnchor.constraint(equalTo: differentTimesHeaderView.trailingAnchor),

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
            
            // count-based container
            countContainer.topAnchor.constraint(equalTo: timeRangeContainer.bottomAnchor, constant: padding),
            countContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            countContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            countStackView.topAnchor.constraint(equalTo: countContainer.topAnchor, constant: cardPadding),
            countStackView.leadingAnchor.constraint(equalTo: countContainer.leadingAnchor, constant: cardPadding),
            countStackView.trailingAnchor.constraint(equalTo: countContainer.trailingAnchor, constant: -cardPadding),
            countStackView.bottomAnchor.constraint(equalTo: countContainer.bottomAnchor, constant: -cardPadding),
            countHeaderView.heightAnchor.constraint(equalToConstant: 31),

            countLabel.centerYAnchor.constraint(equalTo: countHeaderView.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: countHeaderView.leadingAnchor),
            countSwitch.centerYAnchor.constraint(equalTo: countHeaderView.centerYAnchor),
            countSwitch.trailingAnchor.constraint(equalTo: countHeaderView.trailingAnchor),

            countStepperRow.heightAnchor.constraint(equalToConstant: 36),
            targetValueField.widthAnchor.constraint(equalToConstant: 60),
            targetValueField.heightAnchor.constraint(equalToConstant: 36),
            unitButton.heightAnchor.constraint(equalToConstant: 36),

            // feeling container
            feelingContainer.topAnchor.constraint(equalTo: countContainer.bottomAnchor, constant: padding),
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
        differentTimesSwitch.addTarget(self, action: #selector(differentTimesSwitchChanged), for: .valueChanged)
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        timeRangeSwitch.addTarget(self, action: #selector(timeRangeSwitchChanged), for: .valueChanged)
        countSwitch.addTarget(self, action: #selector(countSwitchChanged), for: .valueChanged)
        targetValueField.addTarget(self, action: #selector(targetValueFieldChanged), for: .editingChanged)
        setupUnitMenu()
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)

        let startTap = UITapGestureRecognizer(target: self, action: #selector(startTimeValueTapped))
        startTimeValueContainer.addGestureRecognizer(startTap)

        let endTap = UITapGestureRecognizer(target: self, action: #selector(endTimeValueTapped))
        endTimeValueContainer.addGestureRecognizer(endTap)

        endTimePicker.date = Calendar.current.date(byAdding: .hour, value: 1, to: startTimePicker.date) ?? startTimePicker.date

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
        if case .edit = mode, let initial = initialFormSnapshot, buildFormData() != initial {
            let alert = UIAlertController(
                title: "discard_changes_title".localized,
                message: "discard_changes_message".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "discard".localized, style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    /// The weekdays "different time per day" applies to: the explicitly picked days for "Belirli günler",
    /// or all 7 days when frequency is "Daily" (every day is scheduled, so every day can have its own time).
    private var activeWeekdays: [Int] {
        frequencyControl.selectedSegmentIndex == 1 ? selectedDays : DayOfWeek.allCases.map { $0.rawValue }
    }
    
    @objc private func frequencyChanged() {
        let isSpecific = frequencyControl.selectedSegmentIndex == 1

        if differentTimesSwitch.isOn {
            rebuildPerDayTimeRows()
        }

        UIView.animate(withDuration: 0.3) {
            self.dayStackView.isHidden = !isSpecific
            self.dayStackView.alpha = isSpecific ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }

    @objc private func differentTimesSwitchChanged() {
        rebuildPerDayTimeRows()
        UIView.animate(withDuration: 0.3) {
            let showSingle = !self.differentTimesSwitch.isOn
            self.timeRangePickersStack.isHidden = !showSingle
            self.timeRangePickersStack.alpha = showSingle ? 1.0 : 0.0

            self.perDayTimeStack.isHidden = !self.differentTimesSwitch.isOn
            self.perDayTimeStack.alpha = self.differentTimesSwitch.isOn ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }

    /// Keeps `perDayTimeStack`'s rows in sync with `activeWeekdays`, preserving any range a day already
    /// has (so toggling the switch off/on or adding/removing a day doesn't discard other days' edits).
    /// `seedRanges` (e.g. a routine's saved overrides) fills in days that don't have a live row yet.
    private func rebuildPerDayTimeRows(seedRanges: [Int: DayTimeRange] = [:]) {
        guard differentTimesSwitch.isOn else {
            dayTimeRows.forEach { $0.removeFromSuperview() }
            dayTimeRows.removeAll()
            return
        }

        var existingRanges = seedRanges
        for row in dayTimeRows { existingRanges[row.weekday] = row.range }
        dayTimeRows.forEach { $0.removeFromSuperview() }
        dayTimeRows.removeAll()

        let fallbackRange = DayTimeRange(
            startHour: Calendar.current.component(.hour, from: startTimePicker.date),
            startMinute: Calendar.current.component(.minute, from: startTimePicker.date),
            endHour: Calendar.current.component(.hour, from: endTimePicker.date),
            endMinute: Calendar.current.component(.minute, from: endTimePicker.date)
        )

        let sortedDays = activeWeekdays.sorted { d1, d2 in
            let p1 = d1 == 1 ? 8 : d1
            let p2 = d2 == 1 ? 8 : d2
            return p1 < p2
        }

        for day in sortedDays {
            let row = DayTimeRangeRow(weekday: day, initialRange: existingRanges[day] ?? fallbackRange)
            row.onExpandToggle = { [weak self] in self?.view.layoutIfNeeded() }
            perDayTimeStack.addArrangedSubview(row)
            dayTimeRows.append(row)
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
        
        if differentTimesSwitch.isOn {
            UIView.animate(withDuration: 0.2) {
                self.rebuildPerDayTimeRows()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func timeRangeSwitchChanged() {
        hasTimeRange = timeRangeSwitch.isOn

        if !hasTimeRange {
            closeStartTimePicker()
            closeEndTimePicker()
            differentTimesSwitch.isOn = false
            rebuildPerDayTimeRows()
        }

        UIView.animate(withDuration: 0.3) {
            self.differentTimesHeaderView.isHidden = !self.hasTimeRange
            self.differentTimesHeaderView.alpha = self.hasTimeRange ? 1.0 : 0.0

            let showSingle = self.hasTimeRange && !self.differentTimesSwitch.isOn
            self.timeRangePickersStack.isHidden = !showSingle
            self.timeRangePickersStack.alpha = showSingle ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func countSwitchChanged() {
        isCountBased = countSwitch.isOn
        UIView.animate(withDuration: 0.3) {
            self.countStepperRow.isHidden = !self.countSwitch.isOn
            self.countStepperRow.alpha = self.countSwitch.isOn ? 1.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }

    @objc private func targetValueFieldChanged() {
        let normalized = (targetValueField.text ?? "").replacingOccurrences(of: ",", with: ".")
        // Double("nan"/"inf") parses successfully but isn't a usable target — ignore those, keep the last good value.
        guard let parsed = Double(normalized), parsed.isFinite else { return }
        targetValue = parsed
    }

    private func setupUnitMenu() {
        let actions = RoutineUnit.allCases.map { unit in
            UIAction(title: unit.displayText) { [weak self] _ in
                self?.selectedUnit = unit
                self?.unitButton.configuration?.title = unit.displayText
            }
        }
        unitButton.menu = UIMenu(children: actions)
        unitButton.configuration?.title = selectedUnit.displayText
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

    /// Gathers every field into a `RoutineFormData` snapshot, without any save/dismiss side effects —
    /// used both to actually save and to detect unsaved changes (see `cancelTapped`).
    private func buildFormData() -> RoutineFormData {
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
        
        let dayTimeRanges: [Int: DayTimeRange] = differentTimesSwitch.isOn
            ? Dictionary(uniqueKeysWithValues: dayTimeRows.map { ($0.weekday, $0.range) })
            : [:]

        return RoutineFormData(
            name: name,
            frequency: selectedFrequency,
            feeling: selectedFeeling,
            motivation: motivationText,
            blockType: selectedBlockType,
            hasReminder: reminderEnabled,
            reminderTime: reminderDate,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            isCountBased: isCountBased,
            targetValue: targetValue,
            unit: selectedUnit,
            dayTimeRanges: dayTimeRanges
        )
    }

    private func completeSaving() {
        let form = buildFormData()

        switch mode {
        case .add:
            onSave?(form)
        case .edit(let routine):
            onUpdate?(routine, form)
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
            differentTimesHeaderView.isHidden = false
            differentTimesHeaderView.alpha = 1.0

            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = Int(routine.startHour)
            components.minute = Int(routine.startMinute)
            if let date = Calendar.current.date(from: components) {
                startTimePicker.date = date
                startTimeValueLabel.text = formattedTime(from: date)
            }

            components.hour = Int(routine.endHour)
            components.minute = Int(routine.endMinute)
            if let date = Calendar.current.date(from: components) {
                endTimePicker.date = date
                endTimeValueLabel.text = formattedTime(from: date)
            }

            let overrides = routine.dayTimeRanges
            if !overrides.isEmpty {
                differentTimesSwitch.isOn = true
                perDayTimeStack.isHidden = false
                perDayTimeStack.alpha = 1.0
                rebuildPerDayTimeRows(seedRanges: overrides)
            } else {
                timeRangePickersStack.isHidden = false
                timeRangePickersStack.alpha = 1.0
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

        isCountBased = routine.isCountBased
        targetValue = max(routine.targetValue, 0.01)
        selectedUnit = routine.routineUnit
        countSwitch.isOn = isCountBased
        targetValueField.text = Routine.formattedGoalValue(targetValue)
        unitButton.configuration?.title = selectedUnit.displayText
        countStepperRow.isHidden = !isCountBased
        countStepperRow.alpha = isCountBased ? 1.0 : 0.0
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

        if isCountBased && (!targetValue.isFinite || targetValue <= 0) {
            showAlert(message: "validation_target_value".localized)
            return false
        }

        if hasTimeRange {
            if differentTimesSwitch.isOn {
                guard dayTimeRows.allSatisfy({ $0.range.isValid }) else {
                    showAlert(message: "validation_end_before_start".localized)
                    return false
                }
            } else {
                let start = Calendar.current.component(.hour, from: startTimePicker.date) * 60
                    + Calendar.current.component(.minute, from: startTimePicker.date)
                let end = Calendar.current.component(.hour, from: endTimePicker.date) * 60
                    + Calendar.current.component(.minute, from: endTimePicker.date)
                guard end > start else {
                    showAlert(message: "validation_end_before_start".localized)
                    return false
                }
            }
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
