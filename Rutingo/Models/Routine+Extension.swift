//
//  Routine+Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation
import UIKit

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
        return isScheduled(on: Date(), using: self.frequency)
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
              return isCompletedToday ? 1 : 0
        }
        
        var currentDate = yesterday
        
        while true {
            let scheduled = wasScheduled(on: currentDate)
            let completed = isCompleted(on: currentDate)
            
            if completed {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
                
            } else if scheduled {
                break
            } else {
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
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
    
    // MARK: - Helper Methods
    
    /// checks if a routine was scheduled for a specific date.
    /// handles historical freq changes by checking the last change date and snapshots.
    func wasScheduled(on date: Date) -> Bool {
        let targetDate = DateHelper.shared.startOfDay(date)
        
        // 1. if there is a completion, then the snapshot for that day is definitive.
        if let completion = completionArray.first(where: {
            guard let d = $0.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: targetDate)
        }) {
            return isScheduled(on: targetDate, using: completion.frequency)
        }
        
        // 2. frequency change check
        // if the date is after the last frequency change, apply the current settings.
        if let changeDate = self.lastFrequencyChangeDate, targetDate >= changeDate {
            return isScheduled(on: targetDate, using: self.frequency)
        }
        
        // 3. historical check
        // If before the change, attempt to find the nearest previous snapshot to determine the rule.
        let previousCompletion = completionArray.first { completion in
            guard let completionDate = completion.date else { return false }
            return completionDate < targetDate
        }
        
        if let snapshotFrequency = previousCompletion?.frequency {
            // apply whatever the old rule was.
            // if the old rule was "daily" and you didn't do it, this returns TRUE.
            // since wasScheduled = True, and isCompleted = False, streak BREAKS
            return isScheduled(on: targetDate, using: snapshotFrequency)
        }
        
        // default if no records exist
        return isScheduled(on: targetDate, using: self.frequency)
    }

    private func isScheduled(on date: Date, using frequency: Frequency) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch frequency {
        case .daily:
            return true
        case .specificDays(let days):
            return days.contains(weekday)
        }
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
                if !isCompleted(on: currentDate) {
                    return true
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return false
    }
    
    // MARK: - Feeling
    enum FeelingType: String {
        case energy = "energy"
        case hard   = "hard"
        case boring = "boring"
        case deep   = "deep"

        var displayText: String {
            switch self {
            case .energy: return "feeling_energy".localized
            case .hard:   return "feeling_hard".localized
            case .boring: return "feeling_boring".localized
            case .deep:   return "feeling_deep".localized
            }
        }

        var color: UIColor {
            switch self {
            case .energy: return AppColors.feelingEnergy
            case .hard:   return AppColors.feelingHard
            case .boring: return AppColors.feelingBoring
            case .deep:   return AppColors.feelingDeep
            }
        }

        static var allCases: [FeelingType] {
            return [.energy, .hard, .boring, .deep]
        }
    }

    // MARK: - Block Type
    enum BlockType: String {
        case morning = "morning"
        case noon    = "noon"
        case evening = "evening"
        case custom  = "custom"
    }
    
    var feelingType: FeelingType? {
        guard let f = feeling else { return nil }
        return FeelingType(rawValue: f)
    }

    var feelingColor: UIColor {
        return feelingType?.color ?? AppColors.tertiary
    }

    var blockTypeEnum: BlockType? {
        guard let b = blockType else { return nil }
        return BlockType(rawValue: b)
    }
}
