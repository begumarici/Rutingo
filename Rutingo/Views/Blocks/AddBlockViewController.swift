//
//  AddBlockViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.04.2026.
//

import UIKit

class AddBlockViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((String, Int, Int) -> Void)?
    
    private var selectedStartHour: Int = 9
    private var selectedEndHour: Int = 10
    
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
        v.layer.cornerRadius = 16
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
        tf.layer.cornerRadius = 8
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
    
    private let startContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = 16
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
    
    private let startPicker: UIPickerView = {
        let p = UIPickerView()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    private let endContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = 16
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
    
    private let endPicker: UIPickerView = {
        let p = UIPickerView()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("save".localized, for: .normal)
        b.titleLabel?.font = AppFonts.bold(18)
        b.backgroundColor = AppColors.primary
        b.setTitleColor(AppColors.background, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupUI()
        setupPickers()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "add_block".localized
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

            // start container
            startContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: p),
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
    
    private func setupPickers() {
        startPicker.dataSource = self
        startPicker.delegate = self
        startPicker.tag = 0
        startPicker.selectRow(selectedStartHour, inComponent: 0, animated: false)
        
        endPicker.dataSource = self
        endPicker.delegate = self
        endPicker.tag = 1
        endPicker.selectRow(selectedEndHour, inComponent: 0, animated: false)
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() { dismiss(animated: true) }
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "validation_name_empty".localized)
            return
        }
        guard selectedEndHour > selectedStartHour else {
            showAlert(message: "block_end_after_start".localized)
            return
        }
        onSave?(title, selectedStartHour, selectedEndHour)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension AddBlockViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 24 }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d:00", row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            selectedStartHour = row
        } else {
            selectedEndHour = row
        }
    }
}
