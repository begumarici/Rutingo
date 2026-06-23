//
//  DateHelper.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation

class DateHelper {
    
    // MARK: - Singleton
    static let shared = DateHelper()

    private var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        cal.locale = .current
        return cal
    }()
    
    private init() {}
    
    // MARK: - Date Normalization
    func startOfDay(_ date: Date = Date()) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func isToday(_ date: Date = Date()) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    func weekday(_ date: Date = Date()) -> Int {
        return calendar.component(.weekday, from: date)
    }
    
    // MARK: - Date Formatting
    func dayOfWeekShort(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(3))
    }
    
    func dayOfMonth(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func formattedDateShort(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        if languageCode == "tr" {
            formatter.dateFormat = "d MMMM EEEE"
        } else {
            formatter.dateFormat = "EEEE, MMMM d"
        }
        
        return formatter.string(from: date)
    }
    
    func formattedDayName(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Date Calculations
    func lastSevenDays() -> [Date] {
        let today = startOfDay()
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }
    
    func lastWeekDays() -> [Date] {
        let today = startOfDay()
        
        guard let currentWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        let thisMonday = currentWeekInterval.start
        
        guard let lastMonday = calendar.date(byAdding: .day, value: -7, to: thisMonday) else { return [] }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: lastMonday)
        }
    }
    
    func currentWeekDays() -> [Date] {
        let today = startOfDay()
        
        guard let currentWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        let thisMonday = currentWeekInterval.start
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: thisMonday)
        }
    }
    
    func weekDays(for weekOffset: Int) -> [Date] {
        let today = startOfDay()
        guard let currentWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        let thisMonday = currentWeekInterval.start
        guard let targetMonday = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: thisMonday) else { return [] }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: targetMonday)
        }
    }
    
    func weekDays(for date: Date) -> [Date] {
        let day = startOfDay(date)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: day) else { return [] }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekInterval.start)
        }
    }
    
    func daysBetween(_ start: Date, _ end: Date) -> Int {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)
        let components = calendar.dateComponents([.day], from: startDay, to: endDay)
        return abs(components.day ?? 0)
    }
    
    // MARK: - Helpers
    static func getDayName(for dayNumber: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEE"
   
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        
        let refComponents = DateComponents(year: 2024, month: 1, day: 1)
        guard let refDate = calendar.date(from: refComponents),
              let targetDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: refDate) else {
            return ""
        }
        
        return formatter.string(from: targetDate)
    }
    
    static func getFullDayName(for index: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE"
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        
        let refComponents = DateComponents(year: 2024, month: 1, day: 1)
        guard let refDate = calendar.date(from: refComponents),
              let targetDate = calendar.date(byAdding: .day, value: index - 1, to: refDate) else {
            return ""
        }
        
        return formatter.string(from: targetDate)
    }
    
    func greetingText() -> String {
        let hour = calendar.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 6..<12:
            greeting = "greeting_morning".localized
        case 12..<17:
            greeting = "greeting_afternoon".localized
        case 17..<22:
            greeting = "greeting_evening".localized
        default:
            greeting = "greeting_night".localized
        }
        
        return "\(greeting)!"
    }
}
