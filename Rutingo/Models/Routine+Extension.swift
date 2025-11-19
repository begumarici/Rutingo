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
    
    var completions: [Date] {
        get {
            return (completionDates as? [Date]) ?? []
        }
        set {
            completionDates = newValue as NSArray
        }
    }
    
    var isScheduledToday: Bool {
        let today = Calendar.current.component(.weekday, from: Date())
        
        switch frequency {
        case .daily:
            return true
        case .specificDays(let days):
            return days.contains(today)
        }
    }
    
    var isCompletedToday: Bool {
        let today = DateHelper.shared.startOfDay()
        return completions.contains { completion in
            Calendar.current.isDate(completion, inSameDayAs: today)
        }
    }
    
    var currentStreak: Int {
        let sortedCompletions = completions
            .map { DateHelper.shared.startOfDay($0) }
            .sorted(by: >)
        
        guard !sortedCompletions.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = DateHelper.shared.startOfDay()
        
        if !isCompletedToday {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                return 0
            }
            currentDate = yesterday
        }
        
        for completion in sortedCompletions {
            if Calendar.current.isDate(completion, inSameDayAs: currentDate) {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                break
            }
        }
        return streak
    }
    
    func toggleCompletion() {
        if isCompletedToday {
            removeCompletion()
        } else {
            addCompletion()
        }
    }
    
    func addCompletion() {
        let today = DateHelper.shared.startOfDay()
        if !isCompletedToday {
            var updated = completions
            updated.append(today)
            completions = updated
        }
    }
    
    func removeCompletion() {
        let today = DateHelper.shared.startOfDay()
        completions = completions.filter { completion in
            !Calendar.current.isDate(completion, inSameDayAs: today)
        }
    }
}
