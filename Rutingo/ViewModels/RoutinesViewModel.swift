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
    
    func addRoutine(_ form: RoutineFormData, completion: () -> Void) {
        let newRoutine = dataManager.saveRoutine(
            name: form.name,
            frequency: form.frequency,
            feeling: form.feeling,
            motivation: form.motivation,
            blockType: form.blockType,
            hasReminder: form.hasReminder,
            reminderTime: form.reminderTime,
            startHour: form.startHour,
            startMinute: form.startMinute,
            endHour: form.endHour,
            endMinute: form.endMinute,
            isCountBased: form.isCountBased,
            targetValue: form.targetValue,
            unit: form.unit,
            dayTimeRanges: form.dayTimeRanges
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
    
    func updateRoutine(routine: Routine, form: RoutineFormData, completion: () -> Void) {
        dataManager.updateRoutine(
            routine: routine,
            name: form.name,
            frequency: form.frequency,
            feeling: form.feeling,
            motivation: form.motivation,
            blockType: form.blockType,
            hasReminder: form.hasReminder,
            reminderTime: form.reminderTime,
            startHour: form.startHour,
            startMinute: form.startMinute,
            endHour: form.endHour,
            endMinute: form.endMinute,
            isCountBased: form.isCountBased,
            targetValue: form.targetValue,
            unit: form.unit,
            dayTimeRanges: form.dayTimeRanges
        )
        NotificationManager.shared.scheduleNotification(for: routine)
        dataManager.syncGeneratedBlocks(for: routine)
        loadData(completion: completion)
    }

    // MARK: - Completion (binary routines)
    func toggleCompletion(_ routine: Routine, on date: Date = Date(), completion: () -> Void) {
        dataManager.toggleCompletion(routine, on: date)
        loadData(completion: completion)
    }

    // MARK: - Goal Progress
    func incrementGoal(_ routine: Routine, on date: Date = Date(), completion: () -> Void) {
        dataManager.incrementCompletionCount(routine, on: date)
        loadData(completion: completion)
    }

    func decrementGoal(_ routine: Routine, on date: Date = Date(), completion: () -> Void) {
        dataManager.decrementCompletionCount(routine, on: date)
        loadData(completion: completion)
    }

    func setGoalValue(_ routine: Routine, value: Double, on date: Date = Date(), completion: () -> Void) {
        dataManager.setCompletionValue(routine, value: value, on: date)
        loadData(completion: completion)
    }

    func resetGoal(_ routine: Routine, on date: Date = Date(), completion: () -> Void) {
        dataManager.resetCompletionCount(routine, on: date)
        loadData(completion: completion)
    }

    // MARK: - Lookup
    func routine(withID id: UUID) -> Routine? {
        if !allRoutines.isEmpty {
            return allRoutines.first { $0.id == id }
        }
        let routines = dataManager.fetchAllRoutines()
        return routines.first { $0.id == id }
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

