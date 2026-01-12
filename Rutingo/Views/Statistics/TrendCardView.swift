//
//  TrendCardView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.12.2025.
//

import UIKit

class TrendCardView: UIView {
    
    // MARK: - UI Components
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "weekly_trend".localized
        label.font = AppFonts.semibold(18)
        label.textColor = AppColors.secondary
        return label
    }()
    
    private let completionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.bold(32)
        label.textColor = AppColors.primary
        return label
    }()
    
    private let chartStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.alignment = .bottom
        return stack
    }()
    
    private let comparisonLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.secondary
        return label
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.cardBackground
        layer.cornerRadius = Layout.cornerRadius
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        addSubview(mainStack)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(completionLabel)
        mainStack.setCustomSpacing(16, after: completionLabel)
        mainStack.addArrangedSubview(chartStack)
        mainStack.setCustomSpacing(12, after: chartStack)
        mainStack.addArrangedSubview(comparisonLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            chartStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            chartStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Configuration
    func configure(weeklyRate: Int, lastWeekRate: Int, dailyRates: [Int]) {
        completionLabel.text = String(format: "percent_format".localized, weeklyRate)
        
        let diff = weeklyRate - lastWeekRate
        let sign = diff > 0 ? "+" : ""
        
        let attributedText = NSMutableAttributedString()
        
        let arrowAttachment = NSTextAttachment()
        if diff > 0 {
            arrowAttachment.image = UIImage(systemName: "arrow.up")?.withTintColor(AppColors.primary, renderingMode: .alwaysOriginal)
        } else if diff < 0 {
            arrowAttachment.image = UIImage(systemName: "arrow.down")?.withTintColor(AppColors.primary, renderingMode: .alwaysOriginal)
        } else {
            arrowAttachment.image = UIImage(systemName: "minus")?.withTintColor(AppColors.secondary, renderingMode: .alwaysOriginal)
        }
        
        arrowAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        attributedText.append(NSAttributedString(attachment: arrowAttachment))
        let diffText = String(format: "percent_format".localized, abs(diff))
        attributedText.append(NSAttributedString(string: " \(sign)\(diffText) \("from_last_week".localized)"))
        
        comparisonLabel.attributedText = attributedText
        
        drawChart(with: dailyRates)
    }
    
    private func drawChart(with rates: [Int]) {
        chartStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard rates.count > 0 else { return }
        
        let dayNames = [
            "day_mon".localized,
            "day_tue".localized,
            "day_wed".localized,
            "day_thu".localized,
            "day_fri".localized,
            "day_sat".localized,
            "day_sun".localized
        ]
    
        let currentWeekDays = DateHelper.shared.currentWeekDays()
        
        for (index, rate) in rates.enumerated() {
            let date = currentWeekDays[index]
            let weekday = Calendar.current.component(.weekday, from: date)
            let dayIndex = (weekday + 5) % 7
            
            let barColumn = createBarColumn(rate: rate, dayName: dayNames[dayIndex])
            chartStack.addArrangedSubview(barColumn)
        }
    }
    
    private func createBarColumn(rate: Int, dayName: String) -> UIView {
        let column = UIStackView()
        column.axis = .vertical
        column.spacing = 4
        column.alignment = .fill
        column.distribution = .fill
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let barView = UIView()
        barView.backgroundColor = AppColors.primary.withAlphaComponent(0.3 + (CGFloat(rate) / 100.0) * 0.7)
        barView.layer.cornerRadius = 4
        barView.translatesAutoresizingMaskIntoConstraints = false
        
        let barHeight = 40.0 * CGFloat(rate) / 100.0
        barView.heightAnchor.constraint(equalToConstant: max(barHeight, 4)).isActive = true
        
        let dayLabel = UILabel()
        dayLabel.text = dayName
        dayLabel.font = AppFonts.regular(11)
        dayLabel.textColor = AppColors.secondary
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        column.addArrangedSubview(spacer)
        column.addArrangedSubview(barView)
        column.addArrangedSubview(dayLabel)
        
        return column
    }
}
