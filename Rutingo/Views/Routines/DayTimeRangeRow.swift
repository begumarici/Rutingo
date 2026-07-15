//
//  DayTimeRangeRow.swift
//  Rutingo
//

import UIKit

/// One row in the "different time per day" list: a weekday label and a tappable value pill
/// that reveals start/end wheel pickers for just that day, mirroring the single global time
/// picker pattern used elsewhere in AddRoutineViewController.
final class DayTimeRangeRow: UIView {

    let weekday: Int
    private(set) var range: DayTimeRange
    var onChange: ((DayTimeRange) -> Void)?
    /// Called when the inline pickers expand/collapse, so the owning screen can animate its layout.
    var onExpandToggle: (() -> Void)?

    private let dayLabel = UILabel()
    private let valueContainer = UIView()
    private let valueLabel = UILabel()
    private let startPicker = UIDatePicker()
    private let endPicker = UIDatePicker()
    private let pickersStack = UIStackView()

    init(weekday: Int, initialRange: DayTimeRange) {
        self.weekday = weekday
        self.range = initialRange
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = AppFonts.semibold(14)
        dayLabel.textColor = AppColors.primary
        dayLabel.text = DayOfWeek(rawValue: weekday)?.shortName
        dayLabel.setContentHuggingPriority(.required, for: .horizontal)

        valueContainer.translatesAutoresizingMaskIntoConstraints = false
        valueContainer.backgroundColor = AppColors.secondaryCardBackground
        valueContainer.layer.cornerRadius = 12
        valueContainer.isUserInteractionEnabled = true

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AppFonts.semibold(14)
        valueLabel.textColor = AppColors.primary
        valueLabel.text = range.displayText

        valueContainer.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: valueContainer.topAnchor, constant: 8),
            valueLabel.bottomAnchor.constraint(equalTo: valueContainer.bottomAnchor, constant: -8),
            valueLabel.leadingAnchor.constraint(equalTo: valueContainer.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: valueContainer.trailingAnchor, constant: -12),
        ])
        valueContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(valueTapped)))

        let headerRow = UIStackView(arrangedSubviews: [dayLabel, valueContainer])
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .equalSpacing

        [startPicker, endPicker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            $0.tintColor = AppColors.primary
        }
        startPicker.date = Self.date(hour: range.startHour, minute: range.startMinute)
        endPicker.date = Self.date(hour: range.endHour, minute: range.endMinute)
        startPicker.addTarget(self, action: #selector(pickersChanged), for: .valueChanged)
        endPicker.addTarget(self, action: #selector(pickersChanged), for: .valueChanged)

        pickersStack.translatesAutoresizingMaskIntoConstraints = false
        pickersStack.axis = .vertical
        pickersStack.spacing = 4
        pickersStack.isHidden = true
        pickersStack.alpha = 0
        pickersStack.addArrangedSubview(startPicker)
        pickersStack.addArrangedSubview(endPicker)

        let mainStack = UIStackView(arrangedSubviews: [headerRow, pickersStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 8

        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func valueTapped() {
        let willShow = pickersStack.isHidden
        UIView.animate(withDuration: 0.25) {
            self.pickersStack.isHidden = !willShow
            self.pickersStack.alpha = willShow ? 1 : 0
            self.valueLabel.textColor = willShow ? .systemRed : AppColors.primary
            self.onExpandToggle?()
        }
    }

    @objc private func pickersChanged() {
        let cal = Calendar.current
        range = DayTimeRange(
            startHour: cal.component(.hour, from: startPicker.date),
            startMinute: cal.component(.minute, from: startPicker.date),
            endHour: cal.component(.hour, from: endPicker.date),
            endMinute: cal.component(.minute, from: endPicker.date)
        )
        valueLabel.text = range.displayText
        onChange?(range)
    }

    private static func date(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
