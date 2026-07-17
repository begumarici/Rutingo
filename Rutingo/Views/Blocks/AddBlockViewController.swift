//
//  AddBlockViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.04.2026.
//

import UIKit

class AddBlockViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((String, Int, Int, Int, Int, Routine?) -> Void)?
    var onUpdate: ((String, Int, Int, Int, Int, Routine?) -> Void)?
    var linkedRoutine: Routine?
    private var allRoutines: [Routine] = []
    private let viewModel: BlocksViewModel
    
    enum Mode { case add; case edit }
    var mode: Mode = .add
    
    private var selectedStartDate: Date = Date()
    private var selectedEndDate: Date = Date()
    private var pendingTitle: String?

    private struct FormSnapshot: Equatable {
        let title: String
        let startHour: Int
        let startMinute: Int
        let endHour: Int
        let endMinute: Int
        let linkedRoutineID: UUID?
    }
    /// Captured at the end of viewDidLoad, to detect unsaved changes on cancel (edit mode only).
    private var initialSnapshot: FormSnapshot?
    
    init(viewModel: BlocksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let titleSectionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "block_title".localized
        l.font = AppFonts.semibold(16)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = AppColors.secondaryCardBackground
        tf.layer.cornerRadius = Layout.cornerRadius
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        tf.leftViewMode = .always
        tf.font = AppFonts.regular(16)
        tf.textColor = AppColors.primary
        tf.attributedPlaceholder = NSAttributedString(
            string: "block_title_placeholder".localized,
            attributes: [.foregroundColor: AppColors.secondary]
        )
        return tf
    }()
    
    private let routineContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()

    private let routineSectionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "link_routine".localized
        l.font = AppFonts.semibold(16)
        l.textColor = AppColors.primary
        return l
    }()

    private lazy var routinePickerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = AppColors.secondaryCardBackground
        config.baseForegroundColor = AppColors.secondary
        config.title = "link_routine_placeholder".localized
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = AppFonts.regular(16)
            return a
        }
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.cornerStyle = .fixed

        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = Layout.cornerRadius
        b.contentHorizontalAlignment = .left
        b.showsMenuAsPrimaryAction = true
        return b
    }()
    
    private let startContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let startLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "block_start_time".localized
        l.font = AppFonts.semibold(16)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let startPicker: UIDatePicker = {
        let p = UIDatePicker()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.datePickerMode = .time
        p.preferredDatePickerStyle = .wheels
        return p
    }()
    
    private let endContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let endLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "block_end_time".localized
        l.font = AppFonts.semibold(16)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let endPicker: UIDatePicker = {
        let p = UIDatePicker()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.datePickerMode = .time
        p.preferredDatePickerStyle = .wheels
        return p
    }()
    
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("save".localized, for: .normal)
        b.titleLabel?.font = AppFonts.bold(18)
        b.backgroundColor = AppColors.primary
        b.setTitleColor(AppColors.background, for: .normal)
        b.layer.cornerRadius = Layout.cardCornerRadius
        return b
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        if mode != .edit { setDefaultTimes() }
        setupNavigationBar()
        setupUI()
        setupPickers()
        setupActions()
        if let t = pendingTitle { titleTextField.text = t }

        allRoutines = viewModel.fetchAllRoutines()
        buildRoutineMenu()

        if let linked = linkedRoutine {
            updateRoutineButton(selected: linked)
        }

        initialSnapshot = currentSnapshot()
    }

    private func currentSnapshot() -> FormSnapshot {
        let cal = Calendar.current
        return FormSnapshot(
            title: titleTextField.text ?? "",
            startHour: cal.component(.hour, from: selectedStartDate),
            startMinute: cal.component(.minute, from: selectedStartDate),
            endHour: cal.component(.hour, from: selectedEndDate),
            endMinute: cal.component(.minute, from: selectedEndDate),
            linkedRoutineID: linkedRoutine?.id
        )
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = (mode == .edit ? "edit_block" : "add_block").localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = AppColors.primary
    }
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleSectionLabel)
        titleContainer.addSubview(titleTextField)

        contentView.addSubview(routineContainer)
        routineContainer.addSubview(routineSectionLabel)
        routineContainer.addSubview(routinePickerButton)

        contentView.addSubview(startContainer)
        startContainer.addSubview(startLabel)
        startContainer.addSubview(startPicker)

        contentView.addSubview(endContainer)
        endContainer.addSubview(endLabel)
        endContainer.addSubview(endPicker)

        contentView.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        let p: CGFloat = 20
        let cp: CGFloat = 16

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // title container
            titleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            titleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            titleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            titleSectionLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: cp),
            titleSectionLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: cp),
            titleSectionLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -cp),

            titleTextField.topAnchor.constraint(equalTo: titleSectionLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: cp),
            titleTextField.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -cp),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            titleTextField.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -cp),

            // routine container
            routineContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: p),
            routineContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            routineContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            routineSectionLabel.topAnchor.constraint(equalTo: routineContainer.topAnchor, constant: cp),
            routineSectionLabel.leadingAnchor.constraint(equalTo: routineContainer.leadingAnchor, constant: cp),
            routineSectionLabel.trailingAnchor.constraint(equalTo: routineContainer.trailingAnchor, constant: -cp),

            routinePickerButton.topAnchor.constraint(equalTo: routineSectionLabel.bottomAnchor, constant: 8),
            routinePickerButton.leadingAnchor.constraint(equalTo: routineContainer.leadingAnchor, constant: cp),
            routinePickerButton.trailingAnchor.constraint(equalTo: routineContainer.trailingAnchor, constant: -cp),
            routinePickerButton.heightAnchor.constraint(equalToConstant: 44),
            routinePickerButton.bottomAnchor.constraint(equalTo: routineContainer.bottomAnchor, constant: -cp),

            // start container
            startContainer.topAnchor.constraint(equalTo: routineContainer.bottomAnchor, constant: p),
            startContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            startContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            startLabel.topAnchor.constraint(equalTo: startContainer.topAnchor, constant: cp),
            startLabel.leadingAnchor.constraint(equalTo: startContainer.leadingAnchor, constant: cp),

            startPicker.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: 8),
            startPicker.leadingAnchor.constraint(equalTo: startContainer.leadingAnchor),
            startPicker.trailingAnchor.constraint(equalTo: startContainer.trailingAnchor),
            startPicker.bottomAnchor.constraint(equalTo: startContainer.bottomAnchor),
            startPicker.heightAnchor.constraint(equalToConstant: 120),

            // end container
            endContainer.topAnchor.constraint(equalTo: startContainer.bottomAnchor, constant: p),
            endContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            endContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            endLabel.topAnchor.constraint(equalTo: endContainer.topAnchor, constant: cp),
            endLabel.leadingAnchor.constraint(equalTo: endContainer.leadingAnchor, constant: cp),

            endPicker.topAnchor.constraint(equalTo: endLabel.bottomAnchor, constant: 8),
            endPicker.leadingAnchor.constraint(equalTo: endContainer.leadingAnchor),
            endPicker.trailingAnchor.constraint(equalTo: endContainer.trailingAnchor),
            endPicker.bottomAnchor.constraint(equalTo: endContainer.bottomAnchor),
            endPicker.heightAnchor.constraint(equalToConstant: 120),

            // save button
            saveButton.topAnchor.constraint(equalTo: endContainer.bottomAnchor, constant: p),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
        ])
    }

    // MARK: - Routine menu
    private func buildRoutineMenu() {
        var actions: [UIAction] = []

        if allRoutines.isEmpty {
            let empty = UIAction(
                title: "no_routines_yet".localized,
                attributes: .disabled
            ) { _ in }
            routinePickerButton.menu = UIMenu(title: "", children: [empty])
            return
        }

        for routine in allRoutines {
            let isSelected = linkedRoutine?.id == routine.id
            let action = UIAction(
                title: routine.name ?? "",
                image: isSelected ? UIImage(systemName: "checkmark") : nil
            ) { [weak self] _ in
                self?.linkedRoutine = routine
                self?.updateRoutineButton(selected: routine)
                self?.buildRoutineMenu()
            }
            actions.append(action)
        }

        if linkedRoutine != nil {
            let unlink = UIAction(
                title: "unlink_routine".localized,
                image: UIImage(systemName: "xmark"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.linkedRoutine = nil
                self?.updateRoutineButton(selected: nil)
                self?.buildRoutineMenu()
            }
            actions.append(unlink)
        }

        routinePickerButton.menu = UIMenu(title: "", children: [
                UIDeferredMenuElement.uncached { completion in
                    completion(actions)
                }
            ])
    }

    private func updateRoutineButton(selected routine: Routine?) {
        var config = routinePickerButton.configuration ?? UIButton.Configuration.filled()
        if let routine = routine {
            config.title = routine.name ?? ""
            config.baseForegroundColor = AppColors.primary
        } else {
            config.title = "link_routine_placeholder".localized
            config.baseForegroundColor = AppColors.secondary
        }
        routinePickerButton.configuration = config
    }
    
    // MARK: - Pickers / Actions
    private func setupPickers() {
        startPicker.date = selectedStartDate
        endPicker.date = selectedEndDate
        startPicker.addTarget(self, action: #selector(startPickerChanged), for: .valueChanged)
        endPicker.addTarget(self, action: #selector(endPickerChanged), for: .valueChanged)
    }

    @objc private func startPickerChanged() {
        selectedStartDate = startPicker.date
    }

    @objc private func endPickerChanged() {
        selectedEndDate = endPicker.date
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setDefaultTimes() {
        let cal = Calendar.current
        let now = Date()
        let minute = cal.component(.minute, from: now)
        let rounded = (minute / 5) * 5
        selectedStartDate = cal.date(bySettingHour: cal.component(.hour, from: now),
                                      minute: rounded, second: 0, of: now)!
        selectedEndDate = cal.date(byAdding: .hour, value: 1, to: selectedStartDate)!
    }
    
    // MARK: - Configure (edit mode)
    func configure(title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, linkedRoutine: Routine? = nil) {
        mode = .edit
        let cal = Calendar.current
        selectedStartDate = cal.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date())!
        selectedEndDate = cal.date(bySettingHour: endHour, minute: endMinute, second: 0, of: Date())!
        pendingTitle = title
        self.linkedRoutine = linkedRoutine
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        if mode == .edit, let initial = initialSnapshot, currentSnapshot() != initial {
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
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "validation_name_empty".localized)
            return
        }
        guard selectedEndDate > selectedStartDate else {
            showAlert(message: "block_end_after_start".localized)
            return
        }
        let cal = Calendar.current
        let startHour   = cal.component(.hour,   from: selectedStartDate)
        let startMinute = cal.component(.minute, from: selectedStartDate)
        let endHour     = cal.component(.hour,   from: selectedEndDate)
        let endMinute   = cal.component(.minute, from: selectedEndDate)
        if mode == .edit {
            onUpdate?(title, startHour, startMinute, endHour, endMinute, linkedRoutine)
        } else {
            onSave?(title, startHour, startMinute, endHour, endMinute, linkedRoutine)
        }
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}
