//
//  TodayViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 20.11.2025.
//

import Foundation

class TodayViewModel {
    private var dataManager: DataManager
    var todayRoutines: [Routine] = []
    
    var greeting: String {
        return DateHelper.shared.greetingText()
    }
    
    var dateText: String {
        return DateHelper.shared.formattedDateShort()
    }
    
    var lastSevenDays: [Date] {
        return DateHelper.shared.lastSevenDays()
    }
    
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    func loadData() {
        todayRoutines = dataManager.fetchTodayRoutines()
        
        todayRoutines.sort { routine1, routine2 in
            if routine1.isCompletedToday == routine2.isCompletedToday {
                return false
            }
            return !routine1.isCompletedToday
        }
    }
    
    func toggleRoutine(_ routine: Routine) {
        dataManager.toggleCompletion(routine)
        loadData()
    }
    
    func isCompleted(on date: Date) -> Bool {
        return todayRoutines.contains { routine in
            routine.completionArray.contains { completion in
                guard let completionDate = completion.date else { return false }
                return Calendar.current.isDate(completionDate, inSameDayAs: date)
            }
        }
    }
    
    func getCompletionProgress() -> [Date: Double] {
        var progressMap: [Date: Double] = [:]
        let allRoutines = dataManager.fetchAllRoutines()
        
        for date in lastSevenDays {
            let normalizedDate = DateHelper.shared.startOfDay(date)
            let weekday = Calendar.current.component(.weekday, from: date)
            
            let scheduledRoutines = allRoutines.filter { routine in
                guard let createdAt = routine.createdAt else { return false }
                let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
                
                guard createdAtNormalized <= normalizedDate else {
                    return false
                }
                
                switch routine.frequency {
                case .daily:
                    return true
                case .specificDays(let days):
                    return days.contains(weekday)
                }
            }
            
            guard !scheduledRoutines.isEmpty else {
                progressMap[normalizedDate] = 0.0
                continue
            }
            
            let completedCount = scheduledRoutines.filter { routine in
                routine.completionArray.contains { completion in
                    guard let completionDate = completion.date else { return false }
                    return Calendar.current.isDate(completionDate, inSameDayAs: normalizedDate)
                }
            }.count
            
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
            let weekday = Calendar.current.component(.weekday, from: date)
            
            let scheduledRoutines = allRoutines.filter { routine in
                guard let createdAt = routine.createdAt else { return false }
                let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
                
                guard createdAtNormalized <= normalizedDate else {
                    return false
                }
                
                switch routine.frequency {
                case .daily:
                    return true
                case .specificDays(let days):
                    return days.contains(weekday)
                }
            }
            
            guard !scheduledRoutines.isEmpty else { continue }
            
            let allCompleted = scheduledRoutines.allSatisfy { routine in
                routine.completionArray.contains { completion in 
                    guard let completionDate = completion.date else { return false }
                    return Calendar.current.isDate(completionDate, inSameDayAs: normalizedDate)
                }
            }
            
            if allCompleted {
                completed.insert(normalizedDate)
            }
        }
        
        return completed
    }
}
