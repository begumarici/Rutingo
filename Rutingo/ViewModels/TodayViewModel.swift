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
    var notCompletedRoutines: [Routine] = []
    var completedRoutines: [Routine] = []
    var isCompletedSectionExpanded: Bool = true
    var selectedDate: Date = DateHelper.shared.startOfDay()
    
    // MARK: - Computed Properties
    var greeting: String {
        return DateHelper.shared.greetingText()
    }
    
    var dateText: String {
        return DateHelper.shared.formattedDateShort(selectedDate)
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
        self.todayRoutines = filterRoutinesForSelectedDate()
        self.sortRoutinesByCompletion()
        self.separateRoutinesByCompletion()
        completion()
    }
    
    func setSelectedDate(_ date: Date, completion: () -> Void) {
        self.selectedDate = DateHelper.shared.startOfDay(date)
        loadData(completion: completion)
    }
    
    func toggleRoutine(_ routine: Routine, completion: () -> Void) {
        let today = DateHelper.shared.startOfDay()
        guard selectedDate == today else {
            completion()
            return
        }
        
        dataManager.toggleCompletion(routine)
        loadData(completion: completion)
    }
    
    // MARK: - Helper Methods
    private func filterRoutinesForSelectedDate() -> [Routine] {
        return getRoutinesScheduledFor(date: selectedDate)
    }
    
    private func sortRoutinesByCompletion() {
        todayRoutines.sort { routine1, routine2 in
            if routine1.isCompletedToday == routine2.isCompletedToday {
                return false
            }
            return !routine1.isCompletedToday
        }
    }
    
    private func separateRoutinesByCompletion() {
        let today = DateHelper.shared.startOfDay()
        
        // only show completed section on current day
        if selectedDate == today {
            notCompletedRoutines = todayRoutines.filter { !$0.isCompletedToday }
            completedRoutines = todayRoutines.filter { $0.isCompletedToday }
        } else {
            notCompletedRoutines = todayRoutines
            completedRoutines = []
        }
    }

// MARK: - Week Calendar Methods
    func getCurrentWeekDates() -> [Date] {
        return DateHelper.shared.currentWeekDays()
    }
    
    func getWeekProgressMap(for dates: [Date]) -> [Date: Double] {
        var progressMap: [Date: Double] = [:]
        
        for date in dates {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let routinesForDate = getRoutinesScheduledFor(date: normalizedDate)
            
            guard !routinesForDate.isEmpty else {
                progressMap[normalizedDate] = 0.0
                continue
            }
            
            let completedCount = routinesForDate.filter { routine in
                routine.isCompleted(on: normalizedDate)
            }.count
            
            let progress = Double(completedCount) / Double(routinesForDate.count)
            progressMap[normalizedDate] = progress
        }
        
        return progressMap
    }
    
    private func getRoutinesScheduledFor(date: Date) -> [Routine] {
        let normalizedDate = DateHelper.shared.startOfDay(date)
        
        return allRoutines.filter { routine in
            guard let createdAt = routine.createdAt else { return false }
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            guard createdAtNormalized <= normalizedDate else { return false }
            
            return routine.wasScheduled(on: normalizedDate)
        }
    }
    
    func toggleCompletedSection() {
        isCompletedSectionExpanded.toggle()
    }
}
