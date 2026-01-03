//
//  Routine+Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation

extension Routine {
    
    // MARK: - Computed Properties
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
            guard wasScheduled(on: currentDate) else {
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
    
    var bestStreak: Int {
        let sortedCompletions = completionArray.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
        
        guard !sortedCompletions.isEmpty else { return 0 }
        
        var bestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedCompletions.count {
            let prevDate = sortedCompletions[i-1].date!
            let currDate = sortedCompletions[i].date!
            
            if missedScheduledDay(between: prevDate, and: currDate) {
                currentStreak = 1
            } else {
                currentStreak += 1
            }
            
            bestStreak = max(bestStreak, currentStreak)
        }
        
        return bestStreak
    }
    
    var completionRate: Int {
        guard let createdAt = self.createdAt else { return 0 }
        
        let today = DateHelper.shared.startOfDay()
        let startDate = DateHelper.shared.startOfDay(createdAt)
        let totalDays = DateHelper.shared.daysBetween(startDate, today) + 1
        
        var scheduledDays = 0
        for i in 0..<totalDays {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) else { continue }
            if self.wasScheduled(on: date) {
                scheduledDays += 1
            }
        }
        
        guard scheduledDays > 0 else { return 0 }
        
        let completedDays = self.completionDates.count
        let rate = Double(completedDays) / Double(scheduledDays) * 100
        return Int(rate)
    }
    
    // MARK: - Methods
    func isScheduled(on date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch frequency {
        case .daily:
            return true
        case .specificDays(let days):
            return days.contains(weekday)
        }
    }
    
    func wasScheduled(on date: Date) -> Bool {
        if let completion = completionArray.first(where: {
            guard let completionDate = $0.date else { return false }
            return Calendar.current.isDate(completionDate, inSameDayAs: date)
        }) {
            let weekday = Calendar.current.component(.weekday, from: date)
            switch completion.frequency {
            case .daily:
                return true
            case .specificDays(let days):
                return days.contains(weekday)
            }
        }
        return isScheduled(on: date)
    }
    
    func isCompleted(on date: Date) -> Bool {
        return completionArray.contains { completion in
            guard let completionDate = completion.date else { return false }
            return Calendar.current.isDate(completionDate, inSameDayAs: date)
        }
    }
    
    func missedScheduledDay(between startDate: Date, and endDate: Date) -> Bool {
        var currentDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        while currentDate < endDate {
            if wasScheduled(on: currentDate) {
                let completed = completionArray.contains { completion in
                    guard let date = completion.date else { return false }
                    return Calendar.current.isDate(date, inSameDayAs: currentDate)
                }
                
                if !completed {
                    return true
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return false
    }
}
