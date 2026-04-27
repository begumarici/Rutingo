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
    func loadData(completion: () -> Void) {
        allRoutines = self.dataManager.fetchAllRoutines()
        completion()
    }
    
    func addRoutine(name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?, completion: () -> Void) {
        let newRoutine = dataManager.saveRoutine(name: name, frequency: frequency, feeling: nil, motivation: nil, blockType: nil, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: newRoutine)
        loadData {
            completion()
        }
    }
    
    func deleteRoutine(_ routine: Routine, completion: () -> Void) {
        NotificationManager.shared.cancelNotification(for: routine)
        dataManager.deleteRoutine(routine)
        loadData(completion: completion)
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date? = nil, completion: () -> Void) {
        dataManager.updateRoutine(routine: routine, name: name, frequency: frequency, feeling: nil, motivation: nil, blockType: nil, hasReminder: hasReminder, reminderTime: reminderTime)
        NotificationManager.shared.scheduleNotification(for: routine)
        loadData(completion: completion)
    }

    // MARK: - Statistics Calculation
    func getBestStreak(for routine: Routine) -> Int {
        return routine.bestStreak
    }
    
    func getCompletionRate(for routine: Routine) -> Int {
        return routine.completionRate
    }
    
    func getWeeklyProgress(for routine: Routine) -> [Date: Double] {
        let dates = DateHelper.shared.currentWeekDays()
        var progressMap: [Date: Double] = [:]
        
        for date in dates {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let isCompleted = routine.isCompleted(on: normalizedDate)
            progressMap[normalizedDate] = isCompleted ? 1.0 : 0.0
        }
        
        return progressMap
    }
}
