//
//  WeekCalendarView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class WeekCalendarView: UIView {
    private var dates: [Date] = []
    private var completedDays: Set<Date> = []
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AppColors.background
        layer.cornerRadius = Layout.cornerRadius
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.smallPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.smallPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.smallPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.smallPadding),
            stackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(with dates: [Date], completedDates: Set<Date>) {
        self.dates = dates
        self.completedDays = completedDates
 
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let today = DateHelper.shared.startOfDay()
        
        for date in dates {
            let dayView = DayCircleView()
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let isCompleted = completedDays.contains(normalizedDate)
            let isToday = Calendar.current.isDate(normalizedDate, inSameDayAs: today)
            
            dayView.configure(with: date, isCompleted: isCompleted, isToday: isToday)
            stackView.addArrangedSubview(dayView)
        }
    }
}
