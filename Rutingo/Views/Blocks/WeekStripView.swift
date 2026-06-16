//
//  WeekStripView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.04.2026.
//

import UIKit

protocol WeekStripViewDelegate: AnyObject {
    func weekStripView(_ view: WeekStripView, didSelectDate date: Date)
}

class WeekStripView: UIView {
    
    // MARK: - Properties
    weak var delegate: WeekStripViewDelegate?
    
    var selectedDate: Date = DateHelper.shared.startOfDay() {
        didSet { buildStrip() }
    }
    
    private var weekOffset: Int = 0
    
    // MARK: - UI
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 4
        return s
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    private func setup() {
        backgroundColor = AppColors.background
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        
        buildStrip()
        setupGestures()
    }
    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Build
    private func buildStrip(animated: Bool = false, fromRight: Bool = true) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let dates = DateHelper.shared.weekDays(for: weekOffset)
        let dayLetters = [
            "weekday_mon".localized,
            "weekday_tue".localized,
            "weekday_wed".localized,
            "weekday_thu".localized,
            "weekday_fri".localized,
            "weekday_sat".localized,
            "weekday_sun".localized
        ]
        let calendar = Calendar.current
        
        for (index, date) in dates.enumerated() {
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(date)
            let dayNum = calendar.component(.day, from: date)
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
            
            let letterLabel = UILabel()
            letterLabel.translatesAutoresizingMaskIntoConstraints = false
            letterLabel.text = dayLetters[index]
            letterLabel.font = AppFonts.regular(10)
            letterLabel.textColor = AppColors.tertiary
            letterLabel.textAlignment = .center
            
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 14
            
            let numLabel = UILabel()
            numLabel.translatesAutoresizingMaskIntoConstraints = false
            numLabel.text = "\(dayNum)"
            numLabel.font = isSelected ? AppFonts.bold(14) : AppFonts.regular(14)
            numLabel.textAlignment = .center
            
            if isSelected {
                circle.backgroundColor = AppColors.accentOrange
                numLabel.textColor = AppColors.background
            } else if isToday {
                circle.backgroundColor = AppColors.accentOrange.withAlphaComponent(0.12)
                numLabel.textColor = AppColors.primary
            } else {
                circle.backgroundColor = .clear
                numLabel.textColor = AppColors.primary
            }
            
            button.addSubview(letterLabel)
            button.addSubview(circle)
            circle.addSubview(numLabel)
            
            NSLayoutConstraint.activate([
                letterLabel.topAnchor.constraint(equalTo: button.topAnchor),
                letterLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                
                circle.topAnchor.constraint(equalTo: letterLabel.bottomAnchor, constant: 4),
                circle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                circle.widthAnchor.constraint(equalToConstant: 28),
                circle.heightAnchor.constraint(equalToConstant: 28),
                circle.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                
                numLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                numLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            ])
            
            circle.isUserInteractionEnabled = false
            numLabel.isUserInteractionEnabled = false
            letterLabel.isUserInteractionEnabled = false

            if animated {
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = .push
                transition.subtype = fromRight ? .fromRight : .fromLeft
                stackView.layer.add(transition, forKey: nil)
            }
            
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Actions
    @objc private func dayTapped(_ sender: UIButton) {
        let dates = DateHelper.shared.weekDays(for: weekOffset)
        guard sender.tag < dates.count else { return }
        let date = DateHelper.shared.startOfDay(dates[sender.tag])
        guard !Calendar.current.isDate(date, inSameDayAs: selectedDate) else { return }
        selectedDate = date
        delegate?.weekStripView(self, didSelectDate: date)
    }
    
    @objc private func swipedLeft() {
        weekOffset += 1
        buildStrip(animated: true, fromRight: true)
    }

    @objc private func swipedRight() {
        weekOffset -= 1
        buildStrip(animated: true, fromRight: false)
    }
}

