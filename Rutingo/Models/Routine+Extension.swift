//
//  Routine+Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation

extension Routine {
    var frequency: Frequency {
        get {
            guard let data = frequencyData else { return .daily }
            return (try? JSONDecoder().decode(Frequency.self, from: data)) ?? .daily
        }
        set {
            frequencyData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var completionArray: [RoutineCompletion] {
        let set = completions as? Set<RoutineCompletion> ?? []
        return Array(set).sorted {
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
        }
    }
    
    var completionDates: [Date] {
        return completionArray.compactMap { $0.date }
    }
    
    func isScheduled(on date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch frequency {
        case .daily:
            return true
        case .specificDays(let days):
            return days.contains(weekday)
        }
    }
    
    func completionRate(in days: [Date]) -> Double {
        let scheduledDays = days.filter { isScheduled(on: $0) }
        guard !scheduledDays.isEmpty else { return 0 }
        
        let completedCount = scheduledDays.filter { date in
            completionArray.contains {
                guard let completionDate = $0.date else { return false }
                return Calendar.current.isDate(completionDate, inSameDayAs: date)
            }
        }.count
        
        return Double(completedCount) / Double(scheduledDays.count)
    }
    
    var isScheduledToday: Bool {
        return isScheduled(on: Date())
    }
    
    var isCompletedToday: Bool {
        let today = DateHelper.shared.startOfDay()
        return completionArray.contains {
            guard let date = $0.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }
    }
    
    var currentStreak: Int {
        var streak = 0
        let today = DateHelper.shared.startOfDay()
        
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else {
              return 0
        }
        
        var currentDate = yesterday
        
        while true {
            guard isScheduled(on: currentDate) else {
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
                continue
            }
            
            let completed = completionArray.contains {
                guard let date = $0.date else { return false }
                return Calendar.current.isDate(date, inSameDayAs: currentDate)
            }
            
            if completed {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                break
            }
        }
        if isCompletedToday {
            streak += 1
        }
        return streak
    }
}
