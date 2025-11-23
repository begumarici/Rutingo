//
//  DateHelper.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation

class DateHelper {
    static let shared = DateHelper()
    private init() {}
    
    func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func isToday(_ date: Date = Date()) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func weekday(_ date: Date = Date()) -> Int {
        Calendar.current.component(.weekday, from: date)
    }
    
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
    
    func lastSevenDays() -> [Date] {
        let today = startOfDay()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }
    
    func daysBetween(_ start: Date, _ end: Date) -> Int {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)
        let components = Calendar.current.dateComponents([.day], from: startDay, to: endDay)
        return abs(components.day ?? 0)
    }
    
    func greetingText(name: String = "Begüm") -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        
        switch hour {
        case 0..<12:
            timeOfDay = "Good Morning"
        case 12..<17:
            timeOfDay = "Good Afternoon"
        default:
            timeOfDay = "Good Evening"
        }
        
        return "\(timeOfDay), \(name)."
    }
    
    func formattedDateShort(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}
