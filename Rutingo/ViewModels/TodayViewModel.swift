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
    var skippedRoutines: [Routine] = []
    var isSkippedSectionExpanded: Bool = true
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
        guard selectedDate <= today else {
            completion()
            return
        }
        
        if routine.isCountBased {
            guard routine.canQuickComplete(on: selectedDate) else {
                completion()
                return
            }
            dataManager.completeCompletionCount(routine, on: selectedDate)
        } else {
            dataManager.toggleCompletion(routine, on: selectedDate)
        }
        loadData(completion: completion)
    }
    
    // MARK: - Helper Methods
    private func filterRoutinesForSelectedDate() -> [Routine] {
        return getRoutinesScheduledFor(date: selectedDate)
    }
    
    private func sortRoutinesByCompletion() {
        todayRoutines.sort { routine1, routine2 in
            let completed1 = routine1.isCompleted(on: selectedDate)
            let completed2 = routine2.isCompleted(on: selectedDate)
            if completed1 == completed2 {
                return false
            }
            return !completed1
        }
    }
    
    private func separateRoutinesByCompletion() {
        notCompletedRoutines = todayRoutines.filter {
            !$0.isCompleted(on: selectedDate) && !dataManager.hasSkipLog(routineId: $0.id ?? UUID(), date: selectedDate)
        }
        completedRoutines = todayRoutines.filter { $0.isCompleted(on: selectedDate) }
        skippedRoutines = todayRoutines.filter {
            dataManager.hasSkipLog(routineId: $0.id ?? UUID(), date: selectedDate)
        }
    }
    
    func skipRoutine(_ routine: Routine, completion: () -> Void) {
        let today = DateHelper.shared.startOfDay()
        guard selectedDate <= today else {
            completion()
            return
        }
        
        if let id = routine.id {
            dataManager.saveSkipLog(routineId: id, date: selectedDate, reason: "skipped_from_today")
        }
        
        CoreDataManager.shared.deleteGeneratedBlockForDate(routineId: routine.id, date: selectedDate)
        loadData(completion: completion)
    }
    
    func unskipRoutine(_ routine: Routine, completion: () -> Void) {
        let today = DateHelper.shared.startOfDay()
        guard selectedDate <= today else {
            completion()
            return
        }
        
        if let id = routine.id {
            dataManager.deleteSkipLog(routineId: id, date: selectedDate)
        }
        
        CoreDataManager.shared.syncGeneratedBlocks(for: routine)
        loadData(completion: completion)
    }

// MARK: - Week Calendar Methods
    func getCurrentWeekDates() -> [Date] {
        return DateHelper.shared.weekDays(for: selectedDate)
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
    
    func goToNextDay(completion: () -> Void) {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else { return }
        setSelectedDate(next, completion: completion)
    }

    func goToPreviousDay(completion: () -> Void) {
        guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else { return }
        setSelectedDate(prev, completion: completion)
    }

    func goToNextWeek(completion: () -> Void) {
        guard let next = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) else { return }
        setSelectedDate(next, completion: completion)
    }

    func goToPreviousWeek(completion: () -> Void) {
        guard let prev = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) else { return }
        setSelectedDate(prev, completion: completion)
    }
    
    func toggleCompletedSection() {
        isCompletedSectionExpanded.toggle()
    }
}
