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
    
    func addRoutine(
        name: String,
        frequency: Frequency,
        feeling: String?,
        motivation: String?,
        blockType: String?,
        hasReminder: Bool,
        reminderTime: Date?,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        completion: () -> Void
    ) {
        let newRoutine = dataManager.saveRoutine(
            name: name,
            frequency: frequency,
            feeling: feeling,
            motivation: motivation,
            blockType: blockType,
            hasReminder: hasReminder,
            reminderTime: reminderTime,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        NotificationManager.shared.scheduleNotification(for: newRoutine)
        dataManager.syncGeneratedBlocks(for: newRoutine)
        loadData {
            completion()
        }
    }
    
    func deleteRoutine(_ routine: Routine, completion: () -> Void) {
        NotificationManager.shared.cancelNotification(for: routine)
        dataManager.deleteGeneratedBlocksFromNow(for: routine)
        dataManager.deleteRoutine(routine)
        loadData(completion: completion)
    }
    
    func updateRoutine(
        routine: Routine,
        name: String,
        frequency: Frequency,
        feeling: String?,
        motivation: String?,
        blockType: String?,
        hasReminder: Bool,
        reminderTime: Date? = nil,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        completion: () -> Void
    ) {
        dataManager.updateRoutine(
            routine: routine,
            name: name,
            frequency: frequency,
            feeling: feeling,
            motivation: motivation,
            blockType: blockType,
            hasReminder: hasReminder,
            reminderTime: reminderTime,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        NotificationManager.shared.scheduleNotification(for: routine)
        dataManager.syncGeneratedBlocks(for: routine)
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
