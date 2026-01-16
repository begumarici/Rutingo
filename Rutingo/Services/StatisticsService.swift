//
//  StatisticsService.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.12.2025.
//

import Foundation

class StatisticsService {
    // MARK: - Properties
    private let dataManager: DataManager
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - OVerall Statistics
    func getTotalCompletions() -> Int {
        let allRoutines = dataManager.fetchAllRoutines()
        return allRoutines.reduce(0) { total, routine in
            return total + routine.completionDates.count
        }
    }
    
    func getOverallStreak() -> Int {
        let allRoutines = dataManager.fetchAllRoutines()
        guard !allRoutines.isEmpty else { return 0 }
        
        let oldestDate = allRoutines.compactMap { $0.createdAt }.min() ?? Date()
        let oldestDateNormalized = DateHelper.shared.startOfDay(oldestDate)
        
        var streak = 0
        var currentDate = DateHelper.shared.startOfDay()
        
        while currentDate >= oldestDateNormalized {
            if isDayFullyCompleted(allRoutines, on: currentDate) {
                streak += 1
            } else if hasScheduledRoutines(allRoutines, on: currentDate) {
                break
            }
            guard let yesterday = previousDay(from: currentDate) else { break }
            currentDate = yesterday
        }
        
        return streak
    }
    
    func getOverallCompletionRate() -> Int {
        let allRoutines = dataManager.fetchAllRoutines()
        guard !allRoutines.isEmpty else { return 0 }
        
        let rates = allRoutines.map { $0.completionRate }
        
        guard !rates.isEmpty else { return 0 }
        let totalRate = rates.reduce(0, +)
        return totalRate / rates.count
    }
    
    func getActiveRoutinesCount() -> Int {
        return dataManager.fetchAllRoutines().count
    }
    
    // MARK: - Progress Tracking
    func getWeeklyCompletionProgress() -> [Date: Double] {
        var progressMap: [Date: Double] = [:]
        let allRoutines = dataManager.fetchAllRoutines()
        let currentWeekDays = DateHelper.shared.currentWeekDays()
        
        for date in currentWeekDays {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let progress = calculateDayProgress(allRoutines, on: normalizedDate)
            progressMap[normalizedDate] = progress
        }
        
        return progressMap
    }
    
    func getFullyCompletedDays() -> Set<Date> {
         var completed = Set<Date>()
         let allRoutines = dataManager.fetchAllRoutines()
         let currentWeekDays = DateHelper.shared.currentWeekDays()
         
         for date in currentWeekDays {
             let normalizedDate = DateHelper.shared.startOfDay(date)
             if isDayFullyCompleted(allRoutines, on: normalizedDate) {
                 completed.insert(normalizedDate)
             }
         }
         
         return completed
     }
    
    // MARK: - Weekly Insights
    func getBestDayOfWeek() -> String? {
        let allRoutines = dataManager.fetchAllRoutines()
        let currentWeekDays = DateHelper.shared.currentWeekDays()
        
        let completions = countWeekdayCompletions(allRoutines, currentWeekDays)
        let scheduled = countWeekdayScheduled(allRoutines, currentWeekDays)
        
        var stats: [Int: (completed: Int, scheduled: Int)] = [:]
        for day in 1...7 {
            stats[day] = (completions[day] ?? 0, scheduled[day] ?? 0)
        }
        
        let bestDay = findBestWeekday(from: stats)
        
        guard let day = bestDay else { return nil }
        return DateHelper.getFullDayName(for: day)
    }
    
    // MARK: - Trend Data
    func getDailyCompletionRates() -> [Int] {
        let allRoutines = dataManager.fetchAllRoutines()
        let currentWeekDays = DateHelper.shared.currentWeekDays()
        var rates: [Int] = []
        
        for date in currentWeekDays {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let scheduledRoutines = getScheduledRoutines(allRoutines, for: normalizedDate)
            
            guard !scheduledRoutines.isEmpty else {
                rates.append(0)
                continue
            }
            
            let completedCount = countCompletedRoutines(scheduledRoutines, on: normalizedDate)
            let rate = Int((Double(completedCount) / Double(scheduledRoutines.count)) * 100)
            rates.append(rate)
        }
        
        return rates
    }

