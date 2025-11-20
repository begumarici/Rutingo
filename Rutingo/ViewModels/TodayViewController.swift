//
//  TodayViewController.swift
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
    }
    
    func toggleRoutine(_ routine: Routine) {
        dataManager.toggleCompletion(routine)
        loadData()
    }
    
    func isCompleted(on date: Date) -> Bool {
        return todayRoutines.contains { routine in
            routine.completions.contains { completion in
                Calendar.current.isDate(completion, inSameDayAs: date)
            }
        }
    }
}
