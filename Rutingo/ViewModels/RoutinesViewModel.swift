//
//  RoutinesViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 20.11.2025.
//

import Foundation

class RoutinesViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    var allRoutines: [Routine] = []
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data Management
    func loadData() {
        allRoutines = dataManager.fetchAllRoutines()
    }
    
    func addRoutine(name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?) {
        let newRoutine = dataManager.saveRoutine(name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: newRoutine)
        loadData()
    }
    
    func deleteRoutine(_ routine: Routine) {
        NotificationManager.shared.cancelNotification(for: routine)
        dataManager.deleteRoutine(routine)
        loadData()
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date? = nil) {
        dataManager.updateRoutine(routine: routine, name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: routine)
        loadData()
    }

    // MARK: - Statistics Calculation
    func getBestStreak(for routine: Routine) -> Int {
        var bestStreak = 0
        var currentStreak = 0
        
        let sortedDates = routine.completionDates.sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var previousDate: Date? = nil
        
        for date in sortedDates {
            if let prev = previousDate {
                let daysBetween = DateHelper.shared.daysBetween(prev, date)
                
                if daysBetween == 1 {
                    currentStreak += 1
                } else {
                    bestStreak = max(bestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            previousDate = date
        }
        
        bestStreak = max(bestStreak, currentStreak)
        return bestStreak
    }
    
    func getCompletionRate(for routine: Routine) -> Int {
        guard let createdAt = routine.createdAt else { return 0 }
        
        let today = DateHelper.shared.startOfDay()
        let startDate = DateHelper.shared.startOfDay(createdAt)
        
        let totalDays = DateHelper.shared.daysBetween(startDate, today) + 1
        
       let scheduledDays = countScheduledDays(for: routine, from: startDate, totalDays: totalDays)
        
        guard scheduledDays > 0 else { return 0 }
        
        let completedDays = routine.completionDates.count
        let rate = Double(completedDays) / Double(scheduledDays) * 100
        return Int(rate)
    }
    
    private func countScheduledDays(for routine: Routine, from startDate: Date, totalDays: Int) -> Int {
        var scheduledDays = 0
        for i in 0..<totalDays {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) else { continue }
            if routine.isScheduled(on: date) {
                scheduledDays += 1
            }
        }
        return scheduledDays
    }
}
