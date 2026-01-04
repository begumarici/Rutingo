//
//  ProfileViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.12.2025.
//

import Foundation

class StatisticsViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    private let statisticsService: StatisticsService
    
    // MARK: - Computed Properties
    var lastSevenDays: [Date] {
        return DateHelper.shared.lastSevenDays()
    }
    
    var totalCompletions: Int {
        return statisticsService.getTotalCompletions()
    }
    
    var completionRate: Int {
        return statisticsService.getOverallCompletionRate()
    }
    
    var activeRoutines: Int {
        return statisticsService.getActiveRoutinesCount()
    }
    
    var bestDayOfWeek: String? {
        return statisticsService.getBestDayOfWeek()
    }
    
    var overallStreak: Int {
        return statisticsService.getOverallStreak()
    }
    
    var dailyCompletionRates: [Int] {
        return statisticsService.getDailyCompletionRates()
    }

    var weeklyCompletionRate: Int {
        return statisticsService.getWeeklyCompletionRate()
    }
    
    var lastWeekCompletionRate: Int {
        return statisticsService.getLastWeekCompletionRate()
    }
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared, statisticsService: StatisticsService = StatisticsService()) {
        self.dataManager = dataManager
        self.statisticsService = statisticsService
    }
    
    // MARK: - Data MAnagement
    func loadData(completion: () -> Void) {
        completion()
    }
    
    func getCompletionProgress() -> [Date: Double] {
        return statisticsService.getWeeklyCompletionProgress()
    }
}
