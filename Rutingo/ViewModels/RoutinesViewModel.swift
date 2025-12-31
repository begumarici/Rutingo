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
        return routine.completionRate
    }
}
