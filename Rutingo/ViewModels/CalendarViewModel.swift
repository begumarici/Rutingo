//
//  CalendarViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.01.2026.
//

import Foundation

// MARK: - Day Status (normal calendar + detail calendar)
enum DayStatus {
    case empty
    case future
    case notScheduled
    case completed
    case skipped
    case missed
    case pending
}

// MARK: - View State Item
struct CalendarDayItem {
    let date: Date?
    let text: String
    let isSelected: Bool
    let isToday: Bool
    let hasRoutine: Bool
    // additional space for detail calendar, .empty for normal calendar
    var dayStatus: DayStatus = .empty
}

struct RoutineWithStatus {
    let routine: Routine
    let isCompleted: Bool
    let isSkipped: Bool
}

class CalendarViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    private(set) var uiModels: [CalendarDayItem] = []
    
    private(set) var currentMonth: Date
    private(set) var selectedDate: Date
    
    /// if it is set, only filters for this routine (detail screen)
    var filteredRoutine: Routine?
    
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
        let allRoutines: [Routine]
        
        if let filtered = filteredRoutine {
            allRoutines = [filtered]
        } else {
            allRoutines = dataManager.fetchAllRoutines()
        }
        
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
                hasRoutine: false,
                dayStatus: .empty
            ))
        }
        
        let today = DateHelper.shared.startOfDay()
        
        for day in 1...numDays {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let normalized = DateHelper.shared.startOfDay(date)
            
            let status: DayStatus
            if let routine = filteredRoutine {
                status = dayStatus(for: normalized, routine: routine, today: today)
            } else {
                status = .empty
            }
            
            uiModels.append(CalendarDayItem(
                date: date,
                text: "\(day)",
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                isToday: calendar.isDateInToday(date),
                hasRoutine: checkRoutine(for: date, in: allRoutines),
                dayStatus: status
            ))
        }
    }
    
    // MARK: - Detail Mode
    private func dayStatus(for date: Date, routine: Routine, today: Date) -> DayStatus {
        guard let createdAt = routine.createdAt else { return .notScheduled }
        let created = DateHelper.shared.startOfDay(createdAt)
        
        guard created <= date else { return .notScheduled }
        
        let isFuture = date > today
        let scheduled = routine.wasScheduled(on: date)
        
        if !scheduled { return .notScheduled }
        
        if isFuture { return .future }
        
        if Calendar.current.isDate(date, inSameDayAs: today) {
            // today
            if routine.isCompleted(on: date) { return .completed }
            if routine.isSkipped(on: date)   { return .skipped }
            return .pending
        }
        
        // past day
        if routine.isCompleted(on: date) { return .completed }
        if routine.isSkipped(on: date)   { return .skipped }
        return .missed
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
    
    func getRoutinesForSelectedDate() -> [RoutineWithStatus] {
        let allRoutines: [Routine]
        if let filtered = filteredRoutine {
            allRoutines = [filtered]
        } else {
            allRoutines = dataManager.fetchAllRoutines()
        }
        
        let normalized = DateHelper.shared.startOfDay(selectedDate)
        
        return allRoutines
            .filter { routine in
                guard let created = routine.createdAt else { return false }
                let createdNorm = DateHelper.shared.startOfDay(created)
                guard createdNorm <= normalized else { return false }
                return routine.wasScheduled(on: normalized) || routine.isCompleted(on: normalized)
            }
            .map { routine in
                let isSkipped = routine.id.map {
                    dataManager.hasSkipLog(routineId: $0, date: normalized)
                } ?? false
                return RoutineWithStatus(
                    routine: routine,
                    isCompleted: routine.isCompleted(on: normalized),
                    isSkipped: isSkipped
                )
            }
    }
}
