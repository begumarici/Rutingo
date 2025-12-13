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
    var todayRoutines: [Routine] = []
    
    // MARK: - Computed Properties
    var greeting: String {
        return DateHelper.shared.greetingText()
    }
    
    var dateText: String {
        return DateHelper.shared.formattedDateShort()
    }
    
    var lastSevenDays: [Date] {
        return DateHelper.shared.lastSevenDays()
    }
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data Management
    func loadData() {
        todayRoutines = dataManager.fetchTodayRoutines()
        sortRoutinesByCompletion()
    }
    
    func toggleRoutine(_ routine: Routine) {
        dataManager.toggleCompletion(routine)
        loadData()
    }
    
    // MARK: - Progress Calculation
    func getCompletionProgress() -> [Date: Double] {
        var progressMap: [Date: Double] = [:]
        let allRoutines = dataManager.fetchAllRoutines()
        
        for date in lastSevenDays {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let scheduledRoutines = getScheduledRoutines(allRoutines, for: normalizedDate)
            
            guard !scheduledRoutines.isEmpty else {
                progressMap[normalizedDate] = 0.0
                continue
            }
            
            let completedCount = countCompletedRoutines(scheduledRoutines, on: normalizedDate)
            let progress = Double(completedCount) / Double(scheduledRoutines.count)
            progressMap[normalizedDate] = progress
        }
        
        return progressMap
    }
    
    func getCompletedDays() -> Set<Date> {
        var completed = Set<Date>()
        let allRoutines = dataManager.fetchAllRoutines()
        
        for date in lastSevenDays {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let scheduledRoutines = getScheduledRoutines(allRoutines, for: normalizedDate)
            
            guard !scheduledRoutines.isEmpty else { continue }
            
            let allCompleted = scheduledRoutines.allSatisfy { routine in
                isRoutineCompleted(routine, on: normalizedDate)
            }

            if allCompleted {
                completed.insert(normalizedDate)
            }
        }
        
        return completed
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
    
    private func getScheduledRoutines(_ routines: [Routine], for date: Date) -> [Routine] {
        let weekday = Calendar.current.component(.weekday, from: date)
        
        return routines.filter { routine in
            guard let createdAt = routine.createdAt else { return false}
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            
            guard createdAtNormalized <= date else {
                return false
            }
            
            switch routine.frequency {
            case .daily:
                return true
            case .specificDays(let days):
                return days.contains(weekday)
            }
        }
    }
    
    private func countCompletedRoutines(_ routines: [Routine], on date: Date) -> Int {
        return routines.filter { routine in
            isRoutineCompleted(routine, on: date)
        }.count
    }
    
    private func isRoutineCompleted(_ routine: Routine, on date: Date) -> Bool {
        return routine.completionArray.contains { completion in
            guard let completionDate = completion.date else { return false }
            return Calendar.current.isDate(completionDate, inSameDayAs: date)
        }
    }
    
    func isCompleted(on date: Date) -> Bool {
        return todayRoutines.contains { routine in
            isRoutineCompleted(routine, on: date)
        }
    }
}