    func getWeeklyCompletionRate() -> Int {
        let dates = DateHelper.shared.currentWeekDays()
        let validDates = dates.filter { $0 <= Date() }
        return calculateCompletionRateForDates(validDates)
    }
    
    func getLastWeekCompletionRate() -> Int {
        let dates = DateHelper.shared.lastWeekDays()
        return calculateCompletionRateForDates(dates)
    }
    
    // MARK: - Helpers
    private func getScheduledRoutines(_ routines: [Routine], for date: Date) -> [Routine] {
        let weekday = Calendar.current.component(.weekday, from: date)
        
        return routines.filter { routine in
            guard let createdAt = routine.createdAt else { return false }
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            
            // routine must be created before or on this date
            guard createdAtNormalized <= date else {
                return false
            }
            
            // check if routine is scheduled for this weekday
            switch routine.frequency {
            case .daily:
                return true
            case .specificDays(let days):
                return days.contains(weekday)
            }
        }
    }
    
    private func countCompletedRoutines(_ routines: [Routine], on date: Date) -> Int {
        return routines.filter { $0.isCompleted(on: date) }.count
    }
    
    private func isDayFullyCompleted(_ routines: [Routine], on date: Date) -> Bool {
        let scheduled = getScheduledRoutines(routines, for: date)
        guard !scheduled.isEmpty else { return false }
        
        return scheduled.allSatisfy { $0.isCompleted(on: date) }
    }
    
    private func hasScheduledRoutines(_ routines: [Routine], on date: Date) -> Bool {
        return !getScheduledRoutines(routines, for: date).isEmpty
    }
    
    private func previousDay(from date: Date) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: date)
    }
    
    private func calculateDayProgress(_ routines: [Routine], on date: Date) -> Double {
        let scheduledRoutines = getScheduledRoutines(routines, for: date)
        
        guard !scheduledRoutines.isEmpty else { return 0.0 }
        
        let completedCount = countCompletedRoutines(scheduledRoutines, on: date)
        return Double(completedCount) / Double(scheduledRoutines.count)
    }
    
    private func countWeekdayCompletions(_ routines: [Routine], _ dates: [Date]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        
        for routine in routines {
            for completion in routine.completionArray {
                guard let date = completion.date else { continue }
                guard dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date)}) else {
                    continue
                }
                
                let weekday = Calendar.current.component(.weekday, from: date)
                counts[weekday, default: 0] += 1
            }
        }
        
        return counts
    }
    
    private func countWeekdayScheduled(_ routines: [Routine], _ dates: [Date]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        
        for date in dates {
            let weekday = Calendar.current.component(.weekday, from: date)
            let scheduledCount = getScheduledRoutines(routines, for: date).count
            counts[weekday, default: 0] += scheduledCount
        }
        
        return counts
    }
    
    private func findBestWeekday(from stats: [Int: (completed: Int, scheduled: Int)]) -> Int? {
        var bestDay: Int?
        var bestRate: Double = 0
        
        for day in 1...7 {
            guard let stat = stats[day], stat.scheduled > 0 else { continue }
            
            let rate = Double(stat.completed) / Double(stat.scheduled)
            
            if rate > bestRate {
                bestRate = rate
                bestDay = day
            }
        }
        
        return bestDay
    }
    
    private func calculateCompletionRateForDates(_ dates: [Date]) -> Int {
        let allRoutines = dataManager.fetchAllRoutines()
        var totalScheduled = 0
        var totalCompleted = 0
        
        for date in dates {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let scheduledRoutines = getScheduledRoutines(allRoutines, for: normalizedDate)
            
            totalScheduled += scheduledRoutines.count
            totalCompleted += countCompletedRoutines(scheduledRoutines, on: normalizedDate)
        }
        
        guard totalScheduled > 0 else { return 0 }
        return Int((Double(totalCompleted) / Double(totalScheduled)) * 100)
    }
}

