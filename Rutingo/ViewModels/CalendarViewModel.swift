//
//  CalendarViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.01.2026.
//

import Foundation

// MARK: - View State Item
struct CalendarDayItem {
    let date: Date?
    let text: String
    let isSelected: Bool
    let isToday: Bool
    let hasRoutine: Bool
}

class CalendarViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    private(set) var uiModels: [CalendarDayItem] = []
    
    private(set) var currentMonth: Date
    private(set) var selectedDate: Date
    
    // MARK: - Init
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
        self.currentMonth = Date()
        self.selectedDate = Date()
    }
    
    // MARK: - Public Methods
    func loadData(completion: () -> Void) {
        generateGrid()
        completion()
    }
    
    func selectDate(at index: Int, completion: () -> Void) {
        guard index < uiModels.count, let date = uiModels[index].date else { return }
        
        self.selectedDate = date
        generateGrid()
        completion()
    }
    
    func changeMonth(by value: Int, completion: () -> Void) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newDate
    
        if Calendar.current.isDate(newDate, equalTo: Date(), toGranularity: .month) {
            selectedDate = Date()
        } else {
            let components = Calendar.current.dateComponents([.year, .month], from: newDate)
            if let startOfMonth = Calendar.current.date(from: components) {
                selectedDate = startOfMonth
            }
        }
        
        generateGrid()
        completion()
    }
    
    // MARK: - The Core Logic
    private func generateGrid() {
        uiModels.removeAll()
        
        let calendar = Calendar.current
        let allRoutines = dataManager.fetchAllRoutines()
        
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return }
        
        let numDays = range.count
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let emptyDays = (firstWeekday + 5) % 7
        
        for _ in 0..<emptyDays {
            uiModels.append(CalendarDayItem(
                date: nil,
                text: "",
                isSelected: false,
                isToday: false,
                hasRoutine: false
            ))
        }
        
        for day in 1...numDays {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            
            let isToday = calendar.isDateInToday(date)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let hasRoutine = checkRoutine(for: date, in: allRoutines)
            
            uiModels.append(CalendarDayItem(
                date: date,
                text: "\(day)",
                isSelected: isSelected,
                isToday: isToday,
                hasRoutine: hasRoutine
            ))
        }
    }
    
    private func checkRoutine(for date: Date, in routines: [Routine]) -> Bool {
        let normalized = DateHelper.shared.startOfDay(date)
        return routines.contains { routine in
            guard let created = routine.createdAt else { return false }
            let createdNorm = DateHelper.shared.startOfDay(created)
            
            guard createdNorm <= normalized else { return false }
            
            return routine.wasScheduled(on: normalized)
        }
    }
    
    // MARK: - Helpers
    func getMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .current
        return formatter.string(from: currentMonth).capitalized
    }
    
    func getRoutinesForSelectedDate() -> [Routine] {
        return getRoutinesForDate(selectedDate)
    }
    
    private func getRoutinesForDate(_ date: Date) -> [Routine] {
        let allRoutines = dataManager.fetchAllRoutines()
        let normalized = DateHelper.shared.startOfDay(date)
        
        return allRoutines.filter { routine in
            guard let created = routine.createdAt else { return false }
            let createdNorm = DateHelper.shared.startOfDay(created)
            guard createdNorm <= normalized else { return false }
            
            return routine.wasScheduled(on: normalized) || routine.isCompleted(on: normalized)
        }
    }
}
