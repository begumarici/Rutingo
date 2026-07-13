//
//  Routine+Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 17.11.2025.
//

import Foundation
import UIKit
import CoreData

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
        return completionArray.filter { isFullyCompleted($0) }.compactMap { $0.date }
    }

    /// Whether a completion record counts as "done", based on the tracking mode/target that were in effect
    /// on the day it was created — not the routine's current settings. Without this, switching a routine
    /// between binary and goal-based (or changing its target) would retroactively break past streaks.
    private func isFullyCompleted(_ completion: RoutineCompletion) -> Bool {
        guard completion.wasCountBased else { return true }
        return completion.currentValue >= max(completion.targetSnapshot, 0.01)
    }
    
    var isScheduledToday: Bool {
        return isScheduled(on: Date(), using: self.frequency)
    }
    
    var isCompletedToday: Bool {
        return isCompleted(on: DateHelper.shared.startOfDay())
    }

    /// Whether a checkmark tap, swipe, or long-press action would complete this routine right now.
    /// For goal-based routines this is also the *only* direction those quick actions ever go — once
    /// complete, there's deliberately no quick "undo" (only the routine detail screen's +/-, typed value,
    /// or reset), so a stray extra tap/swipe can't silently wipe out progress tracked manually there.
    var canQuickComplete: Bool {
        canQuickComplete(on: DateHelper.shared.startOfDay())
    }

    /// Same as `canQuickComplete`, but for an arbitrary day (e.g. logging a past day from Today or the routine calendar).
    func canQuickComplete(on date: Date) -> Bool {
        !isCompleted(on: date)
    }

    /// Today's progress value for a goal-based routine (e.g. 2 of 4 glasses of water, or 3.5 of 5 km). Always 0/1 for binary routines.
    var todayValue: Double {
        value(on: DateHelper.shared.startOfDay())
    }

    /// Progress value recorded for an arbitrary day (e.g. 2 of 4 glasses of water on a past date). Always 0/1 for binary routines.
    func value(on date: Date) -> Double {
        guard let completion = completionArray.first(where: {
            guard let d = $0.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: date)
        }) else { return 0 }
        return completion.currentValue
    }
    
    var routineUnit: RoutineUnit {
        get { unit.flatMap { RoutineUnit(rawValue: $0) } ?? .count }
        set { unit = newValue == .count ? nil : newValue.rawValue }
    }
    
    /// Formats a goal value for display: whole numbers show without a decimal ("2"), fractional values show one decimal ("3.5").
    static func formattedGoalValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
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
            let skipped = isSkipped(on: currentDate)
            
            if completed {
                streak += 1
                guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else if skipped {
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
        guard let createdAt = self.createdAt else { return 0 }

        let today = DateHelper.shared.startOfDay()
        let startDate = DateHelper.shared.startOfDay(createdAt)
        let totalDays = DateHelper.shared.daysBetween(startDate, today) + 1

        var best = 0
        var current = 0

        for i in 0..<totalDays {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) else { continue }

            let scheduled = wasScheduled(on: date)
            let completed = isCompleted(on: date)
            let skipped   = isSkipped(on: date)

            if !scheduled {
                continue
            } else if completed {
                current += 1
                best = max(best, current)
            } else if skipped {
                continue
            } else {
                current = 0
            }
        }

        return best
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
            return Calendar.current.isDate(completionDate, inSameDayAs: date) && isFullyCompleted(completion)
        }
    }
    
    func missedScheduledDay(between startDate: Date, and endDate: Date) -> Bool {
        var currentDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        while currentDate < endDate {
            if wasScheduled(on: currentDate) {
                if !isCompleted(on: currentDate) && !isSkipped(on: currentDate) {
                    return true
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return false
    }
    
    func isSkipped(on date: Date) -> Bool {
        guard let id = self.id else { return false }
        return CoreDataManager.shared.hasSkipLog(routineId: id, date: date)
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

// MARK: - Goal Unit
enum RoutineUnit: String, CaseIterable {
    case count
    case steps
    case meters
    case kilometers
    case seconds
    case minutes
    case kcal
    case kilograms

    var displayText: String {
        switch self {
        case .count:      return "unit_count".localized
        case .steps:      return "unit_steps".localized
        case .meters:     return "unit_meters".localized
        case .kilometers: return "unit_kilometers".localized
        case .seconds:    return "unit_seconds".localized
        case .minutes:    return "unit_minutes".localized
        case .kcal:       return "unit_kcal".localized
        case .kilograms:  return "unit_kilograms".localized
        }
    }

    /// Short suffix appended after the number (e.g. "3 km"). Count has none — it just reads "3".
    var shortSuffix: String {
        switch self {
        case .count:      return ""
        case .steps:      return " " + "unit_steps_short".localized
        case .meters:     return " m"
        case .kilometers: return " km"
        case .seconds:    return " " + "unit_seconds_short".localized
        case .minutes:    return " " + "unit_minutes_short".localized
        case .kcal:       return " kcal"
        case .kilograms:  return " kg"
        }
    }

    var isTimeBased: Bool {
        self == .seconds || self == .minutes
    }
}
