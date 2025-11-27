//
//  WeekCalendarView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 23.11.2025.
//

import UIKit

class WeekCalendarView: UIView {
    private var dates: [Date] = []
    private var progressMap: [Date: Double] = [:]
    
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
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.smallPadding),
            stackView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func configure(with dates: [Date], progressMap: [Date: Double]) {
        self.dates = dates
        self.progressMap = progressMap
 
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let today = DateHelper.shared.startOfDay()
        
        for date in dates {
            let dayView = DayCircleView()
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let progress = progressMap[normalizedDate] ?? 0.0
            let isToday = Calendar.current.isDate(normalizedDate, inSameDayAs: today)
            
            dayView.configure(with: date, progress: progress, isToday: isToday)
            stackView.addArrangedSubview(dayView)
        }
    }
}
