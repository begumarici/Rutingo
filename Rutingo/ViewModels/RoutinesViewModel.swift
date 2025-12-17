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
    private(set) var allRoutines: [Routine] = []
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data Management
    func loadData(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.allRoutines = self.dataManager.fetchAllRoutines()
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
    func addRoutine(name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?, completion: @escaping () -> Void) {
        let newRoutine = dataManager.saveRoutine(name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: newRoutine)
        loadData {
            completion()
        }
    }
    
    func deleteRoutine(_ routine: Routine, completion: @escaping () -> Void) {
        NotificationManager.shared.cancelNotification(for: routine)
        dataManager.deleteRoutine(routine)
        loadData {
            completion()
        }
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date? = nil, completion: @escaping () -> Void) {
        dataManager.updateRoutine(routine: routine, name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: routine)
        loadData {
            completion()
        }
    }

    // MARK: - Statistics Calculation
    func getBestStreak(for routine: Routine) -> Int {
        return routine.bestStreak
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
            if routine.wasScheduled(on: date) {
                scheduledDays += 1
            }
        }
        return scheduledDays
    }
}
