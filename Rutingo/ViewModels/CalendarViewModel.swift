//
//  CalendarViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 16.01.2026.
//

import Foundation

class CalendarViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    private let statisticsService: StatisticsService
    
    private var allRoutines: [Routine] = []
    
    private(set) var selectedDate: Date = Date()
    private(set) var currentMonth: Date = Date()
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared,
         statisticsService: StatisticsService = StatisticsService()) {
        self.dataManager = dataManager
        self.statisticsService = statisticsService
    }
    
    // MARK: - Data Management
    func loadData(completion: () -> Void) {
        self.allRoutines = dataManager.fetchAllRoutines()
        completion()
    }
    
    // MARK: - Date Navigation
    func moveToNextMonth() {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = nextMonth
    }
    
    func moveToPreviousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    func selectDate(_ date: Date) {
        selectedDate = DateHelper.shared.startOfDay(date)
    }
    
    // MARK: - Calendar Data
    func getMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .current
        return formatter.string(from: currentMonth)
    }
    
    func getDaysInMonth() -> [Date?] {
        var days: [Date?] = []

        let components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        guard let firstDayOfMonth = Calendar.current.date(from: components) else { return [] }
        
        guard let range = Calendar.current.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }
        
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth)
        
        let emptyDays = (firstWeekday + 5) % 7
        
        for _ in 0..<emptyDays {
            days.append(nil)
        }
        
        for day in range {
            var dayComponents = components
            dayComponents.day = day
            if let date = Calendar.current.date(from: dayComponents) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func getRoutinesForSelectedDate() -> [Routine] {
        let normalizeDate = DateHelper.shared.startOfDay(selectedDate)
        
        return allRoutines.filter { routine in
            guard let createdAt = routine.createdAt else { return false }
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            guard createdAtNormalized <= normalizeDate else { return false }
            return routine.wasScheduled(on: normalizeDate)
        }
    }
    
    func getRoutinesForDate(_ date: Date) -> [Routine] {
        let normalizedDate = DateHelper.shared.startOfDay(date)
        
        return allRoutines.filter { routine in
            guard let createdAt = routine.createdAt else { return false }
            let createdAtNormalized = DateHelper.shared.startOfDay(createdAt)
            
            guard createdAtNormalized <= normalizedDate else { return false }
            
            return routine.wasScheduled(on: normalizedDate)
        }
    }
    
    // MARK: - Helpers
    func isDateInFuture(_ date: Date) -> Bool {
        let normalizeDate = DateHelper.shared.startOfDay(date)
        let today = DateHelper.shared.startOfDay()
        return normalizeDate > today
    }
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
}
