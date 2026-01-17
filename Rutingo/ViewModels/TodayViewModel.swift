//
//  TodayViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 20.11.2025.
//

import Foundation

class TodayViewModel {
    
    // MARK: - Properties
    private var dataManager: DataManager

    private var allRoutines: [Routine] = []
    var todayRoutines: [Routine] = []
    
    // MARK: - Computed Properties
    var greeting: String {
        return DateHelper.shared.greetingText()
    }
    
    var dateText: String {
        return DateHelper.shared.formattedDateShort()
    }
    
    var currentWeekDays: [Date] {
        return DateHelper.shared.currentWeekDays()
    }
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data Management
    func loadData(completion: () -> Void) {
        self.allRoutines = dataManager.fetchAllRoutines()
        self.todayRoutines = filterRoutinesForToday()
        self.sortRoutinesByCompletion()
        completion()
    }
    
    func toggleRoutine(_ routine: Routine, completion: () -> Void) {
        dataManager.toggleCompletion(routine)
        loadData(completion: completion)
    }
    
    // MARK: - Helper Methods
    private func filterRoutinesForToday() -> [Routine] {
        let today = DateHelper.shared.startOfDay()
        
        return allRoutines.filter { routine in
            guard let createdAt = routine.createdAt else { return false }
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            guard createdAtNormalized <= today else { return false }

            return routine.wasScheduled(on: today)
        }
    }
    
    private func sortRoutinesByCompletion() {
        todayRoutines.sort { routine1, routine2 in
            if routine1.isCompletedToday == routine2.isCompletedToday {
                return false
            }
            return !routine1.isCompletedToday
        }
    }
}
