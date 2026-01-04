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
    private let statisticsService: StatisticsService
    private(set) var allRoutines: [Routine] = []
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared, statisticsService: StatisticsService = StatisticsService()) {
        self.dataManager = dataManager
        self.statisticsService = statisticsService
    }
    
    // MARK: - Data Management
    func loadData(completion: () -> Void) {
        allRoutines = self.dataManager.fetchAllRoutines()
        completion()
    }
    
    func addRoutine(name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?, completion: () -> Void) {
        let newRoutine = dataManager.saveRoutine(name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
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
        dataManager.updateRoutine(routine: routine, name: name, frequency: frequency, hasReminder: hasReminder, reminderTime: reminderTime)
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
}
