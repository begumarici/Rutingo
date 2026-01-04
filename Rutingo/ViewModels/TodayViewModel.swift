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
    private var statisticsService: StatisticsService
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
    init(dataManager: DataManager = CoreDataManager.shared, statisticsService: StatisticsService = StatisticsService()) {
        self.dataManager = dataManager
        self.statisticsService = statisticsService
    }
    
    // MARK: - Data Management
    func loadData(completion: () -> Void) {
        self.todayRoutines = self.dataManager.fetchTodayRoutines()
        self.sortRoutinesByCompletion()
        completion()
    }
    
    func toggleRoutine(_ routine: Routine, completion: () -> Void) {
        dataManager.toggleCompletion(routine)
        loadData(completion: completion)
    }
    
    // MARK: - Progress Calculation
    func getCompletionProgress() -> [Date: Double] {
        return statisticsService.getWeeklyCompletionProgress()
    }
    
    func getCompletedDays() -> Set<Date> {
        return statisticsService.getFullyCompletedDays()
    }
    
    // MARK: - Helper Methods
    private func sortRoutinesByCompletion() {
        todayRoutines.sort { routine1, routine2 in
            if routine1.isCompletedToday == routine2.isCompletedToday {
                return false
            }
            return !routine1.isCompletedToday
        }
    }
}
