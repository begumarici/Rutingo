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
    private init() {}
    
    // MARK: - Date Normalization
    func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func isToday(_ date: Date = Date()) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func weekday(_ date: Date = Date()) -> Int {
        Calendar.current.component(.weekday, from: date)
    }
    
    // MARK: - Date Formatting
    func dayOfWeekShort(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(3))
    }
    
    func dayOfMonth(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func formattedDateShort(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Date Calculations
    func lastSevenDays() -> [Date] {
        let today = startOfDay()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }
    
    func lastWeekDays() -> [Date] {
        let today = startOfDay()
        return(8...14).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }
    
    func currentWeekDays() -> [Date] {
        let today = startOfDay()
        let currentWeekday = Calendar.current.component(.weekday, from: today)
        let daysToMonday = currentWeekday == 1 ? 6 : currentWeekday - 2
        
        guard let monday = Calendar.current.date(byAdding: .day, value: -daysToMonday, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: monday)}
    }
    
    func daysBetween(_ start: Date, _ end: Date) -> Int {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)
        let components = Calendar.current.dateComponents([.day], from: startDay, to: endDay)
        return abs(components.day ?? 0)
    }
    
    // MARK: - Helpers
    static func getDayName(for dayNumber: Int) -> String {
        let dayKeys = ["day_mon", "day_tue", "day_wed", "day_thu", "day_fri", "day_sat", "day_sun"]
        
        // convert: Sunday(1) -> 6, Monday(2) -> 0...
        let index = dayNumber == 1 ? 6 : dayNumber - 2
        return dayKeys[index].localized
    }
    
    static func getFullDayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[weekday - 1]
    }
    
    func greetingText(name: String = "Begüm") -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 0..<12:
            greeting = "greeting_morning".localized
        case 12..<17:
            greeting = "greeting_afternoon".localized
        case 17..<21:
            greeting = "greeting_evening".localized
        default:
            greeting = "greeting_night".localized
        }
        
        return "\(greeting), \(name)."
    }
}
