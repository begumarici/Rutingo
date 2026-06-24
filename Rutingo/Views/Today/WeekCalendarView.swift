//
//  WeekCalendarView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class WeekCalendarView: UIView {
    
    // MARK: - Properties
    private var dates: [Date] = []
    private var progressMap: [Date: Double] = [:]
    private var selectedDate: Date = DateHelper.shared.startOfDay()
    var onDateSelected: ((Date) -> Void)?
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = Layout.cornerRadius
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.smallPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.smallPadding),
            stackView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
    }
    
    @objc private func swipedLeft() { onSwipeLeft?() }
    @objc private func swipedRight() { onSwipeRight?() }
    
    
    // MARK: - Configuration
    func configure(with dates: [Date], progressMap: [Date: Double], selectedDate: Date? = nil) {
        self.dates = dates
        self.progressMap = progressMap
        if let selectedDate = selectedDate {
            self.selectedDate = DateHelper.shared.startOfDay(selectedDate)
        }
        updateDayViews()
    }
    
    // MARK: - Helpers
    private func updateDayViews() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let today = DateHelper.shared.startOfDay()
        
        for date in dates {
            let dayView = createDayView(for: date, today: today)
            stackView.addArrangedSubview(dayView)
        }
    }
    
    private func createDayView(for date: Date, today: Date) -> DayCircleView {
        let dayView = DayCircleView()
        let normalizedDate = DateHelper.shared.startOfDay(date)
        let progress = progressMap[normalizedDate] ?? 0.0
        let isToday = Calendar.current.isDate(normalizedDate, inSameDayAs: today)
        let isSelected = Calendar.current.isDate(normalizedDate, inSameDayAs: selectedDate)
        
        dayView.configure(with: date, progress: progress, isToday: isToday, isSelected: isSelected)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dayTapped(_:)))
        dayView.addGestureRecognizer(tapGesture)
        dayView.isUserInteractionEnabled = true
        dayView.tag = dates.firstIndex(of: date) ?? 0
        
        return dayView
    }
    
    @objc private func dayTapped(_ gesture: UITapGestureRecognizer) {
        guard let dayView = gesture.view,
              dates.indices.contains(dayView.tag) else { return }
        
        let tappedDate = dates[dayView.tag]
        selectedDate = DateHelper.shared.startOfDay(tappedDate)
        onDateSelected?(tappedDate)
        updateDayViews()
    }
}
